extends "res://scripts/core/veilleurs_tactical_combat_runtime_v2.gd"
class_name VeilleursCombatRuntime

# Neutral production runtime. It keeps the serialized v07/v08/v09 contract while
# collapsing their tactical inheritance into one orchestration layer above V2.
const RUNTIME_CONTENT_DB_SCRIPT := preload("res://scripts/core/veilleurs_content_db_v081_canonical.gd")
const RUNTIME_BEHAVIOR_SCRIPT := preload("res://scripts/core/veilleurs_skill_behavior_runtime_v07.gd")
const SELECTOR_SCRIPT := preload("res://scripts/core/veilleurs_enemy_skill_selector_v2.gd")
const BOSS_RULE_SCRIPT := preload("res://scripts/core/veilleurs_boss_rule_runtime.gd")
const ULTIMATE_SCRIPT := preload("res://scripts/core/veilleurs_ultimate_runtime.gd")
const REMANENCE_SCRIPT := preload("res://scripts/core/veilleurs_remanence_combat_bridge_v09.gd")
const BOSS_DIRECTOR_SCRIPT := preload("res://scripts/core/veilleurs_boss_director_v08.gd")
const PHASE_SCRIPT := preload("res://scripts/core/veilleurs_boss_phase_runtime_v09.gd")
const SUBMISSION_SCRIPT := preload("res://scripts/core/veilleurs_submission_runtime_v09.gd")

var skill_selector: VeilleursEnemySkillSelectorV2
var boss_rules: VeilleursBossRuleRuntime
var ultimate_runtime: VeilleursUltimateRuntime
var remanence_bridge: VeilleursRemanenceCombatBridgeV09
var boss_director: VeilleursBossDirectorV08
var boss_phase: VeilleursBossPhaseRuntimeV09
var submission: VeilleursSubmissionRuntimeV09

var active_boss_id := ""
var last_boss_rule: Dictionary = {}
var terrain_effects: Dictionary = {}
var summon_requests: Array[Dictionary] = []
var last_boss_mechanics: Dictionary = {}
var active_region_id := ""
var last_phase_event: Dictionary = {}

func _init() -> void:
    super()
    content_db = RUNTIME_CONTENT_DB_SCRIPT.new() as VeilleursContentDBV081Canonical
    content_db.reload()
    skill_behavior = RUNTIME_BEHAVIOR_SCRIPT.new() as VeilleursSkillBehaviorRuntimeV07
    skill_selector = SELECTOR_SCRIPT.new() as VeilleursEnemySkillSelectorV2
    boss_rules = BOSS_RULE_SCRIPT.new() as VeilleursBossRuleRuntime
    ultimate_runtime = ULTIMATE_SCRIPT.new() as VeilleursUltimateRuntime
    remanence_bridge = REMANENCE_SCRIPT.new() as VeilleursRemanenceCombatBridgeV09
    boss_director = BOSS_DIRECTOR_SCRIPT.new() as VeilleursBossDirectorV08
    boss_phase = PHASE_SCRIPT.new() as VeilleursBossPhaseRuntimeV09
    submission = SUBMISSION_SCRIPT.new() as VeilleursSubmissionRuntimeV09

func setup_first_combat(enemy_ids: Array[String] = ["ENT_ENEMY_GOULE_AFFAMEE", "ENT_ENEMY_ECORCHEUSE", "ENT_ENEMY_FOUISSEUSE"], region_id: String = "khar_sen") -> Dictionary:
    active_boss_id = ""
    last_boss_rule.clear()
    terrain_effects.clear()
    summon_requests.clear()
    active_region_id = region_id
    last_boss_mechanics.clear()
    last_phase_event.clear()
    var result: Dictionary = super.setup_first_combat(enemy_ids)
    if not bool(result.get("ok", false)):
        return result

    # Preserve the effective v07 -> v08 order: level/tree initialization first,
    # then Rémanence preparation, then a final doctrine selection.
    for enemy_id: String in enemy_ids:
        if not combatants.has(enemy_id):
            continue
        var row: Dictionary = combatants[enemy_id]
        row["level"] = _initial_enemy_level(row)
        row["ultimate_charges"] = _ultimate_charges_for_level(int(row["level"]))
        combatants[enemy_id] = row
        skill_selector.ensure_tree(self, enemy_id)

    var remanence_rows: Dictionary = {}
    var chosen_trees: Dictionary = {}
    for enemy_id: String in enemy_ids:
        if not combatants.has(enemy_id):
            continue
        var row: Dictionary = combatants[enemy_id]
        row["definition_id"] = enemy_id
        row.erase("chosen_tree")
        combatants[enemy_id] = row
        remanence_rows[enemy_id] = remanence_bridge.prepare_enemy(self, enemy_id, active_region_id)
        chosen_trees[enemy_id] = skill_selector.ensure_tree(self, enemy_id)
    result["chosen_trees"] = chosen_trees
    result["remanence"] = remanence_rows
    result["version"] = "0.9.0"
    return result

func setup_boss_combat(boss_id: String, context: Dictionary = {}) -> Dictionary:
    active_boss_id = ""
    last_boss_rule.clear()
    terrain_effects.clear()
    summon_requests.clear()
    active_region_id = str(context.get("region_id", "boss_region"))
    last_boss_mechanics.clear()
    last_phase_event.clear()

    var no_enemies: Array[String] = []
    var result: Dictionary = super.setup_first_combat(no_enemies)
    if not bool(result.get("ok", false)):
        return result
    var definition: Dictionary = (content_db as VeilleursContentDBV07Runtime).boss(boss_id)
    if definition.is_empty():
        return {"ok":false, "reason":"missing_boss", "boss_id":boss_id}
    _register(definition, "enemy")
    if not grid.place(boss_id, Vector2i(5, 2)):
        return {"ok":false, "reason":"boss_placement", "boss_id":boss_id}
    var row: Dictionary = combatants[boss_id]
    var stats: Dictionary = row.get("stats", {})
    var balance: Dictionary = content_db.combat_constants.get("v061_balance", {})
    row["resolve_current"] = int(stats.get("RES", 80))
    row["statuses"] = {}
    row["passive_effects"] = {}
    row["observed_by"] = {}
    row["guard_bonus"] = 0
    row["evasive_bonus"] = 0
    row["adaptations"] = []
    row["weapon_power"] = int(balance.get("enemy_weapon_power", 42)) + 8
    row["level"] = 50
    row["boss"] = true
    row["ultimate_charges"] = 3
    row["definition_id"] = boss_id
    combatants[boss_id] = row

    var chosen_tree: String = skill_selector.ensure_tree(self, boss_id)
    active_boss_id = boss_id
    last_boss_rule = boss_rules.begin(boss_id, context)
    last_boss_mechanics = boss_director.apply_round(self, boss_id, last_boss_rule)
    result = {
        "ok":true,
        "watchers":WATCHER_IDS.duplicate(),
        "boss":boss_id,
        "chosen_tree":chosen_tree,
        "boss_rule":last_boss_rule.duplicate(true),
        "grid":grid.snapshot(),
        "boss_mechanics":last_boss_mechanics.duplicate(true),
        "boss_phase":boss_phase.begin(boss_id),
        "version":"0.9.0"
    }
    return result

func resolve_skill(attacker_id: String, target_id: String, skill_id: String, zone: String = "torso", forced_roll: int = -1) -> Dictionary:
    var result: Dictionary = super.resolve_skill(attacker_id, target_id, skill_id, zone, forced_roll)
    if not bool(result.get("ok", false)):
        return result
    if active_boss_id != "" and combatants.has(attacker_id) and str((combatants[attacker_id] as Dictionary).get("team", "")) == "watcher":
        var skill: Dictionary = content_db.skill(skill_id)
        boss_rules.register_player_action(str(skill.get("action_type", "attack")))
    if active_boss_id != "" and target_id == active_boss_id and bool(result.get("hit", false)):
        var mutation: Dictionary = boss_rules.after_body_change(self)
        if not mutation.is_empty():
            result["boss_body_response"] = mutation
    return result

func enemy_step(enemy_id: String) -> Dictionary:
    if combatants.has(enemy_id) and bool((combatants[enemy_id] as Dictionary).get("subdued", false)):
        return {"ok":false, "reason":"enemy_subdued", "enemy":enemy_id}
    if not combatants.has(enemy_id) or str((combatants[enemy_id] as Dictionary).get("team", "")) != "enemy":
        return {"ok":false, "reason":"not_enemy"}
    var actor_verdict := TARGET_RESOLVER_SCRIPT.validate_tactical_actor(self, enemy_id)
    if not bool(actor_verdict.get("ok", false)):
        return actor_verdict
    remanence_bridge.refresh_enemy(self, enemy_id)
    var base_decision: Dictionary = enemy_ai.decide(self, enemy_id)
    var decision: Dictionary = (skill_selector as VeilleursEnemySkillSelectorV2).refine_decision(self, enemy_id, base_decision)
    if str(decision.get("action", "")) in ["move", "flee"]:
        var cell_value: Variant = decision.get("cell", Vector2i(-1, -1))
        if cell_value is Vector2i and not can_move_to(cell_value as Vector2i, enemy_id):
            decision["action"] = "hold"
            decision["reason"] = "boss_or_terrain_cell_locked"
    var row: Dictionary = combatants[enemy_id]
    var level := int(row.get("level", 1))
    var progress_state := _progress_state_for(enemy_id)
    if level >= 16:
        if ultimate_runtime.pending.has(enemy_id):
            var executed: Dictionary = ultimate_runtime.execute_pending(self, enemy_id, progress_state)
            if bool(executed.get("ok", false)):
                _apply_progress_state(enemy_id, executed.get("progress_state", {}))
                executed["generated_ultimate"] = true
                executed["doctrine_used"] = bool(decision.get("doctrine_used", false))
                return executed
        elif round_index % 4 == 1 and str(decision.get("target", "")) != "":
            var prepared: Dictionary = ultimate_runtime.prepare(self, enemy_id, str(decision.get("target", "")), progress_state)
            if bool(prepared.get("ok", false)) and bool(prepared.get("prepared", false)):
                prepared["generated_ultimate"] = true
                prepared["doctrine_used"] = bool(decision.get("doctrine_used", false))
                action_log.append(prepared.duplicate(true))
                return prepared
    var action := str(decision.get("action", "none"))
    if action not in ["attack", "support"]:
        return _resolve_non_skill_decision(enemy_id, decision)
    var skill: Dictionary = skill_selector.select_skill(self, enemy_id, decision)
    if skill.is_empty():
        return _fallback_enemy_action(enemy_id, decision, "no_doctrine_skill")
    var skill_action := str(skill_behavior.effective_action(skill))
    var target_id := str(decision.get("target", ""))
    if skill_action in ["guard", "heal", "transform"]:
        target_id = enemy_id
    elif skill_action == "support" and (target_id == "" or not combatants.has(target_id) or str((combatants[target_id] as Dictionary).get("team", "")) != "enemy"):
        target_id = enemy_id
    if target_id == "":
        return _fallback_enemy_action(enemy_id, decision, "missing_target")
    var zone := str(decision.get("zone", "torso"))
    var result: Dictionary = resolve_skill(enemy_id, target_id, str(skill.get("skill_id", "")), zone, -1)
    if not bool(result.get("ok", false)):
        return _fallback_enemy_action(enemy_id, decision, str(result.get("reason", "skill_failed")))
    result["generated_skill"] = true
    result["selected_tree"] = str((combatants[enemy_id] as Dictionary).get("chosen_tree", ""))
    result["decision_reason"] = str(decision.get("reason", "doctrine_skill"))
    result["memory_used"] = bool(decision.get("memory_used", false))
    result["doctrine_used"] = true
    return result

func use_ultimate(attacker_id: String, target_id: String, progress_state: Dictionary) -> Dictionary:
    var result: Dictionary = ultimate_runtime.prepare(self, attacker_id, target_id, progress_state)
    if bool(result.get("ok", false)) and result.has("progress_state"):
        _apply_progress_state(attacker_id, result.get("progress_state", {}))
    if bool(result.get("ok", false)) and combatants.has(attacker_id) and str((combatants[attacker_id] as Dictionary).get("team", "")) == "watcher":
        boss_rules.register_player_action("ultimate")
    action_log.append(result.duplicate(true))
    return result

func register_terrain_effect(cell: Vector2i, skill_id: String, owner_id: String, duration: int) -> Dictionary:
    var key := "%d:%d" % [cell.x, cell.y]
    terrain_effects[key] = {"cell":[cell.x, cell.y], "skill_id":skill_id, "owner_id":owner_id, "remaining":maxi(1, duration)}
    return (terrain_effects[key] as Dictionary).duplicate(true)

func request_summon(owner_id: String, count: int, skill_id: String) -> Dictionary:
    var request := {"owner_id":owner_id, "count":clampi(count, 1, 2), "skill_id":skill_id, "round":round_index}
    summon_requests.append(request)
    while summon_requests.size() > 4:
        summon_requests.pop_front()
    return request.duplicate(true)

func finish_remanence(outcome: String, context: Dictionary = {}) -> Dictionary:
    var results: Dictionary = {}
    for enemy_id_value: Variant in combatants.keys():
        var enemy_id := str(enemy_id_value)
        var row: Dictionary = combatants[enemy_id]
        if str(row.get("team", "")) != "enemy" or bool(row.get("boss", false)):
            continue
        var enemy_outcome := "killed" if not TARGET_RESOLVER_SCRIPT.tactical_actor_alive(row) else outcome
        var merged := context.duplicate(true)
        merged["region_id"] = str(context.get("region_id", active_region_id))
        results[enemy_id] = remanence_bridge.finish_enemy(self, enemy_id, enemy_outcome, merged)
    return results

func can_move_to(cell: Vector2i, actor_id: String = "") -> bool:
    if actor_id != "" and not bool(TARGET_RESOLVER_SCRIPT.validate_tactical_actor(self, actor_id, {"action_type":"move"}).get("ok", false)):
        return false
    if not grid.inside(cell) or grid.occupied(cell):
        return false
    if active_boss_id != "" and boss_director.cell_locked(self, cell):
        return false
    var key := "%d:%d" % [cell.x, cell.y]
    if terrain_effects.has(key):
        var effect: Dictionary = terrain_effects[key]
        if str(effect.get("skill_id", "")) == "BOSS_GARDIEN_LOCK":
            return false
    return true

func boss_rule_snapshot() -> Dictionary:
    return boss_rules.snapshot()

func attempt_subdue(target_id: String) -> Dictionary:
    return submission.subdue(self, target_id)

func subdue_status(target_id: String) -> Dictionary:
    return submission.evaluate(self, target_id)

func alive_ids(team: String = "") -> Array[String]:
    if team == "enemy":
        return submission.active_enemy_ids(self)
    var result: Array[String] = []
    for entity_id_value: Variant in combatants.keys():
        var entity_id := str(entity_id_value)
        var row: Dictionary = combatants[entity_id]
        if not TARGET_RESOLVER_SCRIPT.tactical_actor_alive(row):
            continue
        if team != "" and str(row.get("team", "")) != team:
            continue
        result.append(entity_id)
    return result

func boss_phase_snapshot() -> Dictionary:
    return boss_phase.snapshot()

func next_round() -> void:
    super.next_round()
    _decay_terrain_effects()
    if active_boss_id != "" and combatants.has(active_boss_id) and TARGET_RESOLVER_SCRIPT.tactical_actor_alive(combatants[active_boss_id]):
        last_boss_rule = boss_rules.before_round(self)
        action_log.append({"ok":true, "action":"boss_rule", "boss":active_boss_id, "state":last_boss_rule.duplicate(true)})
        last_boss_mechanics = boss_director.apply_round(self, active_boss_id, last_boss_rule)
        action_log.append({"ok":true, "action":"boss_mechanic", "boss":active_boss_id, "state":last_boss_mechanics.duplicate(true)})
        last_phase_event = boss_phase.update(self)
        if not last_phase_event.is_empty():
            action_log.append({"ok":true, "action":"boss_phase", "boss":active_boss_id, "state":last_phase_event.duplicate(true)})

func serialize() -> Dictionary:
    var payload: Dictionary = super.serialize()
    payload["v07_active_boss_id"] = active_boss_id
    payload["v07_boss_rules"] = boss_rules.snapshot()
    payload["v07_ultimates"] = ultimate_runtime.serialize()
    payload["v07_last_boss_rule"] = last_boss_rule.duplicate(true)
    payload["v07_terrain_effects"] = terrain_effects.duplicate(true)
    payload["v07_summon_requests"] = summon_requests.duplicate(true)
    payload["v08_region_id"] = active_region_id
    payload["v08_last_boss_mechanics"] = last_boss_mechanics.duplicate(true)
    payload["v09_boss_phase"] = boss_phase.snapshot()
    payload["v09_last_phase_event"] = last_phase_event.duplicate(true)
    return payload

func deserialize(payload: Dictionary) -> bool:
    if not super.deserialize(payload):
        return false
    active_boss_id = str(payload.get("v07_active_boss_id", ""))
    boss_rules.restore(payload.get("v07_boss_rules", {}))
    ultimate_runtime.deserialize(payload.get("v07_ultimates", {}))
    last_boss_rule = (payload.get("v07_last_boss_rule", {}) as Dictionary).duplicate(true)
    terrain_effects = (payload.get("v07_terrain_effects", {}) as Dictionary).duplicate(true)
    summon_requests.clear()
    for value: Variant in payload.get("v07_summon_requests", []):
        if value is Dictionary:
            summon_requests.append((value as Dictionary).duplicate(true))
    active_region_id = str(payload.get("v08_region_id", ""))
    last_boss_mechanics = (payload.get("v08_last_boss_mechanics", {}) as Dictionary).duplicate(true)
    boss_phase.restore(payload.get("v09_boss_phase", {}))
    last_phase_event = (payload.get("v09_last_phase_event", {}) as Dictionary).duplicate(true)
    return true

func set_enemy_level(enemy_id: String, level: int) -> bool:
    if not combatants.has(enemy_id):
        return false
    var row: Dictionary = combatants[enemy_id]
    row["level"] = clampi(level, 1, 50)
    row["ultimate_charges"] = _ultimate_charges_for_level(int(row["level"]))
    combatants[enemy_id] = row
    return true

func set_enemy_tree(enemy_id: String, tree_id: String) -> bool:
    if not combatants.has(enemy_id):
        return false
    var valid := false
    for value: Variant in content_db.skills_for(enemy_id):
        if value is Dictionary and str((value as Dictionary).get("tree_id", "")) == tree_id:
            valid = true
            break
    if not valid:
        return false
    var row: Dictionary = combatants[enemy_id]
    row["chosen_tree"] = tree_id
    combatants[enemy_id] = row
    return true

func _push_away(attacker_id: String, target_id: String, distance: int) -> int:
    if not combatants.has(target_id):
        return 0
    var row: Dictionary = combatants[target_id]
    var resist := maxi(0, int(row.get("forced_move_resist", 0)))
    var blocked_steps := mini(distance, int(resist / 10))
    var effective_distance := maxi(0, distance - blocked_steps)
    row["forced_move_resist"] = maxi(0, resist - distance * 10)
    combatants[target_id] = row
    if effective_distance <= 0:
        return 0
    return super._push_away(attacker_id, target_id, effective_distance)

func _decay_terrain_effects() -> void:
    var remove_keys: Array[String] = []
    for key_value: Variant in terrain_effects.keys():
        var key := str(key_value)
        var state: Dictionary = terrain_effects[key]
        state["remaining"] = int(state.get("remaining", 1)) - 1
        if int(state["remaining"]) <= 0:
            remove_keys.append(key)
        else:
            terrain_effects[key] = state
    for key: String in remove_keys:
        terrain_effects.erase(key)

func _progress_state_for(entity_id: String) -> Dictionary:
    var row: Dictionary = combatants.get(entity_id, {})
    return {
        "entity_id":entity_id,
        "level":int(row.get("level", 1)),
        "chosen_tree":str(row.get("chosen_tree", "")),
        "ultimate_charges":int(row.get("ultimate_charges", _ultimate_charges_for_level(int(row.get("level", 1)))))
    }

func _apply_progress_state(entity_id: String, state: Dictionary) -> void:
    if not combatants.has(entity_id) or state.is_empty():
        return
    var row: Dictionary = combatants[entity_id]
    row["level"] = int(state.get("level", row.get("level", 1)))
    row["chosen_tree"] = str(state.get("chosen_tree", row.get("chosen_tree", "")))
    row["ultimate_charges"] = int(state.get("ultimate_charges", row.get("ultimate_charges", 0)))
    combatants[entity_id] = row

func _ultimate_charges_for_level(level: int) -> int:
    if level >= 48:
        return 3
    if level >= 32:
        return 2
    if level >= 16:
        return 1
    return 0

func _initial_enemy_level(row: Dictionary) -> int:
    var threat := float(row.get("threat_value", 1.0))
    return clampi(1 + int(floor(threat * 3.0)), 1, 8)

func _resolve_non_skill_decision(enemy_id: String, decision: Dictionary) -> Dictionary:
    var action := str(decision.get("action", "none"))
    if action in ["move", "flee"]:
        var cell_value: Variant = decision.get("cell", Vector2i(-1, -1))
        if cell_value is Vector2i:
            var cell: Vector2i = cell_value
            if can_move_to(cell, enemy_id) and grid.move(enemy_id, cell):
                var moved := {"ok":true, "action":action, "enemy":enemy_id, "to":[cell.x, cell.y], "decision_reason":str(decision.get("reason", "doctrine_move")), "doctrine_used":bool(decision.get("doctrine_used", false))}
                action_log.append(moved.duplicate(true))
                return moved
        return {"ok":false, "reason":"doctrine_move_blocked"}
    if action == "hold":
        var hold := {"ok":true, "action":"hold", "enemy":enemy_id, "decision_reason":str(decision.get("reason", "hold")), "doctrine_used":bool(decision.get("doctrine_used", false))}
        action_log.append(hold.duplicate(true))
        return hold
    return _fallback_enemy_action(enemy_id, decision, "unsupported_decision")

func _fallback_enemy_action(enemy_id: String, decision: Dictionary, reason: String) -> Dictionary:
    var fallback: Dictionary = _enemy_step_v07_compat(enemy_id)
    fallback["generated_skill_fallback"] = true
    fallback["generated_skill_reason"] = reason
    fallback["original_decision_reason"] = str(decision.get("reason", ""))
    return fallback

func _enemy_step_v07_compat(enemy_id: String) -> Dictionary:
    if not combatants.has(enemy_id) or str((combatants[enemy_id] as Dictionary).get("team", "")) != "enemy":
        return {"ok":false, "reason":"not_enemy"}
    var decision: Dictionary = enemy_ai.decide(self, enemy_id)
    var row: Dictionary = combatants[enemy_id]
    var level := int(row.get("level", 1))
    var progress_state := _progress_state_for(enemy_id)
    if level >= 16:
        if ultimate_runtime.pending.has(enemy_id):
            var executed: Dictionary = ultimate_runtime.execute_pending(self, enemy_id, progress_state)
            if bool(executed.get("ok", false)):
                _apply_progress_state(enemy_id, executed.get("progress_state", {}))
                executed["generated_ultimate"] = true
                return executed
        elif round_index % 4 == 1 and str(decision.get("target", "")) != "":
            var prepared: Dictionary = ultimate_runtime.prepare(self, enemy_id, str(decision.get("target", "")), progress_state)
            if bool(prepared.get("ok", false)) and bool(prepared.get("prepared", false)):
                prepared["generated_ultimate"] = true
                action_log.append(prepared.duplicate(true))
                return prepared

    var action := str(decision.get("action", "none"))
    if action not in ["attack", "support"]:
        return super.enemy_step(enemy_id)
    var skill: Dictionary = skill_selector.select_skill(self, enemy_id, decision)
    if skill.is_empty():
        var fallback: Dictionary = super.enemy_step(enemy_id)
        fallback["generated_skill_fallback"] = true
        return fallback
    var skill_action := skill_behavior.effective_action(skill)
    var target_id := str(decision.get("target", ""))
    if skill_action in ["guard", "heal", "transform"]:
        target_id = enemy_id
    elif skill_action == "support" and (target_id == "" or not combatants.has(target_id) or str((combatants[target_id] as Dictionary).get("team", "")) != "enemy"):
        target_id = enemy_id
    if target_id == "":
        var fallback_no_target: Dictionary = super.enemy_step(enemy_id)
        fallback_no_target["generated_skill_fallback"] = true
        return fallback_no_target
    var zone := str(decision.get("zone", "torso"))
    var result: Dictionary = resolve_skill(enemy_id, target_id, str(skill.get("skill_id", "")), zone, -1)
    if not bool(result.get("ok", false)):
        var fallback_failed: Dictionary = super.enemy_step(enemy_id)
        fallback_failed["generated_skill_fallback"] = true
        fallback_failed["generated_skill_reason"] = str(result.get("reason", "failed"))
        return fallback_failed
    result["generated_skill"] = true
    result["selected_tree"] = str((combatants[enemy_id] as Dictionary).get("chosen_tree", ""))
    result["decision_reason"] = str(decision.get("reason", "tactical_skill"))
    result["memory_used"] = bool(decision.get("memory_used", false))
    return result
