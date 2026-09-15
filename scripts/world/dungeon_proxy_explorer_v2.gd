extends "res://scripts/world/dungeon_proxy_explorer.gd"

# P0 mobile : le blockout 3D doit rester jouable sans clavier.
# On conserve exactement le contrôleur desktop existant et on lui ajoute un
# D-pad tactile + interaction. Ces contrôles sont purement UI et n'altèrent pas
# la géométrie ni le contrat des salles.

var _virtual_direction := Vector2.ZERO
var _touch_layer: CanvasLayer = null
var _held := {"left": false, "right": false, "up": false, "down": false}

func _ready() -> void:
    super._ready()
    if _touch_controls_required():
        _create_touch_controls()

func _movement_input() -> Vector2:
    var keyboard := super._movement_input()
    _refresh_virtual_direction()
    var combined := keyboard + _virtual_direction
    return combined.normalized() if combined.length_squared() > 1.0 else combined

func _touch_controls_required() -> bool:
    return DisplayServer.is_touchscreen_available() or OS.has_feature("mobile") or OS.has_feature("web_ios") or OS.has_feature("web_android")

func _refresh_virtual_direction() -> void:
    var x := float(_held["right"]) - float(_held["left"])
    var y := float(_held["down"]) - float(_held["up"])
    _virtual_direction = Vector2(x, y)
    if _virtual_direction.length_squared() > 1.0:
        _virtual_direction = _virtual_direction.normalized()

func _create_touch_controls() -> void:
    if _touch_layer != null:
        return
    _touch_layer = CanvasLayer.new()
    _touch_layer.name = "DungeonTouchControls"
    _touch_layer.layer = 90
    add_child(_touch_layer)

    var root := Control.new()
    root.name = "TouchRoot"
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _touch_layer.add_child(root)

    var dpad := Control.new()
    dpad.name = "DPad"
    dpad.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
    dpad.offset_left = 24.0
    dpad.offset_top = -250.0
    dpad.offset_right = 244.0
    dpad.offset_bottom = -24.0
    dpad.mouse_filter = Control.MOUSE_FILTER_IGNORE
    root.add_child(dpad)

    _add_hold_button(dpad, "Up", "▲", Vector2(76, 0), "up")
    _add_hold_button(dpad, "Left", "◀", Vector2(0, 76), "left")
    _add_hold_button(dpad, "Right", "▶", Vector2(152, 76), "right")
    _add_hold_button(dpad, "Down", "▼", Vector2(76, 152), "down")

    var interact := Button.new()
    interact.name = "TouchInteract"
    interact.text = "INTERAGIR"
    interact.focus_mode = Control.FOCUS_NONE
    interact.custom_minimum_size = Vector2(180, 76)
    interact.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
    interact.offset_left = -214.0
    interact.offset_top = -118.0
    interact.offset_right = -34.0
    interact.offset_bottom = -42.0
    interact.pressed.connect(_on_touch_interact_pressed)
    root.add_child(interact)

    var hint := Label.new()
    hint.name = "TouchHint"
    hint.text = "Déplacement tactile"
    hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    hint.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
    hint.offset_left = 24.0
    hint.offset_top = -286.0
    hint.offset_right = 244.0
    hint.offset_bottom = -258.0
    hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
    root.add_child(hint)

func _add_hold_button(parent: Control, node_name: String, label: String, position_value: Vector2, key: String) -> void:
    var button := Button.new()
    button.name = node_name
    button.text = label
    button.focus_mode = Control.FOCUS_NONE
    button.position = position_value
    button.size = Vector2(68, 68)
    button.custom_minimum_size = Vector2(68, 68)
    button.button_down.connect(func(): _set_touch_hold(key, true))
    button.button_up.connect(func(): _set_touch_hold(key, false))
    parent.add_child(button)

func _set_touch_hold(key: String, value: bool) -> void:
    _held[key] = value
    _refresh_virtual_direction()

func _on_touch_interact_pressed() -> void:
    if focused_interaction_id == "":
        return
    interaction_requested.emit(focused_interaction_id, focused_interaction_label)
