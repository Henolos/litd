extends SceneTree

const HitResolver := preload("res://scripts/core/combat/veilleurs_hit_resolver.gd")
const DamageResolver := preload("res://scripts/core/combat/veilleurs_damage_resolver.gd")

func _init() -> void:
    var actor := {"id":"mathilde","coordination_bonus":0,"posture":"none"}
    var target := {"id":"porte_cendre_sandbox","name":"Porte-Cendre"}
    var action := {"id":"test_strike","accuracy":75,"power":10}

    var first := HitResolver.resolve(actor, action, target, "torso", 1)
    var second := HitResolver.resolve(actor, action, target, "torso", 1)
    assert(first == second, "Hit resolution must remain deterministic for the same combat state")
    assert(int(first.get("roll", -1)) >= 0 and int(first.get("roll", -1)) <= 99, "Stable roll must remain in [0,99]")

    var armored := DamageResolver.resolve(actor, action, target, "torso")
    assert(is_equal_approx(float(armored.get("armor_factor", 0.0)), 0.55), "Porte-Cendre protected zones must retain the sandbox armor factor")
    assert(int(armored.get("damage", 0)) == 6, "10 power against protected Porte-Cendre torso must retain rounded damage parity")

    var unarmored := DamageResolver.resolve(actor, action, target, "head")
    assert(is_equal_approx(float(unarmored.get("armor_factor", 0.0)), 1.0), "Unprotected Porte-Cendre zones must retain full damage")
    assert(int(unarmored.get("damage", 0)) == 10, "Unprotected zone damage parity changed")

    print("VEILLEURS_COMBAT_RESOLVERS_SMOKE_OK")
    quit(0)
