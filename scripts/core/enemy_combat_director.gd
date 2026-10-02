extends Node

const AI_V3_SCRIPT := preload("res://scripts/core/veilleurs_enemy_ai_v3.gd")
const POSITION_RUNTIME_SCRIPT := preload("res://scripts/core/combat_position_runtime.gd")

var enemy_ai_v3: VeilleursEnemyAIV3 = AI_V3_SCRIPT.new()
var position_runtime := POSITION_RUNTIME_SCRIPT.new()
var data: Dictionary = {}
var skills: Array = []
var archetype_rules: Array = []

func _ready() -> void:
    var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/enemy_combat_profiles.json"))
    if parsed is Dictionary:
        data = parsed
        skills = data.get("skills", [])
        archetype_rules = data.get("archetype_rules", [])

func archetype(enemy: Dictionary) -> String:
    if bool(enemy.get("boss", false)):
        return "boss"
    var searchable := String(enemy.get("name", "")).to_lower()
    for rule_value: Variant in archetype_rules:
        var rule: Dictionary = rule_value
        for token_value: Variant in rule.get("contains", []):
            if searchable.contains(String(token_value).to_lower()):
                return String(rule.get("archetype", "any"))
    return String(enemy.get("archetype", "any"))

func choose_action(enemy: Dictionary, heroes: Array) -> Dictionary:
    var allies: Array = GameState.alive_enemies()
    var decision := enemy_ai_v3.decide_rank_action(enemy, heroes, allies, maxi(1, int(GameState.battle_rounds)))

    match str(decision.get("action", "attack")):
        "flee":
            var flee_action := _ge01_flee_action(enemy)
            if not flee_action.is_empty():
                flee_action["decision_reason"] = str(decision.get("reason", "critical_survival"))
                return flee_action
        "move":
            var move_action := position_runtime.enemy_move_action(enemy, GameState.battle_enemies)
            if not move_action.is_empty():
                move_action["decision_reason"] = str(decision.get("reason", "restore_role_position"))
                return move_action
        "support":
            var support_action := _support_action(enemy, heroes)
            if not support_action.is_empty():
                support_action["decision_reason"] = str(decision.get("reason", "ally_critical"))
                return support_action
        "hold":
            return {"id":"hold","name":"Attente","power":0.0,"target":"none","hold":true,"decision_reason":str(decision.get("reason","hold"))}

    var candidates: Array[Dictionary] = []
    var enemy_archetype := archetype(enemy)
    for skill_value: Variant in skills:
        var skill: Dictionary = skill_value
        var allowed: Array = skill.get("archetypes", [])
        if not allowed.has("any") and not allowed.has(enemy_archetype):
            continue
        if not _requirements_met(enemy, skill.get("requires", {})):
            continue
        for _weight in range(maxi(1, int(skill.get("weight", 1)))):
            candidates.append(skill)
    if candidates.is_empty():
        var fallback := {"id":"basic_attack","name":"Attaque","power":1.0,"target":"random"}
        fallback = _apply_remanence_action(enemy, fallback)
        fallback = NgPlusCycleDirector.modify_enemy_action(fallback, enemy, heroes)
        fallback["target_index"] = _target_index(enemy, heroes, String(fallback.get("target", "random")))
        return fallback
    var chosen: Dictionary = candidates[randi() % candidates.size()].duplicate(true)
    chosen = _apply_remanence_action(enemy, chosen)
    chosen = NgPlusCycleDirector.modify_enemy_action(chosen, enemy, heroes)
    chosen["target_index"] = _target_index(enemy, heroes, String(chosen.get("target", "random")))
    return chosen

func _support_action(enemy: Dictionary, heroes: Array) -> Dictionary:
    var enemy_archetype := archetype(enemy)
    var support_candidates: Array[Dictionary] = []
    for skill_value: Variant in skills:
        if not skill_value is Dictionary:
            continue
        var skill: Dictionary = skill_value
        var allowed: Array = skill.get("archetypes", [])
        if not allowed.has("any") and not allowed.has(enemy_archetype):
            continue
        if not _requirements_met(enemy, skill.get("requires", {})):
            continue
        var is_support := str(skill.get("self_status", "")) != "" or float(skill.get("power", 1.0)) <= 0.7 and int(skill.get("fear_damage", 0)) > 0
        if is_support:
            support_candidates.append(skill)
    if support_candidates.is_empty():
        return {}
    var chosen := support_candidates[posmod((str(enemy.get("combat_uid", enemy.get("id", ""))) + str(GameState.battle_rounds)).hash(), support_candidates.size())].duplicate(true)
    chosen = _apply_remanence_action(enemy, chosen)
    chosen = NgPlusCycleDirector.modify_enemy_action(chosen, enemy, heroes)
    chosen["target_index"] = _target_index(enemy, heroes, String(chosen.get("target", "random")))
    chosen["support"] = true
    return chosen

func _ge01_flee_action(enemy: Dictionary) -> Dictionary:
    if not bool(enemy.get("ge01_can_flee", false)) or bool(enemy.get("ge01_fled", false)):
        return {}
    if bool(enemy.get("boss", false)) or bool(enemy.get("is_boss", false)) or bool(enemy.get("remanence_protected", false)):
        return {}
    var hp_before := int(enemy.get("hp", 0))
    var hp_ratio := float(hp_before) / maxf(1.0, float(enemy.get("max_hp", hp_before)))
    var limb_lost := not (enemy.get("dismembered_parts", []) as Array).is_empty()
    var allies_dead := false
    for other_value: Variant in GameState.battle_enemies:
        var other: Dictionary = other_value
        if other == enemy:
            continue
        if int(other.get("hp", 0)) <= 0 and not bool(other.get("ge01_fled", false)):
            allies_dead = true
            break
    if hp_ratio > 0.30 and not limb_lost and not allies_dead:
        return {}
    if not bool(enemy.get("ge01_escape_route", true)) or bool(enemy.get("immobilized", false)):
        return {}
    var default_chances := {"ghoul_hungry": 35, "emaciated": 15, "ash_roamer": 55, "ash_bearer": 40, "ghoul_voracious": 10}
    var species_id := str(enemy.get("species_id", ""))
    var chance := clampi(int(enemy.get("ge01_flee_chance", default_chances.get(species_id, 0))), 0, 100)
    if chance <= 0 or randi_range(1, 100) > chance:
        return {}
    var runtime := get_node_or_null("/root/GE01Runtime")
    if runtime == null or not runtime.has_method("try_flee_enemy"):
        return {}
    var result: Dictionary = runtime.call("try_flee_enemy", enemy, 0)
    if not bool(result.get("success", false)):
        return {}
    enemy["hp"] = hp_before
    enemy["captured"] = false
    enemy["ge01_fled"] = true
    GameState.battle_enemies.erase(enemy)
    GameState.add_log("%s rompt le combat et disparaît dans les galeries." % str(enemy.get("name", "La créature")))
    return {"id": "ge01_flee", "name": "Fuite", "power": 0.0, "target": "none", "ge01_flee": true, "reason": "wounded" if hp_ratio <= 0.30 else ("mutilated" if limb_lost else "allies_lost")}

func _apply_remanence_action(enemy: Dictionary, action: Dictionary) -> Dictionary:
    var result := action.duplicate(true)
    var target_mode := str(enemy.get("remanence_target_mode", ""))
    if target_mode != "":
        result["target"] = target_mode
    var memory_multiplier := maxf(0.1, float(enemy.get("remanence_damage_multiplier", 1.0)))
    if not is_equal_approx(memory_multiplier, 1.0):
        result["power"] = float(result.get("power", 1.0)) * memory_multiplier
        result["remanence_modified"] = true
    return result

func apply_secondary(action: Dictionary, enemy: Dictionary, target: Dictionary, all_targets: Array) -> Array[String]:
    var messages: Array[String] = []
    if String(action.get("self_status", "")) == "guarding":
        enemy["guarding"] = true
        messages.append("%s renforce sa garde." % String(enemy.get("name", "L’ennemi")))
    var fear_damage := int(action.get("fear_damage", 0))
    if fear_damage > 0:
        for hero_value: Variant in all_targets:
            var hero: Dictionary = hero_value
            hero["fear"] = mini(100, int(hero.get("fear", 0)) + fear_damage)
        messages.append("Le cri répand %d Peur dans toute la compagnie." % fear_damage)
    var status := String(action.get("status", "none"))
    if status != "none" and randi_range(1, 100) <= int(action.get("status_chance", 0)):
        target[status] = 2
        messages.append("%s subit %s." % [String(target.get("name", "La cible")), status.replace("_", " ")])
    return messages

func intent_preview(enemy: Dictionary) -> String:
    var enemy_archetype := archetype(enemy)
    var fear := int(enemy.get("enemy_fear", enemy.get("fear_gauge", 0)))
    var target_mode := str(enemy.get("remanence_target_mode", ""))
    if target_mode == "weakest":
        return "Mémoire tactique · cible le Veilleur le plus vulnérable"
    if fear >= 70:
        return "Panique probable · intention instable"
    if enemy_archetype == "spider":
        return "Entrave ou attaque d’une cible vulnérable"
    if enemy_archetype in ["boss", "veil"]:
        return "Menace collective ou attaque lourde"
    if enemy_archetype in ["humanoid", "undead"]:
        return "Garde, rupture ou attaque directe"
    return "Attaque prédatrice"

func _requirements_met(enemy: Dictionary, requirements: Dictionary) -> bool:
    var fear := int(enemy.get("enemy_fear", enemy.get("fear_gauge", 0)))
    var hp_percent := 100.0 * float(enemy.get("hp", 0)) / maxf(1.0, float(enemy.get("max_hp", enemy.get("hp", 1))))
    if fear < int(requirements.get("fear_min", 0)):
        return false
    if fear > int(requirements.get("fear_max", 100)):
        return false
    if hp_percent > float(requirements.get("hp_percent_max", 100.0)):
        return false
    return true

func _target_index(enemy: Dictionary, heroes: Array, mode: String) -> int:
    return enemy_ai_v3.choose_rank_target_index(enemy, heroes, mode, maxi(1, int(GameState.battle_rounds)))
