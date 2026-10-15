extends Area3D

# A nearby seal/lever uses the same targeting contract as other world objects.
var world: Node3D
var edge: Dictionary = {}
var side_room := ""

func configure(owner_world: Node3D, passage: Dictionary, room_id: String, point: Vector3) -> void:
    world = owner_world
    edge = passage.duplicate(true)
    side_room = room_id
    position = point + Vector3.UP
    collision_layer = 1
    collision_mask = 0
    monitoring = false
    var collision := CollisionShape3D.new()
    var shape := SphereShape3D.new()
    shape.radius = 0.7
    collision.shape = shape
    add_child(collision)
    var visual := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = Vector3(0.6, 1.0, 0.6)
    visual.mesh = mesh
    var material := StandardMaterial3D.new()
    material.albedo_color = Color(0.65, 0.45, 0.22) if is_shortcut() else Color(0.4, 0.5, 0.6)
    visual.material_override = material
    add_child(visual)

func is_shortcut() -> bool:
    return str(edge.get("requires", "")) == "unlock_from_deep_side"

func edge_id() -> String:
    return str(edge.get("from", "")) + ">" + str(edge.get("to", ""))

func interaction_descriptor(actor: Object = null) -> Dictionary:
    var opened: bool = world.runtime.campaign.dungeon.passage_is_open(edge)
    var reason := ""
    if actor != world.party:
        reason = "wrong_actor"
    elif world.runtime.combat != null:
        reason = "combat_active"
    elif world.current_room_id != side_room:
        reason = "wrong_room"
    elif (actor as Node3D).global_position.distance_to(global_position) > 2.4:
        reason = "out_of_reach"
    elif not opened and side_room != str(edge.get("from", "")):
        reason = "wrong_side"
    elif not bool(world.runtime.campaign.dungeon.node_flags.get(side_room, {}).get("completed", false)):
        reason = "room_not_cleared"
    return EnvironmentInteractionContract.descriptor(
        "accord:passage:" + edge_id(),
        EnvironmentInteractionContract.KIND_MECHANISM if is_shortcut() else EnvironmentInteractionContract.KIND_CURIOSITY,
        "Levier du raccourci" if is_shortcut() else "Sceau ancien",
        "PASSAGE OUVERT" if opened else ("OUVRIR" if is_shortcut() else "EXAMINER"),
        reason == "", reason, opened, {"open":opened})

func perform_interaction(actor: Object = null) -> Dictionary:
    var descriptor := interaction_descriptor(actor)
    if not bool(descriptor.get("available", false)):
        return EnvironmentInteractionContract.result(descriptor, false, "blocked", str(descriptor.get("blocked_reason", "")))
    var result: Dictionary = world.open_passage(edge_id(), is_shortcut())
    return EnvironmentInteractionContract.result(descriptor, bool(result.get("ok", false)), "opened" if bool(result.get("changed", false)) else "already_open", str(result.get("reason", "")), result)
