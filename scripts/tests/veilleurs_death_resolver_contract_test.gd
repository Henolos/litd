extends Node

const DEATH_RESOLVER := preload("res://scripts/core/combat/veilleurs_death_resolver.gd")

var failures: Array[String] = []

func _ready() -> void:
    _direct_death_compacts()
    _dot_death_compacts()
    _idempotent_death_does_not_repeat()
    if failures.is_empty():
        print("VEILLEURS_DEATH_RESOLVER_CONTRACT_OK")
        get_tree().quit(0)
    else:
        for failure in failures:
            push_error(failure)
        get_tree().quit(1)

func _direct_death_compacts() -> void:
    var enemies: Array = [
        {"id":"e1","hp":0,"combat_position":0},
        {"id":"e2","hp":10,"combat_position":1},
        {"id":"e3","hp":10,"combat_position":2},
        {"id":"e4","hp":10,"combat_position":3},
    ]
    var result := DEATH_RESOLVER.resolve_actor(enemies[0], "enemy", enemies)
    _check(bool(result.get("died", false)), "direct death is emitted")
    _check(int(enemies[1].combat_position) == 0, "e2 compacts to R1")
    _check(int(enemies[2].combat_position) == 1, "e3 compacts to R2")
    _check(int(enemies[3].combat_position) == 2, "e4 compacts to R3")

func _dot_death_compacts() -> void:
    var enemies: Array = [
        {"id":"e1","hp":8,"combat_position":0},
        {"id":"e2","hp":1,"combat_position":1},
        {"id":"e3","hp":8,"combat_position":2},
    ]
    enemies[1]["hp"] = 0
    var result := DEATH_RESOLVER.resolve_actor(enemies[1], "enemy", enemies)
    _check(bool(result.get("died", false)), "dot death is emitted")
    _check(int(enemies[2].combat_position) == 1, "dot death compacts following enemy")

func _idempotent_death_does_not_repeat() -> void:
    var enemy := {"id":"e1","hp":0,"combat_position":0}
    var enemies: Array = [enemy]
    var first := DEATH_RESOLVER.resolve_actor(enemy, "enemy", enemies)
    var second := DEATH_RESOLVER.resolve_actor(enemy, "enemy", enemies)
    _check(bool(first.get("died", false)), "first death resolves")
    _check(not bool(second.get("died", true)), "death resolution is idempotent")

func _check(condition: bool, message: String) -> void:
    if not condition:
        failures.append(message)
