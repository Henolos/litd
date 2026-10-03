extends RefCounted
class_name FirstAccordEncounterPlanner

const SEEDS := preload("res://scripts/world/dungeon_run_seed.gd")

# Planning only: enemy composition and physical spawning remain downstream.
# Called after scar projection; never rewrites topology or nemesis assignments.
static func populate(plan: Dictionary, catalog: Dictionary, library: Dictionary, context: Dictionary = {}) -> Dictionary:
    var result := plan.duplicate(true)
    var rules: Dictionary = catalog.get("director_rules", {})
    var modules := {}
    for module in library.get("modules", []):
        modules[str(module.get("module_id", ""))] = module
    var errors: Array[String] = []
    var critical_count := 0
    var selected_count := 0
    var relieved := float(context.get("injury_pressure", 0.0)) >= float(rules.get("injury_pressure_relief_threshold", 0.65)) or float(context.get("supplies_ratio", 1.0)) <= float(rules.get("low_supplies_relief_threshold", 0.30))
    for node in result.get("nodes", []):
        node["encounter_plan"] = {}
        var module: Dictionary = modules.get(str(node.get("module_id", "")), {})
        var anchors: Array = module.get("encounter_anchors", [])
        var role := str(node.get("role", ""))
        if role == "boss":
            var boss: Dictionary = catalog.get("boss", {})
            if anchors.is_empty() or int(anchors[0].get("capacity", 0)) < 1 or str(boss.get("encounter_id", "")) == "" or str(module.get("pool", "")) != str(boss.get("room_pool", "")):
                errors.append("boss_encounter_unresolved")
                continue
            node["encounter_plan"] = {"id": boss["encounter_id"], "threat": boss.get("threat", 0), "anchor_id": anchors[0].get("anchor_id", ""), "capacity_limit": anchors[0].get("capacity", 0), "authored": true, "composition_pending": true}
            selected_count += 1
            continue
        if anchors.is_empty() or role in ["entry", "rest", "secret"]:
            continue
        var max_threat := _max_threat(catalog, int(node.get("depth", 0)))
        var candidates: Array = []
        for candidate in catalog.get("room_tables", {}).get(str(node.get("module_pool", "")), []):
            if str(candidate.get("id", "")) == "" or float(candidate.get("weight", 1.0)) <= 0.0 or int(candidate.get("threat", 0)) < 0 or (bool(node.get("critical", false)) and int(candidate.get("threat", 0)) == 0) or int(candidate.get("threat", 0)) > max_threat:
                continue
            var anchor := _compatible_anchor(candidate, anchors)
            if anchor.is_empty():
                continue
            var copy: Dictionary = candidate.duplicate(true)
            copy["anchor_id"] = anchor.get("anchor_id", "")
            copy["capacity_limit"] = anchor.get("capacity", 0)
            copy["composition_pending"] = int(candidate.get("threat", 0)) > 0 and not candidate.has("enemy_count")
            candidates.append(copy)
        if relieved and not candidates.is_empty():
            var lowest := max_threat
            for candidate in candidates:
                lowest = mini(lowest, int(candidate["threat"]))
            candidates = candidates.filter(func(candidate: Dictionary) -> bool: return int(candidate["threat"]) == lowest)
        var rng := SEEDS.generator(int(result.get("seed", 0)), "encounter", str(node.get("id", "")))
        var critical := bool(node.get("critical", false))
        if not critical and rng.randf() >= clampf(float(rules.get("optional_encounter_chance", 0.65)), 0.0, 1.0):
            continue
        var selected := _pick(candidates, rng)
        if selected.is_empty():
            continue
        node["encounter_plan"] = selected
        if int(selected.get("threat", 0)) > 0:
            selected_count += 1
        if critical:
            critical_count += 1
    if critical_count < int(rules.get("critical_path_min_encounters", 4)) or critical_count > int(rules.get("critical_path_max_encounters", 7)):
        errors.append("critical_encounter_count:%d" % critical_count)
    result["encounter_report"] = {"version": 1, "ok": errors.is_empty(), "errors": errors, "critical_nonboss_count": critical_count, "selected_count": selected_count, "relief_active": relieved, "physical_spawn_pending": true}
    return result

static func _compatible_anchor(candidate: Dictionary, anchors: Array) -> Dictionary:
    for anchor in anchors:
        var capacity := int(anchor.get("capacity", 0))
        if capacity <= 0 or int(candidate.get("enemy_count", 1)) > capacity or (candidate.has("enemy_count") and int(candidate["enemy_count"]) <= 0):
            continue
        # Every requested formation tag must be supported by the authored anchor.
        var compatible := true
        for tag in candidate.get("formation_tags", []):
            if tag not in anchor.get("formation_tags", []):
                compatible = false
                break
        if compatible:
            return anchor
    return {}

static func _max_threat(catalog: Dictionary, depth: int) -> int:
    for band in catalog.get("depth_bands", {}).values():
        var bounds: Array = band.get("depth", [])
        var budget: Array = band.get("budget", [])
        if bounds.size() == 2 and budget.size() == 2 and depth >= int(bounds[0]) and depth <= int(bounds[1]):
            return int(budget[1])
    return 0

static func _pick(candidates: Array, rng: RandomNumberGenerator) -> Dictionary:
    var total := 0.0
    for candidate in candidates:
        total += float(candidate.get("weight", 1.0))
    if total <= 0.0:
        return {}
    var roll := rng.randf() * total
    for candidate in candidates:
        roll -= float(candidate.get("weight", 1.0))
        if roll < 0.0:
            return candidate
    return candidates.back()
