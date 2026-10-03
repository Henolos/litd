extends RefCounted
class_name VeilleursEncounterDirector

const HYBRID_SCRIPT := preload("res://scripts/core/veilleurs_hybrid_generation_bridge.gd")
const RECENT_CAP := 6
const MAX_COMBAT_ENEMIES := 4

var hybrid: VeilleursHybridGenerationBridge
var recent_templates: Array[String] = []
var resolved_templates: Dictionary = {}

func _init() -> void:
    hybrid = HYBRID_SCRIPT.new() as VeilleursHybridGenerationBridge

func next_encounter(family: String, band: String, variant: int, seed_value: int) -> Dictionary:
    var selected: Dictionary = {}
    for offset in range(12):
        var candidate := hybrid.generate_encounter(family, band, variant, seed_value + offset * 7919)
        if candidate.is_empty():
            continue
        var template_id := str(candidate.get("template_id", ""))
        if not recent_templates.has(template_id) or offset >= 8:
            selected = candidate
            break
    if selected.is_empty():
        selected = hybrid.generate_encounter(family, band, variant, seed_value)
    if not selected.is_empty():
        _remember(str(selected.get("template_id", "")))
    return selected

func resolve_encounter(encounter: Dictionary, outcome: String, anchor_id: String, context: Dictionary = {}) -> Dictionary:
    var template_id := str(encounter.get("template_id", ""))
    if template_id == "":
        return {"ok":false, "reason":"missing_template"}
    resolved_templates[template_id] = int(resolved_templates.get(template_id, 0)) + 1
    var result := {"ok":true, "template_id":template_id, "outcome":outcome, "times_resolved":int(resolved_templates[template_id])}
    if outcome in ["retreat", "defeat", "victory_with_mutilation"]:
        var scar_context := context.duplicate(true)
        scar_context["summary"] = str(context.get("summary", "Rencontre %s : %s" % [template_id, outcome]))
        scar_context["protected"] = bool(context.get("protected", false))
        var severity := "major" if outcome in ["defeat", "victory_with_mutilation"] else "trace"
        result["scar_id"] = RemanenceRuntime.create_world_scar(anchor_id, "encounter_%s" % outcome, severity, scar_context)
    return result

func serialize() -> Dictionary:
    return {"recent_templates":recent_templates.duplicate(), "resolved_templates":resolved_templates.duplicate(true)}

func deserialize(payload: Dictionary) -> void:
    recent_templates.clear()
    for value: Variant in payload.get("recent_templates", []):
        recent_templates.append(str(value))
    while recent_templates.size() > RECENT_CAP:
        recent_templates.remove_at(0)
    resolved_templates = (payload.get("resolved_templates", {}) as Dictionary).duplicate(true)

func _remember(template_id: String) -> void:
    if template_id == "":
        return
    recent_templates.erase(template_id)
    recent_templates.append(template_id)
    while recent_templates.size() > RECENT_CAP:
        recent_templates.remove_at(0)

# Pure planning stage for the existing hybrid dungeon pipeline. It reserves
# authored encounter definitions/slots; it does not spawn actors or resolve combat.
static func populate_dungeon_plan(plan: Dictionary, library: Dictionary, tables: Dictionary, context: Dictionary = {}) -> Dictionary:
    if not bool(plan.get("ok", false)) or bool(plan.get("fallback", false)):
        return plan.duplicate(true)
    var result := plan.duplicate(true)
    var rules: Dictionary = tables.get("director_rules", {})
    var modules := {}
    for module in library.get("modules", []):
        modules[str(module.get("module_id", ""))] = module
    var errors: Array[String] = []
    var decisions: Array = []
    var critical_count := 0
    var optional_count := 0
    var boss_selected := false
    var ordered_nodes: Array = result.get("nodes", []).duplicate()
    ordered_nodes.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return str(a.get("id", "")) < str(b.get("id", "")))
    for node in ordered_nodes:
        node.erase("encounter") # Regeneration must never retain stale selections.
        var room_id := str(node.get("id", ""))
        var role := str(node.get("role", ""))
        var decision := {"room_id": room_id, "selected_id": "", "rejected": [], "eligible_ids": [], "reason": ""}
        var module: Dictionary = modules.get(str(node.get("module_id", "")), {})
        if module.is_empty():
            errors.append("encounter_module_missing:%s" % room_id)
            decision["reason"] = "module_missing"
            decisions.append(decision)
            continue
        if role in ["entry", "rest", "secret", "exit"]:
            decision["reason"] = "protected_safe_role"
            decisions.append(decision)
            continue
        if not node.has("encounter_seed"):
            errors.append("encounter_seed_missing:%s" % room_id)
        var fixed_boss := room_id == str(plan.get("objective_id", "")) and role == "boss"
        var candidates: Array = []
        if fixed_boss:
            var boss: Dictionary = tables.get("boss", {}).duplicate(true)
            boss["id"] = str(boss.get("encounter_id", ""))
            boss["weight"] = 1.0
            candidates.append(boss)
            if str(boss.get("room_pool", "")) != str(node.get("module_pool", "")):
                errors.append("boss_pool_mismatch:%s" % room_id)
        else:
            candidates = tables.get("room_tables", {}).get(str(node.get("module_pool", "")), []).duplicate(true)
        candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return str(a.get("id", "")) < str(b.get("id", "")))
        var budget := _room_budget(int(node.get("depth", 0)), tables)
        if budget.is_empty() and not fixed_boss:
            errors.append("encounter_depth_band_missing:%s" % room_id)
            decision["reason"] = "missing_depth_band"
            decisions.append(decision)
            continue
        var eligible: Array = []
        var known_ids := {}
        for candidate in candidates:
            var candidate_id := str(candidate.get("id", ""))
            if known_ids.has(candidate_id):
                errors.append("duplicate_encounter_id:%s:%s" % [room_id, candidate_id])
                continue
            known_ids[candidate_id] = true
            var rejection := _encounter_rejection(candidate, budget, context, fixed_boss)
            var anchor := _compatible_anchor(module.get("encounter_anchors", []), candidate)
            if rejection == "" and float(candidate.get("threat", 0)) > 0.0 and anchor.is_empty():
                rejection = "room_capacity_or_formation"
            if rejection != "":
                decision["rejected"].append({"id": candidate_id, "reason": rejection})
                continue
            candidate["anchor_id"] = str(anchor.get("anchor_id", ""))
            candidate["capacity"] = int(anchor.get("capacity", 0))
            eligible.append(candidate)
        eligible.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return str(a.get("id", "")) < str(b.get("id", "")))
        for candidate in eligible:
            decision["eligible_ids"].append(str(candidate.get("id", "")))
        var critical := bool(node.get("critical", false)) or fixed_boss
        if not critical and _optional_pressure_relief(context, rules):
            decision["reason"] = "optional_pressure_relief"
        elif not critical and _room_roll(node, "presence") >= clampf(float(rules.get("optional_encounter_chance", 0.65)), 0.0, 1.0):
            decision["reason"] = "optional_chance"
        elif eligible.is_empty():
            decision["reason"] = "no_eligible_encounter"
            if fixed_boss or (critical and not candidates.is_empty()):
                errors.append("required_encounter_unresolved:%s" % room_id)
        else:
            var selected := _pick_room_encounter(eligible, node)
            selected["seed"] = int(node.get("encounter_seed", 0))
            selected["budget"] = budget.duplicate()
            selected["fixed_boss"] = fixed_boss
            selected["materialization_status"] = "definition_only"
            node["encounter"] = selected
            decision["selected_id"] = str(selected.get("id", ""))
            decision["reason"] = "selected" if float(selected.get("threat", 0)) > 0.0 else "authored_empty"
            if fixed_boss and float(selected.get("threat", 0)) > 0.0:
                boss_selected = true
            if float(selected.get("threat", 0)) > 0.0:
                if critical:
                    critical_count += 1
                else:
                    optional_count += 1
        decisions.append(decision)
    if not boss_selected:
        errors.append("fixed_boss_unresolved")
    var minimum := int(rules.get("critical_path_min_encounters", 0))
    var maximum := int(rules.get("critical_path_max_encounters", 999))
    if critical_count < minimum or critical_count > maximum:
        errors.append("critical_encounter_count_out_of_bounds:%d" % critical_count)
    var report := {"version": 1, "ok": errors.is_empty(), "errors": errors, "critical_count": critical_count, "optional_count": optional_count, "boss_included_in_critical_count": true, "decisions": decisions, "materialization_status": "definition_only"}
    result["encounter_report"] = report
    var generation_report: Dictionary = result.get("generation_report", {}).duplicate(true)
    generation_report["encounters"] = report.duplicate(true)
    result["generation_report"] = generation_report
    result["ok"] = errors.is_empty()
    return result

static func _encounter_rejection(candidate: Dictionary, budget: Array, context: Dictionary, fixed_boss: bool) -> String:
    var threat := float(candidate.get("threat", -1))
    var weight := float(candidate.get("weight", 0))
    var count := int(candidate.get("enemy_count", -1))
    if str(candidate.get("id", "")) == "" or not is_finite(threat) or threat < 0.0 or count < 0 or (threat > 0.0 and count == 0) or (threat == 0.0 and count != 0):
        return "invalid_definition"
    if count > MAX_COMBAT_ENEMIES:
        return "combat_rank_capacity"
    if not is_finite(weight) or weight <= 0.0:
        return "disabled_weight"
    # The authored boss cannot be removed by optional pressure or blacklist rules.
    if not fixed_boss:
        if str(candidate.get("id", "")) in context.get("blocked_encounter_ids", []):
            return "blocked_by_context"
        if threat > 0.0 and (threat < float(budget[0]) or threat > float(budget[1])):
            return "outside_depth_budget"
    return ""

static func _compatible_anchor(anchors: Array, candidate: Dictionary) -> Dictionary:
    if float(candidate.get("threat", 0)) <= 0.0:
        return {}
    var ordered := anchors.duplicate(true)
    ordered.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return str(a.get("anchor_id", "")) < str(b.get("anchor_id", "")))
    for anchor in ordered:
        if int(anchor.get("capacity", 0)) < int(candidate.get("enemy_count", 0)):
            continue
        var supported := true
        for tag in candidate.get("required_formation_tags", []):
            if tag not in anchor.get("formation_tags", []):
                supported = false
                break
        if supported and str(anchor.get("anchor_id", "")) != "":
            return anchor
    return {}

static func _room_budget(depth: int, tables: Dictionary) -> Array:
    for band in tables.get("depth_bands", {}).values():
        var depths: Array = band.get("depth", [])
        var budget: Array = band.get("budget", [])
        if depths.size() != 2 or budget.size() != 2:
            continue
        if depth >= int(depths[0]) and depth <= int(depths[1]) and float(budget[0]) >= 0.0 and float(budget[1]) >= float(budget[0]):
            return budget
    return []

static func _optional_pressure_relief(context: Dictionary, rules: Dictionary) -> bool:
    return float(context.get("injury_pressure", 0.0)) >= float(rules.get("injury_pressure_relief_threshold", 0.65)) or float(context.get("supplies_ratio", 1.0)) <= float(rules.get("low_supplies_relief_threshold", 0.30))

static func _room_roll(node: Dictionary, purpose: String) -> float:
    var rng := RandomNumberGenerator.new()
    rng.seed = ("%d|%s" % [int(node.get("encounter_seed", 0)), purpose]).hash()
    return rng.randf()

static func _pick_room_encounter(candidates: Array, node: Dictionary) -> Dictionary:
    var total := 0.0
    for candidate in candidates:
        total += float(candidate.get("weight", 0))
    var roll := _room_roll(node, "selection") * total
    for candidate in candidates:
        roll -= float(candidate.get("weight", 0))
        if roll < 0.0:
            return candidate.duplicate(true)
    return candidates.back().duplicate(true)

# Validate the actual final selections, without rerolling or trusting reports.
static func validate_dungeon_plan(plan: Dictionary, library: Dictionary, tables: Dictionary, context: Dictionary = {}) -> Dictionary:
    var errors: Array[String] = []
    var critical_count := 0
    var boss_count := 0
    var modules := {}
    for module in library.get("modules", []):
        modules[str(module.get("module_id", ""))] = module
    for node in plan.get("nodes", []):
        var room_id := str(node.get("id", ""))
        var role := str(node.get("role", ""))
        var encounter: Dictionary = node.get("encounter", {})
        var boss := room_id == str(plan.get("objective_id", "")) and role == "boss"
        var candidates: Array = tables.get("room_tables", {}).get(str(node.get("module_pool", "")), [])
        if encounter.is_empty():
            if boss or (bool(node.get("critical", false)) and not candidates.is_empty() and role not in ["entry", "rest", "secret", "exit"]):
                errors.append("required_encounter_missing:" + room_id)
            continue
        if role in ["entry", "rest", "secret", "exit"]:
            errors.append("safe_room_has_encounter:" + room_id)
        var authored: Dictionary = {}
        if boss:
            authored = tables.get("boss", {}).duplicate(true)
            authored["id"] = authored.get("encounter_id", "")
            authored["weight"] = 1.0
        else:
            for candidate in candidates:
                if str(candidate.get("id", "")) == str(encounter.get("id", "")):
                    authored = candidate.duplicate(true)
                    break
        if authored.is_empty():
            errors.append("unknown_selected_encounter:" + room_id)
            continue
        for key in authored:
            if encounter.get(key) != authored[key]:
                errors.append("encounter_definition_changed:" + room_id + ":" + str(key))
        var budget := _room_budget(int(node.get("depth", 0)), tables)
        if not boss and budget.is_empty():
            errors.append("encounter_depth_band_missing:" + room_id)
            continue
        if _encounter_rejection(authored, budget, context, boss) != "":
            errors.append("invalid_selected_encounter:" + room_id)
        var module: Dictionary = modules.get(str(node.get("module_id", "")), {})
        var anchor := _compatible_anchor(module.get("encounter_anchors", []), authored)
        if float(authored.get("threat", 0)) > 0.0 and (anchor.is_empty() or str(encounter.get("anchor_id", "")) != str(anchor.get("anchor_id", "")) or int(encounter.get("capacity", 0)) != int(anchor.get("capacity", 0))):
            errors.append("invalid_encounter_anchor:" + room_id)
        if str(encounter.get("materialization_status", "")) != "definition_only" or bool(encounter.get("fixed_boss", false)) != boss or int(encounter.get("seed", 0)) != int(node.get("encounter_seed", 0)) or encounter.get("budget", []) != budget:
            errors.append("invalid_encounter_contract:" + room_id)
        if float(authored.get("threat", 0)) > 0.0:
            if bool(node.get("critical", false)) or boss:
                critical_count += 1
            if boss:
                boss_count += 1
    var rules: Dictionary = tables.get("director_rules", {})
    if critical_count < int(rules.get("critical_path_min_encounters", 0)) or critical_count > int(rules.get("critical_path_max_encounters", 999)):
        errors.append("critical_encounter_count_out_of_bounds")
    if boss_count != 1:
        errors.append("fixed_boss_unresolved")
    return {"ok":errors.is_empty(), "errors":errors}

# Materialize the already selected definition; never reroll a different template.
func materialize_selected(selected: Dictionary, db: Variant) -> Dictionary:
    var count := int(selected.get("enemy_count", -1))
    if count < 0 or count > MAX_COMBAT_ENEMIES or count > int(selected.get("capacity", 0)):
        return {"ok":false, "reason":"selected_encounter_capacity"}
    if bool(selected.get("fixed_boss", false)):
        var boss_id := str(selected.get("boss_id", ""))
        if db.boss(boss_id).is_empty() or count != 1:
            return {"ok":false, "reason":"selected_boss_missing"}
        return {"ok":true, "boss":true, "boss_id":boss_id, "template_id":str(selected.get("id", "")), "seed_salt":int(selected.get("seed", 0)), "procedural_selected":true}
    var ids: Array = selected.get("composition", [])
    if ids.size() != count:
        return {"ok":false, "reason":"selected_composition_count"}
    var composition: Array = []
    var actual_threat := 0.0
    for member in ids:
        var enemy_id := str(member.get("definition_id", ""))
        var definition: Dictionary = db.enemy(str(enemy_id))
        if definition.is_empty():
            return {"ok":false, "reason":"selected_enemy_missing", "entity_id":enemy_id}
        var threat := float(definition.get("threat_value", 0))
        actual_threat += threat
        composition.append({"definition_id":str(enemy_id), "threat":threat})
    return {"ok":true, "template_id":str(selected.get("id", "")), "composition":composition, "actual_threat":actual_threat, "target_threat":float(selected.get("threat", 0)), "objective":"survive", "seed_salt":int(selected.get("seed", 0)), "capacity":int(selected.get("capacity", 0)), "procedural_selected":true, "nemesis_allowed":bool(selected.get("memory_eligible", false))}
