extends Node3D

## Authored 20 x 14 m entry blockout. Origin is the floor centre; -Z faces the gallery.
## Connector positions are stable even if decoration is varied later.

const MODULE_ID := "accord_entry_vestibule_v1"

func _ready() -> void:
    set_meta("module_id", MODULE_ID)
    set_meta("blender_asset_slot", "architecture/first_accord_entry_vestibule")
    _box("Floor", Vector3(0, -0.3, 0), Vector3(20, 0.6, 14))
    _box("NorthLeft", Vector3(-6, 2, -7), Vector3(8, 4, 0.8))
    _box("NorthRight", Vector3(6, 2, -7), Vector3(8, 4, 0.8))
    _box("SouthLeft", Vector3(-6, 2, 7), Vector3(8, 4, 0.8))
    _box("SouthRight", Vector3(6, 2, 7), Vector3(8, 4, 0.8))
    _box("WestWall", Vector3(-10, 2, 0), Vector3(0.8, 4, 14))
    _box("EastWall", Vector3(10, 2, 0), Vector3(0.8, 4, 14))
    var connectors := Node3D.new()
    connectors.name = "Connectors"
    add_child(connectors)
    _connector(connectors, "north", Vector3(0, 0, -7), 0.0)
    _connector(connectors, "exit", Vector3(0, 0, 7), PI)
    var region := NavigationRegion3D.new()
    region.name = "Navigation"
    region.use_edge_connections = true
    region.navigation_mesh = make_navigation_mesh()
    add_child(region)

static func make_navigation_mesh() -> NavigationMesh:
    # Full shared polygon edges are required at both thresholds.
    var mesh := NavigationMesh.new()
    mesh.vertices = PackedVector3Array([
        Vector3(-9.5, 0, -6.5), Vector3(9.5, 0, -6.5),
        Vector3(9.5, 0, 6.5), Vector3(-9.5, 0, 6.5),
        Vector3(-2, 0, -7), Vector3(2, 0, -7),
        Vector3(-2, 0, 7), Vector3(2, 0, 7),
        Vector3(-2, 0, -6.5), Vector3(2, 0, -6.5),
        Vector3(-2, 0, 6.5), Vector3(2, 0, 6.5)
    ])
    mesh.add_polygon(PackedInt32Array([3, 10, 8, 0]))
    mesh.add_polygon(PackedInt32Array([10, 11, 9, 8]))
    mesh.add_polygon(PackedInt32Array([11, 2, 1, 9]))
    mesh.add_polygon(PackedInt32Array([8, 9, 5, 4]))
    mesh.add_polygon(PackedInt32Array([6, 7, 11, 10]))
    return mesh

func _connector(parent: Node3D, id: String, point: Vector3, yaw: float) -> void:
    var marker := Marker3D.new()
    marker.name = id
    marker.position = point
    marker.rotation.y = yaw
    parent.add_child(marker)

func _box(id: String, point: Vector3, dimensions: Vector3) -> void:
    var body := StaticBody3D.new()
    body.name = id
    body.position = point
    add_child(body)
    var shape := CollisionShape3D.new()
    var box := BoxShape3D.new()
    box.size = dimensions
    shape.shape = box
    body.add_child(shape)
    var visual := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = dimensions
    visual.mesh = mesh
    body.add_child(visual)
