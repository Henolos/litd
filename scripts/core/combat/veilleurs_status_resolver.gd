extends RefCounted
class_name VeilleursStatusResolver

static func resolve_after_hit(target: Dictionary, action: Dictionary, severity: int, resulting_hp: int) -> Dictionary:
    var pain_state := "severe" if severity >= 3 else "strong"
    var bleeding_state := str(target.get("bleeding_state", "none"))
    if str(action.get("impact", "")) == "slashing":
        bleeding_state = "important" if severity >= 2 else "light"
    var max_hp := maxi(1, int(target.get("max_hp", 1)))
    var vital_state := "stable"
    if resulting_hp <= 0:
        vital_state = "agony"
    else:
        var ratio := float(resulting_hp) / float(max_hp)
        if ratio <= 0.25: vital_state = "critical"
        elif ratio <= 0.6: vital_state = "wounded"
    return {"pain_state":pain_state,"bleeding_state":bleeding_state,"vital_state":vital_state,"public_vital_state":vital_state}
