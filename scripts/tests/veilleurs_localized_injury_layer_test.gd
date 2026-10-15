extends SceneTree

const Body := preload("res://scripts/core/veilleurs_body_component.gd")

func _initialize() -> void:
    var body := Body.new()
    assert((body.localized_injuries("left_arm") as Array).is_empty())
    var hit: Dictionary = body.apply_trauma("left_arm", 30)
    assert(hit.ok)
    assert(str(body.states.left_arm) != "L0")
    var wounds: Array = body.localized_injuries("left_arm")
    assert(wounds.size() == 1)
    assert(str(wounds[0].zone) == "left_arm")
    assert(str(wounds[0].severity) == str(body.states.left_arm))
    assert(int(wounds[0].trauma) == 30)
    var snapshot: Dictionary = body.serialize()
    var restored := Body.new()
    restored.deserialize(snapshot)
    assert(restored.localized_injuries("left_arm") == wounds, "localized injuries must survive serialization")
    assert(str(restored.states.left_arm) == str(body.states.left_arm), "anatomy state remains independent and serializable")
    print("VEILLEURS_LOCALIZED_INJURY_LAYER_OK")
    quit(0)
