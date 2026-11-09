extends Control
## Prototype de sélection anatomique : affichage uniquement, aucun calcul de combat.
## Le contrôleur parent fournit les zones et traite la confirmation d'attaque.
class_name AnatomyTargetSelector

signal zone_selected(zone_id: String)

const HUMANOID_ZONES := [
    {"id": "head", "label": "Tête", "rect": Rect2(0.39, 0.03, 0.22, 0.15)},
    {"id": "torso", "label": "Torse", "rect": Rect2(0.32, 0.22, 0.36, 0.28)},
    {"id": "left_arm", "label": "Bras G", "rect": Rect2(0.04, 0.23, 0.25, 0.30)},
    {"id": "right_arm", "label": "Bras D", "rect": Rect2(0.71, 0.23, 0.25, 0.30)},
    {"id": "left_leg", "label": "Jambe G", "rect": Rect2(0.26, 0.55, 0.22, 0.41)},
    {"id": "right_leg", "label": "Jambe D", "rect": Rect2(0.52, 0.55, 0.22, 0.41)}
]

var _zones: Array[Dictionary] = []
var _selected_zone: String = ""
var _buttons: Dictionary = {}

func _ready() -> void:
    custom_minimum_size = Vector2(240, 300)
    set_zones(HUMANOID_ZONES)

func set_zones(zones: Array) -> void:
    _zones.clear()
    for entry in zones:
        if entry is Dictionary and entry.has("id") and entry.has("rect"):
            _zones.append((entry as Dictionary).duplicate(true))
    if is_node_ready():
        _rebuild()

func set_selected_zone(zone_id: String) -> void:
    _selected_zone = zone_id
    _refresh()

func _rebuild() -> void:
    for child in get_children():
        remove_child(child)
        child.queue_free()
    _buttons.clear()
    for entry in _zones:
        var zone_id := str(entry.get("id", ""))
        var rect: Rect2 = entry.get("rect", Rect2())
        var button := Button.new()
        button.text = str(entry.get("label", zone_id))
        button.tooltip_text = str(entry.get("reason", ""))
        button.disabled = not bool(entry.get("targetable", true))
        button.anchor_left = rect.position.x
        button.anchor_top = rect.position.y
        button.anchor_right = rect.end.x
        button.anchor_bottom = rect.end.y
        button.offset_left = 0
        button.offset_top = 0
        button.offset_right = 0
        button.offset_bottom = 0
        button.focus_mode = Control.FOCUS_ALL
        button.pressed.connect(_on_zone_pressed.bind(zone_id))
        add_child(button)
        _buttons[zone_id] = button
    _refresh()

func _refresh() -> void:
    for zone_id in _buttons:
        var button: Button = _buttons[zone_id]
        button.button_pressed = zone_id == _selected_zone
        button.toggle_mode = true

func _on_zone_pressed(zone_id: String) -> void:
    if not _buttons.has(zone_id) or (_buttons[zone_id] as Button).disabled:
        return
    set_selected_zone(zone_id)
    zone_selected.emit(zone_id)
