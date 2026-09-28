extends RefCounted
class_name VeilleursAfflictionSynergyRuntime

const STATUS_RESOLVER := preload("res://scripts/core/combat/veilleurs_status_resolver.gd")

# Synergies never create a second damage/status engine. They only expose
# conditions already present on the target so canonical skills can consume them.
static func inspect(target: Dictionary) -> Dictionary:
    var afflictions: Dictionary = target.get("afflictions", {})
    var anatomy: Dictionary = target.get("anatomy", {})
    var lesion := _has_lesion(anatomy) or str(target.get("bleeding_state", "none")) not in ["", "none"]
    var bleed := STATUS_RESOLVER.has(target, "bleed")
    var vulnerability := STATUS_RESOLVER.has(target, "vulnerability")
    var weakness := STATUS_RESOLVER.has(target, "weakness")
    var controls: Array[String] = []
    for kind in ["stun", "silence", "snare", "blind"]:
        if STATUS_RESOLVER.has(target, kind):
            controls.append(kind)
    return {
        "open_wound_team": bleed and lesion,
        "breaker_execution_window": vulnerability and weakness,
        "control_window": not controls.is_empty(),
        "active_controls": controls,
        "lesion": lesion,
        "bleed": bleed
    }

static func decorate_action(actor: Dictionary, target: Dictionary, action: Dictionary) -> Dictionary:
    var result := action.duplicate(true)
    var state := inspect(target)
    var tags: Array = result.get("canonical_tags", result.get("tags", []))
    var skill_id := str(result.get("id", ""))
    var hero_name := str(actor.get("name", actor.get("id", "")))

    # Existing wound/lesion mechanics are shared between Mathilde and Aurélien.
    if bool(state.get("open_wound_team", false)) and hero_name in ["Mathilde", "Aurélien", "aurelien", "mathilde"]:
        if _has_any_tag(tags, ["SAIGNEMENT", "MEMBRE_BLESSÉ", "LÉSION", "HÉMORRAGIE", "VASCULAIRE"]):
            result["synergy_open_wound"] = true

    # Marec's vulnerability+weakness window is consumable by precision/lesion skills.
    if bool(state.get("breaker_execution_window", false)) and hero_name in ["Mathilde", "Aurélien", "mathilde", "aurelien"]:
        if _has_any_tag(tags, ["PRÉCISION", "LÉSION", "EXPOSÉ", "MEMBRE_BLESSÉ", "TENDON", "VASCULAIRE"]):
            result["synergy_breaker_window"] = true
            # Accuracy only: vulnerability already owns the damage multiplier.
            result["accuracy"] = mini(100, int(result.get("accuracy", result.get("base_accuracy_pct", 75))) + 10)

    # Control effects remain distinct. This marker is informational for UI/AI.
    if bool(state.get("control_window", false)):
        result["synergy_control_window"] = true
        result["active_controls"] = state.get("active_controls", [])

    result["synergy_skill_id"] = skill_id
    return result

static func result_receipt(target: Dictionary, action: Dictionary) -> Dictionary:
    var state := inspect(target)
    return {
        "open_wound_team": bool(action.get("synergy_open_wound", false)),
        "breaker_execution_window": bool(action.get("synergy_breaker_window", false)),
        "control_window": bool(action.get("synergy_control_window", false)),
        "active_controls": state.get("active_controls", [])
    }

static func _has_lesion(anatomy: Dictionary) -> bool:
    for value in anatomy.values():
        if value is Dictionary:
            var zone: Dictionary = value
            if str(zone.get("state", "healthy")) not in ["", "healthy", "intact", "normal"]:
                return true
            if str(zone.get("function", "functional")) not in ["", "functional"]:
                return true
    return false

static func _has_any_tag(tags: Array, expected: Array[String]) -> bool:
    for value in tags:
        if str(value) in expected:
            return true
    return false
