extends Node3D
class_name FirstAccordModuleBlockout

# Physical proxy for modules that have no authored scene yet. Dimensions and
# connectors come from the same module library used by the room resolver.
const LIBRARY_PATH := "res://data/dungeons/first_accord_module_library.json"
const SIZES := {"m": Vector2(18, 14), "l": Vector2(24, 18), "xl": Vector2(28, 22), "boss": Vector2(30, 24)}

var module_id := ""
var definition: Dictionary = {}

func configure(id: String, module: Dictionary) -> bool:
    if id == "" or str(module.get("module_id", "")) != id or module.get("connectors", []).is_empty():
        return false
    module_id = id
    definition = module.duplicate(true)
    return true

func _ready() -> void:
    if definition.is_empty():
        push_error("FirstAccordModuleBlockout: configure before adding to tree")
        return
    set_meta("module_id", module_id)
    set_meta("physical_tier", "proxy")
    var size: Vector2 = SIZES.get(str(definition.get("size_class", "m")), Vector2.ZERO)
    if size == Vector2.ZERO:
        push_error("FirstAccordModuleBlockout: invalid size class")
        return
    _box("Floor", Vector3(0, -0.3, 0), Vector3(size.x, 0.6, size.y))
    var connectors := Node3D.new()
    connectors.name = "Connectors"
    add_child(connectors)
    var sides := {"north": false, "south": false, "east": false, "west": false}
    for spec in definition.get("connectors", []):
        var side := str(spec.get("orientation", ""))
        if not sides.has(side):
            push_error("FirstAccordModuleBlockout: unsupported connector orientation")
            continue
        sides[side] = true
        var marker := Marker3D.new()
        marker.name = str(spec.get("id", ""))
        marker.position = _threshold(side, size)
        marker.set_meta("connector_type", str(spec.get("type", "")))
        marker.set_meta("compatibility_tags", spec.get("compatibility_tags", []).duplicate())
        marker.set_meta("level", int(spec.get("level", 0)))
        marker.set_meta("hidden", bool(spec.get("hidden", false)))
        connectors.add_child(marker)
    _wall("North", size.x, -size.y * 0.5, true, bool(sides.north))
    _wall("South", size.x, size.y * 0.5, true, bool(sides.south))
    _wall("West", size.y, -size.x * 0.5, false, bool(sides.west))
    _wall("East", size.y, size.x * 0.5, false, bool(sides.east))
    for category in ["scar", "encounter", "resource", "lore"]:
        var anchors := Node3D.new()
        anchors.name = category.capitalize() + "Anchors"
        add_child(anchors)
        var entries: Array = definition.get(category + "_anchors", [])
        for i in entries.size():
            var marker := Marker3D.new()
            marker.name = str(entries[i].get("anchor_id", "anchor_%d" % i)).replace(".", "_")
            marker.position = Vector3(float((i % 3) - 1) * 3.0, 0.0, float(i / 3) * 3.0)
            marker.set_meta("anchor_id", str(entries[i].get("anchor_id", "")))
            anchors.add_child(marker)

func _threshold(side: String, size: Vector2) -> Vector3:
    match side:
        "north": return Vector3(0, 0, -size.y * 0.5)
        "south": return Vector3(0, 0, size.y * 0.5)
        "east": return Vector3(size.x * 0.5, 0, 0)
        _: return Vector3(-size.x * 0.5, 0, 0)

func _wall(id: String, span: float, offset: float, horizontal: bool, opening: bool) -> void:
    var gap := 4.0 if opening else 0.0
    var length := (span - gap) * 0.5 if opening else span
    if opening:
        for sign_value in [-1.0, 1.0]:
            var along: float = sign_value * (gap + length) * 0.5
            var position := Vector3(along, 2, offset) if horizontal else Vector3(offset, 2, along)
            _box(id + ("Left" if sign_value < 0 else "Right"), position, Vector3(length, 4, 0.8) if horizontal else Vector3(0.8, 4, length))
    else:
        _box(id, Vector3(0, 2, offset) if horizontal else Vector3(offset, 2, 0), Vector3(span, 4, 0.8) if horizontal else Vector3(0.8, 4, span))

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
