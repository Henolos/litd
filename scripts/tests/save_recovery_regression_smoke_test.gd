extends Node

# Isolated file-level regression checks: never touches player save slots.
const TEST_PATH := "user://litd_save_recovery_regression.json"
var failures: Array[String] = []

func _ready() -> void:
    call_deferred("_run")

func _run() -> void:
    _cleanup()
    var first_body := JSON.stringify({"version":"0.31","marker":"first"})
    var first_envelope := JSON.stringify({"checksum":first_body.sha256_text(),"body":first_body})
    _check(SaveManager._atomic_write(TEST_PATH, first_envelope), "initial write")
    _check(str(SaveManager._read_payload(TEST_PATH).get("marker", "")) == "first", "initial payload roundtrip")

    var second_body := JSON.stringify({"version":"0.31","marker":"second"})
    var second_envelope := JSON.stringify({"checksum":second_body.sha256_text(),"body":second_body})
    _check(SaveManager._atomic_write(TEST_PATH, second_envelope), "replacement write")
    _check(str(SaveManager._read_payload(TEST_PATH).get("marker", "")) == "second", "new generation is authoritative")
    _check(str(SaveManager._read_payload(TEST_PATH + ".bak").get("marker", "")) == "first", "previous generation is preserved as backup")

    var corrupt_envelope := JSON.stringify({"checksum":"invalid","body":second_body})
    _check(_write_raw(TEST_PATH, corrupt_envelope), "inject corrupt envelope")
    _check(SaveManager._read_payload(TEST_PATH).is_empty(), "checksum mismatch is rejected")
    _check(str(SaveManager._read_payload(TEST_PATH + ".bak").get("marker", "")) == "first", "backup survives corrupt primary")

    _check(_write_raw(TEST_PATH, "{not-json"), "inject invalid JSON")
    _check(SaveManager._read_payload(TEST_PATH).is_empty(), "invalid JSON is rejected")
    _check(str(SaveManager._read_payload(TEST_PATH + ".bak").get("marker", "")) == "first", "backup survives invalid JSON")

    _check(SaveManager._migrate({"version":"0.30"}).is_empty(), "incompatible version is rejected")
    _check(not SaveManager._migrate({"version":"0.31"}).is_empty(), "current version is accepted")
    _cleanup()
    _finish()

func _write_raw(path: String, body: String) -> bool:
    var file := FileAccess.open(path, FileAccess.WRITE)
    if file == null:
        return false
    file.store_string(body)
    file.close()
    return true

func _cleanup() -> void:
    for path: String in [TEST_PATH, TEST_PATH + ".bak", TEST_PATH + ".tmp"]:
        if FileAccess.file_exists(path):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _check(condition: bool, message: String) -> void:
    if not condition:
        failures.append(message)

func _finish() -> void:
    if failures.is_empty():
        print("SAVE_RECOVERY_REGRESSION_OK")
        get_tree().quit(0)
        return
    for failure in failures:
        push_error("SAVE_RECOVERY_REGRESSION_FAIL: %s" % failure)
    get_tree().quit(1)
