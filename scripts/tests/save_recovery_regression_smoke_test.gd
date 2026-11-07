extends Node

const TEST_PATH := "user://litd_save_recovery_regression.json"
const FAILURE_PATH := "user://litd_save_replacement_failure.json"
const BLOCKED_PATH := "user://litd_save_backup_blocked.json"
const FAILURE_FIXTURE := preload("res://scripts/tests/save_manager_replacement_failure_fixture.gd")
var failures: Array[String] = []

func _ready() -> void:
    call_deferred("_run")

func _run() -> void:
    var sandbox := OS.get_environment("LITD_SAVE_TEST_SANDBOX")
    if sandbox.is_empty() or sandbox != OS.get_environment("XDG_DATA_HOME") or not OS.get_user_data_dir().begins_with(sandbox + "/"):
        push_error("SAVE_RECOVERY_REQUIRES_ISOLATED_DATA_ROOT")
        get_tree().quit(1)
        return
    _cleanup()
    _test_staged_data_and_backup()
    _test_replacement_failures()
    _test_slot_zero_fallback()
    _cleanup()
    _finish()

func _envelope(marker: String) -> String:
    var body := JSON.stringify({"version": SaveManager.SAVE_VERSION, "marker": marker})
    return JSON.stringify({"checksum": body.sha256_text(), "body": body})

func _test_staged_data_and_backup() -> void:
    _check(SaveManager._atomic_write(TEST_PATH, _envelope("first")), "initial write")
    _check(str(SaveManager._read_payload(TEST_PATH).get("marker", "")) == "first", "initial roundtrip")
    _check(SaveManager._atomic_write(TEST_PATH, _envelope("second")), "replacement write")
    _check(str(SaveManager._read_payload(TEST_PATH).get("marker", "")) == "second", "new generation authoritative")
    _check(str(SaveManager._read_payload(TEST_PATH + ".bak").get("marker", "")) == "first", "previous generation backup")
    _check(_write_raw(TEST_PATH, "{not-json"), "inject corrupt primary")
    _check(SaveManager._read_payload(TEST_PATH).is_empty(), "corruption rejected")
    _check(SaveManager._atomic_write(TEST_PATH, _envelope("third")), "write after corruption")
    _check(str(SaveManager._read_payload(TEST_PATH + ".bak").get("marker", "")) == "first", "corrupt primary cannot replace good backup")
    for invalid: String in ["{bad-json", JSON.stringify({"checksum": "invalid", "body": "{}"}), JSON.stringify({"marker": "no-version"}), JSON.stringify({"version": "99.0"})]:
        _check(not SaveManager._atomic_write(TEST_PATH, invalid), "invalid staged payload rejected")
        _check(str(SaveManager._read_payload(TEST_PATH).get("marker", "")) == "third", "rejected stage preserves primary")
        _check(str(SaveManager._read_payload(TEST_PATH + ".bak").get("marker", "")) == "first", "rejected stage preserves backup")
    _check(SaveManager._migrate({"version": "0.30"}).is_empty(), "incompatible schema rejected")
    _check(SaveManager._migrate({"gold": 1}).is_empty(), "missing version rejected")
    _check(not SaveManager._migrate({"version": SaveManager.SAVE_VERSION}).is_empty(), "current schema accepted")
    DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH + ".tmp"))
    _check(DirAccess.make_dir_absolute(TEST_PATH + ".tmp") == OK, "block temporary write")
    _check(not SaveManager._atomic_write(TEST_PATH, _envelope("blocked")), "temporary open failure reported")
    _check(str(SaveManager._read_payload(TEST_PATH).get("marker", "")) == "third", "temporary failure preserves primary")

func _test_replacement_failures() -> void:
    var failing := FAILURE_FIXTURE.new()
    add_child(failing)
    _check(failing._atomic_write(FAILURE_PATH, _envelope("safe")), "seed replacement fixture")
    failing.fail_replacement = true
    _check(not failing._atomic_write(FAILURE_PATH, _envelope("new")), "failed replacement reported")
    _check(str(failing._read_payload(FAILURE_PATH).get("marker", "")) == "safe", "rename failure preserves primary")
    failing.remove_destination_before_failure = true
    _check(not failing._atomic_write(FAILURE_PATH, _envelope("new")), "destructive backend failure reported")
    _check(str(failing._read_payload(FAILURE_PATH).get("marker", "")) == "safe", "missing destination restored from backup")
    _check(str(failing._read_payload(FAILURE_PATH + ".bak").get("marker", "")) == "safe", "backup survives destructive failure")
    failing.free()
    _check(SaveManager._atomic_write(BLOCKED_PATH, _envelope("safe")), "seed backup failure fixture")
    _check(DirAccess.make_dir_absolute(BLOCKED_PATH + ".bak") == OK, "block backup creation")
    _check(not SaveManager._atomic_write(BLOCKED_PATH, _envelope("new")), "failed backup copy reported")
    _check(str(SaveManager._read_payload(BLOCKED_PATH).get("marker", "")) == "safe", "backup copy failure preserves primary")

func _test_slot_zero_fallback() -> void:
    GameState.gold = 100
    _check(SaveManager.save_game(0), "first slot zero save")
    DirAccess.remove_absolute(ProjectSettings.globalize_path(SaveManager.SAVE_PATH))
    _check(DirAccess.make_dir_absolute(SaveManager.SAVE_PATH) == OK, "block legacy mirror destination")
    GameState.gold = 200
    _check(SaveManager.save_game(0), "canonical write succeeds despite legacy mirror failure")
    DirAccess.remove_absolute(ProjectSettings.globalize_path(SaveManager.SAVE_PATH))
    var legacy := SaveManager._build_payload()
    legacy["gold"] = 5
    _check(_write_raw(SaveManager.SAVE_PATH, JSON.stringify(legacy)), "seed stale legacy mirror")
    _check(SaveManager.load_game(0) and GameState.gold == 200, "canonical outranks stale legacy")
    for invalid: String in ["{bad-json", JSON.stringify({"version": "99.0", "gold": 999}), JSON.stringify({"gold": 999})]:
        _check(_write_raw(SaveManager._path(0), invalid), "inject invalid slot zero primary")
        _check(SaveManager.load_game(0) and GameState.gold == 100, "valid backup outranks invalid primary and stale legacy")
    DirAccess.remove_absolute(ProjectSettings.globalize_path(SaveManager._path(0)))
    DirAccess.remove_absolute(ProjectSettings.globalize_path(SaveManager._backup_path(0)))
    _check(SaveManager.load_game(0) and GameState.gold == 5, "legacy is last resort")
    SaveManager.delete_slot(0)

func _write_raw(path: String, body: String) -> bool:
    var file := FileAccess.open(path, FileAccess.WRITE)
    if file == null:
        return false
    file.store_string(body)
    file.close()
    return true

func _cleanup() -> void:
    for primary: String in [TEST_PATH, FAILURE_PATH, BLOCKED_PATH]:
        for suffix: String in ["", ".bak", ".tmp"]:
            var path := ProjectSettings.globalize_path(primary + suffix)
            if FileAccess.file_exists(path) or DirAccess.dir_exists_absolute(path):
                DirAccess.remove_absolute(path)

func _check(condition: bool, message: String) -> void:
    if not condition:
        failures.append(message)

func _finish() -> void:
    if failures.is_empty():
        print("SAVE_RECOVERY_REGRESSION_OK")
        get_tree().quit(0)
        return
    for failure in failures:
        push_error("SAVE_RECOVERY_REGRESSION_FAIL: " + failure)
    get_tree().quit(1)
