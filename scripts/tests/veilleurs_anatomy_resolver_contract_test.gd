extends SceneTree

const AnatomyResolver := preload("res://scripts/core/combat/veilleurs_anatomy_resolver.gd")

func _init() -> void:
    var anatomy := {"torso":{"state":"healthy","armor":"unknown","function":"functional","injuries":[]}}
    var light := AnatomyResolver.resolve(anatomy, "torso", 1, 1.0, {"id":"strike","impact":"slashing"})
    assert(str(light.zone_state.state) == "injured")
    assert(str(light.zone_state.function) == "functional")
    assert(str(light.zone_state.armor) == "weak")
    assert(anatomy.torso.state == "healthy", "Resolver must not mutate its input")
    var severe := AnatomyResolver.resolve(anatomy, "torso", 2, 0.55, {"id":"strike","impact":"slashing"})
    assert(str(severe.zone_state.function) == "impaired")
    assert(str(severe.zone_state.armor) == "strong")
    assert(int(severe.zone_state.injuries[0].severity) == 2)
    assert(str(severe.zone_state.injuries[0].impact) == "slashing")
    assert(str(severe.zone_state.injuries[0].source) == "strike")
    print("VEILLEURS_ANATOMY_RESOLVER_CONTRACT_OK")
    quit(0)
