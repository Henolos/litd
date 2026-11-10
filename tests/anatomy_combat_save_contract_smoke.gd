extends SceneTree

# Contract test: run headless with Godot from the project root.
# A combat snapshot must retain anatomy and turn state without changing the original.
func _initialize() -> void:
    var bridge = get_root().get_node_or_null("AshlandsCombatBridge")
    if bridge == null:
        push_error("AshlandsCombatBridge autoload unavailable")
        quit(1)
        return
    var game_state = get_root().get_node_or_null("GameState")
    if game_state == null:
        push_error("GameState autoload unavailable")
        quit(1)
        return
    var original_active: bool = bridge.active
    var original_id: String = bridge.encounter_id
    var original_type: String = bridge.encounter_type
    var original_enemies: Array = game_state.battle_enemies.duplicate(true)
    var original_rounds: int = game_state.battle_rounds
    var original_selected_hero: int = game_state.selected_hero
    bridge.active = true
    bridge.encounter_id = "qa_anatomy_resume"
    bridge.encounter_type = "boss"
    game_state.battle_rounds = 4
    game_state.selected_hero = 1
    game_state.battle_enemies = [
        {"id": "qa_cerberus", "dismemberment_profile": "cerberus", "hp": 70, "max_hp": 100,
         "dismembered_parts": ["left_head"], "anatomy_part_trauma": {"center_head": 19},
         "anatomy_injuries": {"center_head": "wounded"}},
        {"id": "qa_jorogumo", "dismemberment_profile": "jorogumo", "hp": 80, "max_hp": 100,
         "dismembered_parts": ["left_spider_leg_1"], "anatomy_part_trauma": {"right_spider_leg_2": 33},
         "anatomy_injuries": {"right_spider_leg_2": "wounded"}}
    ]
    var snapshot: Dictionary = bridge.serialize()
    var decoded: Variant = JSON.parse_string(JSON.stringify(snapshot))
    var valid := decoded is Dictionary
    if valid:
        var payload: Dictionary = decoded
        valid = payload.get("combat_snapshot_version", -1) == 1 and payload.get("combat_rounds", -1) == 4
        valid = valid and payload.get("combat_selected_hero", -1) == 1
        var enemies: Array = payload.get("combat_enemies", [])
        valid = valid and enemies.size() == 2
        if enemies.size() == 2:
            valid = valid and enemies[0].get("dismembered_parts", []).has("left_head")
            valid = valid and enemies[0].get("anatomy_part_trauma", {}).get("center_head", -1) == 19
            valid = valid and enemies[1].get("dismembered_parts", []).has("left_spider_leg_1")
            valid = valid and enemies[1].get("anatomy_part_trauma", {}).get("right_spider_leg_2", -1) == 33
    # The snapshot must be a deep copy: later combat changes cannot rewrite a saved turn.
    game_state.battle_enemies[0]["dismembered_parts"].clear()
    if decoded is Dictionary:
        var saved_enemies: Array = decoded.get("combat_enemies", [])
        valid = valid and saved_enemies.size() == 2 and saved_enemies[0].get("dismembered_parts", []).has("left_head")
    # Rehydrate the saved state and check that the wounded limbs survive.
    if decoded is Dictionary:
        game_state.battle_enemies = []
        game_state.battle_rounds = 0
        game_state.selected_hero = 0
        bridge.deserialize(decoded)
        valid = valid and game_state.battle_rounds == 4 and game_state.selected_hero == 1
        valid = valid and game_state.battle_enemies.size() == 2
        if game_state.battle_enemies.size() == 2:
            valid = valid and game_state.battle_enemies[0].get("dismembered_parts", []).has("left_head")
            valid = valid and game_state.battle_enemies[1].get("anatomy_part_trauma", {}).get("right_spider_leg_2", -1) == 33
    bridge.active = original_active
    bridge.encounter_id = original_id
    bridge.encounter_type = original_type
    game_state.battle_enemies = original_enemies
    game_state.battle_rounds = original_rounds
    game_state.selected_hero = original_selected_hero
    if not valid:
        push_error("Combat save contract missing anatomy or round state")
        quit(1)
        return
    print("anatomy_combat_save_contract_smoke: PASS")
    quit(0)
