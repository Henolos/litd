extends Node

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
    var flee_action := _ge01_flee_action(enemy)
    if not flee_action.is_empty():
        flee_action["decision_factors"] = {"forced":"flee"}
        flee_action["decision_reason"] = "forced_flee"
        return flee_action

    var candidates: Array[Dictionary] = []
    var enemy_archetype := archetype(enemy)
    for skill_value: Variant in skills:
        var skill: Dictionary = skill_value
        var allowed: Array = skill.get("archetypes", [])
        if not allowed.has("any") and not allowed.has(enemy_archetype):
            continue
        if not _requirements_met(enemy, skill.get("requires", {})):
            continue
        var scored := _score_action(enemy, skill)
        candidates.append({
            "skill": skill,
            "score": float(scored.get("score", 1.0)),
            "factors": (scored.get("factors", {}) as Dictionary).duplicate(true)
        })

    if candidates.is_empty():
        candidates.append({
            "skill":{"id":"basic_attack","name":"Attaque","power":1.0,"target":"random","weight":1},
            "score":1.0,
            "factors":{"fallback":1.0,"configured_weight":1.0}
        })

    # Preserve the historical meaning of profile "weight": it is a propensity,
    # not an absolute priority. Selection stays varied, but becomes deterministic
    # for an identical combat state and fully traceable.
    var selection := _select_weighted_candidate(candidates, enemy, heroes)
    var selected_index := int(selection.get("index", 0))
    var selected: Dictionary = candidates[selected_index]
    var chosen: Dictionary = (selected.get("skill", {}) as Dictionary).duplicate(true)
    chosen = _apply_remanence_action(enemy, chosen)
    chosen = NgPlusCycleDirector.modify_enemy_action(chosen, enemy, heroes)

    var target_eval := _target_evaluation(
        heroes,
        String(chosen.get("target", "random")),
        enemy,
        str(chosen.get("id", ""))
    )
    chosen["target_index"] = int(target_eval.get("index", -1))
    chosen["action_score"] = float(selected.get("score", 0.0))
    chosen["target_score"] = float(target_eval.get("score", 0.0))
    chosen["decision_factors"] = {
        "action":(selected.get("factors", {}) as Dictionary).duplicate(true),
        "target":(target_eval.get("factors", {}) as Dictionary).duplicate(true),
        "selection":{
            "strategy":"deterministic_weighted_utility",
            "ticket":float(selection.get("ticket", 0.0)),
            "total_weight":float(selection.get("total_weight", 0.0))
        }
    }
    chosen["decision_reason"] = "deterministic_weighted_utility"
    return chosen

func _score_action(enemy: Dictionary, skill: Dictionary) -> Dictionary:
    var configured_weight := maxf(1.0, float(skill.get("weight", 1)))
    var multiplier := 1.0
    var factors := {"configured_weight":configured_weight}
    var hp_ratio := float(enemy.get("hp", 0)) / maxf(1.0, float(enemy.get("max_hp", enemy.get("hp", 1))))
    if str(skill.get("self_status", "")) == "guarding" and hp_ratio <= 0.5:
        factors["wounded_guard_multiplier"] = 1.5
        multiplier *= 1.5
    var fear := float(enemy.get("enemy_fear", enemy.get("fear_gauge", 0)))
    if fear >= 70.0 and str(skill.get("target", "")) == "none":
        factors["high_fear_safe_action_multiplier"] = 1.5
        multiplier *= 1.5
    factors["context_multiplier"] = multiplier
    factors["effective_weight"] = configured_weight * multiplier
    return {"score":configured_weight * multiplier, "factors":factors}

func _select_weighted_candidate(candidates: Array[Dictionary], enemy: Dictionary, heroes: Array) -> Dictionary:
    var total_weight := 0.0
    for candidate: Dictionary in candidates:
        total_weight += maxf(0.001, float(candidate.get("score", 0.0)))
    if candidates.is_empty():
        return {"index":0, "ticket":0.0, "total_weight":0.0}

    var state_key := _decision_state_key(enemy, heroes, candidates)
    var bucket := _stable_bucket(state_key, 1000000)
    var ticket := (float(bucket) / 1000000.0) * total_weight
    var cumulative := 0.0
    for index in range(candidates.size()):
        cumulative += maxf(0.001, float(candidates[index].get("score", 0.0)))
        if ticket < cumulative:
            return {"index":index, "ticket":ticket, "total_weight":total_weight}
    return {"index":candidates.size() - 1, "ticket":ticket, "total_weight":total_weight}

func _decision_state_key(enemy: Dictionary, heroes: Array, candidates: Array[Dictionary]) -> String:
    var parts: Array[String] = [
        str(enemy.get("combat_uid", enemy.get("id", enemy.get("species_id", enemy.get("name", ""))))),
        str(enemy.get("hp", 0)),
        str(enemy.get("max_hp", 0)),
        str(enemy.get("enemy_fear", enemy.get("fear_gauge", 0))),
        str(enemy.get("remanence_target_mode", "")),
        str(enemy.get("remanence_damage_multiplier", 1.0))
    ]
    for hero_value: Variant in heroes:
        if hero_value is Dictionary:
            var hero: Dictionary = hero_value
            parts.append("%s:%s:%s:%s" % [
                str(hero.get("combat_uid", hero.get("id", hero.get("name", "")))),
                str(hero.get("hp", 0)),
                str(hero.get("max_hp", 0)),
                str(hero.get("combat_position", ""))
            ])
    for candidate: Dictionary in candidates:
        parts.append(str((candidate.get("skill", {}) as Dictionary).get("id", "")))
    return "|".join(parts)

func _stable_bucket(key: String, modulo: int) -> int:
    if modulo <= 0:
        return 0
    var value: int = 0
    for index in range(key.length()):
        value = int((value * 131 + key.unicode_at(index)) % 2147483647)
    return value % modulo

func _target_evaluation(heroes: Array, mode: String, enemy: Dictionary = {}, action_id: String = "") -> Dictionary:
    if heroes.is_empty():
        return {"index":-1, "score":-INF, "factors":{"reason":"no_target"}}
    var best_index := 0
    var best_score := -INF
    var best_factors: Dictionary = {}
    for index in range(heroes.size()):
        var hero: Dictionary = heroes[index]
        var score := 0.0
        var factors := {"mode":mode}
        match mode:
            "weakest":
                score = 1.0 - float(hero.get("hp", 0)) / maxf(1.0, float(hero.get("max_hp", 1)))
                factors["missing_hp_ratio"] = score
            "fastest":
                score = float(hero.get("speed", 0))
                factors["speed"] = score
            "highest_hope":
                score = float(hero.get("hope", 0))
                factors["hope"] = score
            "highest_precision":
                score = float(hero.get("precision", 0))
                factors["precision"] = score
            "guarding":
                score = 1.0 if bool(hero.get("guarding", false)) else 0.0
                factors["guarding"] = score
            "nearest":
                score = -float(hero.get("combat_position", index))
                factors["negative_position"] = score
            _:
                var target_key := "%s|%s|%s|%s|%s|%s" % [
                    str(enemy.get("combat_uid", enemy.get("id", enemy.get("name", "")))),
                    action_id,
                    str(hero.get("combat_uid", hero.get("id", hero.get("name", index)))),
                    str(hero.get("hp", 0)),
                    str(hero.get("max_hp", 0)),
                    str(index)
                ]
                score = float(_stable_bucket(target_key, 1000000)) / 1000000.0
                factors["stable_roll"] = score
        if score > best_score:
            best_score = score
            best_index = index
            best_factors = factors
    return {"index":best_index, "score":best_score, "factors":best_factors}

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

func _target_index(heroes: Array, mode: String) -> int:
    return int(_target_evaluation(heroes, mode).get("index", -1))
