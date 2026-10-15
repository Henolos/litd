extends Area3D

# Physical exit in rooms that the canonical dungeon marks as extraction points.
var world: FirstAccordPlayableWorld
var room_id := ""

func configure(owner_world: FirstAccordPlayableWorld, source_room: String, point: Vector3) -> void:
    world = owner_world
    room_id = source_room
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
    var mesh := CylinderMesh.new()
    mesh.top_radius = 0.35
    mesh.bottom_radius = 0.55
    mesh.height = 1.8
    visual.mesh = mesh
    var material := StandardMaterial3D.new()
    material.albedo_color = Color(0.56, 0.55, 0.43)
    visual.material_override = material
    add_child(visual)

func interaction_descriptor(actor: Object = null) -> Dictionary:
    var reason := ""
    if actor != world.party:
        reason = "wrong_actor"
    elif world.runtime.combat != null:
        reason = "combat_active"
    elif world.current_room_id != room_id:
        reason = "wrong_room"
    elif (actor as Node3D).global_position.distance_to(global_position) > 2.4:
        reason = "out_of_reach"
    elif not world.runtime.campaign.dungeon.can_extract():
        reason = "extraction_unavailable"
    return EnvironmentInteractionContract.descriptor(
        "accord:extraction:" + room_id, EnvironmentInteractionContract.KIND_DOOR,
        "Issue de l’expédition", "EXTRAIRE", reason == "", reason)

func perform_interaction(actor: Object = null) -> Dictionary:
    var descriptor := interaction_descriptor(actor)
    if not bool(descriptor.get("available", false)):
        return EnvironmentInteractionContract.result(descriptor, false, "blocked", str(descriptor.get("blocked_reason", "")))
    var result := world.extract_expedition(room_id)
    return EnvironmentInteractionContract.result(descriptor, bool(result.get("ok", false)), "extracted", str(result.get("reason", "")), result)
