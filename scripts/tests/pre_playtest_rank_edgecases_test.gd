extends Node

# Pre-playtest rank regression: verify multiple casualties and stable survivor order.
const POSITION_RUNTIME := preload("res://scripts/core/combat_position_runtime.gd")
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
