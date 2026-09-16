extends RefCounted
class_name VeilleursAnatomyResolver

static func resolve(current_anatomy: Dictionary, zone: String, severity: int, armor_factor: float, action: Dictionary) -> Dictionary:
    var anatomy := current_anatomy.duplicate(true)
    var zone_state: Dictionary = (anatomy.get(zone, {}) as Dictionary).duplicate(true)
    zone_state["state"] = "injured"
    zone_state["function"] = "impaired" if severity >= 2 else "functional"
    zone_state["armor"] = "strong" if armor_factor < 0.8 else "weak"
    var injuries: Array = (zone_state.get("injuries", []) as Array).duplicate(true)
    injuries.append({"severity":severity,"impact":str(action.get("impact", "unknown")),"source":str(action.get("id", ""))})
    zone_state["injuries"] = injuries
    anatomy[zone] = zone_state
    return {"anatomy":anatomy,"zone_state":zone_state,"functional_loss":str(zone_state.get("function", "functional"))}
