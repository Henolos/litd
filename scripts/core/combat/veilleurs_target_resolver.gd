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
