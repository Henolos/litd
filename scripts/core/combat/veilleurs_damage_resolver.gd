extends RefCounted
class_name VeilleursDamageResolver

const STATUS_RESOLVER := preload("res://scripts/core/combat/veilleurs_status_resolver.gd")

## Pure damage calculation. Mutation of combatants stays in the combat runtime for this first migration.

static func resolve(actor: Dictionary, action: Dictionary, target: Dictionary, zone: String) -> Dictionary:
    var power := int(action.get("power", 1))
    if str(actor.get("posture", "none")) == "force_cost":
        power += 3
    var armor_factor := 0.55 if str(target.get("name", "")) == "Porte-Cendre" and zone in ["torso", "left_arm", "right_arm"] else 1.0
    var damage := maxi(1, int(round(float(power) * armor_factor * STATUS_RESOLVER.outgoing_factor(actor) * STATUS_RESOLVER.incoming_factor(target))))
    var severity := 3 if damage >= 13 else (2 if damage >= 8 else 1)
    return {
        "damage": damage,
        "severity": severity,
        "armor_factor": armor_factor,
    }

static func resolve_tactical_skill(actor: Dictionary, action: Dictionary, target: Dictionary, exposed: bool = false) -> Dictionary:
    var actor_stats: Dictionary = actor.get("stats", {})
    var effect: Dictionary = action.get("effect_spec", {})
    var multiplier := float(effect.get("damage_multiplier", 0.0))
    if multiplier <= 0.0:
        multiplier = 0.75 + float(maxi(1, int(action.get("skill_index", 1))) - 1) / 28.0
    var attack_power := float(actor.get("weapon_power", 25)) * multiplier * (0.70 + float(actor_stats.get("FOR", 50)) / 200.0)
    var armor := float(target.get("armor", 0)) + float(target.get("guard_bonus", 0)) + float(target.get("equipment_guard_power", 0))
    if exposed:
        armor *= 0.80
    var reduction := armor / (armor + 100.0)
    var physical_resistance := clampf(float(target.get("physical_resistance", 0)), 0.0, 80.0) / 100.0
    var damage := maxi(1, int(round(attack_power * (1.0 - reduction) * (1.0 - physical_resistance))))
    return {"damage":damage,"attack_power":attack_power,"effective_armor":armor,"reduction":reduction,"physical_resistance":physical_resistance}


## Canonical enemy-role damage path. Preserves the legacy tactical enemy formula exactly.
static func resolve_enemy_role(actor: Dictionary, target: Dictionary) -> Dictionary:
    var role := str(actor.get("combat_role", "assault"))
    var role_multiplier := 1.15 if role in ["brute", "execution"] else (0.92 if role == "ranged" else 1.0)
    var armor := float(target.get("armor", 0)) + float(target.get("guard_bonus", 0)) + float(target.get("equipment_guard_power", 0))
    var reduction := armor / (armor + 100.0)
    var physical_resistance := clampf(float(target.get("physical_resistance", 0)), 0.0, 80.0) / 100.0
    var damage := maxi(1, int(round(float(actor.get("weapon_power", 20)) * role_multiplier * (1.0 - reduction) * (1.0 - physical_resistance))))
    return {"damage":damage, "role_multiplier":role_multiplier, "effective_armor":armor, "reduction":reduction, "physical_resistance":physical_resistance}
