extends RefCounted
class_name VeilleursCombatEvent

static func make(event_type: String, actor_id: String, target_id: String, payload: Dictionary = {}) -> Dictionary:
    return {"type":event_type,"actor_id":actor_id,"target_id":target_id,"payload":payload.duplicate(true)}

static func from_attack(actor: Dictionary, target: Dictionary, result: Dictionary) -> Dictionary:
    var event_type := "attack_hit" if bool(result.get("hit", false)) else "attack_miss"
    return make(event_type, str(actor.get("id", "")), str(target.get("id", "")), result)
