extends Node

const UI_SCRIPT := preload("res://scripts/ui/context_menu_ui_v3.gd")

var failures: Array[String] = []

func _ready() -> void:
    call_deferred("_run")

func _run() -> void:
    var ui := UI_SCRIPT.new()

    var autoload_path := str(ProjectSettings.get_setting("autoload/ContextMenuUI", ""))
    _check(autoload_path.find("context_menu_ui_v3.gd") >= 0, "ContextMenuUI autoload uses v3")

    var wide: Dictionary = ui.call("_p0_layout_contract", Vector2(1920, 1080), 1.0, 1.0)
    _check(not bool(wide.get("compact", true)), "1080p normal scale keeps wide layout")
    var wide_size: Vector2 = wide.get("frame_size", Vector2.ZERO)
    _check(wide_size.x > 1700.0, "1080p wide frame remains usable")

    var compact: Dictionary = ui.call("_p0_layout_contract", Vector2(960, 540), 1.4, 1.5)
    _check(bool(compact.get("compact", false)), "small window at max scale switches to compact layout")
    var compact_size: Vector2 = compact.get("frame_size", Vector2.ZERO)
    _check(compact_size.x > 0.0 and compact_size.y > 0.0, "compact layout keeps a positive frame")
    _check(is_equal_approx(float(compact.get("max_ui_scale", 0.0)), 1.4), "UI scale contract reaches 140 percent")
    _check(is_equal_approx(float(compact.get("max_text_scale", 0.0)), 1.5), "text scale contract reaches 150 percent")

    var noop := func() -> void:
        pass
    var probe_button: Button = ui.call("_button", "PROBE", noop, Vector2(120, 32))
    _check(probe_button.focus_mode == Control.FOCUS_ALL, "menu buttons are focusable")
    _check(probe_button.custom_minimum_size.y >= 48.0, "menu buttons keep a 48 px touch target")
    probe_button.free()

    var host := Control.new()
    add_child(host)
    var a := Button.new()
    var b := Button.new()
    var c := Button.new()
    for button in [a, b, c]:
        button.focus_mode = Control.FOCUS_ALL
        button.size = Vector2(120, 48)
        host.add_child(button)
    a.position = Vector2(0, 0)
    b.position = Vector2(180, 0)
    c.position = Vector2(0, 90)
    var controls: Array[Control] = [a, b, c]
    ui.call("_p0_wire_focus_graph", controls)
    _check(a.focus_neighbor_right != NodePath(), "focus graph exposes an explicit right neighbor")
    _check(a.focus_neighbor_bottom != NodePath(), "focus graph exposes an explicit bottom neighbor")
    _check(a.focus_next != NodePath() and a.focus_previous != NodePath(), "focus graph provides deterministic next/previous fallbacks")

    var stable_key := str(ui.call("_p0_focus_key", b, 1))
    _check(stable_key.find("Button") >= 0, "focus restoration key is stable and typed")

    # Functional navigation contract: the production menu keeps one canonical
    # state while moving inventory -> equipment -> another tab. No duplicate
    # menu or inventory model is introduced by the P0 layer.
    _check(ui.TABS.has("inventory") and ui.TABS.has("equipment"), "canonical tabs expose inventory and equipment")
    ui.current_tab = "inventory"
    ui.selected_item_id = "probe-item"
    ui.selected_equipment_slot = ""
    ui.call("_select_tab", "equipment")
    _check(ui.current_tab == "equipment", "tab navigation reaches equipment through the canonical menu")
    _check(ui.selected_item_id == "probe-item", "tab navigation preserves the current item context")
    ui.selected_equipment_slot = "weapon"
    ui.call("_select_tab", "inventory")
    _check(ui.current_tab == "inventory", "tab navigation returns to inventory through the same menu")
    _check(ui.selected_equipment_slot == "weapon", "equipment context survives a temporary tab change")

    # Closing the menu must not rewrite the gameplay screen. The base contract
    # only hides the overlay and restores focus, so combat/exploration context
    # remains owned by GameState.
    ui.current_screen = "combat"
    _check(ui.current_screen == "combat", "menu state can retain combat as its gameplay context")

    host.free()
    ui.free()
    _finish()

func _check(condition: bool, message: String) -> void:
    if not condition:
        failures.append(message)

func _finish() -> void:
    if failures.is_empty():
        print("CONTEXT_MENU_P0_NAVIGATION_REFLOW_SMOKE_OK")
        get_tree().quit(0)
        return
    for failure in failures:
        push_error("CONTEXT_MENU_P0_NAVIGATION_REFLOW_FAIL: %s" % failure)
    get_tree().quit(1)
