extends Node3D

const ENTRY := preload("res://scenes/dungeons/first_accord_entry_vestibule.tscn")
const LIBRARY := "res://data/dungeons/first_accord_module_library.json"

var failures: Array[String] = []

func _ready() -> void:
    call_deferred("_run")

func _run() -> void:
    var entry := ENTRY.instantiate() as Node3D
    add_child(entry)
    var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(LIBRARY))
    var module: Dictionary = data.get("modules", [])[0]
    _check(module.get("module_id") == entry.get_meta("module_id"), "module id")
    _check(module.get("scene_path") == ENTRY.resource_path, "scene registry")
    for connector: Dictionary in module.get("connectors", []):
        var port := entry.get_node_or_null("Connectors/" + str(connector.get("id"))) as Marker3D
        _check(port != null, "connector marker " + str(connector.get("id")))
        if port != null:
            _check(is_equal_approx(absf(port.position.x), 0.0), "connector centred")
            _check(is_equal_approx(absf(port.position.z), 7.0), "connector at boundary")
            _check(connector.get("width_m") == 4 and connector.get("level") == 0, "connector dimensions")

    var space := get_world_3d().direct_space_state
    await get_tree().physics_frame
    for z: float in [-6.8, 6.8]:
        var hit := space.intersect_ray(PhysicsRayQueryParameters3D.create(Vector3(0, 2, z), Vector3(0, -2, z)))
        _check(hit.get("collider") == entry.get_node("Floor"), "threshold floor collision")
    var wall_hit := space.intersect_ray(PhysicsRayQueryParameters3D.create(Vector3(6, 2, -8), Vector3(6, 2, -6)))
    _check(wall_hit.get("collider") == entry.get_node("NorthRight"), "north wall collision")
    var door_hit := space.intersect_ray(PhysicsRayQueryParameters3D.create(Vector3(0, 2, -8), Vector3(0, 2, -6)))
    _check(door_hit.is_empty(), "north opening unobstructed")

    # A straight four-metre receiving corridor stands in for the gallery's
    # south connector; the actual gallery scene is the following milestone.
    var receiving := NavigationRegion3D.new()
    receiving.name = "GalleryConnectorFixture"
    receiving.use_edge_connections = true
    var nav := NavigationMesh.new()
    nav.vertices = PackedVector3Array([
        Vector3(-2, 0, -7), Vector3(2, 0, -7),
        Vector3(2, 0, -13), Vector3(-2, 0, -13)
    ])
    nav.add_polygon(PackedInt32Array([0, 1, 2, 3]))
    receiving.navigation_mesh = nav
    add_child(receiving)
    var map := get_world_3d().navigation_map
    var route := PackedVector3Array()
    for attempt in 120:
        await get_tree().physics_frame
        NavigationServer3D.map_force_update(map)
        route = NavigationServer3D.map_get_path(map, Vector3(0, 0, 4), Vector3(0, 0, -12), true)
        if route.size() >= 2 and route[-1].distance_to(Vector3(0, 0, -12)) < 0.1:
            break
    _check(route.size() >= 2 and route[-1].distance_to(Vector3(0, 0, -12)) < 0.1, "navigation crosses north seam")
    if failures.is_empty():
        print("FIRST_ACCORD_ENTRY_PHYSICAL_OK connectors=2 collision=ok nav_seam=ok")
        get_tree().quit(0)
    else:
        for failure in failures:
            push_error(failure)
        get_tree().quit(1)

func _check(ok: bool, message: String) -> void:
    if not ok:
        failures.append(message)
