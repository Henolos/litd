extends RefCounted
class_name VeilleursCombatCommand

static func make(actor_id: String, action_id: String, target_side: String, target_index: int, zone: String = "torso") -> Dictionary:
    return {"actor_id":actor_id,"action_id":action_id,"target_side":target_side,"target_index":target_index,"zone":zone}

static func validate(command: Dictionary) -> Dictionary:
    for key in ["actor_id", "action_id", "target_side", "target_index", "zone"]:
        if not command.has(key): return {"ok":false,"reason":"missing_%s" % key}
    if str(command.get("actor_id", "")).is_empty(): return {"ok":false,"reason":"missing_actor_id"}
    if str(command.get("action_id", "")).is_empty(): return {"ok":false,"reason":"missing_action_id"}
    if str(command.get("target_side", "")) not in ["enemy", "ally", "self"]: return {"ok":false,"reason":"invalid_target_side"}
    return {"ok":true}
