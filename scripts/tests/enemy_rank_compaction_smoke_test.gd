extends Node

const POSITION_RUNTIME := preload("res://scripts/core/combat_position_runtime.gd")
var failures: Array[String] = []

func _ready() -> void:
    call_deferred("_run")

func _run() -> void:
    var runtime := POSITION_RUNTIME.new()
    add_child(runtime)
    var enemies: Array = [
        {"id":"e1","hp":0,"combat_position":0},
        {"id":"e2","hp":10,"combat_position":1},
        {"id":"e3","hp":10,"combat_position":2},
        {"id":"e4","hp":10,"combat_position":3},
    ]
    _check(runtime.compact_enemy_formation(enemies), "casualty triggers compaction")
    _check(int(enemies[1].combat_position) == 0, "E2 advances to R1")
    _check(int(enemies[2].combat_position) == 1, "E3 advances to R2")
    _check(int(enemies[3].combat_position) == 2, "E4 advances to R3")

    enemies[1].hp = 0
    runtime.compact_enemy_formation(enemies)
    _check(int(enemies[2].combat_position) == 0, "second casualty advances E3 to R1")
    _check(int(enemies[3].combat_position) == 1, "second casualty advances E4 to R2")
    _finish()

func _check(condition: bool, message: String) -> void:
    if not condition:
        failures.append(message)

func _finish() -> void:
    if failures.is_empty():
        print("ENEMY_RANK_COMPACTION_SMOKE_OK")
        get_tree().quit(0)
        return
    for failure in failures:
        push_error("ENEMY_RANK_COMPACTION_FAIL: %s" % failure)
    get_tree().quit(1)
