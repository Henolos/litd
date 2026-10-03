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
    var tree := str(result.get("tree", ""))
    var build_role := str(result.get("build_role", ""))

    # Existing wound/lesion mechanics are shared between Mathilde and Aurélien.
    # A prepared wound improves reliability only; it never adds a free damage multiplier.
    if bool(state.get("open_wound_team", false)) and hero_name in ["Mathilde", "Aurélien", "aurelien", "mathilde"]:
        if _has_any_tag(tags, ["SAIGNEMENT", "MEMBRE_BLESSÉ", "LÉSION", "HÉMORRAGIE", "VASCULAIRE"]):
            result["synergy_open_wound"] = true
            result["accuracy"] = mini(100, int(result.get("accuracy", result.get("base_accuracy_pct", 75))) + 5)

    # Marec's vulnerability+weakness window is consumable by precision/lesion skills.
    if bool(state.get("breaker_execution_window", false)) and hero_name in ["Mathilde", "Aurélien", "mathilde", "aurelien"]:
        if _has_any_tag(tags, ["PRÉCISION", "LÉSION", "EXPOSÉ", "MEMBRE_BLESSÉ", "TENDON", "VASCULAIRE"]):
            result["synergy_breaker_window"] = true
            # Accuracy only: vulnerability already owns the damage multiplier.
            result["accuracy"] = mini(100, int(result.get("accuracy", result.get("base_accuracy_pct", 75))) + 10)

    # A controlled target creates a short tactical opportunity for skills that
    # explicitly exploit precision, exposure, interruption or compromised support.
    # Control identities stay distinct and are never converted into one another.
    if bool(state.get("control_window", false)):
        result["synergy_control_window"] = true
        result["active_controls"] = state.get("active_controls", [])
        if _has_any_tag(tags, ["PRÉCISION", "EXPOSÉ", "INTERROMPU", "TENDON", "MEMBRE_BLESSÉ"]):
            result["synergy_control_exploit"] = true
            result["accuracy"] = mini(100, int(result.get("accuracy", result.get("base_accuracy_pct", 75))) + 5)

    # Tree-local payoffs make afflictions part of a build loop rather than isolated buttons.
    # They improve reliability/functional exploitation only; canonical damage remains authoritative.
    if hero_name in ["Mathilde", "mathilde"] and tree == "Entaille" and bool(state.get("bleed", false)):
        if skill_id in ["MA-ENT-05", "MA-ENT-09", "MA-ENT-14"] or _has_any_tag(tags, ["TENDON", "MEMBRE_BLESSÉ"]):
            result["synergy_tree_payoff"] = "mathilde_hemorrhage"
            result["accuracy"] = mini(100, int(result.get("accuracy", result.get("base_accuracy_pct", 75))) + 5)

    if hero_name in ["Marec", "marec"] and tree == "Brisure":
        if bool(state.get("control_window", false)) or vulnerability or weakness:
            if skill_id in ["MR-BRI-06", "MR-BRI-12", "MR-BRI-14"]:
                result["synergy_tree_payoff"] = "marec_breaker"
                result["accuracy"] = mini(100, int(result.get("accuracy", result.get("base_accuracy_pct", 75))) + 5)

    if hero_name in ["Anouk", "anouk"] and tree == "Dissidence" and STATUS_RESOLVER.has(target, "silence"):
        if skill_id in ["AN-DIS-08", "AN-DIS-12", "AN-DIS-14"]:
            result["synergy_tree_payoff"] = "anouk_disruptor"
            result["accuracy"] = mini(100, int(result.get("accuracy", result.get("base_accuracy_pct", 75))) + 5)

    if hero_name in ["Aurélien", "aurelien"] and tree in ["Anatomie", "Hémocorde"]:
        if STATUS_RESOLVER.has(target, "snare") and skill_id in ["AU-ANA-09", "AU-ANA-14"]:
            result["synergy_tree_payoff"] = "aurelien_anatomical_control"
            result["accuracy"] = mini(100, int(result.get("accuracy", result.get("base_accuracy_pct", 75))) + 5)
        elif bool(state.get("bleed", false)) and skill_id in ["AÏ-HÉM-05", "AÏ-HÉM-09", "AÏ-HÉM-12", "AÏ-HÉM-14"]:
            result["synergy_tree_payoff"] = "aurelien_hemocorde"
            result["accuracy"] = mini(100, int(result.get("accuracy", result.get("base_accuracy_pct", 75))) + 5)

    result["synergy_skill_id"] = skill_id
    return result

static func result_receipt(target: Dictionary, action: Dictionary) -> Dictionary:
    var state := inspect(target)
    return {
        "open_wound_team": bool(action.get("synergy_open_wound", false)),
        "breaker_execution_window": bool(action.get("synergy_breaker_window", false)),
        "control_window": bool(action.get("synergy_control_window", false)),
        "control_exploit": bool(action.get("synergy_control_exploit", false)),
        "active_controls": state.get("active_controls", []),
        "tree_payoff": str(action.get("synergy_tree_payoff", ""))
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
