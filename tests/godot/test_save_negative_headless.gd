extends SceneTree

# Isolated negative tests for SaveManager file-integrity guarantees.
const PATH := "user://litd_save_negative_contract.json"
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func _check(condition: bool, description: String) -> void:
    if not condition:
        failures += 1
        push_error(description)

func _envelope(value: int, version: String = "0.31") -> String:
    var body := JSON.stringify({"version": version, "gold": value})
    return JSON.stringify({"body": body, "checksum": body.sha256_text()})

func _remove_files() -> void:
    for suffix in ["", ".bak", ".tmp"]:
        var path := PATH + suffix
        if FileAccess.file_exists(path):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _run() -> void:
    var sandbox := OS.get_environment("LITD_SAVE_TEST_SANDBOX")
    if sandbox.is_empty() or sandbox != OS.get_environment("XDG_DATA_HOME") or not OS.get_user_data_dir().begins_with(sandbox + "/"):
        push_error("SAVE_NEGATIVE_REQUIRES_ISOLATED_DATA_ROOT")
        quit(1)
        return
    _remove_files()
    var manager := root.get_node_or_null("SaveManager")
    if manager == null:
        push_error("SaveManager autoload unavailable")
        quit(1)
        return

    _check(manager._atomic_write(PATH, _envelope(10)), "initial valid save failed")
    _check(manager._atomic_write(PATH, _envelope(20)), "second valid save failed")
    _check(int(manager._read_payload(PATH + ".bak").get("gold", -1)) == 10, "backup lost after valid replacement")

    var mismatched := JSON.stringify({"body": JSON.stringify({"version": "0.31", "gold": 999}), "checksum": "invalid"})
    _check(not manager._atomic_write(PATH, mismatched), "invalid checksum accepted")
    _check(int(manager._read_payload(PATH).get("gold", -1)) == 20, "checksum rejection altered primary")
    _check(int(manager._read_payload(PATH + ".bak").get("gold", -1)) == 10, "checksum rejection altered backup")

    _check(not manager._atomic_write(PATH, _envelope(999, "999")), "unknown save version accepted")
    _check(int(manager._read_payload(PATH).get("gold", -1)) == 20, "version rejection altered primary")

    var corrupted := FileAccess.open(PATH, FileAccess.WRITE)
    _check(corrupted != null, "failed to open primary for corruption test")
    if corrupted != null:
        corrupted.store_string("{broken")
        corrupted.close()
    _check(manager._read_payload(PATH).is_empty(), "corrupted primary accepted")
    _check(int(manager._read_payload(PATH + ".bak").get("gold", -1)) == 10, "backup unreadable after corruption")

    _check(manager._atomic_write(PATH, _envelope(30)), "recovery write failed")
    _check(int(manager._read_payload(PATH).get("gold", -1)) == 30, "recovered primary invalid")
    _check(int(manager._read_payload(PATH + ".bak").get("gold", -1)) == 10, "corrupt primary overwrote valid backup")

    _remove_files()
    if failures == 0:
        print("SAVE_NEGATIVE_CONTRACT_PASS")
    quit(1 if failures > 0 else 0)
