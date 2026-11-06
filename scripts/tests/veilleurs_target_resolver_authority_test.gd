extends Node

const TARGET_RESOLVER := preload("res://scripts/core/combat/veilleurs_target_resolver.gd")

class FakeGrid:
    var distances := {}
    func distance(a: String, b: String) -> int:
        return int(distances.get(a + "|" + b, -1))

class FakeBehavior:
    func effective_action(skill: Dictionary) -> String:
        return str(skill.get("action_type", "attack"))
    func range_for(skill: Dictionary) -> int:
        return int(skill.get("range_cells", 1))

class FakeRuntime:
    var combatants := {}
    var grid := FakeGrid.new()
    var skill_behavior := FakeBehavior.new()

var failures: Array[String] = []

func _ready() -> void:
    var runtime := FakeRuntime.new()
    runtime.combatants = {
        "hero":{"hp":10},
        "near":{"hp":10},
        "far":{"hp":10},
        "dead":{"hp":0},
        "subdued":{"hp":10, "subdued":true}
    }
    runtime.grid.distances = {
        "hero|near":1,
        "hero|far":3,
        "hero|dead":1,
        "hero|subdued":1
    }
    var melee := {"action_type":"attack", "range_cells":1}
    var sets := TARGET_RESOLVER.tactical_target_sets(runtime, "hero", melee, ["near", "far", "dead", "subdued"])
    _expect((sets.get("candidates", []) as Array).has("near"), "near target must be legal")
    _expect((sets.get("blocked", []) as Array).has("far"), "far target must be blocked")
    _expect(str((sets.get("reasons", {}) as Dictionary).get("far", "")) == "out_of_range", "far target reason")
    _expect(str((sets.get("reasons", {}) as Dictionary).get("dead", "")) == "target_unavailable", "dead target reason")
    _expect(str((sets.get("reasons", {}) as Dictionary).get("subdued", "")) == "target_unavailable", "subdued target reason")
    var move_attack := {"action_type":"attack_move", "range_cells":1}
    var move_verdict := TARGET_RESOLVER.validate_tactical_target(runtime, "hero", "far", move_attack)
    _expect(bool(move_verdict.get("ok", false)), "attack_move may acquire distant target before movement")
    var zone_action := {"target":"enemy_zone","requires_body_zone":true}
    var amputated_body := VeilleursBodyComponent.new()
    amputated_body.missing_parts.append("left_arm")
    var anatomical_target := {"hp":10,"body":amputated_body}
    _expect(not TARGET_RESOLVER.can_target_body_zone(zone_action, anatomical_target, "left_arm"), "amputated component arm must not be targetable")
    _expect(TARGET_RESOLVER.can_target_body_zone(zone_action, anatomical_target, "right_arm"), "intact arm must remain targetable")
    _expect(not TARGET_RESOLVER.can_target_body_zone(zone_action, anatomical_target, "invalid_zone"), "invalid zone must not silently target torso")
    var serialized_target := {"hp":10,"body":amputated_body.serialize()}
    _expect(not TARGET_RESOLVER.can_target_body_zone(zone_action, serialized_target, "left_arm"), "serialized amputation must not be targetable")
    _expect(TARGET_RESOLVER.can_target_body_zone(zone_action, serialized_target, "right_arm"), "serialized intact arm remains targetable")
    if failures.is_empty():
        print("VEILLEURS_TARGET_RESOLVER_AUTHORITY_OK")
        get_tree().quit(0)
        return
    for failure in failures:
        push_error(failure)
    get_tree().quit(1)

func _expect(value: bool, message: String) -> void:
    if not value:
        failures.append(message)
