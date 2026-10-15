extends SceneTree

# Headless integration checks against the actual SaveManager autoload.
# Run only in an isolated Godot user-data directory / CI runner.
const PATH := "user://litd_headless_save_contract.json"
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func check(condition: bool, message: String) -> void:
    if not condition:
        failures += 1
        push_error(message)

func envelope(value: int) -> String:
    var body := JSON.stringify({"version": "0.31", "gold": value})
    return JSON.stringify({"checksum": body.sha256_text(), "body": body})

func cleanup() -> void:
    for suffix in ["", ".bak", ".tmp"]:
        var p := PATH + suffix
        if FileAccess.file_exists(p):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(p))

func _run() -> void:
    cleanup()
    var manager := root.get_node_or_null("SaveManager")
    if manager == null:
        push_error("SaveManager autoload unavailable")
        quit(1)
        return

    check(manager._atomic_write(PATH, envelope(10)), "Initial write failed")
    check(int(manager._read_payload(PATH).get("gold", -1)) == 10, "Initial read failed")
    check(manager._atomic_write(PATH, envelope(20)), "Second write failed")
    check(int(manager._read_payload(PATH + ".bak").get("gold", -1)) == 10, "Backup should contain prior save")
    check(int(manager._read_payload(PATH).get("gold", -1)) == 20, "Primary should contain newest save")

    var corrupted := FileAccess.open(PATH, FileAccess.WRITE)
    check(corrupted != null, "Could not inject corruption")
    if corrupted != null:
        corrupted.store_string("{corrupted")
        corrupted.close()
    check(manager._read_payload(PATH).is_empty(), "Corrupted primary should be rejected")
    check(int(manager._read_payload(PATH + ".bak").get("gold", -1)) == 10, "Backup must remain readable")

    check(manager._atomic_write(PATH, envelope(30)), "Recovery write failed")
    check(int(manager._read_payload(PATH + ".bak").get("gold", -1)) == 10, "Corrupted primary overwrote good backup")
    check(int(manager._read_payload(PATH).get("gold", -1)) == 30, "Recovered primary invalid")

    check(not manager._atomic_write(PATH, "{bad-json"), "Invalid staged payload was accepted")
    check(int(manager._read_payload(PATH).get("gold", -1)) == 30, "Rejected write changed primary")

    cleanup()
    if failures == 0:
        print("SAVE_RUNTIME_CONTRACT_PASS")
    quit(1 if failures > 0 else 0)
