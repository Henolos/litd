extends RefCounted
class_name VeilleursTargetResolver

const RULES := preload("res://scripts/core/combat_targeting_rules.gd")
const ZONES := ["head", "torso", "left_arm", "right_arm", "left_leg", "right_leg"]

static func normalize_zone(zone: String) -> String:
    return zone if zone in ZONES else "torso"

static func validate_index(collection: Array, index: int) -> Dictionary:
    if index < 0 or index >= collection.size():
        return {"ok":false, "reason":"invalid_target"}
    return {"ok":true, "target":collection[index]}

static func ensure_enemy_positions(enemies: Array) -> void:
    RULES.ensure_enemy_positions(enemies)

static func target_positions(hero: Dictionary, action: Dictionary) -> Array[int]:
    return RULES.target_positions(hero, action)

static func can_target(hero: Dictionary, action: Dictionary, enemy: Dictionary, enemies: Array) -> bool:
    return RULES.can_target(hero, action, enemy, enemies)

static func targetable_indices(hero: Dictionary, action: Dictionary, enemies: Array) -> Array[int]:
    return RULES.targetable_indices(hero, action, enemies)

static func body_zones_for_action(action: Dictionary) -> Array[String]:
    var explicit_value: Variant = action.get("allowed_body_zones", action.get("target_zones", null))
    var result: Array[String] = []
    if explicit_value is Array:
        for value: Variant in explicit_value:
            var zone := normalize_zone(str(value))
            if not result.has(zone):
                result.append(zone)
        if not result.is_empty():
            return result
    if str(action.get("target", "")) == "enemy_zone" or bool(action.get("requires_body_zone", false)):
        return ZONES.duplicate()
    return result

static func requires_body_zone(action: Dictionary) -> bool:
    return str(action.get("target", "")) == "enemy_zone" or bool(action.get("requires_body_zone", false)) or not body_zones_for_action(action).is_empty()

static func can_target_body_zone(action: Dictionary, target: Dictionary, zone: String) -> bool:
    if not requires_body_zone(action):
        return true
    if target.is_empty() or int(target.get("hp", 0)) <= 0:
        return false
    return body_zones_for_action(action).has(normalize_zone(zone))

static func uses_rank_targeting(action: Dictionary) -> bool:
    return str(action.get("effect", "")) in ["attack", "affliction"] or action.has("source_stat") or action.has("branch")

static func validate_target_contract(hero: Dictionary, action: Dictionary, enemy: Dictionary, enemies: Array, zone: String = "") -> Dictionary:
    if enemy.is_empty() or int(enemy.get("hp", 0)) <= 0:
        return {"ok":false, "reason":"enemy_not_targetable"}
    if uses_rank_targeting(action) and not can_target(hero, action, enemy, enemies):
        return {"ok":false, "reason":"enemy_not_targetable"}
    if requires_body_zone(action):
        if zone == "":
            return {"ok":false, "reason":"body_zone_required"}
        var normalized := normalize_zone(zone)
        if not can_target_body_zone(action, enemy, normalized):
            return {"ok":false, "reason":"body_zone_not_targetable", "zone":normalized}
        return {"ok":true, "target":enemy, "zone":normalized}
    return {"ok":true, "target":enemy, "zone":""}

# Consume the existing body contract; a disabled two-handed grip does not
# disable one-handed or natural attacks. No new injury multiplier is implied.
static func tactical_actor_alive(row: Dictionary) -> bool:
    var body: VeilleursBodyComponent = row.get("body") as VeilleursBodyComponent
    if row.get("body") is Dictionary:
        return int(row.get("hp", 0)) > 0 and not bool((row["body"] as Dictionary).get("dead", false))
    return int(row.get("hp", 0)) > 0 and (body == null or bool(body.functional_flags().get("alive", true)))

static func validate_tactical_actor(runtime: Variant, actor_id: String, skill: Dictionary = {}) -> Dictionary:
    if runtime == null or not runtime.combatants.has(actor_id):
        return {"ok":false, "reason":"invalid_attacker"}
    var row: Dictionary = runtime.combatants[actor_id]
    if not tactical_actor_alive(row) or bool(row.get("subdued", false)):
        return {"ok":false, "reason":"actor_unavailable"}
    var body: VeilleursBodyComponent = row.get("body") as VeilleursBodyComponent
    if body == null:
        return {"ok":true}
    var flags: Dictionary = body.functional_flags()
    var action := str(skill.get("action_type", "attack"))
    if runtime.skill_behavior != null:
        action = str(runtime.skill_behavior.effective_action(skill))
    var required := ""
    if action in ["move", "flee", "attack_move"]:
        required = "can_walk"
    elif action == "guard":
        required = "can_guard"
    if required != "" and not bool(flags.get(required, true)):
        return {"ok":false, "reason":"body_function_unavailable", "required_function":required}
    if action in ["attack", "attack_move"] and bool(row.get("weapon_two_handed", false)):
        required = "can_use_two_handed"
    if required != "" and not bool(flags.get(required, true)):
        return {"ok":false, "reason":"body_function_unavailable", "required_function":required}
    return {"ok":true}

static func validate_tactical_target(runtime: Variant, attacker_id: String, target_id: String, skill: Dictionary, allow_attack_move: bool = true) -> Dictionary:
    if runtime == null or not runtime.combatants.has(attacker_id):
        return {"ok":false, "reason":"invalid_attacker"}
    if target_id == "" or not runtime.combatants.has(target_id):
        return {"ok":false, "reason":"invalid_target"}
    var actor_verdict := validate_tactical_actor(runtime, attacker_id, skill)
    if not bool(actor_verdict.get("ok", false)):
        return actor_verdict
    var target: Dictionary = runtime.combatants[target_id]
    if not tactical_actor_alive(target) or bool(target.get("subdued", false)):
        return {"ok":false, "reason":"target_unavailable", "target":target_id}
    var action := str(skill.get("action_type", "attack"))
    if runtime.skill_behavior != null and runtime.skill_behavior.has_method("effective_action"):
        action = str(runtime.skill_behavior.effective_action(skill))
    var required_range := 0
    if runtime.skill_behavior != null and runtime.skill_behavior.has_method("range_for"):
        required_range = int(runtime.skill_behavior.range_for(skill))
    var distance := int(runtime.grid.distance(attacker_id, target_id))
    var in_range := required_range <= 0 or (distance >= 0 and distance <= required_range)
    if action == "attack_move" and allow_attack_move:
        in_range = true
    return {
        "ok":in_range,
        "reason":"" if in_range else "out_of_range",
        "attacker":attacker_id,
        "target":target_id,
        "action":action,
        "distance":distance,
        "required_range":required_range
    }

static func tactical_target_sets(runtime: Variant, attacker_id: String, skill: Dictionary, target_ids: Array) -> Dictionary:
    var candidates: Array[String] = []
    var blocked: Array[String] = []
    var reasons := {}
    for target_value in target_ids:
        var target_id := str(target_value)
        var verdict := validate_tactical_target(runtime, attacker_id, target_id, skill)
        if bool(verdict.get("ok", false)):
            candidates.append(target_id)
        else:
            blocked.append(target_id)
            reasons[target_id] = str(verdict.get("reason", "invalid_target"))
    return {"candidates":candidates, "blocked":blocked, "reasons":reasons}
