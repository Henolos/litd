extends Node

var failures: Array[String] = []
var outside_clicks := 0
var covered_clicks := 0

func _ready() -> void:
    call_deferred("_run")

func _run() -> void:
    var field := Control.new()
    field.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    field.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(field)
    var outside := Button.new()
    outside.position = Vector2(20, 400)
    outside.size = Vector2(180, 60)
    outside.text = "Action de combat"
    outside.pressed.connect(func(): outside_clicks += 1)
    field.add_child(outside)
    outside.grab_focus()
    var inspector := get_node("/root/CombatantInspectionUI")
    inspector.call("open_detail", {"id":"hud_input_test","name":"Veilleur","hp":20,"max_hp":20}, false)
    await get_tree().process_frame
    await get_tree().process_frame
    var close: Button = inspector.get("detail_close_button")
    _check(close.has_focus(), "opening inspection focuses its close control")
    var frame: PanelContainer = inspector.get("detail_frame")
    var dim := (inspector.get("detail_overlay") as Control).get_child(0) as ColorRect
    _check(dim.color.a == 0.0, "inspection backdrop stays transparent")
    _check(dim.mouse_filter == Control.MOUSE_FILTER_IGNORE, "backdrop ignores mouse input")
    _check((inspector.get("detail_overlay") as Control).mouse_filter == Control.MOUSE_FILTER_IGNORE, "overlay ignores mouse input")
    _check(frame.mouse_filter == Control.MOUSE_FILTER_STOP, "panel absorbs its own clicks")
    var covered := Button.new()
    covered.position = frame.get_global_rect().position
    covered.size = frame.size
    covered.text = "Underlying action"
    covered.pressed.connect(func(): covered_clicks += 1)
    field.add_child(covered)
    await get_tree().process_frame
    await _click(outside.get_global_rect().get_center())
    _check(outside_clicks == 1, "combat action outside inspection remains clickable")
    _check(bool(inspector.get("detail_open")), "outside combat action does not close inspection")
    await _click(frame.get_global_rect().position + Vector2(5, 5))
    _check(covered_clicks == 0, "click inside inspection never executes underlying action")
    await _click(close.get_global_rect().get_center())
    _check(not bool(inspector.get("detail_open")), "close button works through the overlay")
    _check(outside.has_focus(), "closing inspection restores original combat focus")
    await _click(covered.get_global_rect().get_center())
    _check(covered_clicks == 1, "closing inspection restores the previously covered action")
    await _check_focus_lifecycle(inspector, outside, covered)
    field.queue_free()
    if failures.is_empty():
        print("COMBATANT_INSPECTION_INPUT_SMOKE_OK")
        get_tree().quit(0)
    else:
        for message in failures:
            push_error("COMBATANT_INSPECTION_INPUT_SMOKE_FAIL: " + message)
        get_tree().quit(1)

func _click(at: Vector2) -> void:
    var motion := InputEventMouseMotion.new()
    motion.position = at
    motion.global_position = at
    get_viewport().push_input(motion, true)
    for pressed in [true, false]:
        var event := InputEventMouseButton.new()
        event.position = at
        event.global_position = at
        event.button_index = MOUSE_BUTTON_LEFT
        event.pressed = pressed
        get_viewport().push_input(event, true)
        await get_tree().process_frame

func _check(condition: bool, message: String) -> void:
    if not condition:
        failures.append(message)

func _check_focus_lifecycle(inspector: Node, outside: Button, covered: Button) -> void:
    var actor := {"id":"hud_input_test","name":"Veilleur","hp":20,"max_hp":20}
    outside.grab_focus()
    inspector.call("open_detail", actor, false)
    await get_tree().process_frame
    await get_tree().process_frame
    var cancel := InputEventAction.new()
    cancel.action = "back"
    cancel.pressed = true
    get_viewport().push_input(cancel, true)
    await get_tree().process_frame
    _check(not bool(inspector.get("detail_open")) and outside.has_focus(), "back closes inspection and returns focus")
    inspector.call("open_detail", actor, false)
    await get_tree().process_frame
    await get_tree().process_frame
    covered.grab_focus()
    inspector.call("close_detail")
    _check(covered.has_focus(), "closing preserves a newer outside focus choice")
    outside.grab_focus()
    inspector.call("open_detail", actor, false)
    await get_tree().process_frame
    await get_tree().process_frame
    outside.hide()
    inspector.call("close_detail")
    _check(not outside.has_focus(), "hidden combat control is not refocused")
    outside.show()
    var removed := Button.new()
    add_child(removed)
    removed.grab_focus()
    inspector.call("open_detail", actor, false)
    await get_tree().process_frame
    await get_tree().process_frame
    removed.free()
    inspector.call("close_detail")
    _check(not bool(inspector.get("detail_open")), "deleted return control is handled safely")
