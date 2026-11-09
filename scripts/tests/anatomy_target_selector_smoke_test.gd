extends SceneTree

# Headless smoke: godot --headless --path . --script res://scripts/tests/anatomy_target_selector_smoke_test.gd
const PROFILE = preload("res://scripts/ui/anatomy_target_profile.gd")
const SELECTOR = preload("res://scripts/ui/anatomy_target_selector.gd")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var profile: Dictionary = PROFILE.profile_for_enemy({"id": 2})
    assert(bool(profile.get("ok", false)), "Candidate humanoid profile missing")
    var unknown: Dictionary = PROFILE.profile_for_enemy({"id": 9999})
    assert(not bool(unknown.get("ok", true)), "Unknown anatomy must fall back")
    var enemy := {"id": 2, "body": {"missing_parts": ["left_arm"]}}
    var zones: Array[Dictionary] = PROFILE.display_zones(enemy)
    assert(zones.size() == 6, "Humanoid should have six zones")
    var left_arm: Dictionary = zones[2]
    assert(not bool(left_arm.get("available", true)), "Amputated arm must be disabled")
    var selector: Control = SELECTOR.new()
    root.add_child(selector)
    await process_frame
    var button_zones: Array[Dictionary] = []
    for zone in zones:
        var anchor: Vector2 = zone["anchor"]
        button_zones.append({
            "id": zone["id"], "label": zone["label"],
            "rect": Rect2(anchor - Vector2(0.11, 0.12), Vector2(0.22, 0.24)),
            "targetable": zone["available"], "reason": zone["reason"]
        })
    selector.call("set_zones", button_zones)
    selector.call("set_selected_zone", "head")
    assert(selector.get_child_count() == 6, "Selector must render six zone buttons")
    assert((selector.get_child(2) as Button).disabled, "Amputated arm must not be clickable")
    selector.queue_free()
    print("ANATOMY_SELECTOR_SMOKE_OK")
    quit(0)
