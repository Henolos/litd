extends SceneTree

const CombatEvent := preload("res://scripts/core/combat/veilleurs_combat_event.gd")
const CombatInspector := preload("res://scripts/core/combat/veilleurs_combat_inspector.gd")

func _init() -> void:
    var inspector := CombatInspector.new()
    inspector.set_enabled(true)
    inspector.max_entries = 2

    var source_result := {"hit":true, "damage":8, "roll":12, "accuracy":75, "zone":"torso"}
    var first := CombatEvent.from_attack({"id":"mathilde"}, {"id":"charognard"}, source_result)
    inspector.record(first, {"round":1, "source":"sandbox"})

    source_result.damage = 99
    var snapshot := inspector.latest()
    assert(int(snapshot.event.payload.damage) == 8, "Inspector must snapshot immutable combat event data")
    assert(str(snapshot.context.source) == "sandbox")

    inspector.record(CombatEvent.make("status_applied", "anouk", "charognard", {"affliction":"bleed"}))
    inspector.record(CombatEvent.make("position_changed", "charognard", "charognard", {"from":4, "to":3}))
    assert(inspector.entries().size() == 2, "Inspector must enforce bounded history")
    assert(str(inspector.entries()[0].event.type) == "status_applied")
    assert(str(inspector.entries()[1].event.type) == "position_changed")

    inspector.clear()
    assert(inspector.entries().is_empty())

    inspector.record(first, {"round":2})
    var line := CombatInspector.format_entry(inspector.latest())
    assert(line.contains("attack_hit mathilde -> charognard"))
    assert(line.contains("damage=8"))
    assert(line.contains("round=2"))

    print("VEILLEURS_COMBAT_INSPECTOR_CONTRACT_OK")
    quit(0)
