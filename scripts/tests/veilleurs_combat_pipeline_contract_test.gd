extends SceneTree

const TargetResolver := preload("res://scripts/core/combat/veilleurs_target_resolver.gd")
const StatusResolver := preload("res://scripts/core/combat/veilleurs_status_resolver.gd")
const ReactionResolver := preload("res://scripts/core/combat/veilleurs_reaction_resolver.gd")
const CombatCommand := preload("res://scripts/core/combat/veilleurs_combat_command.gd")
const CombatEvent := preload("res://scripts/core/combat/veilleurs_combat_event.gd")

func _init() -> void:
    assert(TargetResolver.normalize_zone("head") == "head")
    assert(TargetResolver.normalize_zone("invalid") == "torso")
    var command := CombatCommand.make("mathilde", "strike", "enemy", 0, "head")
    assert(bool(CombatCommand.validate(command).ok))
    var status := StatusResolver.resolve_after_hit({"max_hp":100,"bleeding_state":"none"}, {"impact":"slashing"}, 2, 50)
    assert(status.vital_state == "wounded")
    assert(status.pain_state == "strong")
    assert(status.bleeding_state == "important")
    var enemy := {"observed_patterns":{}}
    var hero := {"id":"mathilde"}
    var first := ReactionResolver.observe_enemy(enemy, hero, "head", {"hit":true,"functional_loss":"functional"})
    enemy.observed_patterns = first.patterns
    var second := ReactionResolver.observe_enemy(enemy, hero, "head", {"hit":true,"functional_loss":"functional"})
    assert(second.reaction.decision == "guard_zone")
    var event := CombatEvent.from_attack(hero, {"id":"target"}, {"hit":true,"damage":8})
    assert(event.type == "attack_hit")
    assert(event.payload.damage == 8)
    print("VEILLEURS_COMBAT_PIPELINE_CONTRACT_OK")
    quit(0)
