extends RefCounted
class_name VeilleursTargetResolver

const ZONES := ["head", "torso", "left_arm", "right_arm", "left_leg", "right_leg"]

static func normalize_zone(zone: String) -> String:
    return zone if zone in ZONES else "torso"

static func validate_index(collection: Array, index: int) -> Dictionary:
    if index < 0 or index >= collection.size():
        return {"ok":false, "reason":"invalid_target"}
    return {"ok":true, "target":collection[index]}

static func validate_tactical_target(runtime: Variant, attacker_id: String, target_id: String, skill: Dictionary, allow_attack_move: bool = true) -> Dictionary:
    if runtime == null or not runtime.combatants.has(attacker_id):
        return {"ok":false, "reason":"invalid_attacker"}
    if target_id == "" or not runtime.combatants.has(target_id):
        return {"ok":false, "reason":"invalid_target"}
    var target: Dictionary = runtime.combatants[target_id]
    if int(target.get("hp", 0)) <= 0 or bool(target.get("subdued", false)):
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
