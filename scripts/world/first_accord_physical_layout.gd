extends RefCounted
class_name FirstAccordPhysicalLayout

# The protected spine and its three authored side rooms remain the spatial source.
# Generated branches are attached to the spine's outward-facing side.
const AUTHORED_SLOTS := {
    "vestibule|gallery_of_names": "broken_guardroom",
    "debate_chamber|collapsed_passage": "sealed_archive",
    "three_pillars_hall|warden_sanctum": "memory_vault"
}
const OUTWARD := {
    "vestibule": 1,
    "gallery_of_names": -1,
    "debate_chamber": -1,
    "collapsed_passage": 1,
    "three_pillars_hall": -1
}

static func resolve(plan: Dictionary, map_data: Dictionary) -> Dictionary:
    if not bool(plan.get("ok", false)) or bool(plan.get("fallback", false)):
        return {"ok": false, "reason": "plan_unavailable"}
    var authored := {}
    for floor_data in map_data.get("floors", []):
        for room_data in floor_data.get("rooms", []):
            authored[str(room_data.get("id", ""))] = room_data
    var incoming := {}
    var outgoing := {}
    for edge in plan.get("edges", []):
        var source := str(edge.get("from", ""))
        var target := str(edge.get("to", ""))
        if str(edge.get("kind", "")) == "branch":
            incoming[target] = source
        elif str(edge.get("kind", "")) == "loop":
            outgoing[source] = target
    var placements := {}
    var generated_rooms: Array = []
    var generated_connections: Array = []
    var deferred_edges: Array = []
    var errors: Array[String] = []
    var used_slots := {}
    var ordinal_by_anchor := {}
    var ordered: Array = plan.get("nodes", []).duplicate(true)
    ordered.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return str(a.get("id", "")) < str(b.get("id", "")))
    for node in ordered:
        var id := str(node.get("id", ""))
        if bool(node.get("protected", false)):
            if not authored.has(id):
                errors.append("protected_room_missing:%s" % id)
            else:
                placements[id] = {"room_id": id, "center": authored[id].get("center", []), "authored": true, "module_id":node.get("module_id", ""), "variation_seed":node.get("variation_seed", 0), "encounter_id":node.get("encounter", {}).get("id", "")}
            continue
        var anchor := str(incoming.get(id, ""))
        if not authored.has(anchor) or not OUTWARD.has(anchor):
            errors.append("branch_anchor_missing:%s" % id)
            continue
        var loop_target := str(outgoing.get(id, ""))
        var slot := str(AUTHORED_SLOTS.get("%s|%s" % [anchor, loop_target], ""))
        if slot != "" and authored.has(slot) and not used_slots.has(slot):
            used_slots[slot] = true
            placements[id] = {"room_id": slot, "center": authored[slot].get("center", []), "authored": true, "module_id":node.get("module_id", ""), "variation_seed":node.get("variation_seed", 0), "encounter_id":node.get("encounter", {}).get("id", "")}
            continue
        var ordinal := int(ordinal_by_anchor.get(anchor, 0))
        ordinal_by_anchor[anchor] = ordinal + 1
        var origin: Array = authored[anchor].get("center", [])
        var direction := int(OUTWARD[anchor])
        var lane_x := direction * (36.0 + ordinal * 26.0)
        var center := [direction * (56.0 + ordinal * 26.0), float(origin[1]), float(origin[2]) + ordinal * 22.0]
        var new_room := {
            "id": id, "name": id, "kind": str(node.get("role", "transit")),
            "center": center, "size": [14, 1, 14],
            "module_id": str(node.get("module_id", "")),
            "variation_seed": int(node.get("variation_seed", 0)),
            "encounter": str(node.get("encounter", {}).get("id", ""))
        }
        var half_width := float(authored[anchor].get("size", [14, 1, 14])[0]) * 0.5
        var points := [origin, [float(origin[0]) + direction * (half_width + 4.0), float(origin[1]), float(origin[2])], [lane_x, float(origin[1]), float(origin[2])], [lane_x, float(origin[1]), float(center[2])], center]
        generated_rooms.append(new_room)
        generated_connections.append({"id":"generated_%s" % id, "from":anchor, "to":id, "kind":"branch", "hidden":str(node.get("role", "")) == "secret", "waypoints":points, "width":3.0})
        placements[id] = {"room_id": id, "center": center, "authored": false, "module_id":node.get("module_id", ""), "variation_seed":node.get("variation_seed", 0), "encounter_id":node.get("encounter", {}).get("id", "")}
        if loop_target != "":
            if not authored.has(loop_target):
                errors.append("loop_target_missing:%s" % id)
                deferred_edges.append({"from":id, "to":loop_target, "kind":"loop"})
            else:
                var target: Array = authored[loop_target].get("center", [])
                var outer_x := float(center[0]) + direction * 12.0
                var loop_points := [center, [outer_x, float(center[1]), float(center[2])], [outer_x, float(target[1]), float(target[2])], target]
                generated_connections.append({"id":"generated_loop_%s" % id, "from":id, "to":loop_target, "kind":"loop", "hidden":false, "waypoints":loop_points, "width":3.0})
    for node in ordered:
        if not placements.has(str(node.get("id", ""))):
            errors.append("unplaced_node:%s" % str(node.get("id", "")))
    for room in generated_rooms:
        var center: Array = room["center"]
        for other in authored.values():
            if _overlaps(center, room["size"], other.get("center", []), other.get("size", [])):
                errors.append("room_overlap:%s:%s" % [room["id"], other.get("id", "")])
        for other in generated_rooms:
            if room == other:
                continue
            if _overlaps(center, room["size"], other.get("center", []), other.get("size", [])):
                errors.append("room_overlap:%s:%s" % [room["id"], other.get("id", "")])
    return {"ok":errors.is_empty(), "errors":errors, "placements":placements, "generated_rooms":generated_rooms, "generated_connections":generated_connections, "deferred_edges":deferred_edges, "fully_realized":deferred_edges.is_empty()}

static func _overlaps(a: Array, a_size: Array, b: Array, b_size: Array) -> bool:
    if a.size() < 3 or b.size() < 3 or a_size.size() < 3 or b_size.size() < 3:
        return true
    return absf(float(a[0]) - float(b[0])) < (float(a_size[0]) + float(b_size[0])) * 0.5 + 2.0 and absf(float(a[2]) - float(b[2])) < (float(a_size[2]) + float(b_size[2])) * 0.5 + 2.0
