extends SceneTree

const CombatEvent := preload("res://scripts/core/combat/veilleurs_combat_event.gd")
const CombatInspector := preload("res://scripts/core/combat/veilleurs_combat_inspector.gd")

func _init() -> void:
    var inspector := CombatInspector.new()
    inspector.set_enabled(true)
    inspector.set_max_entries(2)
    assert(inspector.has_signal("entry_recorded"))

    var source_result := {"hit":true, "damage":8, "roll":12, "accuracy":75, "zone":"torso"}
    var first := CombatEvent.from_attack({"id":"mathilde"}, {"id":"charognard"}, source_result)
    inspector.record(first, {"round":1, "source":"sandbox"})

    source_result.damage = 99
    var snapshot := inspector.latest()
    assert(int(snapshot.sequence) == 1)
    assert(int(snapshot.event.payload.damage) == 8, "Inspector must snapshot immutable combat event data")
    assert(str(snapshot.context.source) == "sandbox")

    inspector.record(CombatEvent.make("status_applied", "anouk", "charognard", {"affliction":"bleed"}), {"source":"sandbox"})
    inspector.record(CombatEvent.make("position_changed", "charognard", "charognard", {"from":4, "to":3}), {"source":"formation"})
    assert(inspector.entries().size() == 2, "Inspector must enforce bounded history")
    assert(str(inspector.entries()[0].event.type) == "status_applied")
    assert(str(inspector.entries()[1].event.type) == "position_changed")
    assert(inspector.query({"source":"sandbox"}).size() == 1)
    assert(inspector.query({"type":"position_changed"}).size() == 1)

    var summary := inspector.summary()
    assert(int(summary.entries) == 2)
    assert(int(summary.by_type.status_applied) == 1)
    assert(int(summary.by_source.formation) == 1)

    inspector.clear()
    assert(inspector.entries().is_empty())

    inspector.record(first, {"round":2, "source":"sandbox"})
    var line := CombatInspector.format_entry(inspector.latest())
    assert(line.contains("#1 attack_hit mathilde -> charognard"))
    assert(line.contains("damage=8"))
    assert(line.contains("round=2"))

    var attack_summary := inspector.summary()
    assert(int(attack_summary.hits) == 1)
    assert(int(attack_summary.misses) == 0)
    assert(int(attack_summary.total_damage) == 8)

    print("VEILLEURS_COMBAT_INSPECTOR_CONTRACT_OK")
    quit(0)
