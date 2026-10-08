extends Node

const POSITION_RUNTIME := preload("res://scripts/core/combat_position_runtime.gd")
const TARGETING_RULES := preload("res://scripts/core/combat_targeting_rules.gd")

func _ready() -> void:
    var enemies: Array = [
        {"id":"dead_e1","hp":0,"max_hp":19,"combat_position":0},
        {"id":"dead_e2","hp":0,"max_hp":19,"combat_position":1},
        {"id":"dead_e3","hp":0,"max_hp":19,"combat_position":2},
        {"id":"survivor_e4","hp":19,"max_hp":19,"combat_position":3}
    ]

    var runtime := POSITION_RUNTIME.new()
    assert(runtime.compact_enemy_formation(enemies), "living survivor must compact toward E1")
    assert(int((enemies[3] as Dictionary).get("combat_position", -1)) == 0, "survivor must move E4 -> E1")

    # The targeting normalization pass runs later in the inherited combat UI.
    # It must not let dead enemies reclaim E1/E2/E3 and push the survivor back.
    TARGETING_RULES.ensure_enemy_positions(enemies)
    assert(int((enemies[3] as Dictionary).get("combat_position", -1)) == 0, "dead slots must not undo live compaction")

    # Regression contract: corpses may remain addressable, but never steal a living tactical rank.\n    var occupied: Dictionary = {}
    for enemy_value: Variant in enemies:
        var enemy: Dictionary = enemy_value
        var position := int(enemy.get("combat_position", -1))
        assert(position >= 0 and position <= 3, "all enemy ranks must stay in E1-E4")
        assert(not occupied.has(position), "living and dead entries must keep unique tactical slots")
        occupied[position] = true

    var hero := {"id":"hero","class_id":"watcher","combat_position":0}
    var melee := {"id":"basic_strike","effect":"attack"}
    var targetable := TARGETING_RULES.targetable_indices(hero, melee, enemies)
    assert(targetable.has(3), "compacted survivor must be reachable as the live E1 target")

    print("ENEMY_FORMATION_COMPACTION_CONTRACT_OK")
    get_tree().quit(0)
