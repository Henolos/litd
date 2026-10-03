extends "res://scripts/core/veilleurs_enemy_ai_v2.gd"
class_name VeilleursEnemyAIV3

const PSYCH_ROLES: Array[String] = ["psych", "psych_support"]
const CONTROL_ROLES: Array[String] = ["controller", "controller_tank"]
const ANATOMY_ROLES: Array[String] = ["anatomy", "execution", "hunter"]
const TARGET_RESOLVER := preload("res://scripts/core/combat/veilleurs_target_resolver.gd")

func decide(runtime: Variant, enemy_id: String) -> Dictionary:
    var decision: Dictionary = super.decide(runtime, enemy_id)
    if str(decision.get("action", "")) != "attack":
        return decision
    var enemy: Dictionary = runtime.combatants.get(enemy_id, {})
    var role := str(enemy.get("combat_role", "assault"))
    var target_id := str(decision.get("target", ""))
    if target_id == "" or not runtime.combatants.has(target_id):
        return decision

    var memory := _memory_state(enemy)
    var stage := str(memory.get("stage", enemy.get("remanence_stage", "normal")))
    var adaptations: Array = memory.get("adaptations", enemy.get("adaptations", []))
    var memory_target := _memory_adjusted_target(runtime, enemy_id, target_id, stage, adaptations)
    if memory_target != "":
        target_id = memory_target
        decision["target"] = target_id

    var preferred_zone := _preferred_zone(runtime.combatants[target_id], role, stage)
    var ai_action := {"target":"enemy_zone","requires_body_zone":true}
    decision["zone"] = preferred_zone if TARGET_RESOLVER.can_target_body_zone(ai_action, runtime.combatants[target_id], preferred_zone) else "torso"
    decision["attack_kind"] = "psych" if PSYCH_ROLES.has(role) else ("control" if CONTROL_ROLES.has(role) else "physical")
    decision["memory_stage"] = stage
    decision["adaptations"] = adaptations.duplicate()
    decision["memory_used"] = stage in ["veteran", "elite", "nemesis"] or not adaptations.is_empty()
    if bool(decision["memory_used"]):
        decision["reason"] = "%s+remanence" % str(decision.get("reason", "tactical_attack"))
    return decision

func _memory_state(enemy: Dictionary) -> Dictionary:
    var remanence_id := str(enemy.get("remanence_id", ""))
    if remanence_id == "" or RemanenceRuntime == null:
        return {}
    return RemanenceRuntime.entity_state(remanence_id)

func _memory_adjusted_target(runtime: Variant, enemy_id: String, current_target: String, stage: String, adaptations: Array) -> String:
    if stage not in ["veteran", "elite", "nemesis"] and adaptations.is_empty():
        return current_target
    var candidates: Array[String] = runtime.alive_ids("watcher")
    if candidates.is_empty():
        return current_target
    if adaptations.has("avoid_guard"):
        var least_guarded := current_target
        var best_guard := 9999
        for candidate: String in candidates:
            var row: Dictionary = runtime.combatants[candidate]
            var guard := int(row.get("guard_bonus", 0))
            if guard < best_guard:
                best_guard = guard
                least_guarded = candidate
        return least_guarded
    if adaptations.has("pressure_wounded") or stage in ["elite", "nemesis"]:
        var weakest := current_target
        var lowest_ratio := 2.0
        for candidate: String in candidates:
            var row: Dictionary = runtime.combatants[candidate]
            var ratio := float(row.get("hp", 0)) / maxf(1.0, float(row.get("max_hp", 1)))
            if ratio < lowest_ratio:
                lowest_ratio = ratio
                weakest = candidate
        return weakest
    if stage == "veteran" and _recent_target_count(runtime, enemy_id, current_target) >= 2:
        var alternatives: Array[String] = []
        for candidate: String in candidates:
            if candidate != current_target:
                alternatives.append(candidate)
        if not alternatives.is_empty():
            alternatives.sort()
            return alternatives[posmod(enemy_id.hash() + runtime.round_index, alternatives.size())]
    return current_target

func _recent_target_count(runtime: Variant, enemy_id: String, target_id: String) -> int:
    var count := 0
    var checked := 0
    for index in range(runtime.action_log.size() - 1, -1, -1):
        var row: Dictionary = runtime.action_log[index]
        if str(row.get("attacker", row.get("enemy", ""))) != enemy_id:
            continue
        checked += 1
        if str(row.get("target", "")) == target_id:
            count += 1
        if checked >= 4:
            break
    return count

func _preferred_zone(target: Dictionary, role: String, stage: String) -> String:
    if PSYCH_ROLES.has(role):
        return "head"
    if role == "hunter":
        return _weaker_of(target, "left_leg", "right_leg")
    if ANATOMY_ROLES.has(role):
        return _most_injured_zone(target)
    if role == "ranged":
        return "right_arm" if stage in ["veteran", "elite", "nemesis"] else "torso"
    return "torso"

func _most_injured_zone(target: Dictionary) -> String:
    var body: Variant = target.get("body")
    if body == null or not body.has_method("serialize"):
        return "torso"
    var states: Dictionary = (body.call("serialize") as Dictionary).get("states", {})
    var best := "torso"
    var best_level := -1
    for zone_value: Variant in states.keys():
        var zone := str(zone_value)
        var state := str(states.get(zone, "L0"))
        var level := int(state.trim_prefix("L")) if state.begins_with("L") else 0
        if level > best_level:
            best_level = level
            best = zone
    return best

func _weaker_of(target: Dictionary, a: String, b: String) -> String:
    var body: Variant = target.get("body")
    if body == null or not body.has_method("serialize"):
        return a
    var states: Dictionary = (body.call("serialize") as Dictionary).get("states", {})
    var a_level := int(str(states.get(a, "L0")).trim_prefix("L"))
    var b_level := int(str(states.get(b, "L0")).trim_prefix("L"))
    return a if a_level >= b_level else b


# Rank-based adapter used by the current main combat loop. It keeps the V3
# tactical priorities (role, wounds, memory/adaptations) while consuming the
# canonical target candidate list instead of maintaining another target ruleset.
func choose_rank_target_index(enemy: Dictionary, heroes: Array, target_mode: String = "random", round_value: int = 1) -> int:
    var candidates: Array[int] = TARGET_RESOLVER.enemy_targetable_indices(enemy, {"target": target_mode}, heroes)
    if candidates.is_empty():
        return -1

    var role := str(enemy.get("combat_role", enemy.get("archetype", "assault")))
    var memory := _memory_state(enemy)
    var stage := str(memory.get("stage", enemy.get("remanence_stage", "normal")))
    var adaptations: Array = memory.get("adaptations", enemy.get("adaptations", enemy.get("remanence_adaptations", [])))

    var best_index := candidates[0]
    var best_score := -INF
    for index: int in candidates:
        var hero: Dictionary = heroes[index]
        var score := _rank_target_score(enemy, hero, role, target_mode, stage, adaptations, round_value)
        if score > best_score:
            best_score = score
            best_index = index
    return best_index

func _rank_target_score(enemy: Dictionary, hero: Dictionary, role: String, target_mode: String, stage: String, adaptations: Array, round_value: int) -> float:
    var hp_ratio := _hp_ratio(hero)
    var distance := _rank_distance(enemy, hero)
    var score := 100.0 - float(distance) * 8.0

    if PREDATOR_ROLES.has(role):
        score += (1.0 - hp_ratio) * 65.0
        score += _rank_wound_pressure(hero)
    if role == "ranged":
        score += 12.0 if distance >= 2 and distance <= 4 else 0.0
    if role in ["controller", "psych", "psych_support"]:
        var stats: Dictionary = hero.get("stats", {})
        var resolve_value := float(stats.get("RES", hero.get("resolve", 60)))
        score += (100.0 - resolve_value) * 0.25
        score += float(hero.get("fear", 0)) * 0.15

    match target_mode:
        "weakest":
            score += (1.0 - hp_ratio) * 120.0
        "fastest":
            score += float(hero.get("speed", hero.get("mobility", 0))) * 1.2
        "highest_hope":
            score += float(hero.get("hope", 0)) * 0.9
        "highest_precision":
            score += float(hero.get("precision", 0)) * 0.9
        "guarding":
            score += 80.0 if bool(hero.get("guarding", false)) else 0.0
        "nearest":
            score -= float(distance) * 18.0
        "random":
            score += _stable_rank_jitter(enemy, hero, round_value) * 18.0
        _:
            score += _stable_rank_jitter(enemy, hero, round_value) * 4.0

    if adaptations.has("avoid_guard") and bool(hero.get("guarding", false)):
        score -= 90.0
    if adaptations.has("pressure_wounded") or stage in ["elite", "nemesis"]:
        score += (1.0 - hp_ratio) * 55.0
    if stage == "veteran":
        score += _stable_rank_jitter(enemy, hero, round_value) * 6.0
    return score

func _rank_distance(enemy: Dictionary, hero: Dictionary) -> int:
    # Both formations encode 0 as their frontline. Front-to-front therefore has
    # distance 1; moving either combatant toward its backline increases range.
    return 1 + clampi(int(enemy.get("combat_position", 0)), 0, 3) + clampi(int(hero.get("combat_position", 0)), 0, 3)

func _rank_wound_pressure(hero: Dictionary) -> float:
    var pressure := 0.0
    if str(hero.get("bleeding_state", hero.get("bleeding", "none"))) not in ["", "none", "0"]:
        pressure += 10.0
    if str(hero.get("pain_state", "controlled")) in ["strong", "severe", "unbearable"]:
        pressure += 8.0
    if int(hero.get("hp", 0)) * 2 <= int(hero.get("max_hp", 1)):
        pressure += 12.0
    return pressure

func _stable_rank_jitter(enemy: Dictionary, hero: Dictionary, round_value: int) -> float:
    var enemy_id := str(enemy.get("combat_uid", enemy.get("id", enemy.get("name", "enemy"))))
    var hero_id := str(hero.get("id", hero.get("name", "hero")))
    return float(posmod(("%s:%s:%d" % [enemy_id, hero_id, round_value]).hash(), 1000)) / 999.0


# Main-combat adapter: V3 now chooses the action family as well as the target.
# The director still owns the concrete authored skill definitions and execution.
func decide_rank_action(enemy: Dictionary, heroes: Array, allies: Array, round_value: int = 1) -> Dictionary:
    if enemy.is_empty() or int(enemy.get("hp", 0)) <= 0:
        return {"action":"none","reason":"dead"}

    var role := str(enemy.get("combat_role", enemy.get("archetype", "assault")))
    var hp_ratio := _hp_ratio(enemy)
    var stage := str(enemy.get("remanence_stage", "normal"))

    if hp_ratio <= 0.18 and not STOIC_ROLES.has(role) and stage != "nemesis":
        return {"action":"flee","reason":"critical_survival"}

    if SUPPORT_ROLES.has(role):
        for ally_value: Variant in allies:
            if not ally_value is Dictionary:
                continue
            var ally: Dictionary = ally_value
            if ally == enemy or int(ally.get("hp", 0)) <= 0:
                continue
            if _hp_ratio(ally) < 0.55:
                return {"action":"support","reason":"ally_critical"}

    if heroes.is_empty():
        return {"action":"hold","reason":"no_target"}

    var preferred := _rank_preferred_position(enemy, role)
    var current := clampi(int(enemy.get("combat_position", 0)), 0, 3)
    var memory_target_mode := str(enemy.get("remanence_target_mode", ""))
    var living_targets := TARGET_RESOLVER.enemy_targetable_indices(enemy, {"target": memory_target_mode if memory_target_mode != "" else "random"}, heroes)
    if current != preferred and memory_target_mode == "" and not living_targets.is_empty():
        return {"action":"move","reason":"restore_role_position","preferred_position":preferred}

    return {"action":"attack","reason":"remanence_target_priority" if memory_target_mode != "" else "tactical_attack"}

func _rank_preferred_position(enemy: Dictionary, role: String) -> int:
    var species := str(enemy.get("species_id", ""))
    if species in ["ash_roamer", "ghoul_hungry", "ghoul_voracious", "mutilated_guardian"]:
        return 0
    if species == "ash_bearer":
        return 1
    if role in ["ranged", "support", "psych_support"]:
        return 3
    if role in ["controller", "psych"]:
        return 2
    return 1
