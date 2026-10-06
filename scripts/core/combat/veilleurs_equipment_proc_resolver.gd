extends RefCounted
class_name VeilleursEquipmentProcResolver

const STATUS_RESOLVER := preload("res://scripts/core/combat/veilleurs_status_resolver.gd")
const HIT_RESOLVER := preload("res://scripts/core/combat/veilleurs_hit_resolver.gd")

# Equipment only requests canonical afflictions. Duration, resistance and
# recovery immunity remain owned by VeilleursStatusResolver.
const STATUS_PROCS := {
    "bleed_chance":{"affliction":"bleed","turns":2},
    "stun_chance":{"affliction":"stun","turns":1}
}

static func resolve_after_hit(attacker: Dictionary, target: Dictionary, seed_text: String) -> Dictionary:
    var result_target := target.duplicate(true)
    var bonuses: Dictionary = attacker.get("equipment_bonuses", {})
    var events: Array[Dictionary] = []
    if int(result_target.get("hp", 0)) <= 0 or bonuses.is_empty():
        return {"target":result_target, "events":events}
    for stat_value: Variant in STATUS_PROCS.keys():
        var stat := str(stat_value)
        var chance := clampi(int(bonuses.get(stat, 0)), 0, 100)
        if chance <= 0:
            continue
        var rule: Dictionary = STATUS_PROCS[stat]
        var kind := str(rule.get("affliction", ""))
        var roll := HIT_RESOLVER.tactical_roll(seed_text + "|equipment|" + stat)
        var event := {"stat":stat, "affliction":kind, "chance":chance, "roll":roll, "applied":false}
        if roll > chance:
            events.append(event)
            continue
        var applied: Dictionary = STATUS_RESOLVER.apply_affliction(result_target, kind, int(rule.get("turns", 1)))
        if bool(applied.get("ok", false)):
            result_target["afflictions"] = applied.get("afflictions", {})
            event["applied"] = not bool(applied.get("resisted", false))
            event["turns"] = int(applied.get("turns", 0))
            event["resisted"] = bool(applied.get("resisted", false))
            event["immune"] = bool(applied.get("immune", false))
        else:
            event["reason"] = str(applied.get("reason", "apply_failed"))
        events.append(event)
    return {"target":result_target, "events":events}
