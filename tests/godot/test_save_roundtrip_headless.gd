extends SceneTree

# Real SaveManager round-trip smoke test. Run ONLY in an isolated user:// root.
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool, message: String) -> void:
    if not ok:
        failures += 1
        push_error(message)

func _run() -> void:
    var sandbox: String = OS.get_environment("LITD_SAVE_TEST_SANDBOX")
    if sandbox.is_empty() or sandbox != OS.get_environment("XDG_DATA_HOME") or not OS.get_user_data_dir().begins_with(sandbox + "/"):
        push_error("SAVE_ROUNDTRIP_REQUIRES_ISOLATED_DATA_ROOT")
        quit(1)
        return

    var manager := root.get_node_or_null("SaveManager")
    var state := root.get_node_or_null("GameState")
    if manager == null or state == null:
        push_error("SaveManager or GameState autoload unavailable")
        quit(1)
        return

    # Preserve the in-memory state as well as the isolated disk state.
    var original_gold: int = state.gold
    var original_essence: int = state.essence
    var original_light: int = state.light
    var original_supplies: int = state.supplies
    var original_room: int = state.expedition_room
    var original_slot: int = manager.active_slot
    var original_party: Array = state.party.duplicate(true)
    var hero_testable: bool = not state.party.is_empty() and state.party[0] is Dictionary
    _check(hero_testable, "No hero available for character round-trip test")
    if hero_testable:
        state.party[0]["hp"] = 17
        state.party[0]["xp"] = 123
        state.party[0]["skill_points"] = 3
        state.party[0]["persistent_injuries"] = [{"id": "roundtrip_test_injury", "severity": "minor", "untreated_runs": 2, "stabilized": false, "permanent": false}]

    state.gold = 321
    state.essence = 47
    state.light = 63
    state.supplies = 12
    state.expedition_room = 5

    var saved: bool = manager.save_game(2)
    _check(saved, "Saving slot 2 failed")
    if saved:
        state.gold = 1
        state.essence = 2
        state.light = 3
        state.supplies = 4
        state.expedition_room = 0
        if hero_testable:
            state.party[0]["hp"] = 1
            state.party[0]["xp"] = 0
            state.party[0]["skill_points"] = 0
            state.party[0]["persistent_injuries"] = []
        var loaded: bool = manager.load_game(2)
        _check(loaded, "Loading slot 2 failed")
        if loaded:
            _check(state.gold == 321, "Gold not restored")
            _check(state.essence == 47, "Essence not restored")
            _check(state.light == 63, "Light not restored")
            _check(state.supplies == 12, "Supplies not restored")
            _check(state.expedition_room == 5, "Expedition room not restored")
            if hero_testable:
                _check(not state.party.is_empty() and int(state.party[0].get("hp", -1)) == 17, "Hero HP not restored")
                _check(int(state.party[0].get("xp", -1)) == 123, "Hero XP not restored")
                _check(int(state.party[0].get("skill_points", -1)) == 3, "Hero skill points not restored")
                var restored_injuries: Array = state.party[0].get("persistent_injuries", [])
                _check(restored_injuries.size() == 1 and str(restored_injuries[0].get("id", "")) == "roundtrip_test_injury", "Persistent injury not restored")

    _check(not FileAccess.file_exists("user://litd_slot_0.json"), "Round-trip test modified slot 0")
    _check(not FileAccess.file_exists("user://litd_slot_1.json"), "Round-trip test modified slot 1")
    _check(not FileAccess.file_exists("user://litd_autosave.json"), "Round-trip test modified autosave")

    state.gold = original_gold
    state.essence = original_essence
    state.light = original_light
    state.supplies = original_supplies
    state.expedition_room = original_room
    state.party = original_party
    manager.active_slot = original_slot
    manager.delete_slot(2)

    if failures == 0:
        print("SAVE_ROUNDTRIP_CONTRACT_PASS")
    quit(1 if failures > 0 else 0)
