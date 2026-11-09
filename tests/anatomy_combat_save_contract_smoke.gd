extends SceneTree

# Contract test: run headless with Godot from the project root.
# A combat snapshot must retain anatomy and turn state without changing the original.
func _initialize() -> void:
    var bridge = get_root().get_node_or_null("AshlandsCombatBridge")
    if bridge == null:
        push_error("AshlandsCombatBridge autoload unavailable")
        quit(1)
        return
    var original_active: bool = bridge.active
    var original_id: String = bridge.encounter_id
    var original_type: String = bridge.encounter_type
    var original_enemies: Array = GameState.battle_enemies.duplicate(true)
    var original_rounds: int = GameState.battle_rounds
    bridge.active = true
    bridge.encounter_id = "qa_anatomy_resume"
    bridge.encounter_type = "boss"
    GameState.battle_rounds = 4
    GameState.battle_enemies = [
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
        var enemies: Array = payload.get("combat_enemies", [])
        valid = valid and enemies.size() == 2
        if enemies.size() == 2:
            valid = valid and enemies[0].get("dismembered_parts", []).has("left_head")
            valid = valid and enemies[0].get("anatomy_part_trauma", {}).get("center_head", -1) == 19
            valid = valid and enemies[1].get("dismembered_parts", []).has("left_spider_leg_1")
            valid = valid and enemies[1].get("anatomy_part_trauma", {}).get("right_spider_leg_2", -1) == 33
    bridge.active = original_active
    bridge.encounter_id = original_id
    bridge.encounter_type = original_type
    GameState.battle_enemies = original_enemies
    GameState.battle_rounds = original_rounds
    if not valid:
        push_error("Combat save contract missing anatomy or round state")
        quit(1)
        return
    print("anatomy_combat_save_contract_smoke: PASS")
    quit(0)
