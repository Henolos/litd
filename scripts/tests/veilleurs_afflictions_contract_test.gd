extends SceneTree

const Status := preload("res://scripts/core/combat/veilleurs_status_resolver.gd")
const Hit := preload("res://scripts/core/combat/veilleurs_hit_resolver.gd")
const Damage := preload("res://scripts/core/combat/veilleurs_damage_resolver.gd")
const Runtime := preload("res://scripts/core/veilleurs_combat_sandbox_runtime.gd")

func _init() -> void:
    var actor := {"id":"actor", "hp":40, "max_hp":40, "afflictions":{}}
    for kind: String in Status.AFFLICTIONS:
        var applied: Dictionary = Status.apply_affliction(actor, kind, 2)
        assert(applied.ok and int(applied.afflictions[kind]) == 2, "application failed: %s" % kind)
        assert((actor.afflictions as Dictionary).is_empty(), "resolver mutated its input")
    assert(Status.AFFLICTIONS.size() == 10)
    assert(not Status.apply_affliction(actor, "unknown", 2).ok)
    assert(not Status.apply_affliction(actor, "poison", 0).ok)
    actor.afflictions = {"poison":2,"burn":2,"bleed":2}
    assert(int(Status.start_turn(actor).damage) == 9, "periodic damage must be additive")
    assert(int(actor.hp) == 40, "tick must not mutate its input")
    actor.afflictions = Status.finish_turn(actor)
    assert(int(actor.afflictions.poison) == 1)
    actor.afflictions = Status.finish_turn(actor)
    assert(actor.afflictions.is_empty(), "effects must expire after two actor turns")
    assert(int(Status.start_turn(actor).damage) == 0)
    actor.afflictions = Status.apply_affliction(actor, "poison", 3).afflictions
    actor.afflictions = Status.apply_affliction(actor, "poison", 1).afflictions
    assert(int(actor.afflictions.poison) == 3, "reapplication must not shorten duration")
    actor.afflictions = {"stun":1}
    assert(Status.action_block(actor, {}) == "stunned")
    assert(Status.movement_block(actor))
    actor.afflictions = {"silence":1}
    assert(Status.action_block(actor, {"trame_cost":1}) == "silenced")
    assert(Status.action_block(actor, {"effect":"trame_control"}) == "silenced")
    assert(Status.action_block(actor, {"effect":"guard_stance"}) == "")
    actor.afflictions = {"freeze":1,"snare":1,"blind":1}
    assert(Status.movement_block(actor) and Status.accuracy_penalty(actor) == 40)
    assert(int(Hit.resolve(actor, {"id":"strike","accuracy":80}, {"id":"enemy"}, "torso", 1).accuracy) == 40)
    actor.afflictions = {"weakness":1}
    var target := {"name":"enemy", "afflictions":{"vulnerability":1}}
    assert(int(Damage.resolve(actor, {"power":16}, target, "torso").damage) == 15)
    assert(int(Damage.resolve({"posture":"none"}, {"power":16}, target, "torso").damage) == 20)

    var runtime := Runtime.new()
    assert(runtime.setup().ok)
    var names := {"poison":"MATH-AFF-01","bleed":"MA-ENT-01","blind":"MA-DIS-09", "stun":"MR-BRI-01","vulnerability":"MR-BRI-05","weakness":"MR-BRI-09", "burn":"ANOU-AFF-01","freeze":"ANOU-AFF-02","silence":"AN-DIS-06", "snare":"AU-ANA-11"}
    var canonical_build_actions := {"MA-ENT-01":"Entaille","MA-DIS-09":"Disparition","MR-BRI-01":"Brisure","MR-BRI-05":"Brisure","MR-BRI-09":"Brisure","AN-DIS-06":"Dissidence","AU-ANA-11":"Anatomie"}
    for i in range(runtime.heroes.size()):
        for action: Dictionary in runtime.heroes[i].sandbox_actions:
            if names.has(str(action.get("affliction", ""))):
                assert(str(action.get("id")) == names[str(action.affliction)])
                if canonical_build_actions.has(str(action.get("id"))):
                    assert(str(action.get("tree", "")) == canonical_build_actions[str(action.get("id"))], "canonical affliction action must declare its tree")
                    assert(str(action.get("build_role", "")) != "", "canonical affliction action must declare a build role")
                runtime.active_hero_index = i
                runtime.heroes[i].ap = 20
                for round_number in range(1, 30):
                    if Hit.resolve(runtime.heroes[i], action, runtime.enemies[0], "torso", round_number).hit:
                        runtime.round = round_number
                        break
                var action_result: Dictionary = runtime.perform_action(str(action.id), 0)
                assert(action_result.ok and action_result.hit, "action not usable: %s" % str(action.id))
                assert(Status.has(runtime.enemies[0], str(action.affliction)), "effect not stored: %s" % str(action.affliction))
    assert((runtime.inspect_actor("enemy", 0).afflictions as Dictionary).size() == 10)
    runtime.active_hero_index = 0
    runtime.heroes[0].afflictions = {"stun":1}
    var ap_before: int = int(runtime.heroes[0].ap)
    var blocked: Dictionary = runtime.perform_action("MATH-LAM-01", 0)
    assert(not blocked.ok and blocked.reason == "stunned" and int(runtime.heroes[0].ap) == ap_before)
    assert(runtime.move_hero(0, 2).reason == "movement_blocked")
    runtime.heroes[0].afflictions = {}
    runtime.active_hero_index = 2
    runtime.heroes[2].afflictions = {"silence":1}
    ap_before = int(runtime.heroes[2].ap)
    assert(runtime.perform_action("ANOU-TRA-02", 0).reason == "silenced")
    assert(int(runtime.heroes[2].ap) == ap_before)

    runtime = Runtime.new()
    assert(runtime.setup().ok)
    var enemy: Dictionary = runtime.enemies[0]
    enemy.afflictions = Status.apply_affliction(enemy, "stun", 1).afflictions
    var hero: Dictionary = runtime.heroes[0]
    var next_hero: Dictionary = runtime.heroes[1]
    next_hero.afflictions = Status.apply_affliction(next_hero, "poison", 1).afflictions
    runtime.end_active_turn()
    assert(int(next_hero.hp) == int(next_hero.max_hp) - 3, "poison must tick at actor turn start")
    assert(int(next_hero.afflictions.poison) == 1, "effect must last throughout the actor turn")
    runtime.end_active_turn(); runtime.end_active_turn(); runtime.end_active_turn()
    assert(next_hero.afflictions.is_empty(), "hero effect expired at end of actor turn")
    assert(enemy.afflictions.is_empty(), "enemy stun expired after skipped enemy phase")
    print("VEILLEURS_AFFLICTIONS_CONTRACT_OK")
    quit(0)
