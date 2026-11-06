extends Node

var failures: Array[String] = []

func _ready() -> void:
    call_deferred("_run")

func _run() -> void:
    # Refuse destructive checks unless the caller created an isolated data root.
    var sandbox := OS.get_environment("LITD_SAVE_DELETE_SANDBOX")
    if sandbox.is_empty() or sandbox != OS.get_environment("XDG_DATA_HOME") or not OS.get_user_data_dir().begins_with(sandbox + "/"):
        push_error("SAVE_SLOT0_DELETE_REQUIRES_ISOLATED_DATA_ROOT")
        get_tree().quit(1)
        return
    var slot0 := SaveManager._path(0)
    var slot1 := SaveManager._path(1)
    var autosave := SaveManager._path(SaveManager.AUTOSAVE_SLOT)
    var legacy := SaveManager.SAVE_PATH
    var body := JSON.stringify({"version": SaveManager.SAVE_VERSION, "marker": "delete-regression"})
    var envelope := JSON.stringify({"checksum": body.sha256_text(), "body": body})
    for primary: String in [slot0, slot1, autosave, legacy]:
        for suffix: String in ["", ".bak", ".tmp"]:
            _check(_write(primary + suffix, body if primary == legacy else envelope), "seed " + primary + suffix)
    # Deleting another slot must preserve the legacy slot-0 fallback.
    _check(SaveManager.delete_slot(1), "delete slot 1")
    for suffix: String in ["", ".bak", ".tmp"]:
        _check(FileAccess.file_exists(legacy + suffix), "slot 1 preserves legacy " + suffix)
        _check(_write(slot1 + suffix, envelope), "restore slot 1 fixture " + suffix)
    _check(SaveManager.delete_slot(0), "delete slot 0")
    for primary: String in [slot0, legacy]:
        for suffix: String in ["", ".bak", ".tmp"]:
            _check(not FileAccess.file_exists(primary + suffix), "removed " + primary + suffix)
    _check(not SaveManager.load_game(0), "deleted slot 0 cannot resurrect")
    _check(SaveManager.slot_metadata(0).is_empty(), "deleted slot has no metadata")
    _check(not SaveManager.delete_slot(0), "repeat deletion is a no-op")
    for primary: String in [slot1, autosave]:
        for suffix: String in ["", ".bak", ".tmp"]:
            _check(FileAccess.get_file_as_string(primary + suffix) == envelope, "other slot unchanged " + primary + suffix)
    if failures.is_empty():
        print("SAVE_SLOT0_DELETE_REGRESSION_OK")
        get_tree().quit(0)
        return
    for failure in failures:
        push_error("SAVE_SLOT0_DELETE_REGRESSION_FAIL: " + failure)
    get_tree().quit(1)

func _write(path: String, text: String) -> bool:
    var file := FileAccess.open(path, FileAccess.WRITE)
    if file == null:
        return false
    file.store_string(text)
    file.close()
    return true

func _check(condition: bool, message: String) -> void:
    if not condition:
        failures.append(message)
