extends RefCounted
class_name VeilleursDungeonRuntimeV07

const PROCEDURAL_PLAN := preload("res://scripts/world/first_accord_hybrid_runtime_plan.gd")
const FIRST_ACCORD_ID := "dungeon_first_map_hall_of_first_accord"

const ENCOUNTER_DIRECTOR_SCRIPT := preload("res://scripts/core/veilleurs_encounter_director.gd")

var content_db: Variant
var data: Dictionary = {}
var nodes_by_id: Dictionary = {}
var current_node := ""
var visited: Array[String] = []
var node_flags: Dictionary = {}
var active_encounter: Dictionary = {}
var encounter_director: VeilleursEncounterDirector
var run_seed := 0
var procedural_plan: Dictionary = {}
var discovered_edges: Array[String] = []

var load_errors: Array[String] = []

func _init() -> void:
    encounter_director = ENCOUNTER_DIRECTOR_SCRIPT.new() as VeilleursEncounterDirector

func configure(db: Variant, dungeon_id: String) -> bool:
    content_db = db
    procedural_plan.clear()
    discovered_edges.clear()
    data = content_db.dungeon(dungeon_id) if content_db != null and content_db.has_method("dungeon") else {}
    nodes_by_id.clear()
    load_errors.clear()
    if dungeon_id == FIRST_ACCORD_ID:
        data = {"dungeon_id":dungeon_id, "entry_node":"vestibule"}
        return true
    if data.is_empty():
        load_errors.append("missing_dungeon:%s" % dungeon_id)
        return false
    for value: Variant in data.get("nodes", []):
        if not (value is Dictionary):
            continue
        var row: Dictionary = (value as Dictionary).duplicate(true)
        var node_id := str(row.get("node_id", ""))
        if node_id == "" or nodes_by_id.has(node_id):
            load_errors.append("invalid_node:%s" % node_id)
            continue
        nodes_by_id[node_id] = row
    var entry := str(data.get("entry_node", ""))
    if not nodes_by_id.has(entry):
        load_errors.append("entry_missing")
    if not _terminal_reachable(entry):
        load_errors.append("terminal_unreachable")
    return load_errors.is_empty()

func start(seed: int = 0) -> Dictionary:
    if not load_errors.is_empty():
        return {"ok":false, "reason":"invalid_dungeon", "errors":load_errors.duplicate()}
    run_seed = seed if seed != 0 else posmod(str(data.get("dungeon_id", "dungeon")).hash(), 1000000) + 700000
    if str(data.get("dungeon_id", "")) == FIRST_ACCORD_ID:
        var generated := PROCEDURAL_PLAN.build({"campaign_seed":run_seed, "dungeon_id":FIRST_ACCORD_ID})
        if not _install_procedural_plan(generated):
            return {"ok":false, "reason":"procedural_generation_failed", "errors":load_errors.duplicate()}
    discovered_edges.clear()
    current_node = str(data.get("entry_node", ""))
    visited.clear()
    node_flags.clear()
    active_encounter.clear()
    return enter(current_node)

func enter(node_id: String) -> Dictionary:
    if not nodes_by_id.has(node_id):
        return {"ok":false, "reason":"unknown_node", "node_id":node_id}
    current_node = node_id
    if not visited.has(node_id):
        visited.append(node_id)
    var node: Dictionary = (nodes_by_id[node_id] as Dictionary).duplicate(true)
    active_encounter.clear()
    if bool(node.get("encounter", false)) and not bool(node_flags.get(node_id, {}).get("completed", false)):
        if node.has("selected_encounter"):
            active_encounter = encounter_director.materialize_selected(node["selected_encounter"], content_db)
            if not bool(active_encounter.get("ok", false)):
                return active_encounter
            active_encounter["node_id"] = node_id
            active_encounter["dungeon_id"] = FIRST_ACCORD_ID
        elif str(node.get("kind", "")) == "boss":
            active_encounter = {"boss":true, "boss_id":str(node.get("boss_id", data.get("boss_id", ""))), "node_id":node_id, "dungeon_id":str(data.get("dungeon_id", ""))}
        else:
            active_encounter = encounter_director.next_encounter(str(node.get("family", "GOULES")), str(node.get("band", "LOW")), int(node.get("variant", 1)), _node_seed(node_id))
            active_encounter["node_id"] = node_id
            active_encounter["dungeon_id"] = str(data.get("dungeon_id", ""))
            active_encounter["memoriel_required"] = bool(node.get("memoriel_required", false))
        node["materialized_encounter"] = active_encounter.duplicate(true)
    return {"ok":true, "dungeon_id":str(data.get("dungeon_id", "")), "node":node, "visited":visited.duplicate(), "can_extract":bool(node.get("extraction", false))}

func complete_current(outcome: String = "cleared", context: Dictionary = {}) -> Dictionary:
    if current_node == "" or not nodes_by_id.has(current_node):
        return {"ok":false, "reason":"no_current_node"}
    var node: Dictionary = nodes_by_id[current_node]
    if not procedural_plan.is_empty():
        if bool(node_flags.get(current_node, {}).get("completed", false)):
            return {"ok":false, "reason":"node_already_completed"}
        if not active_encounter.is_empty() and str(context.get("combat_node_id", "")) != current_node:
            return {"ok":false, "reason":"combat_required"}
        if outcome not in ["cleared", "victory"]:
            # A failed fight cannot be cleared by the noncombat action afterward.
            var escape: Array[String] = []
            for edge in procedural_plan.get("edges", []):
                if str(edge.get("to", "")) == current_node and str(edge.get("from", "")) in visited:
                    escape.append(str(edge.get("from", "")))
            var pending_flags: Dictionary = node_flags.get(current_node, {})
            pending_flags["escape_next"] = escape
            node_flags[current_node] = pending_flags
            return {"ok":true, "outcome":outcome, "completed":false}
    var flags: Dictionary = node_flags.get(current_node, {})
    flags.merge({"completed":true, "outcome":outcome, "context":context.duplicate(true)}, true)
    node_flags[current_node] = flags
    var result := {"ok":true, "dungeon_id":str(data.get("dungeon_id", "")), "node_id":current_node, "outcome":outcome}
    if not active_encounter.is_empty() and not bool(active_encounter.get("boss", false)):
        var encounter_context := context.duplicate(true)
        encounter_context["region_id"] = str(data.get("dungeon_id", "")).to_lower()
        encounter_context["zone_id"] = current_node
        encounter_context["summary"] = str(context.get("summary", "%s — %s" % [str(node.get("title_fr", current_node)), outcome]))
        result["encounter_result"] = encounter_director.resolve_encounter(active_encounter, "victory" if outcome in ["cleared", "victory"] else outcome, "%s:%s" % [str(data.get("dungeon_id", "dungeon")), current_node], encounter_context)
    if str(node.get("kind", "")) in ["archive", "memory", "objective", "consequence", "boss"] and RemanenceRuntime != null:
        var severity := "major" if str(node.get("kind", "")) in ["objective", "boss", "consequence"] else "trace"
        result["scar_id"] = RemanenceRuntime.create_world_scar("%s:%s" % [str(data.get("dungeon_id", "dungeon")), current_node], "dungeon_%s" % str(node.get("kind", "room")), severity, {"region_id":str(data.get("dungeon_id", "")).to_lower(), "zone_id":current_node, "summary":"%s — %s" % [str(node.get("title_fr", current_node)), outcome], "protected":severity == "major"})
    active_encounter.clear()
    if not procedural_plan.is_empty():
        var loot := _room_rewards(node)
        node_flags[current_node]["rewards"] = loot
        result["rewards"] = loot
        result["room_events"] = node.get("room_events", []).duplicate(true)
    return result

func available_next() -> Array[String]:
    if current_node == "" or not nodes_by_id.has(current_node):
        return []
    if not procedural_plan.is_empty():
        return _procedural_next()
    var result: Array[String] = []
    for value: Variant in (nodes_by_id[current_node] as Dictionary).get("next", []):
        result.append(str(value))
    return result

func choose_next(node_id: String) -> Dictionary:
    if not available_next().has(node_id):
        return {"ok":false, "reason":"invalid_transition", "from":current_node, "to":node_id}
    return enter(node_id)

func can_extract() -> bool:
    return current_node != "" and nodes_by_id.has(current_node) and bool((nodes_by_id[current_node] as Dictionary).get("extraction", false))

func current() -> Dictionary:
    return (nodes_by_id.get(current_node, {}) as Dictionary).duplicate(true)

func progress_summary() -> Dictionary:
    return {"dungeon_id":str(data.get("dungeon_id", "")), "current_node":current_node, "visited_count":visited.size(), "total_nodes":nodes_by_id.size(), "can_extract":can_extract(), "boss_id":str(data.get("boss_id", ""))}

func serialize() -> Dictionary:
    return {"procedural_plan":procedural_plan.duplicate(true), "discovered_edges":discovered_edges.duplicate(), "version":"0.7.0", "dungeon_id":str(data.get("dungeon_id", "")), "run_seed":run_seed, "current_node":current_node, "visited":visited.duplicate(), "node_flags":node_flags.duplicate(true), "active_encounter":active_encounter.duplicate(true), "encounter_director":encounter_director.serialize()}

func deserialize(payload: Dictionary) -> bool:
    if str(payload.get("dungeon_id", "")) != str(data.get("dungeon_id", "")):
        return false
    if str(data.get("dungeon_id", "")) == FIRST_ACCORD_ID:
        if not _install_procedural_plan(payload.get("procedural_plan", {})):
            return false
    discovered_edges.clear()
    for edge_id in payload.get("discovered_edges", []):
        discovered_edges.append(str(edge_id))
    run_seed = int(payload.get("run_seed", 0))
    current_node = str(payload.get("current_node", ""))
    if current_node != "" and not nodes_by_id.has(current_node):
        return false
    visited.clear()
    for value: Variant in payload.get("visited", []):
        var node_id := str(value)
        if nodes_by_id.has(node_id):
            visited.append(node_id)
    node_flags = (payload.get("node_flags", {}) as Dictionary).duplicate(true)
    active_encounter = (payload.get("active_encounter", {}) as Dictionary).duplicate(true)
    encounter_director.deserialize(payload.get("encounter_director", {}))
    return true

func _terminal_reachable(entry: String) -> bool:
    if entry == "":
        return false
    var queue: Array[String] = [entry]
    var seen: Dictionary = {}
    while not queue.is_empty():
        var node_id: String = queue.pop_front() as String
        if seen.has(node_id):
            continue
        seen[node_id] = true
        var node: Dictionary = nodes_by_id[node_id]
        if (node.get("next", []) as Array).is_empty() and str(node.get("kind", "")) in ["extraction", "consequence", "objective"]:
            return true
        for value: Variant in node.get("next", []):
            var next_id := str(value)
            if nodes_by_id.has(next_id) and not seen.has(next_id):
                queue.append(next_id)
    return false

func _node_seed(node_id: String) -> int:
    return run_seed + posmod(node_id.hash(), 100000)

func _install_procedural_plan(plan: Dictionary) -> bool:
    if not bool(plan.get("ok", false)) or bool(plan.get("fallback", false)) or not bool(PROCEDURAL_PLAN.validate_final(plan).get("ok", false)):
        load_errors.append("invalid_procedural_plan")
        return false
    for path in plan.get("generation_report", {}).get("data_revisions", {}):
        if str(plan["generation_report"]["data_revisions"][path]) != FileAccess.get_file_as_string(str(path)).sha256_text():
            load_errors.append("saved_catalog_changed:" + str(path))
            return false
    # Persist the validated plan: world scars change during play, so regeneration
    # against the current world would silently replace the saved expedition.
    var candidate_nodes := {}
    for room in plan.get("nodes", []):
        var selected: Dictionary = room.get("encounter", {})
        var has_encounter := float(selected.get("threat", 0)) > 0
        if has_encounter:
            var materialized := encounter_director.materialize_selected(selected, content_db)
            if not bool(materialized.get("ok", false)):
                load_errors.append(str(materialized.get("reason", "materialization_failed")))
                return false
        var id := str(room.get("id", ""))
        var node: Dictionary = room.duplicate(true)
        var modules: Dictionary = DungeonRoomResolver._module_ids(FirstAccordHybridPlanner._load_json(FirstAccordHybridPlanner.MODULES_PATH))
        node["scene_path"] = str(modules.get(str(room.get("module_id", "")), {}).get("scene_path", ""))
        if node["scene_path"] == "" or not ResourceLoader.exists(node["scene_path"]):
            load_errors.append("module_scene_missing:" + id)
            return false
        node["node_id"] = id
        node["title_fr"] = id.replace("_", " ").capitalize()
        node["kind"] = "objective" if id == str(plan.get("objective_id", "")) else str(room.get("role", "room"))
        node["encounter"] = has_encounter
        if has_encounter:
            node["selected_encounter"] = selected.duplicate(true)
        node["extraction"] = bool(room.get("retreat", false)) or id == str(plan.get("objective_id", ""))
        node["next"] = []
        candidate_nodes[id] = node
    var combat_revision := FileAccess.get_file_as_string("res://data/dungeons/first_accord_combat.json").sha256_text()
    if plan.has("playable_data_revision") and str(plan["playable_data_revision"]) != combat_revision:
        load_errors.append("playable_data_changed")
        return false
    procedural_plan = plan.duplicate(true)
    procedural_plan["playable_data_revision"] = combat_revision
    nodes_by_id = candidate_nodes
    data = {"dungeon_id":FIRST_ACCORD_ID, "entry_node":str(plan.get("entry_id", "")), "nodes":candidate_nodes.values(), "boss_id":"c01_ancient_accord_warden"}
    return true

func _procedural_next() -> Array[String]:
    var result: Array[String] = []
    if not bool(node_flags.get(current_node, {}).get("completed", false)):
        for escaped in node_flags.get(current_node, {}).get("escape_next", []):
            result.append(str(escaped))
        return result
    for edge in procedural_plan.get("edges", []):
        var from_id := str(edge.get("from", ""))
        var to_id := str(edge.get("to", ""))
        if from_id == current_node:
            if not passage_is_open(edge):
                continue
            if to_id not in result:
                result.append(to_id)
        elif to_id == current_node and from_id in visited and passage_is_open(edge):
            if from_id not in result:
                result.append(from_id)
    return result

func discover_current_passages() -> Dictionary:
    if procedural_plan.is_empty() or not bool(node_flags.get(current_node, {}).get("completed", false)):
        return {"ok":false, "reason":"room_not_cleared"}
    var found: Array = []
    for edge in procedural_plan.get("edges", []):
        if str(edge.get("from", "")) == current_node and bool(edge.get("hidden", false)):
            var result := discover_passage(current_node + ">" + str(edge.get("to", "")))
            if bool(result.get("changed", false)):
                found.append(str(edge.get("to", "")))
    return {"ok":true, "discovered":found}

# Passage state belongs to the canonical saved expedition, never to scene nodes.
func passage_is_open(edge: Dictionary) -> bool:
    var edge_id := str(edge.get("from", "")) + ">" + str(edge.get("to", ""))
    if bool(edge.get("hidden", false)) and edge_id not in discovered_edges:
        return false
    var requirement := str(edge.get("requires", ""))
    if requirement == "unlock_from_deep_side":
        return edge_id in node_flags.get(str(edge.get("from", "")), {}).get("opened_shortcuts", [])
    return requirement == ""

func discover_passage(edge_id: String) -> Dictionary:
    return _open_passage(edge_id, false)

func unlock_shortcut(edge_id: String) -> Dictionary:
    return _open_passage(edge_id, true)

func _open_passage(edge_id: String, shortcut: bool) -> Dictionary:
    for edge in procedural_plan.get("edges", []):
        var source := str(edge.get("from", ""))
        if source + ">" + str(edge.get("to", "")) != edge_id:
            continue
        if shortcut != (str(edge.get("requires", "")) == "unlock_from_deep_side") or (not shortcut and (not bool(edge.get("hidden", false)) or str(edge.get("requires", "")) != "")):
            return {"ok":false, "reason":"wrong_passage_kind"}
        if passage_is_open(edge):
            return {"ok":true, "changed":false, "edge_id":edge_id}
        if current_node != source:
            return {"ok":false, "reason":"wrong_side"}
        if not bool(node_flags.get(current_node, {}).get("completed", false)):
            return {"ok":false, "reason":"room_not_cleared"}
        if shortcut:
            var opened: Array = node_flags[source].get("opened_shortcuts", []).duplicate()
            opened.append(edge_id)
            node_flags[source]["opened_shortcuts"] = opened
        else:
            discovered_edges.append(edge_id)
        return {"ok":true, "changed":true, "edge_id":edge_id}
    return {"ok":false, "reason":"unknown_passage"}

func _room_rewards(node: Dictionary) -> Dictionary:
    var payload: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/dungeons/first_accord_combat.json"))
    var rewards := {"gold":0, "materials":0, "essence":0}
    for anchor in node.get("resource_reservations", []):
        var id := str(anchor.get("anchor_id", ""))
        var rng := DungeonRunSeed.generator(int(node.get("loot_seed", 0)), "loot", id)
        var ranges: Dictionary = payload.get("resource_rewards", {}).get(id, {})
        for resource in rewards:
            var bounds: Array = ranges.get(resource, [0, 0])
            rewards[resource] += rng.randi_range(int(bounds[0]), int(bounds[1]))
    return rewards

func collected_rewards() -> Dictionary:
    var result := {"gold":0, "materials":0, "essence":0}
    for flags in node_flags.values():
        for resource in result:
            result[resource] += int(flags.get("rewards", {}).get(resource, 0))
    return result
