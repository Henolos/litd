extends RefCounted
class_name FirstAccordHybridPlanner

const ROOM_RESOLVER := preload("res://scripts/world/dungeon_room_resolver.gd")
const GENERATOR_VERSION := 2

const RUN_SEED := preload("res://scripts/world/dungeon_run_seed.gd")

const CONFIG_PATH := "res://data/dungeons/first_accord_hybrid_config.json"
const MODULES_PATH := "res://data/dungeons/first_accord_module_library.json"
const ENCOUNTERS_PATH := "res://data/dungeons/first_accord_encounters.json"
const REMANENCE_PATH := "res://data/dungeons/first_accord_remanence_anchors.json"

static func build_plan(run_state: Dictionary = {}) -> Dictionary:
    var config := _load_json(CONFIG_PATH)
    var library := _load_json(MODULES_PATH)
    var encounters := _load_json(ENCOUNTERS_PATH)
    var remanence := _load_json(REMANENCE_PATH)
    if config.is_empty() or library.is_empty() or encounters.is_empty() or remanence.is_empty():
        return {"ok": false, "error": "first_accord_hybrid_data_missing"}

    var graph_config := config.duplicate(true)
    graph_config["mandatory_room_ids"] = config.get("protected_story_order", [])
    var generated := HybridDungeonGenerator.generate_graph(graph_config, run_state)
    if not bool(generated.get("ok", false)):
        return _fallback_plan(config, "generic_graph_generation_failed")

    var plan := _rebuild_protected_spine(generated, config)
    var critical_validation := HybridDungeonGenerator.validate_graph(plan, graph_config)
    if not bool(critical_validation.get("ok", false)):
        return _fallback_plan(config, "critical_path_validation_failed", critical_validation)
    plan["critical_path_validation"] = critical_validation
    _assign_modules(plan, config, library)
    _assign_variations(plan)
    _assign_encounter_tables(plan, encounters)
    plan["remenance_catalog"] = remanence

    var validation := validate_plan(plan, config, library)
    if not bool(validation.get("ok", false)):
        return _fallback_plan(config, "first_accord_validation_failed", validation)
    plan["ok"] = true
    plan["validation"] = validation
    plan["generation_report"] = _generation_report(plan, validation)
    plan["generation_report"]["run_state"] = run_state.duplicate(true)
    var revisions := {}
    for path in [CONFIG_PATH, MODULES_PATH, ENCOUNTERS_PATH, REMANENCE_PATH, HybridDungeonGenerator.RULES_PATH]:
        revisions[path] = FileAccess.get_file_as_string(path).sha256_text()
    plan["generation_report"]["data_revisions"] = revisions
    return plan

static func validate_plan(plan: Dictionary, config: Dictionary = {}, library: Dictionary = {}) -> Dictionary:
    if config.is_empty():
        config = _load_json(CONFIG_PATH)
    if library.is_empty():
        library = _load_json(MODULES_PATH)
    var errors: Array[String] = []
    var nodes: Array = plan.get("nodes", [])
    var edges: Array = plan.get("edges", [])
    var protected_order: Array = config.get("protected_story_order", [])

    for room_id in protected_order:
        if not _has_node(nodes, str(room_id)):
            errors.append("protected_room_missing:%s" % str(room_id))

    for i in range(protected_order.size() - 1):
        var from_id := str(protected_order[i])
        var to_id := str(protected_order[i + 1])
        if not _reachable(from_id, to_id, edges):
            errors.append("protected_story_order_broken:%s>%s" % [from_id, to_id])

    if not _reachable(str(protected_order.front()), str(protected_order.back()), edges):
        errors.append("boss_unreachable")

    errors.append_array(HybridDungeonGenerator.validate_protected_path(plan, protected_order))

    var graph_config := config.duplicate(true)
    graph_config["mandatory_room_ids"] = protected_order
    errors.append_array(HybridDungeonGenerator.validate_graph(plan, graph_config).get("errors", []))
    var module_ids := _module_ids(library)
    if module_ids.size() != library.get("modules", []).size():
        errors.append("duplicate_module_id")
    for node in nodes:
        var module_id := str(node.get("module_id", ""))
        if module_id == "" or not module_ids.has(module_id):
            errors.append("module_unresolved:%s" % str(node.get("id", "")))
        elif not ROOM_RESOLVER.compatible(module_ids[module_id], config):
            errors.append("incompatible_module:%s" % str(node.get("id", "")))
        elif str(module_ids[module_id].get("pool", "")) != _source_pool(config, str(node.get("module_pool", ""))):
            errors.append("module_pool_mismatch:%s" % str(node.get("id", "")))

    if _count_retreats(nodes) < int(config.get("retreat_policy", {}).get("minimum", 2)):
        errors.append("insufficient_retreats")

    if bool(config.get("retreat_policy", {}).get("deep_shortcut_required", false)):
        var deep_id := str(protected_order[protected_order.size() - 3])
        var has_deep_shortcut := false
        for edge in edges:
            if str(edge.get("kind", "")) == "retreat_shortcut" and str(edge.get("from", "")) == deep_id and str(edge.get("to", "")) == str(plan.get("entry_id", "")) and not bool(edge.get("hidden", false)) and str(edge.get("requires", "")) in ["", "unlock_from_deep_side"]:
                has_deep_shortcut = true
        if not has_deep_shortcut or not bool(_find_node(nodes, deep_id).get("retreat", false)):
            errors.append("deep_retreat_shortcut_missing")

    var boss_id := str(protected_order.back())
    var boss_node := _find_node(nodes, boss_id)
    if str(boss_node.get("module_id", "")) != str(config.get("protected_boss_module", "")):
        errors.append("boss_module_not_protected")

    return {"ok": errors.is_empty(), "errors": errors}

static func _rebuild_protected_spine(generated: Dictionary, config: Dictionary) -> Dictionary:
    var plan := generated.duplicate(true)
    var protected_order: Array = config.get("protected_story_order", [])
    var nodes: Array = []
    var edges: Array = []

    for i in protected_order.size():
        var room_id := str(protected_order[i])
        var mandatory := _mandatory_by_id(config, room_id)
        nodes.append({
            "id": room_id,
            "role": str(mandatory.get("role", "narrative")),
            "critical": true,
            "protected": true,
            "depth": int(mandatory.get("preferred_depth", i)),
            "module_pool": str(mandatory.get("module_pool", "")),
            "module_id": "",
            "retreat": i == 0,
            "scar_anchors": [],
            "variation_seed": 0
        })
        if i > 0:
            edges.append({"from":str(protected_order[i - 1]),"to":room_id,"kind":"critical","hidden":false,"requires":""})

    for node in generated.get("nodes", []):
        var node_id := str(node.get("id", ""))
        if node_id in protected_order:
            continue
        var copy: Dictionary = node.duplicate(true)
        copy["protected"] = false
        copy["critical"] = false
        copy["module_pool"] = _optional_pool_for_role(config, str(copy.get("role", "transit")), RUN_SEED.generator(int(plan.get("seed", 0)), "room", node_id + "|pool"))
        nodes.append(copy)
        var anchor_index: int = absi(node_id.hash()) % maxi(1, protected_order.size() - 1)
        copy["depth"] = int(nodes[anchor_index].get("depth", 0)) + 1
        edges.append({"from":str(protected_order[anchor_index]),"to":node_id,"kind":"branch","hidden":str(copy.get("role", "")) == "secret","requires":""})
        copy["branch_anchor_index"] = anchor_index

    # Rebuild exactly the validated loop count. A loop rejoins the next protected
    # room, never a later one: required story rooms remain dominators.
    var loop_candidates: Array = []
    for node in nodes:
        if not bool(node.get("critical", false)) and str(node.get("role", "")) != "secret":
            loop_candidates.append(node)
    var rng := RUN_SEED.generator(int(plan.get("seed", 0)), "layout", "protected_loops")
    var loop_target := int(generated.get("loop_count", 0))
    var added := 0
    while added < loop_target and not loop_candidates.is_empty():
        var index := rng.randi_range(0, loop_candidates.size() - 1)
        var node: Dictionary = loop_candidates[index]
        loop_candidates.remove_at(index)
        var anchor_index := int(node["branch_anchor_index"])
        edges.append({"from":str(node["id"]),"to":str(protected_order[anchor_index + 1]),"kind":"loop","hidden":false,"requires":""})
        added += 1
    plan["loop_count"] = added

    _ensure_deep_retreat(nodes, edges, protected_order)
    plan["nodes"] = nodes
    plan["edges"] = edges
    plan["entry_id"] = str(protected_order.front())
    plan["objective_id"] = str(protected_order.back())
    plan["protected_story_order"] = protected_order
    plan["fallback_authored_map"] = config.get("fallback_authored_map", "")
    return plan

static func _assign_modules(plan: Dictionary, config: Dictionary, library: Dictionary) -> void:
    ROOM_RESOLVER._assign_modules(plan, config, library)

static func _assign_variations(plan: Dictionary) -> void:
    for node in plan.get("nodes", []):
        var room_id := str(node.get("id", ""))
        node["variation_seed"] = RUN_SEED.derive(int(plan.get("seed", 0)), "room", room_id + "|variation")
        for stream in ["encounter", "event", "loot", "ai"]:
            node[stream + "_seed"] = RUN_SEED.derive(int(plan.get("seed", 0)), stream, room_id)

static func _assign_encounter_tables(plan: Dictionary, encounters: Dictionary) -> void:
    for node in plan.get("nodes", []):
        var pool := str(node.get("module_pool", ""))
        node["encounter_candidates"] = encounters.get("room_tables", {}).get(pool, [])
        node["nemesis_eligible"] = str(node.get("role", "")) in encounters.get("nemesis_override", {}).get("allowed_roles", [])

static func _ensure_deep_retreat(nodes: Array, edges: Array, protected_order: Array) -> void:
    if protected_order.size() < 4:
        return
    var deep_id := str(protected_order[protected_order.size() - 3])
    var deep_node := _find_node(nodes, deep_id)
    deep_node["retreat"] = true
    edges.append({"from":deep_id,"to":str(protected_order[0]),"kind":"retreat_shortcut","hidden":false,"requires":"unlock_from_deep_side"})

static func _optional_pool_for_role(config: Dictionary, role: String, rng: RandomNumberGenerator) -> String:
    return ROOM_RESOLVER._optional_pool_for_role(config, role, rng)

static func _source_pool(config: Dictionary, pool: String) -> String:
    return ROOM_RESOLVER._source_pool(config, pool)

static func _weighted_pick(candidates: Array, rng: RandomNumberGenerator) -> Dictionary:
    return ROOM_RESOLVER._weighted_pick(candidates, rng)

static func _generation_report(plan: Dictionary, validation: Dictionary) -> Dictionary:
    var loops := 0
    var secrets := 0
    for edge in plan.get("edges", []):
        if str(edge.get("kind", "")) == "loop":
            loops += 1
    for node in plan.get("nodes", []):
        if str(node.get("role", "")) == "secret":
            secrets += 1
    return {
        "version": GENERATOR_VERSION,
        "seed_version": RUN_SEED.VERSION,
        "engine_version": Engine.get_version_info().get("string", ""),
        "seed": plan.get("seed", 0),
        "stage_seeds": plan.get("stage_seeds", {}).duplicate(true),
        "attempt_index": plan.get("attempt_index", 0),
        "room_count": plan.get("nodes", []).size(),
        "loop_count": loops,
        "secret_count": secrets,
        "retreat_count": _count_retreats(plan.get("nodes", [])),
        "module_pool_fallback_count": _count_pool_fallbacks(plan.get("nodes", [])),
        "profile": plan.get("dungeon_profile", {}).duplicate(true),
        "stages": ["seed", "dungeon_profile", "flow_generator", "critical_path_validation", "room_resolver"],
        "critical_path_validation": plan.get("critical_path_validation", {}).duplicate(true),
        "validation": validation.duplicate(true),
        "fallback": false
    }

static func _count_pool_fallbacks(nodes: Array) -> int:
    var count := 0
    for node in nodes:
        if bool(node.get("module_pool_fallback", false)):
            count += 1
    return count

static func _mandatory_by_id(config: Dictionary, room_id: String) -> Dictionary:
    for room in config.get("mandatory_rooms", []):
        if str(room.get("id", "")) == room_id:
            return room
    return {}

static func _module_ids(library: Dictionary) -> Dictionary:
    return ROOM_RESOLVER._module_ids(library)

static func _has_node(nodes: Array, room_id: String) -> bool:
    return not _find_node(nodes, room_id).is_empty()

static func _find_node(nodes: Array, room_id: String) -> Dictionary:
    for node in nodes:
        if str(node.get("id", "")) == room_id:
            return node
    return {}

static func _count_retreats(nodes: Array) -> int:
    var count := 0
    for node in nodes:
        if bool(node.get("retreat", false)):
            count += 1
    return count

static func _reachable(start_id: String, goal_id: String, edges: Array) -> bool:
    var visited := {start_id:true}
    var queue: Array[String] = [start_id]
    while not queue.is_empty():
        var current: String = str(queue.pop_front())
        if current == goal_id:
            return true
        for edge in edges:
            if bool(edge.get("hidden", false)) or str(edge.get("from", "")) != current:
                continue
            var next_id := str(edge.get("to", ""))
            if not visited.has(next_id):
                visited[next_id] = true
                queue.append(next_id)
    return false

static func _fallback_plan(config: Dictionary, reason: String, validation: Dictionary = {}) -> Dictionary:
    return {"ok":true,"fallback":true,"fallback_reason":reason,"fallback_authored_map":config.get("fallback_authored_map", ""),"validation":validation,"generation_report":{"version":1,"fallback":true,"reason":reason,"validation":validation.duplicate(true)}}

static func _load_json(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        return {}
    var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
    return parsed if typeof(parsed) == TYPE_DICTIONARY else {}
