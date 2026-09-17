extends SceneTree

const StatusResolver := preload("res://scripts/core/combat/veilleurs_status_resolver.gd")

func _init() -> void:
    var target := {"max_hp":100,"bleeding_state":"none"}
    var light := StatusResolver.resolve_after_hit(target, {"impact":"blunt"}, 1, 80)
    assert(light.vital_state == "stable")
    assert(light.pain_state == "strong")
    assert(light.bleeding_state == "none")
    var severe := StatusResolver.resolve_after_hit(target, {"impact":"slashing"}, 3, 20)
    assert(severe.vital_state == "critical")
    assert(severe.public_vital_state == "critical")
    assert(severe.pain_state == "severe")
    assert(severe.bleeding_state == "important")
    var dead := StatusResolver.resolve_after_hit(target, {"impact":"blunt"}, 3, 0)
    assert(dead.vital_state == "agony")
    print("VEILLEURS_STATUS_RESOLVER_CONTRACT_OK")
    quit(0)
