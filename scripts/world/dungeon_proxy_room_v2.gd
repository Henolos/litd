extends "res://scripts/world/dungeon_proxy_room.gd"

signal interaction_focus_changed(interaction_id: String, label: String)
signal interaction_requested(interaction_id: String, label: String)

# v2 conserve exactement la géométrie de gameplay/collisions du blockout validé
# et ajoute une couche de lecture architecturale remplaçable par Blender.
const FIRST_VEIL_ARCHITECTURE_KIT := preload("res://scripts/world/first_veil_architecture_kit.gd")
const STATIC_RENDER_SUPPORT := ["WorldEnvironment", "KeyLight", "FillLight"]

var architecture_kit: RefCounted = FIRST_VEIL_ARCHITECTURE_KIT.new()
var architecture_summary: Dictionary = {}

func _rebuild() -> void:
    # Le runtime réutilise la même instance de salle pendant les smoke tests et
    # les changements de pièce. Les nœuds statiques de rendu appartiennent à la
    # scène .tscn et doivent survivre au nettoyage du contenu généré. Les perdre
    # supprimait l'environnement et les lumières sur Web/mobile, ce qui pouvait
    # produire une salle entièrement noire malgré une UI fonctionnelle.
    var static_support := _detach_static_render_support()
    for child in get_children():
        child.free()
    super._rebuild()
    _restore_static_render_support(static_support)
    _ensure_explorer_camera_current()
    _hide_proxy_ceiling_for_isometric_camera()
    architecture_summary = {}
    if room_spec.is_empty():
        return
    architecture_summary = architecture_kit.decorate(self, room_spec)
    _connect_explorer_interactions()

func _detach_static_render_support() -> Array[Node]:
    var detached: Array[Node] = []
    for node_name in STATIC_RENDER_SUPPORT:
        var node := get_node_or_null(NodePath(node_name))
        if node == null:
            continue
        remove_child(node)
        detached.append(node)
    return detached

func _restore_static_render_support(detached: Array[Node]) -> void:
    for node in detached:
        if not is_instance_valid(node):
            continue
        add_child(node)

func _ensure_explorer_camera_current() -> void:
    if explorer == null:
        return
    var camera := explorer.get_node_or_null("Camera3D") as Camera3D
    if camera == null:
        return
    camera.current = true
    camera.make_current()

func render_support_ready() -> bool:
    var environment := get_node_or_null("WorldEnvironment") as WorldEnvironment
    var key_light := get_node_or_null("KeyLight") as DirectionalLight3D
    var fill_light := get_node_or_null("FillLight") as OmniLight3D
    var floor_mesh := get_node_or_null("Floor/Mesh") as MeshInstance3D
    var camera: Camera3D = null
    if explorer != null:
        camera = explorer.get_node_or_null("Camera3D") as Camera3D
    return environment != null and key_light != null and fill_light != null and floor_mesh != null and floor_mesh.visible and camera != null and camera.current

func _hide_proxy_ceiling_for_isometric_camera() -> void:
    # Le plafond fait partie du contrat géométrique de la salle, mais la caméra
    # de visite est placée en vue isométrique intérieure. Le laisser rendu peut
    # masquer entièrement la pièce, particulièrement sur le renderer Web/mobile.
    # On ne touche donc ni à la géométrie canonique ni aux collisions : seule la
    # représentation visuelle du plafond proxy est masquée.
    var ceiling_mesh := get_node_or_null("Ceiling/Mesh") as MeshInstance3D
    if ceiling_mesh != null:
        ceiling_mesh.visible = false

func _connect_explorer_interactions() -> void:
    if explorer == null:
        return
    if explorer.has_signal("interaction_focus_changed"):
        explorer.connect("interaction_focus_changed", Callable(self, "_on_explorer_interaction_focus_changed"))
    if explorer.has_signal("interaction_requested"):
        explorer.connect("interaction_requested", Callable(self, "_on_explorer_interaction_requested"))

func _on_explorer_interaction_focus_changed(interaction_id: String, label: String) -> void:
    interaction_focus_changed.emit(interaction_id, label)

func _on_explorer_interaction_requested(interaction_id: String, label: String) -> void:
    interaction_requested.emit(interaction_id, label)

func nearest_interaction_for(world_position: Vector3, radius: float) -> Dictionary:
    var root: Node = find_child("InteractionAnchors", true, false)
    if root == null:
        return {}
    var best: Dictionary = {}
    var best_distance := radius
    for child in root.get_children():
        if child is Marker3D:
            var marker := child as Marker3D
            var distance := marker.global_position.distance_to(world_position)
            if distance <= best_distance:
                best_distance = distance
                best = {
                    "id": marker.name,
                    "label": str(marker.get_meta("interaction_label", "Interaction")),
                    "distance": distance
                }
    return best

func room_summary() -> Dictionary:
    var summary: Dictionary = super.room_summary()
    summary["architecture"] = architecture_summary.duplicate(true)
    summary["blender_contract_ready"] = not architecture_kit.blender_contract().is_empty()
    summary["architecture_kit_version"] = int(architecture_summary.get("kit_version", 0))
    summary["contextual_interactions"] = true
    summary["render_support_ready"] = render_support_ready()
    return summary
