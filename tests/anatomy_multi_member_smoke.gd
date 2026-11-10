extends SceneTree

# Run with: godot --headless --path . --script res://tests/anatomy_multi_member_smoke.gd
func _initialize() -> void:
    var runtime_script = load("res://scripts/core/anatomy_runtime.gd")
    var runtime = runtime_script.new()
    get_root().add_child(runtime)
    var cerberus := {"dismemberment_profile": "cerberus", "hp": 100, "max_hp": 100}
    var cerberus_parts: Array = runtime.targetable_parts(cerberus)
    for part_id in ["left_head", "center_head", "right_head"]:
        assert(_contains(cerberus_parts, part_id), "Cerberus head missing: " + part_id)
    cerberus["dismembered_parts"] = ["left_head"]
    assert(not _contains(runtime.targetable_parts(cerberus), "left_head"), "Severed head still targetable")
    assert(_contains(runtime.targetable_parts(cerberus), "center_head"), "Healthy head disappeared")
    var hydra := {"dismemberment_profile": "hydra", "hp": 100, "max_hp": 100}
    for part_id in ["head_1", "head_2", "head_3"]:
        assert(_contains(runtime.targetable_parts(hydra), part_id), "Hydra head missing: " + part_id)
    var spider := {"dismemberment_profile": "jorogumo", "hp": 100, "max_hp": 100}
    var visible: Array = runtime.targetable_parts(spider)
    assert(visible.size() == 7, "Jorogumo must expose seven UI targets")
    assert(_contains(visible, "spider_legs"), "Grouped legs target missing")
    assert(not _contains(visible, "left_spider_leg_1"), "Physical leg must be hidden in UI")
    var group: Dictionary = runtime.part_definition(spider, "spider_legs")
    assert(runtime.directional_group_candidates(spider, group["members"], "vertical", "left").size() == 4)
    assert(runtime.directional_group_candidates(spider, group["members"], "lateral").size() == 8)
    spider["dismembered_parts"] = ["left_spider_leg_1"]
    assert(runtime.directional_group_candidates(spider, group["members"], "vertical", "left").size() == 3)
    var hero := {"id": "test_hero", "precision": 100}
    var outcome: Dictionary = runtime.register_directional_group_hit(hero, spider, "normal", 11, "spider_legs", "lateral", "", "", 0)
    assert(outcome.get("damage_allocated", -1) == 11, "Damage budget changed")
    assert(outcome.get("resolved_member_ids", []).size() == 2, "Lateral hit must select two sides")
    assert(outcome.get("hits", []).size() == 2, "Missing physical hit results")
    # JSON round-trip of combat anatomy state, independent of the visual rig.
    # This checks data survival only; SaveManager integration is tested separately.
    var combat_snapshot := {
        "cerberus": cerberus.duplicate(true),
        "hydra": hydra.duplicate(true),
        "jorogumo": spider.duplicate(true)
    }
    var decoded: Variant = JSON.parse_string(JSON.stringify(combat_snapshot))
    assert(decoded is Dictionary, "Anatomy snapshot JSON did not decode")
    var restored: Dictionary = decoded
    var restored_cerberus: Dictionary = restored["cerberus"]
    assert(not _contains(runtime.targetable_parts(restored_cerberus), "left_head"), "Cerberus severed head restored")
    assert(_contains(runtime.targetable_parts(restored_cerberus), "right_head"), "Cerberus healthy head lost on reload")
    var restored_spider: Dictionary = restored["jorogumo"]
    assert(restored_spider.get("dismembered_parts", []).has("left_spider_leg_1"), "Spider lost severed leg on reload")
    var original_trauma: Dictionary = spider.get("anatomy_part_trauma", {})
    var restored_trauma: Dictionary = restored_spider.get("anatomy_part_trauma", {})
    assert(restored_trauma.size() == original_trauma.size(), "Spider trauma member count changed on reload")
    for member_id in original_trauma:
        assert(restored_trauma.has(member_id), "Spider trauma member missing on reload: " + str(member_id))
        assert(int(restored_trauma[member_id]) == int(original_trauma[member_id]), "Spider trauma value changed on reload: " + str(member_id))
    assert(restored_spider.get("anatomy_injuries", {}) == spider.get("anatomy_injuries", {}), "Spider injury states changed on reload")
    assert(runtime.directional_group_candidates(restored_spider, group["members"], "vertical", "left").size() == 3, "Reload changed available legs")
    print("anatomy_multi_member_smoke: PASS")
    quit(0)

func _contains(parts: Array, id: String) -> bool:
    for part in parts:
        if str(part.get("id", "")) == id:
            return true
    return false
