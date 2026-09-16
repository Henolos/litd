extends RefCounted
class_name VeilleursDamageResolver

## Pure damage calculation. Mutation of combatants stays in the combat runtime for this first migration.

static func resolve(actor: Dictionary, action: Dictionary, target: Dictionary, zone: String) -> Dictionary:
    var power := int(action.get("power", 1))
    if str(actor.get("posture", "none")) == "force_cost":
        power += 3
    var armor_factor := 0.55 if str(target.get("name", "")) == "Porte-Cendre" and zone in ["torso", "left_arm", "right_arm"] else 1.0
    var damage := maxi(1, int(round(float(power) * armor_factor)))
    var severity := 3 if damage >= 13 else (2 if damage >= 8 else 1)
    return {
        "damage": damage,
        "severity": severity,
        "armor_factor": armor_factor,
    }
