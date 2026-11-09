extends SceneTree

# Run: godot --headless --path . --script tests/mythic_anatomy_smoke.gd
func _initialize() -> void:
    var anatomy = load("res://scripts/core/anatomy_runtime.gd").new()
    var combat = load("res://scripts/core/enemy_combat_director.gd").new()
    root.add_child(anatomy)
    root.add_child(combat)
    call_deferred("_run", anatomy, combat)

func _run(anatomy: Node, combat: Node) -> void:
    var failures: Array[String] = []
    var expected := {
        "oni": ["weapon_arm", "free_arm", "left_leg", "right_leg", "horns"],
        "manticore": ["front_left_leg", "front_right_leg", "rear_left_leg", "rear_right_leg", "jaw", "venom_tail"],
        "jorogumo": ["front_left_leg", "front_right_leg", "rear_left_leg", "rear_right_leg", "fangs", "spinnerets"]
    }
    for species in expected:
        var enemy := {"anatomy_profile_id": species, "hp": 100, "max_hp": 100}
        anatomy.ensure_state(enemy)
        var ids: Array = []
        for part in anatomy.targetable_parts(enemy):
            ids.append(part.get("id", ""))
        for required in expected[species]:
            if not ids.has(required):
                failures.append("%s missing %s" % [species, required])
        var lost_id: String = expected[species][0]
        enemy["dismembered_parts"] = [lost_id]
        if anatomy.select_part(enemy, lost_id):
            failures.append("%s selected lost part" % species)
        var hit: Dictionary = anatomy.register_targeted_hit({}, enemy, "heavy", 30, lost_id)
        if int(hit.get("trauma_added", -1)) != 0:
            failures.append("%s hit lost part" % species)
    var manticore := {"anatomy_profile_id": "manticore", "dismembered_parts": ["venom_tail"], "anatomy_skill_organs": {"sting": ["venom_tail"]}}
    if combat._organs_available(manticore, {"id": "sting"}):
        failures.append("lost venom tail still allows sting")
    if not combat._organs_available(manticore, {"id": "basic_attack"}):
        failures.append("unrestricted basic attack blocked")
    if failures.is_empty():
        print("Mythic anatomy smoke tests passed")
        quit(0)
    else:
        for failure in failures:
            push_error(failure)
        quit(1)
