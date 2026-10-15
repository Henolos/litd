extends Node

func _ready() -> void:
    var director = EnemyCombatDirector
    director.skills = [
        {"id":"low","name":"Low","weight":1,"target":"weakest","archetypes":["any"]},
        {"id":"high","name":"High","weight":4,"target":"weakest","archetypes":["any"]}
    ]
    director.archetype_rules = []

    var enemy := {"name":"test","hp":10,"max_hp":10,"combat_uid":"enemy-test"}
    var heroes := [
        {"name":"healthy","hp":10,"max_hp":10,"combat_uid":"hero-a"},
        {"name":"wounded","hp":2,"max_hp":10,"combat_uid":"hero-b"}
    ]

    var first: Dictionary = director.choose_action(enemy, heroes)
    var second: Dictionary = director.choose_action(enemy, heroes)

    assert(first == second, "same state must produce the same explainable decision")
    assert(str(first.id) in ["low", "high"])
    assert(int(first.target_index) == 1, "weakest target scoring must remain authoritative")
    assert(float(first.target_score) > 0.0)
    assert(first.decision_factors is Dictionary)
    assert((first.decision_factors as Dictionary).has("action"))
    assert((first.decision_factors as Dictionary).has("target"))
    assert((first.decision_factors as Dictionary).has("selection"))
    var selection: Dictionary = first.decision_factors.selection
    assert(str(selection.get("strategy", "")) == "deterministic_weighted_utility")
    assert(is_equal_approx(float(selection.get("total_weight", 0.0)), 5.0), "configured weights must preserve their propensity meaning")
    assert(str(first.decision_reason) == "deterministic_weighted_utility")

    var wounded_guard: Dictionary = director._score_action(
        {"hp":4,"max_hp":10},
        {"weight":2,"self_status":"guarding"}
    )
    assert(float(wounded_guard.score) > 2.0, "context must be able to raise utility without converting base weights into hard priority")

    print("VEILLEURS_EXPLAINABLE_ENEMY_AI_OK")
    get_tree().quit(0)
