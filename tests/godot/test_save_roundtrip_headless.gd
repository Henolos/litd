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
        var loaded: bool = manager.load_game(2)
        _check(loaded, "Loading slot 2 failed")
        if loaded:
            _check(state.gold == 321, "Gold not restored")
            _check(state.essence == 47, "Essence not restored")
            _check(state.light == 63, "Light not restored")
            _check(state.supplies == 12, "Supplies not restored")
            _check(state.expedition_room == 5, "Expedition room not restored")

    _check(not FileAccess.file_exists("user://litd_slot_0.json"), "Round-trip test modified slot 0")
    _check(not FileAccess.file_exists("user://litd_slot_1.json"), "Round-trip test modified slot 1")
    _check(not FileAccess.file_exists("user://litd_autosave.json"), "Round-trip test modified autosave")

    state.gold = original_gold
    state.essence = original_essence
    state.light = original_light
    state.supplies = original_supplies
    state.expedition_room = original_room
    manager.active_slot = original_slot
    manager.delete_slot(2)

    if failures == 0:
        print("SAVE_ROUNDTRIP_CONTRACT_PASS")
    quit(1 if failures > 0 else 0)
