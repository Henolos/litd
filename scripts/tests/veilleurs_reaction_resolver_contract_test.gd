extends SceneTree

const ReactionResolver := preload("res://scripts/core/combat/veilleurs_reaction_resolver.gd")

func _init() -> void:
    var hero := {"id":"mathilde"}
    var enemy := {"observed_patterns":{}}
    var first := ReactionResolver.observe_enemy(enemy, hero, "torso", {"hit":true,"functional_loss":"impaired"})
    assert(first.reaction.decision == "exploit_wounded_actor")
    enemy.observed_patterns = first.patterns
    var second := ReactionResolver.observe_enemy(enemy, hero, "torso", {"hit":true,"functional_loss":"functional"})
    assert(second.reaction.decision == "guard_zone")
    assert(second.guarded_zone == "torso")
    assert(enemy.get("guarded_zone", "") == "", "Resolver must not mutate enemy input")
    print("VEILLEURS_REACTION_RESOLVER_CONTRACT_OK")
    quit(0)
