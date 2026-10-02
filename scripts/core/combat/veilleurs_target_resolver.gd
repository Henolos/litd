extends RefCounted
class_name VeilleursTargetResolver

const RULES := preload("res://scripts/core/combat_targeting_rules.gd")
const ZONES := ["head", "torso", "left_arm", "right_arm", "left_leg", "right_leg"]

static func normalize_zone(zone: String) -> String:
    return zone if zone in ZONES else "torso"

static func validate_index(collection: Array, index: int) -> Dictionary:
    if index < 0 or index >= collection.size():
        return {"ok": false, "reason": "invalid_target"}
    return {"ok": true, "target": collection[index]}

# Canonical player-facing targeting façade. The legacy rules file remains the
# source of positional truth for now, while every caller goes through this API.
static func ensure_enemy_positions(enemies: Array) -> void:
    RULES.ensure_enemy_positions(enemies)

static func target_positions(hero: Dictionary, skill: Dictionary) -> Array[int]:
    return RULES.target_positions(hero, skill)

static func ignores_frontline(hero: Dictionary, skill: Dictionary) -> bool:
    return RULES.ignores_frontline(hero, skill)

static func can_target(hero: Dictionary, skill: Dictionary, enemy: Dictionary, enemies: Array) -> bool:
    return RULES.can_target(hero, skill, enemy, enemies)

static func targetable_indices(hero: Dictionary, skill: Dictionary, enemies: Array) -> Array[int]:
    return RULES.targetable_indices(hero, skill, enemies)

static func forced_movement_delta(hero: Dictionary, skill: Dictionary) -> int:
    return RULES.forced_movement_delta(hero, skill)

static func move_enemy(enemies: Array, enemy: Dictionary, delta: int) -> Dictionary:
    return RULES.move_enemy(enemies, enemy, delta)

static func target_range_label(hero: Dictionary, skill: Dictionary) -> String:
    return RULES.target_range_label(hero, skill)

static func movement_label(hero: Dictionary, skill: Dictionary) -> String:
    return RULES.movement_label(hero, skill)

# Enemy AI receives candidates from the same resolver. This intentionally does
# not invent a second positional ruleset: until enemy skills declare stricter
# rank contracts, every living hero is a legal candidate and V3 scores them.
static func enemy_targetable_indices(enemy: Dictionary, action: Dictionary, heroes: Array) -> Array[int]:
    var result: Array[int] = []
    if enemy.is_empty() or int(enemy.get("hp", 0)) <= 0:
        return result
    if str(action.get("target", "random")) in ["none", "self"]:
        return result
    for index in range(heroes.size()):
        var hero_value: Variant = heroes[index]
        if not hero_value is Dictionary:
            continue
        var hero: Dictionary = hero_value
        if int(hero.get("hp", 0)) > 0:
            result.append(index)
    return result


static func body_zones_for_action(action: Dictionary, target: Dictionary = {}) -> Array[String]:
    var explicit_value: Variant = action.get("allowed_body_zones", action.get("target_zones", null))
    var result: Array[String] = []
    if explicit_value is Array:
        for value: Variant in explicit_value:
            var zone := normalize_zone(str(value))
            if ZONES.has(zone) and not result.has(zone):
                result.append(zone)
        if not result.is_empty():
            return result
    if str(action.get("target", "")) == "enemy_zone" or bool(action.get("requires_body_zone", false)):
        return ZONES.duplicate()
    return result

static func requires_body_zone(action: Dictionary) -> bool:
    return str(action.get("target", "")) == "enemy_zone" or bool(action.get("requires_body_zone", false)) or not body_zones_for_action(action).is_empty()

static func can_target_body_zone(action: Dictionary, target: Dictionary, zone: String) -> bool:
    if not requires_body_zone(action):
        return true
    if target.is_empty() or int(target.get("hp", 0)) <= 0:
        return false
    var normalized := normalize_zone(zone)
    return body_zones_for_action(action, target).has(normalized)

static func uses_rank_targeting(action: Dictionary) -> bool:
    return str(action.get("effect", "")) == "attack" or action.has("source_stat") or action.has("branch")

static func validate_target_contract(hero: Dictionary, action: Dictionary, enemy: Dictionary, enemies: Array, zone: String = "") -> Dictionary:
    if enemy.is_empty() or int(enemy.get("hp", 0)) <= 0:
        return {"ok": false, "reason": "enemy_not_targetable"}
    if uses_rank_targeting(action) and not can_target(hero, action, enemy, enemies):
        return {"ok": false, "reason": "enemy_not_targetable"}
    if requires_body_zone(action):
        if zone == "":
            return {"ok": false, "reason": "body_zone_required"}
        var normalized := normalize_zone(zone)
        if not can_target_body_zone(action, enemy, normalized):
            return {"ok": false, "reason": "body_zone_not_targetable", "zone": normalized}
        return {"ok": true, "target": enemy, "zone": normalized}
    return {"ok": true, "target": enemy, "zone": ""}

static func body_zone_label(zone: String) -> String:
    return str({
        "head":"Tête",
        "torso":"Torse",
        "left_arm":"Bras gauche",
        "right_arm":"Bras droit",
        "left_leg":"Jambe gauche",
        "right_leg":"Jambe droite"
    }.get(normalize_zone(zone), zone))
