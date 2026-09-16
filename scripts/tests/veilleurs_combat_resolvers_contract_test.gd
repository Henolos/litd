extends SceneTree

const HitResolver := preload("res://scripts/core/combat/veilleurs_hit_resolver.gd")
const DamageResolver := preload("res://scripts/core/combat/veilleurs_damage_resolver.gd")

func _init() -> void:
    var target := {"id":"target","name":"Cible"}
    var base_action := {"id":"strike","accuracy":75,"power":7}

    var normal := HitResolver.resolve({"id":"hero","coordination_bonus":0,"posture":"none"}, base_action, target, "torso", 2)
    var coordinated := HitResolver.resolve({"id":"hero","coordination_bonus":10,"posture":"precision"}, base_action, target, "torso", 2)
    assert(int(normal.get("accuracy", 0)) == 75, "Base accuracy contract changed")
    assert(int(coordinated.get("accuracy", 0)) == 91, "Coordination + precision accuracy contract changed")
    assert(int(normal.get("roll", -1)) == int(coordinated.get("roll", -2)), "Posture/coordination must not perturb deterministic roll seed")

    var light := DamageResolver.resolve({"posture":"none"}, {"power":7}, target, "torso")
    var medium := DamageResolver.resolve({"posture":"none"}, {"power":8}, target, "torso")
    var severe := DamageResolver.resolve({"posture":"none"}, {"power":13}, target, "torso")
    assert(int(light.get("severity", 0)) == 1, "Severity threshold below 8 changed")
    assert(int(medium.get("severity", 0)) == 2, "Severity threshold at 8 changed")
    assert(int(severe.get("severity", 0)) == 3, "Severity threshold at 13 changed")

    var force := DamageResolver.resolve({"posture":"force_cost"}, {"power":10}, target, "torso")
    assert(int(force.get("damage", 0)) == 13, "Force-cost +3 power contract changed")

    print("VEILLEURS_COMBAT_RESOLVERS_CONTRACT_OK")
    quit(0)
