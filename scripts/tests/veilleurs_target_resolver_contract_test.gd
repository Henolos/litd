extends SceneTree

const TargetResolver := preload("res://scripts/core/combat/veilleurs_target_resolver.gd")

func _init() -> void:
    assert(TargetResolver.normalize_zone("left_arm") == "left_arm")
    assert(TargetResolver.normalize_zone("nonsense") == "torso")
    var targets := [{"id":"a"},{"id":"b"}]
    var valid := TargetResolver.validate_index(targets, 1)
    assert(bool(valid.ok))
    assert(valid.target.id == "b")
    assert(not bool(TargetResolver.validate_index(targets, -1).ok))
    assert(not bool(TargetResolver.validate_index(targets, 2).ok))
    print("VEILLEURS_TARGET_RESOLVER_CONTRACT_OK")
    quit(0)
