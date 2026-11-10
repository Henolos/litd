extends SceneTree

# Regression: a resumed campaign victory must award loot exactly once.
func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var bridge = get_root().get_node_or_null("AshlandsCombatBridge")
    if bridge == null:
        push_error("Combat bridge autoload missing")
        quit(1)
        return
    var game_state = get_root().get_node_or_null("GameState")
    if game_state == null:
        push_error("GameState autoload missing")
        quit(1)
        return
    game_state.reset_new_game()
    bridge.active = true
    bridge.encounter_id = "qa_reward_once"
    bridge.encounter_type = "normal"
    bridge.return_zone_id = ""
    bridge.pending_loot = {}
    game_state.current_screen = "combat"
    game_state.battle_enemies = [{"id": 1, "hp": 1, "max_hp": 10}]
    game_state.battle_rounds = 3
    # Shared combat UI has already awarded its prototype currency.
    game_state.gold = 28
    game_state.essence = 4
    var pre_victory: Dictionary = JSON.parse_string(JSON.stringify(bridge.serialize()))
    bridge.active = false
    bridge.deserialize(pre_victory)
    if not bridge.active or game_state.battle_rounds != 3:
        push_error("Combat resume failed before reward test")
        quit(1)
        return
    bridge.resolve_victory()
    var gold_after: int = game_state.gold
    var essence_after: int = game_state.essence
    if gold_after != 18 or essence_after != 2:
        push_error("First victory reward incorrect: gold=%d essence=%d" % [gold_after, essence_after])
        quit(1)
        return
    bridge.resolve_victory()
    if game_state.gold != gold_after or game_state.essence != essence_after:
        push_error("Duplicate reward from repeated victory")
        quit(1)
        return
    var completed_snapshot: Dictionary = JSON.parse_string(JSON.stringify(bridge.serialize()))
    bridge.deserialize(completed_snapshot)
    bridge.resolve_victory()
    if bridge.active or game_state.gold != gold_after or game_state.essence != essence_after:
        push_error("Duplicate reward after restoring completed encounter")
        quit(1)
        return
    print("combat_reward_once_smoke: PASS")
    quit(0)
