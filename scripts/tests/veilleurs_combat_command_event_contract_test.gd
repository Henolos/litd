extends SceneTree

const CombatCommand := preload("res://scripts/core/combat/veilleurs_combat_command.gd")
const CombatEvent := preload("res://scripts/core/combat/veilleurs_combat_event.gd")

func _init() -> void:
    var command := CombatCommand.make("mathilde", "strike", "enemy", 0, "head")
    assert(bool(CombatCommand.validate(command).ok))
    assert(not bool(CombatCommand.validate({}).ok))
    var result := {"hit":false,"roll":98,"accuracy":75}
    var event := CombatEvent.from_attack({"id":"mathilde"}, {"id":"charognard"}, result)
    assert(event.type == "attack_miss")
    assert(event.actor_id == "mathilde")
    assert(event.target_id == "charognard")
    assert(int(event.payload.roll) == 98)
    result.roll = 1
    assert(int(event.payload.roll) == 98, "Event payload must snapshot result")
    print("VEILLEURS_COMBAT_COMMAND_EVENT_CONTRACT_OK")
    quit(0)
