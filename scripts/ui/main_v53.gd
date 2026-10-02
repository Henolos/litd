extends "res://scripts/ui/main_v52.gd"

# v53 — anatomical targeting consolidation.
# Keeps the full main_v52 stack and replaces only the Combat Sandbox runtime
# and zone controls with the canonical targeting contract.

const SANDBOX_RUNTIME_V2_SCRIPT := preload("res://scripts/core/veilleurs_combat_sandbox_runtime_v2.gd")
const SANDBOX_TARGET_RESOLVER := preload("res://scripts/core/combat/veilleurs_target_resolver.gd")

var _sandbox_runtime_v2_installed := false

func _ensure_sandbox_started() -> void:
    if not _sandbox_runtime_v2_installed:
        _sandbox = SANDBOX_RUNTIME_V2_SCRIPT.new()
        _sandbox_started = false
        _sandbox_runtime_v2_installed = true
    super._ensure_sandbox_started()

func _render_sandbox_zones() -> void:
    var box := VBoxContainer.new()
    box.position = Vector2(470, 322)
    box.size = Vector2(420, 180)
    box.add_theme_constant_override("separation", 5)
    content.add_child(box)
    box.add_child(make_label("ZONE ANATOMIQUE", 13, CANON_GOLD))

    var action := _sandbox_selected_action_data()
    var zones: Array[String] = SANDBOX_TARGET_RESOLVER.body_zones_for_action(action)
    if zones.is_empty():
        zones = SANDBOX_TARGET_RESOLVER.ZONES.duplicate()

    var grid := GridContainer.new()
    grid.columns = 2
    grid.add_theme_constant_override("h_separation", 5)
    grid.add_theme_constant_override("v_separation", 5)
    box.add_child(grid)

    var requires_zone := not action.is_empty() and SANDBOX_TARGET_RESOLVER.requires_body_zone(action)
    for zone: String in zones:
        var selected := zone == _sandbox_selected_zone
        var button := make_button(
            ("◆ " if selected else "") + SANDBOX_TARGET_RESOLVER.body_zone_label(zone),
            func(z = zone): _sandbox_select_zone(str(z)),
            Vector2(190, 42)
        )
        button.disabled = not action.is_empty() and not requires_zone
        grid.add_child(button)

func _sandbox_select_zone(zone: String) -> void:
    var normalized := SANDBOX_TARGET_RESOLVER.normalize_zone(zone)
    var action := _sandbox_selected_action_data()
    if not action.is_empty() and SANDBOX_TARGET_RESOLVER.requires_body_zone(action):
        var enemies: Array = _sandbox.get("enemies")
        if _sandbox_selected_target < 0 or _sandbox_selected_target >= enemies.size():
            return
        var target: Dictionary = enemies[_sandbox_selected_target]
        if not SANDBOX_TARGET_RESOLVER.can_target_body_zone(action, target, normalized):
            return
    _sandbox_selected_zone = normalized
    _sandbox_focus_confirm_v51 = _sandbox_action_ready()
    show_screen("combat_sandbox")
