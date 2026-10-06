extends Node

const RUNTIME := preload("res://scripts/core/veilleurs_tactical_combat_runtime_v09.gd")
const TARGET := preload("res://scripts/core/combat/veilleurs_target_resolver.gd")
var failures: Array[String] = []

func check(ok: bool, label: String) -> void:
    if not ok:
        failures.append(label)
        push_error(label)

func _ready() -> void:
    exercise(RUNTIME)
    exercise(preload("res://scripts/core/veilleurs_combat_runtime.gd"))
    print("VEILLEURS_BODY_ACTION_CONTRACT: ", "OK" if failures.is_empty() else failures)
    get_tree().quit(0 if failures.is_empty() else 1)

func exercise(runtime_script: Script) -> void:
    check(TARGET.tactical_actor_alive({"hp":80, "body":{"dead":false}}), "serialized_living_body")
    check(not TARGET.tactical_actor_alive({"hp":80, "body":{"dead":true}}), "serialized_dead_body")
    var runtime = runtime_script.new()
    check(bool(runtime.setup_first_combat().get("ok", false)), "setup")
    var actor := "ENT_WATCHER_marec"
    var enemy: String = runtime.alive_ids("enemy")[0]
    var body: VeilleursBodyComponent = runtime.combatants[actor]["body"]
    var skill_id := ""
    for skill in runtime.content_db.skills_for(actor):
        if runtime.skill_behavior.effective_action(skill) == "attack":
            skill_id = str(skill["skill_id"])
            break
    runtime.grid.move(enemy, Vector2i(1, 1))
    check(bool(runtime.preview_skill(actor, enemy, skill_id).get("ok", false)), "healthy_attack")
    body.states["left_arm"] = "L4"
    check(bool(runtime.preview_skill(actor, enemy, skill_id).get("ok", false)), "one_hand_attack_preserved")
    var saved_items := EquipmentManager.items.duplicate(true)
    var saved_equipped := EquipmentManager.equipped_by_hero.duplicate(true)
    EquipmentManager.add_item({"instance_id":"body_contract_weapon", "slot":"weapon", "two_handed":true, "base_bonuses":{}, "affixes":[]})
    EquipmentManager.equipped_by_hero["Marec"] = {"weapon":"body_contract_weapon"}
    var slice_runtime = preload("res://scripts/core/veilleurs_vertical_slice_runtime_v09.gd").new()
    runtime.combatants[actor] = slice_runtime._apply_equipment_bonuses(actor, runtime.combatants[actor])
    check(bool(runtime.combatants[actor].get("weapon_two_handed", false)), "equipped_two_hand_requirement")
    EquipmentManager.items = saved_items
    EquipmentManager.equipped_by_hero = saved_equipped
    var before := JSON.stringify(runtime.serialize())
    check(not bool(runtime.preview_skill(actor, enemy, skill_id).get("ok", false)), "two_hand_preview_blocked")
    check(not bool(runtime.resolve_skill(actor, enemy, skill_id).get("ok", false)), "two_hand_execution_blocked")
    check(JSON.stringify(runtime.serialize()) == before, "blocked_action_mutated_state")
    runtime.combatants[actor]["weapon_two_handed"] = false
    body.missing_parts = ["left_arm", "right_arm"]
    check(not bool(TARGET.validate_tactical_actor(runtime, actor, {"action_type":"guard"}).get("ok", false)), "guard_without_arms")
    body.missing_parts = ["left_leg", "right_leg"]
    check(not runtime.can_move_to(Vector2i(0, 0), actor), "walk_without_legs")
    body.missing_parts.clear()
    body.states["left_leg"] = "L3"
    check(bool(TARGET.validate_tactical_actor(runtime, actor, {"action_type":"move"}).get("ok", false)), "walking_not_sprinting")
    body.dead = true
    check(not runtime.alive_ids("watcher").has(actor), "body_death_positive_hp")
    check(not bool(runtime.resolve_skill(actor, enemy, skill_id).get("ok", false)), "dead_actor_action")
    check(not bool(runtime.ultimate_runtime.prepare(runtime, actor, enemy, {"level":16, "ultimate_charges":1}).get("ok", false)), "dead_ultimate_actor")
    check(runtime.ultimate_runtime.pending.is_empty(), "dead_ultimate_not_prepared")
    var restored = runtime_script.new()
    check(restored.deserialize(JSON.parse_string(JSON.stringify(runtime.serialize()))), "restore")
    check(not restored.alive_ids("watcher").has(actor), "restored_body_death")
    runtime.combatants[enemy]["body"].dead = true
    check(not runtime.alive_ids("enemy").has(enemy), "dead_enemy_membership")
    check(not bool(runtime.enemy_step(enemy).get("ok", false)), "dead_enemy_action")
    check(not bool(runtime.subdue_status(enemy).get("ok", false)), "dead_enemy_submission")
