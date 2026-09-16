extends RefCounted
class_name VeilleursHitResolver

## Pure deterministic hit resolution for Les Veilleurs combat.
## Keeps the sandbox's existing roll contract while removing hit math from the orchestrator.

static func resolve(actor: Dictionary, action: Dictionary, target: Dictionary, zone: String, round_number: int) -> Dictionary:
    var accuracy := int(action.get("accuracy", 75)) + int(actor.get("coordination_bonus", 0))
    if str(actor.get("posture", "none")) == "precision":
        accuracy += 6
    var roll := stable_roll(str(actor.get("id", "")) + str(target.get("id", "")) + str(action.get("id", "")) + zone + str(round_number))
    return {
        "hit": roll < clampi(accuracy, 5, 97),
        "roll": roll,
        "accuracy": accuracy,
        "zone": zone,
    }

static func stable_roll(seed_text: String) -> int:
    var hash_value := 2166136261
    for byte in seed_text.to_utf8_buffer():
        hash_value = int((hash_value ^ int(byte)) * 16777619) & 0x7fffffff
    return int(hash_value % 100)
