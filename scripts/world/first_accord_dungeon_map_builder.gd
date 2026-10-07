extends RefCounted
class_name FirstAccordDungeonMapBuilder

const MAP_PATH := "res://data/dungeons/first_map_hall_of_first_accord_map.json"
const OCCLUDABLE_SCRIPT := preload("res://scripts/world/isometric_occludable.gd")
const MODULES_PATH := "res://data/dungeons/first_accord_module_library.json"
const ENTRY_SCENE := preload("res://scenes/dungeons/first_accord_entry_vestibule.tscn")
const MODULE_BLOCKOUT_SCENE := preload("res://scenes/dungeons/first_accord_module_blockout.tscn")

# One physical entry point for the authored and generated module catalogs. The
# existing map builder remains responsible for placing and connecting rooms.
static func instantiate_module(module_id: String) -> Node3D:
    var library := _load_json(MODULES_PATH)
    var module: Dictionary = {}
    for entry in library.get("modules", []):
        if str(entry.get("module_id", "")) == module_id:
            module = entry
            break
    if module.is_empty():
        return null
    if module_id == "accord_entry_vestibule_v1":
        return ENTRY_SCENE.instantiate() as Node3D
    var room := MODULE_BLOCKOUT_SCENE.instantiate() as FirstAccordModuleBlockout
    if room == null or not room.configure(module_id, module):
        return null
    return room

# Build a walkable blockout directly from the validated plan. Every room is
# instantiated through the catalog above; locked/hidden links stay absent until
# an exploration controller explicitly opens them.
static func generate_from_plan(parent: Node3D, plan: Dictionary) -> Dictionary:
    if parent == null or not bool(plan.get("ok", false)) or bool(plan.get("fallback", false)) or not bool(plan.get("validation", {}).get("ok", false)):
        return {"ok":false, "reason":"plan_not_validated"}
    var nodes: Array = plan.get("nodes", [])
    var edges: Array = plan.get("edges", [])
    var protected: Array = plan.get("protected_story_order", [])
    var definitions := {}
    var positions := {}
    var branch_counts := {}
    var library := _load_json(MODULES_PATH)
    var known_modules := {}
    for spec in library.get("modules", []):
        known_modules[str(spec.get("module_id", ""))] = true
    for node in nodes:
        var room_id := str(node.get("id", ""))
        var module_id := str(node.get("module_id", ""))
        if room_id == "" or definitions.has(room_id) or not known_modules.has(module_id):
            return {"ok":false, "reason":"room_unresolved", "room_id":room_id}
        definitions[room_id] = node
    for index in protected.size():
        positions[str(protected[index])] = Vector3(0, 0, -55.0 * index)
    var optional_ids: Array[String] = []
    for room_id in definitions.keys():
        if not positions.has(room_id):
            optional_ids.append(str(room_id))
    optional_ids.sort()
    for room_id in optional_ids:
        var anchor_id := ""
        for edge in edges:
            if str(edge.get("to", "")) == room_id and positions.has(str(edge.get("from", ""))):
                anchor_id = str(edge.get("from", ""))
                break
        if anchor_id == "":
            return {"ok":false, "reason":"unplaced_branch", "room_id":room_id}
        var lane := int(branch_counts.get(anchor_id, 0))
        branch_counts[anchor_id] = lane + 1
        positions[room_id] = positions[anchor_id] + Vector3(55.0 * (lane + 1), 0, 0)
    for edge in edges:
        if not positions.has(str(edge.get("from", ""))) or not positions.has(str(edge.get("to", ""))):
            return {"ok":false, "reason":"edge_unresolved"}
    var root := Node3D.new()
    root.name = "GeneratedFirstAccord"
    root.set_meta("generation_seed", plan.get("seed", 0))
    parent.add_child(root)
    var rooms := Node3D.new()
    rooms.name = "Rooms"
    root.add_child(rooms)
    for room_id in definitions.keys():
        var node: Dictionary = definitions[room_id]
        var module := instantiate_module(str(node.get("module_id", "")))
        module.name = str(room_id)
        module.position = positions[room_id]
        module.set_meta("room_id", str(room_id))
        module.set_meta("encounter", node.get("encounter", {}).duplicate(true))
        module.set_meta("room_events", node.get("room_events", []).duplicate(true))
        module.set_meta("resource_reservations", node.get("resource_reservations", []).duplicate(true))
        rooms.add_child(module)
    var connections := Node3D.new()
    connections.name = "Connections"
    root.add_child(connections)
    var open_count := 0
    for edge in edges:
        if bool(edge.get("hidden", false)) or str(edge.get("requires", "")) != "":
            continue
        var result := open_plan_connection(root, edge)
        if not bool(result.get("ok", false)):
            root.queue_free()
            return result
        open_count += 1
    return {"ok":true, "root":root, "room_count":rooms.get_child_count(), "open_connection_count":open_count}

# Stable edge IDs make restoration and repeated interaction idempotent.
static func open_plan_connection(root: Node3D, edge: Dictionary) -> Dictionary:
    var edge_id := str(edge.get("from", "")) + ">" + str(edge.get("to", ""))
    var connections := root.get_node("Connections")
    for existing in connections.get_children():
        if str(existing.get_meta("edge_id", "")) == edge_id:
            return {"ok":true, "changed":false}
    var rooms := root.get_node("Rooms")
    var source := rooms.get_node_or_null(str(edge.get("from", ""))) as Node3D
    var target := rooms.get_node_or_null(str(edge.get("to", ""))) as Node3D
    if source == null or target == null:
        return {"ok":false, "reason":"physical_room_missing"}
    var from_marker := _nearest_connector(source, target.position)
    var to_marker := _nearest_connector(target, source.position, bool(edge.get("hidden", false)))
    if from_marker == null or to_marker == null:
        return {"ok":false, "reason":"physical_connector_missing"}
    var corridor := Node3D.new()
    corridor.name = "Link_%03d" % connections.get_child_count()
    corridor.set_meta("edge_id", edge_id)
    corridor.set_meta("from_room", source.name)
    corridor.set_meta("to_room", target.name)
    connections.add_child(corridor)
    var start := root.to_local(from_marker.global_position)
    var finish := root.to_local(to_marker.global_position)
    var points: Array[Vector3] = [start, finish]
    if str(edge.get("kind", "")) == "retreat_shortcut":
        # Route outside the spine instead of crossing unresolved story rooms.
        var exit := start + (from_marker.global_position - source.global_position).normalized() * 5.0
        var entry := finish + (to_marker.global_position - target.global_position).normalized() * 5.0
        points = [start, exit, Vector3(-55, 0, exit.z), Vector3(-55, 0, entry.z), entry, finish]
    for index in range(1, points.size()):
        _build_path_tiles(corridor, points[index - 1], points[index], 4.0, index)
    return {"ok":true, "changed":true}

static func _nearest_connector(room: Node3D, toward: Vector3, include_hidden: bool = false) -> Marker3D:
    var connectors := room.get_node_or_null("Connectors")
    if connectors == null:
        return null
    var nearest: Marker3D = null
    var distance := INF
    for value in connectors.get_children():
        var marker := value as Marker3D
        if marker == null or (bool(marker.get_meta("hidden", false)) and not include_hidden):
            continue
        var candidate := marker.global_position.distance_squared_to(toward)
        if candidate < distance:
            nearest = marker
            distance = candidate
    return nearest

static func generate(parent: Node3D) -> void:
    var map_data := _load_json(MAP_PATH)
    if map_data.is_empty():
        push_error("FirstAccordDungeonMapBuilder: carte absente")
        return
    var root := Node3D.new()
    root.name = "AuthoredDungeonMap"
    root.set_meta("map_id", str(map_data.get("id", "")))
    root.set_meta("ash_guidance", str(map_data.get("design_rules", {}).get("ash_guidance", "only_on_request")))
    parent.add_child(root)
    _build_rooms(root, map_data.get("floors", []))
    _build_connections(root, map_data.get("connections", []))
    _build_gameplay_markers(root, "Hazards", map_data.get("hazards", []), "dungeon_hazard")
    _build_gameplay_markers(root, "RetreatPoints", map_data.get("retreat_points", []), "physical_retreat")
    _build_gameplay_markers(root, "Discoveries", map_data.get("discoveries", []), "lore_discovery")
    _build_ash_route(root, map_data)

static func _build_rooms(root: Node3D, floors: Array) -> void:
    var floors_root := Node3D.new()
    floors_root.name = "Floors"
    root.add_child(floors_root)
    for floor_data in floors:
        var floor_root := Node3D.new()
        floor_root.name = str(floor_data.get("id", "floor"))
        floor_root.set_meta("display_name", str(floor_data.get("name", "")))
        floor_root.set_meta("physical_retreat_available", true)
        floors_root.add_child(floor_root)
        for room_data in floor_data.get("rooms", []):
            _build_room(floor_root, room_data)

static func _build_room(parent: Node3D, room_data: Dictionary) -> void:
    var center := _vec3(room_data.get("center", [0, 0, 0]))
    var size := _vec3(room_data.get("size", [10, 1, 10]))
    var room := Node3D.new()
    room.name = str(room_data.get("id", "room"))
    room.position = center
    room.set_meta("display_name", str(room_data.get("name", "")))
    room.set_meta("room_kind", str(room_data.get("kind", "critical")))
    room.set_meta("encounter_id", str(room_data.get("encounter", "")))
    room.set_meta("lock", str(room_data.get("lock", "")))
    room.set_meta("reward", str(room_data.get("reward", "")))
    parent.add_child(room)
    _box(room, "Floor", Vector3(0.0, -0.3, 0.0), Vector3(size.x, 0.6, size.z), true, "architecture/dungeon_floor")
    var wall_height := 4.0
    var door_gap: float = minf(5.0, size.x * 0.35)
    var side_width: float = maxf(1.0, (size.x - door_gap) * 0.5)
    _box(room, "NorthWallLeft", Vector3(-(door_gap + side_width) * 0.25, wall_height * 0.5, -size.z * 0.5), Vector3(side_width, wall_height, 0.8), true, "architecture/dungeon_wall")
    _box(room, "NorthWallRight", Vector3((door_gap + side_width) * 0.25, wall_height * 0.5, -size.z * 0.5), Vector3(side_width, wall_height, 0.8), true, "architecture/dungeon_wall")
    _box(room, "SouthWallLeft", Vector3(-(door_gap + side_width) * 0.25, wall_height * 0.5, size.z * 0.5), Vector3(side_width, wall_height, 0.8), true, "architecture/dungeon_wall")
    _box(room, "SouthWallRight", Vector3((door_gap + side_width) * 0.25, wall_height * 0.5, size.z * 0.5), Vector3(side_width, wall_height, 0.8), true, "architecture/dungeon_wall")
    var side_depth: float = maxf(1.0, (size.z - door_gap) * 0.5)
    _box(room, "WestWallNorth", Vector3(-size.x * 0.5, wall_height * 0.5, -(door_gap + side_depth) * 0.25), Vector3(0.8, wall_height, side_depth), true, "architecture/dungeon_wall")
    _box(room, "WestWallSouth", Vector3(-size.x * 0.5, wall_height * 0.5, (door_gap + side_depth) * 0.25), Vector3(0.8, wall_height, side_depth), true, "architecture/dungeon_wall")
    _box(room, "EastWallNorth", Vector3(size.x * 0.5, wall_height * 0.5, -(door_gap + side_depth) * 0.25), Vector3(0.8, wall_height, side_depth), true, "architecture/dungeon_wall")
    _box(room, "EastWallSouth", Vector3(size.x * 0.5, wall_height * 0.5, (door_gap + side_depth) * 0.25), Vector3(0.8, wall_height, side_depth), true, "architecture/dungeon_wall")

static func _build_connections(root: Node3D, connections: Array) -> void:
    var connections_root := Node3D.new()
    connections_root.name = "Connections"
    root.add_child(connections_root)
    for connection in connections:
        var corridor := Node3D.new()
        corridor.name = str(connection.get("id", "connection"))
        corridor.set_meta("from_room", str(connection.get("from", "")))
        corridor.set_meta("to_room", str(connection.get("to", "")))
        corridor.set_meta("connection_kind", str(connection.get("kind", "corridor")))
        corridor.set_meta("hidden", bool(connection.get("hidden", false)))
        corridor.set_meta("requires", str(connection.get("requires", "")))
        corridor.set_meta("shortcut_id", str(connection.get("shortcut_id", "")))
        connections_root.add_child(corridor)
        var points: Array = connection.get("waypoints", [])
        var width := float(connection.get("width", 3.0))
        for index in points.size():
            var point := _vec3(points[index])
            var marker := Marker3D.new()
            marker.name = "Waypoint_%02d" % [index + 1]
            marker.position = point
            marker.set_meta("route_index", index)
            corridor.add_child(marker)
            if index > 0:
                _build_path_tiles(corridor, _vec3(points[index - 1]), point, width, index)

static func _build_path_tiles(parent: Node3D, start: Vector3, finish: Vector3, width: float, segment_index: int) -> void:
    var distance := start.distance_to(finish)
    var tile_count := maxi(1, int(ceil(distance / 1.5)))
    for tile_index in tile_count + 1:
        var ratio := float(tile_index) / float(tile_count)
        var point := start.lerp(finish, ratio)
        _box(parent, "Path_%02d_%02d" % [segment_index, tile_index], point + Vector3(0.0, -0.22, 0.0), Vector3(width, 0.45, width), true, "architecture/dungeon_path")

static func _build_gameplay_markers(root: Node3D, root_name: String, entries: Array, role: String) -> void:
    var marker_root := Node3D.new()
    marker_root.name = root_name
    root.add_child(marker_root)
    for entry in entries:
        var marker := Marker3D.new()
        marker.name = str(entry.get("id", entry.get("room", role)))
        marker.position = _vec3(entry.get("position", [0, 0, 0]))
        marker.set_meta("gameplay_role", role)
        marker.set_meta("data", entry)
        marker_root.add_child(marker)

static func _build_ash_route(root: Node3D, map_data: Dictionary) -> void:
    var ash_route := Node3D.new()
    ash_route.name = "AshGuidanceGraph"
    ash_route.set_meta("only_on_request", true)
    ash_route.set_meta("never_points_through_walls", true)
    ash_route.set_meta("objective_order", map_data.get("ash_routes", {}).get("objective_order", []))
    root.add_child(ash_route)
    for connection in map_data.get("connections", []):
        var edge := Node3D.new()
        edge.name = str(connection.get("id", "edge"))
        edge.set_meta("from_room", str(connection.get("from", "")))
        edge.set_meta("to_room", str(connection.get("to", "")))
        edge.set_meta("waypoints", connection.get("waypoints", []))
        edge.set_meta("hidden", bool(connection.get("hidden", false)))
        edge.set_meta("requires", str(connection.get("requires", "")))
        ash_route.add_child(edge)

static func _box(parent: Node3D, node_name: String, pos: Vector3, size: Vector3, collision_enabled: bool, asset_slot: String) -> void:
    var root := OCCLUDABLE_SCRIPT.new() as Node3D
    root.name = node_name
    root.position = pos
    root.set_meta("blender_asset_slot", asset_slot)
    root.set_meta("blockout_size_m", size)
    var mesh := MeshInstance3D.new()
    var box_mesh := BoxMesh.new()
    box_mesh.size = size
    mesh.mesh = box_mesh
    root.add_child(mesh)
    if collision_enabled:
        var body := StaticBody3D.new()
        root.add_child(body)
        var collision := CollisionShape3D.new()
        var shape := BoxShape3D.new()
        shape.size = size
        collision.shape = shape
        body.add_child(collision)
    parent.add_child(root)

static func _vec3(value: Variant) -> Vector3:
    if typeof(value) != TYPE_ARRAY or value.size() < 3:
        return Vector3.ZERO
    return Vector3(float(value[0]), float(value[1]), float(value[2]))

static func _load_json(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        return {}
    var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
    return parsed if typeof(parsed) == TYPE_DICTIONARY else {}
