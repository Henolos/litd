extends Node

const POSITION_RUNTIME := preload("res://scripts/core/combat_position_runtime.gd")
var failures: Array[String] = []

func _ready() -> void:
    call_deferred("_run")

func _run() -> void:
    var runtime := POSITION_RUNTIME.new()
    add_child(runtime)
    _test_simultaneous_front_casualties(runtime)
    _test_simultaneous_middle_casualties(runtime)
    _test_no_casualties(runtime)
    _test_all_dead(runtime)
    _finish()

func _test_simultaneous_front_casualties(runtime: Node) -> void:
    var enemies: Array = [
        {"id": "e1", "hp": 0, "combat_position": 0},
        {"id": "e2", "hp": 0, "combat_position": 1},
        {"id": "e3", "hp": 10, "combat_position": 2},
        {"id": "e4", "hp": 10, "combat_position": 3}
    ]
    _check(runtime.compact_enemy_formation(enemies), "simultaneous front deaths cause compaction")
    _check(int(enemies[2]["combat_position"]) == 0, "e3 advances to front")
    _check(int(enemies[3]["combat_position"]) == 1, "e4 advances behind e3")
    _check(not runtime.compact_enemy_formation(enemies), "repeated compaction is idempotent")

func _test_simultaneous_middle_casualties(runtime: Node) -> void:
    var enemies: Array = [
        {"id": "e1", "hp": 10, "combat_position": 0},
        {"id": "e2", "hp": 0, "combat_position": 1},
        {"id": "e3", "hp": 0, "combat_position": 2},
        {"id": "e4", "hp": 10, "combat_position": 3}
    ]
    _check(runtime.compact_enemy_formation(enemies), "simultaneous middle deaths cause compaction")
    _check(int(enemies[0]["combat_position"]) == 0, "front survivor stays")
    _check(int(enemies[3]["combat_position"]) == 1, "rear survivor advances")

func _test_no_casualties(runtime: Node) -> void:
    var enemies: Array = [
        {"id": "e1", "hp": 10, "combat_position": 0},
        {"id": "e2", "hp": 10, "combat_position": 1},
        {"id": "e3", "hp": 10, "combat_position": 2},
        {"id": "e4", "hp": 10, "combat_position": 3}
    ]
    _check(not runtime.compact_enemy_formation(enemies), "intact formation does not move")

func _test_all_dead(runtime: Node) -> void:
    var enemies: Array = [
        {"id": "e1", "hp": 0, "combat_position": 0},
        {"id": "e2", "hp": 0, "combat_position": 2}
    ]
    _check(not runtime.compact_enemy_formation(enemies), "no survivors means no compaction")

func _check(condition: bool, message: String) -> void:
    if not condition:
        failures.append(message)

func _finish() -> void:
    if failures.is_empty():
        print("ENEMY_RANK_COMPACTION_EDGE_CASES_OK")
        get_tree().quit(0)
        return
    for failure in failures:
        push_error("ENEMY_RANK_COMPACTION_EDGE_CASES_FAIL: %s" % failure)
    get_tree().quit(1)
