extends RefCounted
class_name VeilleursHitResolver

const STATUS_RESOLVER := preload("res://scripts/core/combat/veilleurs_status_resolver.gd")

## Pure deterministic hit resolution for Les Veilleurs combat.
## Keeps the sandbox's existing roll contract while removing hit math from the orchestrator.

static func resolve(actor: Dictionary, action: Dictionary, target: Dictionary, zone: String, round_number: int) -> Dictionary:
    var accuracy := int(action.get("accuracy", 75)) + int(actor.get("coordination_bonus", 0)) - STATUS_RESOLVER.accuracy_penalty(actor)
    if str(actor.get("posture", "none")) == "precision":
        accuracy += 6
    var roll := stable_roll(str(actor.get("id", "")) + str(target.get("id", "")) + str(action.get("id", "")) + zone + str(round_number))
    return {
        "hit": roll < clampi(accuracy, 5, 97),
        "roll": roll,
        "accuracy": accuracy,
        "zone": zone,
    }

static func resolve_tactical(actor: Dictionary, action: Dictionary, target: Dictionary, zone: String, zone_accuracy_mod: Dictionary, clamp_rules: Dictionary, accuracy_bonus: int = 0, evasive_bonus: int = 0, exposed: bool = false, forced_roll: int = -1, roll_seed: String = "") -> Dictionary:
    var actor_stats: Dictionary = actor.get("stats", {})
    var target_stats: Dictionary = target.get("stats", {})
    var accuracy := 75.0
    accuracy += (float(actor_stats.get("PRE", 50)) - float(target_stats.get("MOB", 50))) * 0.45
    accuracy += float(action.get("precision_mod", 0))
    accuracy += float(zone_accuracy_mod.get(zone, 0))
    accuracy += float(accuracy_bonus)
    accuracy -= float(evasive_bonus)
    if exposed:
        accuracy += 8.0
    var min_percent := int(clamp_rules.get("min_percent", 10))
    var max_percent := int(clamp_rules.get("max_percent", 97))
    var chance := clampi(int(round(accuracy)), min_percent, max_percent)
    var roll := forced_roll if forced_roll >= 1 else tactical_roll(roll_seed)
    return {"hit":roll <= chance,"roll":roll,"accuracy":chance,"zone":zone}

static func tactical_roll(seed_text: String) -> int:
    return posmod(seed_text.hash(), 100) + 1

static func stable_roll(seed_text: String) -> int:
    return absi(hash(seed_text)) % 100
