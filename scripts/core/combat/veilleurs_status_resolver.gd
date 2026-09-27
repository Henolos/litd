extends RefCounted
class_name VeilleursStatusResolver

# One status store for both sides. Durations count the affected actor's turns.
const AFFLICTIONS := ["poison", "burn", "bleed", "freeze", "stun", "blind", "silence", "weakness", "vulnerability", "snare"]
const PERIODIC_DAMAGE := {"poison": 3, "burn": 4, "bleed": 2}

# Signed percentages by affliction and facet: positive resists, negative amplifies.
# Example: {"burn": {"damage": 50, "duration": -50}}.
static func resistance(actor: Dictionary, kind: String, facet: String) -> int:
    var all_resistances: Dictionary = actor.get("affliction_resistances", {})
    var entry: Dictionary = all_resistances.get(kind, {})
    return clampi(int(entry.get(facet, 0)), -100, 100)

static func apply_affliction(target: Dictionary, kind: String, turns: int) -> Dictionary:
    if kind not in AFFLICTIONS or turns <= 0:
        return {"ok": false, "reason": "invalid_affliction"}
    var statuses: Dictionary = (target.get("afflictions", {}) as Dictionary).duplicate(true)
    var adjusted_turns := maxi(0, int(round(float(turns) * (1.0 - float(resistance(target, kind, "duration")) / 100.0))))
    if adjusted_turns > 0:
        statuses[kind] = maxi(int(statuses.get(kind, 0)), adjusted_turns)
    return {"ok": true, "afflictions": statuses, "kind": kind, "turns": int(statuses.get(kind, 0)), "resisted": adjusted_turns == 0}

static func has(actor: Dictionary, kind: String) -> bool:
    return int((actor.get("afflictions", {}) as Dictionary).get(kind, 0)) > 0

static func action_block(actor: Dictionary, action: Dictionary) -> String:
    if has(actor, "stun"):
        return "stunned"
    if has(actor, "silence") and (int(action.get("trame_cost", 0)) > 0 or str(action.get("effect", "")).begins_with("trame_")):
        return "silenced"
    return ""

static func movement_block(actor: Dictionary) -> bool:
    return has(actor, "freeze") or has(actor, "snare") or has(actor, "stun")

static func accuracy_penalty(actor: Dictionary) -> int:
    return (25 if has(actor, "blind") else 0) + (15 if has(actor, "freeze") else 0)

static func outgoing_factor(actor: Dictionary) -> float:
    return 0.75 if has(actor, "weakness") else 1.0

static func incoming_factor(actor: Dictionary) -> float:
    return 1.25 if has(actor, "vulnerability") else 1.0

static func start_turn(actor: Dictionary) -> Dictionary:
    var statuses: Dictionary = (actor.get("afflictions", {}) as Dictionary).duplicate(true)
    var damage := 0
    for kind: String in AFFLICTIONS:
        var remaining := int(statuses.get(kind, 0))
        if remaining <= 0:
            continue
        var base_damage := int(PERIODIC_DAMAGE.get(kind, 0))
        damage += maxi(0, int(round(float(base_damage) * (1.0 - float(resistance(actor, kind, "damage")) / 100.0))))
        # The effect remains active for this turn, even when its last turn starts.
    return {"damage": mini(maxi(0, int(actor.get("hp", 0))), damage), "afflictions": statuses}

static func finish_turn(actor: Dictionary) -> Dictionary:
    var statuses: Dictionary = (actor.get("afflictions", {}) as Dictionary).duplicate(true)
    for kind: String in AFFLICTIONS:
        if int(statuses.get(kind, 0)) > 0:
            statuses[kind] = int(statuses[kind]) - 1
            if int(statuses[kind]) == 0:
                statuses.erase(kind)
    return statuses

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
