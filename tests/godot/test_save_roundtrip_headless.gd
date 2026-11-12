extends SceneTree

var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool, message: String) -> void:
    if not ok:
        failures += 1
        push_error(message)

func _run() -> void:
    var sandbox := OS.get_environment("LITD_SAVE_TEST_SANDBOX")
    if sandbox.is_empty() or sandbox != OS.get_environment("XDG_DATA_HOME") or not OS.get_user_data_dir().begins_with(sandbox + "/"):
        push_error("SAVE_ROUNDTRIP_REQUIRES_ISOLATED_DATA_ROOT")
        quit(1)
        return
    var manager := root.get_node("SaveManager")
    var snapshot := {"gold":321, "party":[{"id":"fixture", "hp":17, "persistent_injuries":[{"severity":"minor"}]}], "equipment":{"items":[{"instance_id":"item"}]}, "future_module":{"unknown_key":[1,2,3]}}
    manager.set_snapshot(snapshot)
    snapshot["gold"] = 0
    _check(manager.save_game(2), "Save opaque state")
    manager.set_snapshot({})
    _check(manager.load_game(2), "Load opaque state")
    var restored: Dictionary = manager.get_snapshot()
    _check(int(restored.get("gold", -1)) == 321, "Snapshot input must be copied")
    _check(int(restored.get("party", [{}])[0].get("hp", -1)) == 17 and restored["party"][0]["persistent_injuries"][0]["severity"] == "minor", "Nested character state preserved")
    _check(restored.get("equipment", {}) == snapshot["equipment"], "Inventory state preserved")
    _check(int(restored.get("future_module", {}).get("unknown_key", [-1])[0]) == 1 and restored["future_module"]["unknown_key"].size() == 3, "Unknown modules preserved")
    restored["party"].clear()
    _check(manager.get_snapshot()["party"].size() == 1, "Snapshot output must be copied")
    _check(not FileAccess.file_exists("user://litd_slot_0.json"), "Other slot untouched")
    _check(manager.autosave("contract"), "Autosave")
    _check(manager.save_qa_snapshot(), "QA snapshot save")
    manager.set_snapshot({})
    _check(manager.load_qa_snapshot(), "QA snapshot load")
    _check(int(manager.get_snapshot().get("gold", -1)) == 321, "QA state restored")
    _check(manager.all_slots_metadata().size() == 4, "Three slots plus autosave")
    manager.delete_slot(2)
    manager.delete_slot(manager.AUTOSAVE_SLOT)
    manager.delete_qa_snapshot()
    if failures == 0:
        print("SAVE_ROUNDTRIP_CONTRACT_PASS")
    quit(1 if failures else 0)
