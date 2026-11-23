extends Node

signal save_started(slot: int)
signal save_finished(slot: int, success: bool, recovered: bool)

const SAVE_PATH := "user://light_in_the_dark_save.json"
const SAVE_VERSION := "0.31"
const SLOT_COUNT := 3
const AUTOSAVE_SLOT := -1
const QA_SNAPSHOT_PATH := "user://litd_qa_snapshot.json"

var active_slot := 0
var last_status := ""
var last_operation := ""
var session_started_ms := 0

# Opaque snapshot: the storage service no longer depends on retired game systems.
var _snapshot: Dictionary = {}

func set_snapshot(payload: Dictionary) -> void:
    _snapshot = payload.duplicate(true)

func get_snapshot() -> Dictionary:
    return _snapshot.duplicate(true)

func _ready() -> void:
    session_started_ms = Time.get_ticks_msec()

func save_game(slot: int = active_slot) -> bool:
    last_operation = "save"
    slot = _valid_slot(slot)
    save_started.emit(slot)
    last_status = "Sauvegarde en cours…"
    var payload := _build_payload()
    var body := JSON.stringify(payload)
    var envelope := {"checksum":body.sha256_text(),"body":body}
    var encoded := JSON.stringify(envelope)
    var success := _atomic_write(_path(slot), encoded)
    # The per-slot envelope is authoritative. A legacy mirror is best-effort only.
    if success and slot == 0:
        _atomic_write(SAVE_PATH, body)
    if success:
        active_slot = slot if slot >= 0 else active_slot
        last_status = "Sauvegarde terminée."

    else:
        last_status = "Échec de la sauvegarde."
    save_finished.emit(slot, success, false)
    return success

func save_qa_snapshot() -> bool:
    last_operation = "qa_save"
    var payload := _build_payload()
    payload["qa_snapshot"] = true
    var body := JSON.stringify(payload)
    var envelope := {"checksum": body.sha256_text(), "body": body}
    return _atomic_write(QA_SNAPSHOT_PATH, JSON.stringify(envelope))

func load_qa_snapshot() -> bool:
    last_operation = "qa_load"
    var payload := _read_payload(QA_SNAPSHOT_PATH)
    if payload.is_empty() or not bool(payload.get("qa_snapshot", false)):
        return false
    payload = _migrate(payload)
    if payload.is_empty():
        return false
    _apply_payload(payload)
    return true

func delete_qa_snapshot() -> bool:
    var removed := false
    for path: String in [QA_SNAPSHOT_PATH, _backup_for(QA_SNAPSHOT_PATH), _temp_for(QA_SNAPSHOT_PATH)]:
        if FileAccess.file_exists(path):
            removed = DirAccess.remove_absolute(ProjectSettings.globalize_path(path)) == OK or removed
    return removed

func autosave(reason: String = "") -> bool:
    var success := save_game(AUTOSAVE_SLOT)
    if success and reason != "":
        last_status = "Autosauvegarde : %s" % reason
    return success

func load_game(slot: int = active_slot) -> bool:
    last_operation = "load"
    slot = _valid_slot(slot)
    var recovered := false
    var payload: Dictionary = {}
    var candidates: Array[String] = [_path(slot), _backup_path(slot)]
    if slot == 0:
        candidates.append(SAVE_PATH)
    # An incompatible primary must not prevent recovery from a valid backup.
    for candidate: String in candidates:
        var candidate_payload: Dictionary = _migrate(_read_payload(candidate))
        if candidate_payload.is_empty():
            continue
        payload = candidate_payload
        recovered = candidate != _path(slot)
        break
    if payload.is_empty():
        last_status = "Sauvegarde absente ou irrécupérable."
        save_finished.emit(slot, false, false)
        return false
    _apply_payload(payload)
    active_slot = slot if slot >= 0 else active_slot
    last_status = "Sauvegarde de secours restaurée." if recovered else "Sauvegarde chargée."

    save_finished.emit(slot, true, recovered)
    return true

func slot_metadata(slot: int) -> Dictionary:
    var payload := _read_payload(_path(_valid_slot(slot)))
    if payload.is_empty():
        payload = _read_payload(_backup_path(_valid_slot(slot)))
    return payload.get("metadata",{}).duplicate(true)

func all_slots_metadata() -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    for slot in range(SLOT_COUNT):
        var metadata := slot_metadata(slot)
        var empty := metadata.is_empty()
        metadata["slot"] = slot
        metadata["empty"] = empty
        result.append(metadata)
    var autosave_metadata := slot_metadata(AUTOSAVE_SLOT)
    var autosave_empty := autosave_metadata.is_empty()
    autosave_metadata["slot"] = AUTOSAVE_SLOT
    autosave_metadata["autosave"] = true
    autosave_metadata["empty"] = autosave_empty
    result.append(autosave_metadata)
    return result

func delete_slot(slot: int) -> bool:
    slot = _valid_slot(slot)
    var removed := false
    var paths := [_path(slot), _backup_path(slot), _temp_path(slot)]
    if slot == 0:
        # A deleted slot must not be resurrected from the legacy mirror.
        paths.append_array([SAVE_PATH, _backup_for(SAVE_PATH), _temp_for(SAVE_PATH)])
    for path in paths:
        if FileAccess.file_exists(path):
            removed = DirAccess.remove_absolute(ProjectSettings.globalize_path(path)) == OK or removed
    return removed

func _build_payload() -> Dictionary:
    var payload := _snapshot.duplicate(true)
    payload["version"] = SAVE_VERSION
    var metadata: Dictionary = payload.get("metadata", {}).duplicate(true)
    metadata["timestamp"] = Time.get_datetime_string_from_system()
    metadata["play_seconds"] = int((Time.get_ticks_msec() - session_started_ms) / 1000)
    payload["metadata"] = metadata
    return payload

func _apply_payload(payload: Dictionary) -> void:
    _snapshot = payload.duplicate(true)

func _migrate(payload: Dictionary) -> Dictionary:
    var version := String(payload.get("version", ""))
    if version != SAVE_VERSION:
        return {}
    payload["campaign_memory"] = payload.get("campaign_memory",{})
    payload["remanence"] = payload.get("remanence",{})
    var veilleurs_payload: Dictionary = payload.get("veilleurs",{})
    if veilleurs_payload.is_empty():
        var old_vs001: Dictionary = payload.get("veilleurs_vs001",{})
        if not old_vs001.is_empty():
            veilleurs_payload = {
                "schema_version": 1,
                "runtime_version": "legacy_vs001",
                "compatibility_mode": "legacy_vs001",
                "legacy_vs001": old_vs001.duplicate(true)
            }
    payload["veilleurs"] = veilleurs_payload
    payload.erase("veilleurs_vs001")
    payload["expedition_reports"] = payload.get("expedition_reports",{})
    payload["preparation_presets"] = payload.get("preparation_presets",{})
    payload["living_exploration"] = payload.get("living_exploration",{})
    payload["progression_scope"] = payload.get("progression_scope",{})
    payload["main_narrative_script"] = payload.get("main_narrative_script",{})
    payload["base_game_enrichment"] = payload.get("base_game_enrichment",{})
    payload["systemic_cross"] = payload.get("systemic_cross",{})
    payload["systemic_cross_narrative"] = payload.get("systemic_cross_narrative",{})
    return payload

func _atomic_write(path: String, text: String) -> bool:
    var temp := _temp_for(path)
    var file := FileAccess.open(temp, FileAccess.WRITE)
    if file == null:
        return false
    file.store_string(text)
    file.flush()
    var write_error := file.get_error()
    file.close()
    # Never replace a good generation with truncated, corrupt or unknown data.
    if write_error != OK or FileAccess.get_file_as_string(temp) != text:
        return false
    if _migrate(_read_payload(temp)).is_empty():
        return false
    var destination := ProjectSettings.globalize_path(path)
    var temporary := ProjectSettings.globalize_path(temp)
    var backup := ProjectSettings.globalize_path(_backup_for(path))
    var previous_is_valid := not _migrate(_read_payload(path)).is_empty()
    if previous_is_valid:
        # An already-corrupt primary must never overwrite the last good backup.
        if DirAccess.copy_absolute(destination, backup) != OK:
            return false
        if FileAccess.get_file_as_string(path) != FileAccess.get_file_as_string(_backup_for(path)):
            return false
    # Let the filesystem replace the destination; do not delete it first.
    if _replace_save_file(temporary, destination) == OK:
        return true
    # Some backends may remove the destination even when replacement fails.
    if previous_is_valid and _migrate(_read_payload(path)).is_empty():
        if DirAccess.copy_absolute(backup, destination) != OK:
            push_warning("Impossible de restaurer la sauvegarde principale ; secours conservé.")
    return false

func _replace_save_file(from_path: String, to_path: String) -> Error:
    return DirAccess.rename_absolute(from_path, to_path)

func _read_payload(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        return {}
    var parser := JSON.new()
    if parser.parse(FileAccess.get_file_as_string(path)) != OK:
        return {}
    var parsed: Variant = parser.data
    if parsed is not Dictionary:
        return {}
    if parsed.has("body"):
        var body := String(parsed.get("body", ""))
        if String(parsed.get("checksum", "")) != body.sha256_text():
            return {}
        if parser.parse(body) != OK:
            return {}
        var payload_value: Variant = parser.data
        return payload_value if payload_value is Dictionary else {}
    if parsed.has("payload"):
        var old_payload: Variant = parsed.get("payload", {})
        return old_payload if old_payload is Dictionary else {}
    return parsed

func _valid_slot(slot: int) -> int:
    return AUTOSAVE_SLOT if slot == AUTOSAVE_SLOT else clampi(slot, 0, SLOT_COUNT - 1)

func _path(slot: int) -> String:
    return "user://litd_autosave.json" if slot == AUTOSAVE_SLOT else "user://litd_slot_%d.json" % slot

func _backup_path(slot: int) -> String:
    return _backup_for(_path(slot))

func _temp_path(slot: int) -> String:
    return _temp_for(_path(slot))

func _backup_for(path: String) -> String:
    return path + ".bak"

func _temp_for(path: String) -> String:
    return path + ".tmp"

# Canonical persistent-state contract; deliberately lives in the approved SaveManager
# script scope defined by docs/reconstruction/RESET_20261112_MANIFEST.json.
const SCHEMA_VERSION := 1
const EXCLUDED_ROOT_FIELDS := ["metadata", "qa_snapshot", "runtime_cache", "animations", "ui_state"]

func canonical_body(campaign_id: String, revision: int, persistent_state: Dictionary) -> String:
    if campaign_id.is_empty() or revision < 0:
        return ""
    for field in EXCLUDED_ROOT_FIELDS:
        if persistent_state.has(field):
            return ""
    if not _supported(persistent_state):
        return ""
    var record := {
        "schema_version": SCHEMA_VERSION,
        "campaign_id": campaign_id,
        "revision": revision,
        "persistent_state": persistent_state
    }
    # Godot JSON.stringify sorts dictionary keys recursively when sort_keys=true.
    return JSON.stringify(record, "", true, true)

func canonical_sha256(campaign_id: String, revision: int, persistent_state: Dictionary) -> String:
    var body := canonical_body(campaign_id, revision, persistent_state)
    return "" if body.is_empty() else body.sha256_text()

func _supported(value: Variant) -> bool:
    match typeof(value):
        TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_STRING:
            return true
        TYPE_FLOAT:
            return is_finite(value)
        TYPE_ARRAY:
            for entry in value:
                if not _supported(entry):
                    return false
            return true
        TYPE_DICTIONARY:
            for key in value.keys():
                if typeof(key) != TYPE_STRING or not _supported(value[key]):
                    return false
            return true
        _:
            return false

# Transaction preview only: pure validation on copies, with no disk writes.
# This is NOT a durable write-ahead journal or a runtime commit operation.
func preview_committed_transaction(current_state: Dictionary, record: Dictionary, applied_ids: Array) -> Dictionary:
    var campaign_id: Variant = record.get("campaign_id")
    var transaction_id: Variant = record.get("transaction_id")
    var base_revision: Variant = record.get("base_revision")
    var result_revision: Variant = record.get("result_revision")
    var current_revision: Variant = record.get("current_revision")
    var next_state: Variant = record.get("result_state")
    var before_hash: Variant = record.get("pre_state_sha256")
    var after_hash: Variant = record.get("post_state_sha256")
    if typeof(campaign_id) != TYPE_STRING or String(campaign_id).is_empty():
        return {}
    if typeof(transaction_id) != TYPE_STRING or String(transaction_id).is_empty():
        return {}
    if typeof(base_revision) != TYPE_INT or typeof(result_revision) != TYPE_INT or typeof(current_revision) != TYPE_INT:
        return {}
    if base_revision < 0 or result_revision != base_revision + 1 or current_revision != base_revision:
        return {}
    if applied_ids.has(transaction_id):
        return {}
    if typeof(next_state) != TYPE_DICTIONARY or typeof(before_hash) != TYPE_STRING or typeof(after_hash) != TYPE_STRING:
        return {}
    if before_hash != canonical_sha256(campaign_id, base_revision, current_state):
        return {}
    if after_hash != canonical_sha256(campaign_id, result_revision, next_state):
        return {}
    if String(before_hash).length() != 64 or String(after_hash).length() != 64:
        return {}
    var ids := applied_ids.duplicate()
    ids.append(transaction_id)
    return {
        "campaign_id": campaign_id,
        "revision": result_revision,
        "persistent_state": next_state.duplicate(true),
        "applied_transaction_ids": ids
    }

# Experimental isolated journal. Never called by save_game/load_game.
# Append-only revision files; a failed or interrupted write must not be accepted.
# FileAccess.flush + readback does not establish power-loss durability.
func journal_append_preview(journal_dir: String, current_state: Dictionary, record: Dictionary, applied_ids: Array) -> bool:
    if not journal_dir.begins_with("user://litd_transaction_lab/"):
        return false
    var preview := preview_committed_transaction(current_state, record, applied_ids)
    if preview.is_empty():
        return false
    var revision: int = preview["revision"]
    var path := journal_dir.path_join("revision_%010d.json" % revision)
    if FileAccess.file_exists(path):
        return false
    if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(journal_dir)) != OK:
        return false
    var entry := {
        "journal_schema_version": 1,
        "record": record.duplicate(true),
        "transaction_id": preview["applied_transaction_ids"].back()
    }
    if not _supported(entry):
        return false
    # Godot JSON parsing converts integer variants to floats; preserve exact types
    # for the canonical revision and SHA-256 checks during recovery.
    var binary := var_to_bytes(entry)
    var encoded := JSON.stringify({
        "payload_base64": Marshalls.raw_to_base64(binary),
        "sha256": Marshalls.raw_to_base64(binary).sha256_text()
    })
    var temp := path + ".pending"
    if FileAccess.file_exists(temp):
        return false
    var file := FileAccess.open(temp, FileAccess.WRITE)
    if file == null:
        return false
    file.store_string(encoded)
    file.flush()
    var write_error := file.get_error()
    file.close()
    if write_error != OK or FileAccess.get_file_as_string(temp) != encoded:
        return false
    if DirAccess.rename_absolute(ProjectSettings.globalize_path(temp), ProjectSettings.globalize_path(path)) != OK:
        return false
    return FileAccess.get_file_as_string(path) == encoded

# Recover a consecutive, validated prefix; never accept a malformed entry.
# A missing revision is an error, not a reason to skip forward.
func journal_recover_preview(journal_dir: String, campaign_id: String, base_revision: int, base_state: Dictionary) -> Dictionary:
    if not journal_dir.begins_with("user://litd_transaction_lab/"):
        return {}
    var state := base_state.duplicate(true)
    var revision := base_revision
    var ids: Array = []
    var directory := DirAccess.open(journal_dir)
    if directory == null:
        return {"revision": revision, "persistent_state": state, "applied_transaction_ids": ids}
    var files := directory.get_files()
    var expected_count := 0
    for name in files:
        if name.begins_with("revision_") and name.ends_with(".json"):
            expected_count += 1
    for index in range(expected_count):
        var path := journal_dir.path_join("revision_%010d.json" % (revision + 1))
        if not FileAccess.file_exists(path):
            return {}
        var parser := JSON.new()
        if parser.parse(FileAccess.get_file_as_string(path)) != OK or not (parser.data is Dictionary):
            return {}
        var envelope: Dictionary = parser.data
        var payload_base64: Variant = envelope.get("payload_base64")
        if typeof(payload_base64) != TYPE_STRING:
            return {}
        var binary := Marshalls.base64_to_raw(payload_base64)
        if binary.is_empty() or envelope.get("sha256") != binary.sha256_text():
            return {}
        var decoded: Variant = bytes_to_var(binary, false)
        if not (decoded is Dictionary):
            return {}
        var entry: Dictionary = decoded
        if entry.get("journal_schema_version") != 1 or not (entry.get("record") is Dictionary):
            return {}
        var record: Dictionary = entry["record"]
        if record.get("campaign_id") != campaign_id or record.get("transaction_id") != entry.get("transaction_id"):
            return {}
        var preview := preview_committed_transaction(state, record, ids)
        if preview.is_empty() or preview.get("revision") != revision + 1:
            return {}
        state = preview["persistent_state"]
        ids = preview["applied_transaction_ids"]
        revision += 1
    return {"revision": revision, "persistent_state": state, "applied_transaction_ids": ids}
