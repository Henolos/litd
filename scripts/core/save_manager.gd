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
