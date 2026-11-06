extends Node

# Pre-playtest rank regression: verify multiple casualties and stable survivor order.
const POSITION_RUNTIME := preload("res://scripts/core/combat_position_runtime.gd")
const TARGETING_RULES := preload("res://scripts/core/combat_targeting_rules.gd")
const TARGET_RESOLVER := preload("res://scripts/core/combat/veilleurs_target_resolver.gd")
var failures: Array[String] = []

func _ready() -> void:
    call_deferred("_run")

func _check(ok: bool, description: String) -> void:
    if not ok:
        failures.append(description)

func _run() -> void:
    var runtime := POSITION_RUNTIME.new()
    add_child(runtime)
    var enemies: Array = [
        {"id": "e1", "hp": 10, "combat_position": 0},
        {"id": "e2", "hp": 0, "combat_position": 1},
        {"id": "e3", "hp": 0, "combat_position": 2},
        {"id": "e4", "hp": 10, "combat_position": 3},
    ]
    _check(runtime.compact_enemy_formation(enemies), "two casualties must compact")
    _check(int(enemies[0].combat_position) == 0, "front survivor must remain E1")
    _check(int(enemies[3].combat_position) == 1, "rear survivor must advance to E2")
    _check(not runtime.compact_enemy_formation(enemies), "second compaction must be idempotent")
    var hero := {"id": "hero", "class_id": "watcher", "combat_position": 0}
    var melee := {"id": "basic_strike", "effect": "attack"}
    var targets := TARGETING_RULES.targetable_indices(hero, melee, enemies)
    _check(targets.has(0) and targets.has(3), "both survivors must remain melee-targetable after compaction")
    _check(not targets.has(1) and not targets.has(2), "dead enemies must not be targetable")
    TARGETING_RULES.ensure_enemy_positions(enemies)
    _check(int(enemies[3].combat_position) == 1, "normalization must preserve live E2 rank")
    _check(TARGETING_RULES.targetable_indices(hero, melee, enemies).has(3), "rear survivor must remain targetable after normalization")
    var anatomy := {"id": "basic_strike", "effect": "attack", "target": "enemy_zone", "allowed_body_zones": ["head", "torso"]}
    _check(str(TARGET_RESOLVER.validate_target_contract(hero, anatomy, enemies[3], enemies).get("reason", "")) == "body_zone_required", "anatomical action must require a body zone")
    _check(bool(TARGET_RESOLVER.validate_target_contract(hero, anatomy, enemies[3], enemies, "head").get("ok", false)), "compacted survivor head must remain targetable")
    _check(str(TARGET_RESOLVER.validate_target_contract(hero, anatomy, enemies[3], enemies, "left_leg").get("reason", "")) == "body_zone_not_targetable", "forbidden anatomical zone must be rejected")
    _check(not bool(TARGET_RESOLVER.validate_target_contract(hero, anatomy, enemies[1], enemies, "head").get("ok", false)), "dead enemy must reject anatomical targeting")

    enemies[0].hp = 0
    _check(runtime.compact_enemy_formation(enemies), "third casualty must compact")
    _check(int(enemies[3].combat_position) == 0, "last survivor must advance to E1")

    enemies[3].hp = 0
    _check(not runtime.compact_enemy_formation(enemies), "empty formation must not move")

    if failures.is_empty():
        print("PRE_PLAYTEST_RANK_EDGECASES_OK")
        get_tree().quit(0)
        return
    for failure in failures:
        push_error("PRE_PLAYTEST_RANK_EDGECASES_FAIL: %s" % failure)
    get_tree().quit(1)
