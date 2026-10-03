extends RefCounted
class_name VeilleursEncounterCompositionResolver

const ENEMIES_PATH := "res://data/veilleurs/v06/enemies_24_definitions.json"
const TREE_PATH := "res://data/veilleurs/v07/enemy_tree_catalog.json"
const THREAT_TOLERANCE := 0.75
const MAX_ENEMIES := 4

const TAG_PROFILES := {
    "frontline":["tank","impact","guard","brute","assault","duelist"],
    "flank":["mobility","hunter","execution","anatomy","adaptive"],
    "ranged":["ranged","observe","area","controller","terrain"],
    "pressure":["assault","impact","execution","psych","control","hunter","controller"],
    "surround":["mobility","hunter","adaptive"],
    "elevated":["ranged","observe","area","controller"],
    "control":["control","controller","pull","guard"],
    "choke":["tank","guard","control","impact","controller"],
    "rear_pressure":["ranged","hunter","mobility","psych","observe"],
    "ambush":["hunter","mobility","anatomy","execution"],
    "hazard_push":["impact","control","area","terrain","pull","controller"],
    "elite":["impact","anatomy","adaptive","execution","duelist","tank"],
    "ritual":["psych","support","risk","summon","adaptive"],
    "veteran":["duelist","guard","support","versatile","control","impact"],
    "small":["mobility","hunter","assault","drain","versatile"],
    "mobile":["mobility","hunter","adaptive","duelist"]
}

static func resolve_plan(plan: Dictionary) -> Dictionary:
    if not bool(plan.get("ok", false)) or bool(plan.get("fallback", false)):
        return plan.duplicate(true)
    var enemies_payload := _load_json(ENEMIES_PATH)
    var trees_payload := _load_json(TREE_PATH)
    var catalog := _catalog(enemies_payload, trees_payload)
    var result := plan.duplicate(true)
    var errors: Array[String] = []
    var resolved_count := 0
    for node in result.get("nodes", []):
        var encounter: Dictionary = node.get("encounter", {})
        if encounter.is_empty() or float(encounter.get("threat", 0.0)) <= 0.0:
            continue
        if bool(encounter.get("fixed_boss", false)):
            encounter["composition_status"] = "authored_boss"
            continue
        var resolved := resolve_encounter(encounter, catalog)
        if not bool(resolved.get("ok", false)):
            errors.append("%s:%s" % [str(node.get("id", "")), str(resolved.get("reason", "unresolved"))])
            continue
        encounter["composition"] = resolved["composition"]
        encounter["composition_threat"] = resolved["threat"]
        encounter["composition_profiles"] = resolved["profiles"]
        encounter["composition_status"] = "resolved"
        resolved_count += 1
    var report := {"version":1, "ok":errors.is_empty(), "errors":errors, "resolved_count":resolved_count, "boss_policy":"authored_only", "spawn_status":"not_spawned"}
    result["composition_report"] = report
    var generation_report: Dictionary = result.get("generation_report", {}).duplicate(true)
    generation_report["compositions"] = report.duplicate(true)
    result["generation_report"] = generation_report
    result["ok"] = errors.is_empty()
    return result

static func resolve_encounter(encounter: Dictionary, catalog: Array) -> Dictionary:
    var count := int(encounter.get("enemy_count", 0))
    var target := float(encounter.get("threat", 0.0))
    if count < 1 or count > MAX_ENEMIES:
        return {"ok":false, "reason":"invalid_enemy_count"}
    var tags: Array = encounter.get("formation_tags", [])
    var candidates: Array = []
    _enumerate(catalog, count, 0, [], 0.0, target, tags, candidates)
    if candidates.is_empty():
        return {"ok":false, "reason":"no_valid_composition"}
    candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
        if float(a["score"]) != float(b["score"]):
            return float(a["score"]) < float(b["score"])
        return str(a["signature"]) < str(b["signature"])
    )
    var best_score := float(candidates[0]["score"])
    var best: Array = []
    for candidate in candidates:
        if absf(float(candidate["score"]) - best_score) > 0.0001:
            break
        best.append(candidate)
    var rng := RandomNumberGenerator.new()
    rng.seed = ("%d|composition|%s" % [int(encounter.get("seed", 0)), str(encounter.get("id", ""))]).hash()
    var chosen: Dictionary = best[rng.randi_range(0, best.size() - 1)]
    var composition: Array = []
    for enemy in chosen["members"]:
        composition.append({"definition_id":str(enemy["entity_id"])})
    return {"ok":true, "composition":composition, "threat":chosen["threat"], "profiles":chosen["profiles"]}

static func validate_plan(plan: Dictionary) -> Dictionary:
    var errors: Array[String] = []
    var valid_ids := {}
    for enemy in _load_json(ENEMIES_PATH).get("enemies", []):
        valid_ids[str(enemy.get("entity_id", ""))] = true
    for node in plan.get("nodes", []):
        var encounter: Dictionary = node.get("encounter", {})
        if encounter.is_empty() or float(encounter.get("threat", 0.0)) <= 0.0:
            continue
        if bool(encounter.get("fixed_boss", false)):
            if str(encounter.get("composition_status", "")) != "authored_boss":
                errors.append("boss_not_authored:" + str(node.get("id", "")))
            continue
        var composition: Array = encounter.get("composition", [])
        if str(encounter.get("composition_status", "")) != "resolved":
            errors.append("composition_not_resolved:" + str(node.get("id", "")))
        if composition.size() != int(encounter.get("enemy_count", -1)) or composition.size() > MAX_ENEMIES:
            errors.append("composition_count:" + str(node.get("id", "")))
        for member in composition:
            if not valid_ids.has(str(member.get("definition_id", ""))):
                errors.append("composition_unknown_enemy:" + str(node.get("id", "")))
        if absf(float(encounter.get("composition_threat", -999.0)) - float(encounter.get("threat", 0.0))) > THREAT_TOLERANCE:
            errors.append("composition_threat:" + str(node.get("id", "")))
    return {"ok":errors.is_empty(), "errors":errors}

static func _enumerate(catalog: Array, remaining: int, start: int, members: Array, threat: float, target: float, tags: Array, out: Array) -> void:
    if remaining == 0:
        if absf(threat - target) > THREAT_TOLERANCE:
            return
        var profiles := _profiles_for_members(members)
        if not _covers(tags, profiles):
            return
        var ids: Array[String] = []
        for member in members:
            ids.append(str(member["entity_id"]))
        out.append({"members":members.duplicate(), "threat":threat, "profiles":profiles, "score":absf(threat-target), "signature":"|".join(ids)})
        return
    for index in range(start, catalog.size()):
        var enemy: Dictionary = catalog[index]
        var next_threat := threat + float(enemy.get("threat_value", 0.0))
        if next_threat > target + THREAT_TOLERANCE:
            continue
        var next := members.duplicate()
        next.append(enemy)
        _enumerate(catalog, remaining - 1, index, next, next_threat, target, tags, out)

static func _catalog(enemies_payload: Dictionary, trees_payload: Dictionary) -> Array:
    var profiles := {}
    for tree in trees_payload.get("trees", []):
        var entity_id := str(tree.get("entity_id", ""))
        if not profiles.has(entity_id):
            profiles[entity_id] = []
        var profile := str(tree.get("profile", ""))
        if profile != "" and profile not in profiles[entity_id]:
            profiles[entity_id].append(profile)
    var result: Array = []
    for value in enemies_payload.get("enemies", []):
        var enemy: Dictionary = value.duplicate(true)
        var entity_id := str(enemy.get("entity_id", ""))
        enemy["profiles"] = (profiles.get(entity_id, []) as Array).duplicate()
        var role := str(enemy.get("combat_role", ""))
        if role != "" and role not in enemy["profiles"]:
            enemy["profiles"].append(role)
        result.append(enemy)
    result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return str(a["entity_id"]) < str(b["entity_id"]))
    return result

static func _profiles_for_members(members: Array) -> Array[String]:
    var result: Array[String] = []
    for member in members:
        for profile in member.get("profiles", []):
            var value := str(profile)
            if value != "" and value not in result:
                result.append(value)
    result.sort()
    return result

static func _covers(tags: Array, profiles: Array[String]) -> bool:
    for tag_value in tags:
        var tag := str(tag_value)
        var accepted: Array = TAG_PROFILES.get(tag, [])
        if accepted.is_empty():
            continue
        var matched := false
        for profile in accepted:
            if str(profile) in profiles:
                matched = true
                break
        if not matched:
            return false
    return true

static func _load_json(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        return {}
    var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
    return parsed as Dictionary if parsed is Dictionary else {}
