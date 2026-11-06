extends Node

var failures: Array[String] = []

func expect(ok: bool, label: String) -> void:
    if not ok:
        failures.append(label)
        push_error(label)

func _ready() -> void:
    var ui := VeilleursTacticalUI.new()
    add_child(ui)
    var body := VeilleursBodyComponent.new()
    body.missing_parts.append("left_arm")
    var snapshot := {"combatants":{"enemy":{"team":"enemy","hp":30,"body":body.serialize()}}}
    ui.bind_snapshot(snapshot)
    ui.set_external_selection("", "enemy", "left_arm")
    expect(ui.selected_zone == "torso", "amputated_selection_repaired")
    var left_button: Button = ui.zone_buttons[2]
    var right_button: Button = ui.zone_buttons[3]
    expect(not left_button.visible, "amputated_arm_hidden")
    expect(right_button.visible, "intact_arm_visible")
    ui._on_zone_pressed("left_arm")
    expect(ui.selected_zone == "torso", "hidden_arm_cannot_be_selected")
    ui._on_zone_pressed("right_arm")
    expect(ui.selected_zone == "right_arm", "intact_arm_selectable")
    body.missing_parts.clear()
    ui.bind_snapshot({"combatants":{"enemy":{"team":"enemy","hp":30,"body":body.serialize()}}})
    expect(left_button.visible, "restored_arm_visible")
    print("VEILLEURS_AMPUTATED_TARGET_UI_", "OK" if failures.is_empty() else "FAILED")
    get_tree().quit(0 if failures.is_empty() else 1)
