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
func journal_append_preview(journal_dir: String, current_state: Dictionary, record: Dictionary, applied_ids: Array, interrupt_at: String = "") -> bool:
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
    if interrupt_at == "before_open":
        return false
    var file := FileAccess.open(temp, FileAccess.WRITE)
    if file == null:
        return false
    if interrupt_at == "after_open":
        file.close()
        return false
    if interrupt_at == "during_store":
        file.store_string(encoded.left(maxi(1, encoded.length() / 2)))
        file.flush()
        file.close()
        return false
    file.store_string(encoded)
    if interrupt_at == "after_store":
        file.close()
        return false
    file.flush()
    var write_error := file.get_error()
    file.close()
    if write_error != OK or FileAccess.get_file_as_string(temp) != encoded:
        return false
    if interrupt_at == "after_flush" or interrupt_at == "before_rename":
        return false
    if DirAccess.rename_absolute(ProjectSettings.globalize_path(temp), ProjectSettings.globalize_path(path)) != OK:
        return false
    if interrupt_at == "after_rename":
        return false
    return FileAccess.get_file_as_string(path) == encoded

# Recover a consecutive, validated prefix; never accept a malformed entry.
# A missing revision is an error, not a reason to skip forward.
func journal_recover_preview(journal_dir: String, campaign_id: String, base_revision: int, base_state: Dictionary, interrupt_at: String = "") -> Dictionary:
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
        if interrupt_at == "after_read":
            return {}
        var payload_base64: Variant = envelope.get("payload_base64")
        if typeof(payload_base64) != TYPE_STRING:
            return {}
        var binary := Marshalls.base64_to_raw(payload_base64)
        if binary.is_empty() or envelope.get("sha256") != String(payload_base64).sha256_text():
            return {}
        if interrupt_at == "after_checksum":
            return {}
        var decoded: Variant = bytes_to_var(binary)
        if not (decoded is Dictionary):
            return {}
        var entry: Dictionary = decoded
        if interrupt_at == "after_decode":
            return {}
        if entry.get("journal_schema_version") != 1 or not (entry.get("record") is Dictionary):
            return {}
        var record: Dictionary = entry["record"]
        if record.get("campaign_id") != campaign_id or record.get("transaction_id") != entry.get("transaction_id"):
            return {}
        if interrupt_at == "before_apply":
            return {}
        var preview := preview_committed_transaction(state, record, ids)
        if preview.is_empty() or preview.get("revision") != revision + 1:
            return {}
        state = preview["persistent_state"]
        ids = preview["applied_transaction_ids"]
        if interrupt_at == "after_apply":
            return {}
        revision += 1
    return {"revision": revision, "persistent_state": state, "applied_transaction_ids": ids}


# Strict preview: caller supplies an independently retained confirmation anchor.
# This does not persist the anchor or establish crash/power-loss durability.
# Unconfirmed suffixes are rejected rather than silently promoted.
func journal_recover_confirmed_preview(journal_dir: String, campaign_id: String, base_revision: int, base_state: Dictionary, anchor: Dictionary) -> Dictionary:
    if campaign_id.is_empty() or base_revision < 0 or anchor.get("campaign_id") != campaign_id:
        return {}
    var confirmed_revision: Variant = anchor.get("revision")
    var confirmed_hash: Variant = anchor.get("state_sha256")
    if typeof(confirmed_revision) != TYPE_INT or confirmed_revision < base_revision:
        return {}
    if typeof(confirmed_hash) != TYPE_STRING or String(confirmed_hash).length() != 64:
        return {}
    var recovered := journal_recover_preview(journal_dir, campaign_id, base_revision, base_state)
    if recovered.is_empty() or recovered.get("revision") != confirmed_revision:
        return {}
    if canonical_sha256(campaign_id, confirmed_revision, recovered["persistent_state"]) != confirmed_hash:
        return {}
    return recovered


# A/B confirmation laboratory. Immutable slot generations avoid overwriting
# the previous confirmation. No pruning or production integration yet.
func anchor_read_preview(dir: String, campaign_id: String) -> Dictionary:
    if not dir.begins_with("user://litd_transaction_lab/") or campaign_id.is_empty():
        return {}
    var d := DirAccess.open(dir)
    if d == null:
        return {}
    var latest: Dictionary = {}
    var count := 0
    for name in d.get_files():
        if not name.begins_with("anchor_") or not name.ends_with(".json"):
            continue
        var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(dir.path_join(name)))
        if not (parsed is Dictionary):
            return {}
        var payload: Variant = parsed.get("payload")
        if typeof(payload) != TYPE_STRING or parsed.get("sha256") != String(payload).sha256_text():
            return {}
        var a: Variant = JSON.parse_string(payload)
        if not (a is Dictionary) or a.get("campaign_id") != campaign_id:
            return {}
        var rev: Variant = a.get("revision")
        var h: Variant = a.get("state_sha256")
        if typeof(rev) != TYPE_STRING or not String(rev).is_valid_int() or int(rev) < 0 or str(int(rev)) != rev:
            return {}
        if typeof(h) != TYPE_STRING or String(h).length() != 64:
            return {}
        var n := int(rev)
        var expected := "anchor_%s_%010d.json" % ["A" if n % 2 == 0 else "B", n]
        if name != expected:
            return {}
        count += 1
        if latest.is_empty() or n > latest["revision"]:
            latest = {"campaign_id": campaign_id, "revision": n, "state_sha256": h}
    if latest.is_empty():
        return {}
    # All generations are retained; detect missing interior generations.
    var first := int(latest["revision"]) - count + 1
    for n in range(first, int(latest["revision"]) + 1):
        if not FileAccess.file_exists(dir.path_join("anchor_%s_%010d.json" % ["A" if n % 2 == 0 else "B", n])):
            return {}
    return latest

func anchor_publish_preview(dir: String, campaign_id: String, revision: int, state: Dictionary, interrupt_at: String = "") -> bool:
    if not dir.begins_with("user://litd_transaction_lab/") or revision < 0:
        return false
    var h := canonical_sha256(campaign_id, revision, state)
    if h.is_empty():
        return false
    if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir)) != OK:
        return false
    var previous := anchor_read_preview(dir, campaign_id)
    if previous.is_empty():
        for name in DirAccess.get_files_at(dir):
            if name.begins_with("anchor_") and name.ends_with(".json"):
                return false
    elif revision != int(previous["revision"]) + 1:
        return false
    var path := dir.path_join("anchor_%s_%010d.json" % ["A" if revision % 2 == 0 else "B", revision])
    var temp := path + ".pending"
    if FileAccess.file_exists(path) or FileAccess.file_exists(temp) or interrupt_at == "before_open":
        return false
    var payload := JSON.stringify({"campaign_id": campaign_id, "revision": str(revision), "state_sha256": h})
    var encoded := JSON.stringify({"payload": payload, "sha256": payload.sha256_text()})
    var f := FileAccess.open(temp, FileAccess.WRITE)
    if f == null:
        return false
    if interrupt_at == "after_open":
        f.close()
        return false
    f.store_string(encoded.left(maxi(1, encoded.length() / 2)) if interrupt_at == "during_store" else encoded)
    if interrupt_at == "during_store" or interrupt_at == "after_store":
        f.close()
        return false
    f.flush()
    var err := f.get_error()
    f.close()
    if err != OK or FileAccess.get_file_as_string(temp) != encoded or interrupt_at in ["after_flush", "before_rename"]:
        return false
    if DirAccess.rename_absolute(ProjectSettings.globalize_path(temp), ProjectSettings.globalize_path(path)) != OK:
        return false
    if interrupt_at == "after_rename":
        return false
    return anchor_read_preview(dir, campaign_id).get("revision") == revision


# Experimental single-writer coordinator. Caller must serialize access.
# A published but unconfirmed suffix blocks recovery; no automatic promotion.
func _coordinated_commit_unlocked_preview(journal_dir: String, anchor_dir: String, campaign_id: String, base_revision: int, base_state: Dictionary, record: Dictionary, interrupt_at: String = "") -> Dictionary:
    if not journal_dir.begins_with("user://litd_transaction_lab/") or not anchor_dir.begins_with("user://litd_transaction_lab/") or journal_dir == anchor_dir:
        return {}
    var anchor := anchor_read_preview(anchor_dir, campaign_id)
    var current := journal_recover_confirmed_preview(journal_dir, campaign_id, base_revision, base_state, anchor)
    if current.is_empty() or record.get("campaign_id") != campaign_id or record.get("base_revision") != current["revision"]:
        return {}
    var next := preview_committed_transaction(current["persistent_state"], record, current["applied_transaction_ids"])
    if next.is_empty() or interrupt_at == "before_journal":
        return {}
    if not journal_append_preview(journal_dir, current["persistent_state"], record, current["applied_transaction_ids"]):
        return {}
    if interrupt_at == "after_journal":
        return {}
    var readback := journal_recover_preview(journal_dir, campaign_id, base_revision, base_state)
    if readback != {"revision": next["revision"], "persistent_state": next["persistent_state"], "applied_transaction_ids": next["applied_transaction_ids"]}:
        return {}
    if not anchor_publish_preview(anchor_dir, campaign_id, next["revision"], next["persistent_state"], interrupt_at.trim_prefix("anchor_") if interrupt_at.begins_with("anchor_") else ""):
        return {}
    if interrupt_at == "after_anchor":
        return {}
    return journal_recover_confirmed_preview(journal_dir, campaign_id, base_revision, base_state, anchor_read_preview(anchor_dir, campaign_id))


# In-process reentrancy guard only; not a cross-process filesystem lock.
var _coordinator_preview_busy := false

func coordinated_commit_preview(journal_dir: String, anchor_dir: String, campaign_id: String, base_revision: int, base_state: Dictionary, record: Dictionary, interrupt_at: String = "") -> Dictionary:
    if _coordinator_preview_busy:
        return {}
    _coordinator_preview_busy = true
    var result := _coordinated_commit_unlocked_preview(journal_dir, anchor_dir, campaign_id, base_revision, base_state, record, interrupt_at)
    _coordinator_preview_busy = false
    return result

# Read-only diagnosis. Never publishes a confirmation or applies gameplay.
func inspect_unconfirmed_preview(journal_dir: String, anchor_dir: String, campaign_id: String, base_revision: int, base_state: Dictionary) -> Dictionary:
    var anchor := anchor_read_preview(anchor_dir, campaign_id)
    if anchor.is_empty():
        return {"status": "blocked"}
    var recovered := journal_recover_preview(journal_dir, campaign_id, base_revision, base_state)
    if recovered.is_empty():
        return {"status": "blocked"}
    if recovered["revision"] == anchor["revision"]:
        if canonical_sha256(campaign_id, recovered["revision"], recovered["persistent_state"]) == anchor["state_sha256"]:
            return {"status": "confirmed", "revision": recovered["revision"]}
        return {"status": "blocked"}
    if recovered["revision"] != int(anchor["revision"]) + 1:
        return {"status": "blocked"}
    # Verify the confirmed prefix against its independent anchor, not merely
    # the self-consistency of the journal's unconfirmed final entry.
    var prefix_state := base_state.duplicate(true)
    var ids: Array = []
    for revision in range(base_revision + 1, int(anchor["revision"]) + 1):
        var path := journal_dir.path_join("revision_%010d.json" % revision)
        var envelope: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
        if not (envelope is Dictionary) or typeof(envelope.get("payload_base64")) != TYPE_STRING:
            return {"status": "blocked"}
        var encoded: String = envelope["payload_base64"]
        if envelope.get("sha256") != encoded.sha256_text():
            return {"status": "blocked"}
        var entry: Variant = bytes_to_var(Marshalls.base64_to_raw(encoded))
        if not (entry is Dictionary) or not (entry.get("record") is Dictionary):
            return {"status": "blocked"}
        var step := preview_committed_transaction(prefix_state, entry["record"], ids)
        if step.is_empty() or step["revision"] != revision or step["campaign_id"] != campaign_id:
            return {"status": "blocked"}
        prefix_state = step["persistent_state"]
        ids = step["applied_transaction_ids"]
    if int(anchor["revision"]) < base_revision or canonical_sha256(campaign_id, anchor["revision"], prefix_state) != anchor["state_sha256"]:
        return {"status": "blocked"}
    return {"status": "unconfirmed", "confirmed_revision": anchor["revision"], "candidate_revision": recovered["revision"], "candidate_state_sha256": canonical_sha256(campaign_id, recovered["revision"], recovered["persistent_state"])}


# Explicit laboratory resolution only. Caller must hold exclusive access.
# Never re-simulates gameplay. A pending anchor requires separate repair.
func resolve_unconfirmed_preview(journal_dir: String, anchor_dir: String, campaign_id: String, base_revision: int, base_state: Dictionary, expected_revision: int, expected_hash: String) -> Dictionary:
    if _coordinator_preview_busy or journal_dir == anchor_dir:
        return {}
    if not journal_dir.begins_with("user://litd_transaction_lab/") or not anchor_dir.begins_with("user://litd_transaction_lab/"):
        return {}
    _coordinator_preview_busy = true
    var result := _resolve_unconfirmed_unlocked_preview(journal_dir, anchor_dir, campaign_id, base_revision, base_state, expected_revision, expected_hash)
    _coordinator_preview_busy = false
    return result

func _resolve_unconfirmed_unlocked_preview(journal_dir: String, anchor_dir: String, campaign_id: String, base_revision: int, base_state: Dictionary, expected_revision: int, expected_hash: String) -> Dictionary:
    var diagnosis := inspect_unconfirmed_preview(journal_dir, anchor_dir, campaign_id, base_revision, base_state)
    if diagnosis.get("status") != "unconfirmed" or diagnosis.get("candidate_revision") != expected_revision or diagnosis.get("candidate_state_sha256") != expected_hash:
        return {}
    var recovered := journal_recover_preview(journal_dir, campaign_id, base_revision, base_state)
    if recovered.is_empty() or recovered.get("revision") != expected_revision:
        return {}
    if canonical_sha256(campaign_id, expected_revision, recovered["persistent_state"]) != expected_hash:
        return {}
    if not anchor_publish_preview(anchor_dir, campaign_id, expected_revision, recovered["persistent_state"]):
        return {}
    return journal_recover_confirmed_preview(journal_dir, campaign_id, base_revision, base_state, anchor_read_preview(anchor_dir, campaign_id))
