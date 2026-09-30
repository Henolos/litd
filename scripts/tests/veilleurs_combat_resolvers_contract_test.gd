extends SceneTree

const HitResolver := preload("res://scripts/core/combat/veilleurs_hit_resolver.gd")
const DamageResolver := preload("res://scripts/core/combat/veilleurs_damage_resolver.gd")
const ReactionResolver := preload("res://scripts/core/combat/veilleurs_reaction_resolver.gd")
const CombatEvent := preload("res://scripts/core/combat/veilleurs_combat_event.gd")
const CombatCommand := preload("res://scripts/core/combat/veilleurs_combat_command.gd")
const TargetResolver := preload("res://scripts/core/combat/veilleurs_target_resolver.gd")
const EnemyMemory := preload("res://scripts/core/combat/veilleurs_enemy_memory.gd")
const EnemyUtilityAI := preload("res://scripts/core/combat/veilleurs_enemy_utility_ai.gd")
const LegacyRuntime := preload("res://scripts/core/veilleurs_combat_sandbox_runtime.gd")

func _init() -> void:
    var target := {"id":"target","name":"Cible"}
    var base_action := {"id":"strike","accuracy":75,"power":7}

    var normal := HitResolver.resolve({"id":"hero","coordination_bonus":0,"posture":"none"}, base_action, target, "torso", 2)
    var coordinated := HitResolver.resolve({"id":"hero","coordination_bonus":10,"posture":"precision"}, base_action, target, "torso", 2)
    assert(int(normal.get("accuracy", 0)) == 75, "Base accuracy contract changed")
    assert(int(coordinated.get("accuracy", 0)) == 91, "Coordination + precision accuracy contract changed")
    assert(int(normal.get("roll", -1)) == int(coordinated.get("roll", -2)), "Posture/coordination must not perturb deterministic roll seed")

    var legacy_runtime := LegacyRuntime.new()
    for seed in ["", "combat-parity-01", "mathildeporte_cendrefrappe_torso1", "aureliencharognardprecisionhead12"]:
        assert(HitResolver.stable_roll(seed) == legacy_runtime._stable_roll(seed), "Stable-roll parity changed for seed: %s" % seed)

    var light := DamageResolver.resolve({"posture":"none"}, {"power":7}, target, "torso")
    var medium := DamageResolver.resolve({"posture":"none"}, {"power":8}, target, "torso")
    var severe := DamageResolver.resolve({"posture":"none"}, {"power":13}, target, "torso")
    assert(int(light.get("severity", 0)) == 1, "Severity threshold below 8 changed")
    assert(int(medium.get("severity", 0)) == 2, "Severity threshold at 8 changed")
    assert(int(severe.get("severity", 0)) == 3, "Severity threshold at 13 changed")

    var force := DamageResolver.resolve({"posture":"force_cost"}, {"power":10}, target, "torso")
    assert(int(force.get("damage", 0)) == 13, "Force-cost +3 power contract changed")

    var tactical_actor := {"weapon_power":30,"stats":{"FOR":50}}
    var tactical_target := {"armor":20,"guard_bonus":8}
    var tactical_action := {"skill_index":1,"effect_spec":{"damage_multiplier":1.0}}
    var tactical_damage := DamageResolver.resolve_tactical_skill(tactical_actor, tactical_action, tactical_target, false)
    var expected_attack_power := 30.0 * (0.70 + 50.0 / 200.0)
    var expected_reduction := 28.0 / 128.0
    var expected_damage := maxi(1, int(round(expected_attack_power * (1.0 - expected_reduction))))
    assert(int(tactical_damage.get("damage", 0)) == expected_damage, "Tactical damage parity changed")
    var exposed_damage := DamageResolver.resolve_tactical_skill(tactical_actor, tactical_action, tactical_target, true)
    assert(int(exposed_damage.get("damage", 0)) >= expected_damage, "EXPOSED must not reduce tactical damage")

    var enemy := {"id":"enemy","observed_patterns":{}}
    var hero := {"id":"hero"}
    var first_reaction := ReactionResolver.observe_enemy(enemy, hero, "left_arm", {"hit":true,"functional_loss":"impaired"})
    assert((enemy.get("observed_patterns", {}) as Dictionary).is_empty(), "ReactionResolver must remain pure")
    assert(str((first_reaction.get("reaction", {}) as Dictionary).get("decision", "")) == "exploit_wounded_actor", "Functional injury reaction contract changed")
    var observed_enemy := enemy.duplicate(true)
    observed_enemy["observed_patterns"] = first_reaction.get("patterns", {})
    var second_reaction := ReactionResolver.observe_enemy(observed_enemy, hero, "left_arm", {"hit":true,"functional_loss":"impaired"})
    assert(str((second_reaction.get("reaction", {}) as Dictionary).get("decision", "")) == "guard_zone", "Repeated-zone reaction contract changed")
    assert(str(second_reaction.get("guarded_zone", "")) == "left_arm", "Guarded-zone contract changed")

    var attack_result := {"ok":true,"kind":"attack","hit":true,"damage":7}
    var event := CombatEvent.from_attack(hero, target, attack_result)
    assert(str(event.get("type", "")) == "attack_hit", "CombatEvent hit type changed")
    assert(str(event.get("actor_id", "")) == "hero" and str(event.get("target_id", "")) == "target", "CombatEvent identity contract changed")
    attack_result["damage"] = 99
    assert(int((event.get("payload", {}) as Dictionary).get("damage", 0)) == 7, "CombatEvent payload must be an immutable snapshot")

    var command := CombatCommand.make("hero", "strike", "enemy", 0, TargetResolver.normalize_zone("invalid_zone"))
    assert(bool(CombatCommand.validate(command).get("ok", false)), "Canonical combat command must validate")
    assert(str(command.get("zone", "")) == "torso", "TargetResolver zone normalization contract changed")
    assert(not bool(CombatCommand.validate({"actor_id":"hero"}).get("ok", true)), "Incomplete combat command must fail closed")
    var targets: Array = [{"id":"enemy"}]
    var valid_target := TargetResolver.validate_index(targets, 0)
    assert(bool(valid_target.get("ok", false)) and str((valid_target.get("target", {}) as Dictionary).get("id", "")) == "enemy", "TargetResolver valid-index contract changed")
    assert(str(TargetResolver.validate_index(targets, 1).get("reason", "")) == "invalid_target", "TargetResolver invalid-index contract changed")

    var memory_source := {"remanence_stage":"veteran","adaptations":["pressure_wounded"],"observed_patterns":{"hero:torso":2}}
    var memory_snapshot := EnemyMemory.snapshot(memory_source)
    (memory_source["adaptations"] as Array).append("late_mutation")
    assert(not (memory_snapshot.get("adaptations",[]) as Array).has("late_mutation"), "EnemyMemory must return an isolated snapshot")
    var watcher_ids: Array = ["mathilde","marec"]
    var ai_command := EnemyUtilityAI.to_combat_command({"action":"attack","target":"marec","zone":"right_arm","reason":"exploit_wounded_target"}, "enemy_01", watcher_ids)
    assert(bool(ai_command.get("ok",false)), "UtilityAI attack intent must produce a valid CombatCommand")
    var emitted: Dictionary = ai_command.get("command",{})
    assert(str(emitted.get("actor_id","")) == "enemy_01" and int(emitted.get("target_index",-1)) == 1, "UtilityAI CombatCommand identity/target contract changed")
    assert(str(emitted.get("zone","")) == "right_arm", "UtilityAI must preserve intent zone without resolving combat outcome")
    assert(str(EnemyUtilityAI.to_combat_command({"action":"move"}, "enemy_01", watcher_ids).get("reason","")) == "non_combat_action", "Non-combat AI intent must not enter CombatCommand attack pipeline")

    print("VEILLEURS_COMBAT_RESOLVERS_CONTRACT_OK")
    quit(0)
