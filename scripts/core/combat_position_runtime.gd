extends Node

const MIN_SLOT := 0
const MAX_SLOT := 3
const CORPSE_RUNTIME := preload("res://scripts/core/veilleurs_corpse_tactical_runtime.gd")

var _corpse_runtime: RefCounted = CORPSE_RUNTIME.new()

func initialize_battle(heroes: Array, enemies: Array) -> void:
    _assign_missing_positions(heroes)
    _assign_missing_positions(enemies)

func compact_living_formation(characters: Array, side: String = "enemy") -> Dictionary:
    var living: Array[Dictionary] = []
    var before: Dictionary = {}
    for value: Variant in characters:
        if not value is Dictionary:
            continue
        var character: Dictionary = value
        if int(character.get("hp", 0)) <= 0:
            continue
        var runtime_id := str(character.get("combat_uid", character.get("id", character.get("name", ""))))
        before[runtime_id] = position_of(character)
        living.append(character)

    living.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
        var left_position := position_of(left)
        var right_position := position_of(right)
        if left_position == right_position:
            return str(left.get("combat_uid", left.get("id", ""))) < str(right.get("combat_uid", right.get("id", "")))
        return left_position < right_position
    )

    var moved: Array[Dictionary] = []
    for rank in range(living.size()):
        var character: Dictionary = living[rank]
        var origin := position_of(character)
        var destination := clampi(rank, MIN_SLOT, MAX_SLOT)
        if origin == destination:
            continue
        character["combat_position"] = destination
        character["last_combat_move"] = {
            "from": origin,
            "to": destination,
            "side": side,
            "source": "death_compaction"
        }
        moved.append({
            "id": str(character.get("combat_uid", character.get("id", character.get("name", "")))),
            "from": origin,
            "to": destination
        })

    if not moved.is_empty():
        GameState.state_changed.emit()
    return {"ok": true, "side": side, "moved": moved, "before": before, "after": formation_snapshot(characters, side)}

func compact_after_death(characters: Array, side: String = "enemy") -> Dictionary:
    return compact_living_formation(characters, side)

func position_of(character: Dictionary, fallback: int = 0) -> int:
    return clampi(int(character.get("combat_position", fallback)), MIN_SLOT, MAX_SLOT)

func available_moves(character: Dictionary, allies: Array, side: String = "hero") -> Array[int]:
    var result: Array[int] = []
    if character.is_empty() or int(character.get("hp", 0)) <= 0:
        return result
    var current := position_of(character)
    for destination in [current - 1, current + 1]:
        if can_move(character, destination, allies, side):
            result.append(destination)
    return result

func can_move(character: Dictionary, destination: int, allies: Array, side: String = "hero") -> bool:
    if character.is_empty() or destination < MIN_SLOT or destination > MAX_SLOT:
        return false
    var current := position_of(character)
    if abs(destination - current) != 1:
        return false
    if _slot_blocked_by_corpse(destination, side):
        return false
    for ally_value: Variant in allies:
        if not ally_value is Dictionary:
            continue
        var ally: Dictionary = ally_value
        if ally == character or int(ally.get("hp", 0)) <= 0:
            continue
        if position_of(ally, -1) == destination:
            return false
    return true

func move(character: Dictionary, destination: int, allies: Array, side: String = "hero", source: String = "manual") -> Dictionary:
    if not can_move(character, destination, allies, side):
        return {"ok": false, "reason": "position_blocked", "from": position_of(character), "to": destination, "side": side}
    var origin := position_of(character)
    character["combat_position"] = destination
    character["last_combat_move"] = {"from": origin, "to": destination, "side": side, "source": source}
    GameState.state_changed.emit()
    return {"ok": true, "from": origin, "to": destination, "side": side, "source": source}

func enemy_move_action(enemy: Dictionary, enemies: Array) -> Dictionary:
    if enemy.is_empty() or int(enemy.get("hp", 0)) <= 0:
        return {}
    var moves := available_moves(enemy, enemies, "enemy")
    if moves.is_empty():
        return {}
    var current := position_of(enemy)
    var preferred := _preferred_enemy_slot(enemy)
    if current == preferred:
        return {}
    var destination := current
    if preferred < current and moves.has(current - 1):
        destination = current - 1
    elif preferred > current and moves.has(current + 1):
        destination = current + 1
    if destination == current:
        return {}
    var result := move(enemy, destination, enemies, "enemy", "ai")
    if not bool(result.get("ok", false)):
        return {}
    return {"id": "tactical_move", "name": "Repositionnement", "target": "none", "power": 0.0, "tactical_move": true, "from": current, "to": destination}

func formation_snapshot(characters: Array, side: String) -> Dictionary:
    var result := {0: [], 1: [], 2: [], 3: []}
    for value: Variant in characters:
        if not value is Dictionary:
            continue
        var character: Dictionary = value
        if int(character.get("hp", 0)) <= 0:
            continue
        (result[position_of(character)] as Array).append(str(character.get("id", character.get("name", "?"))))
    for slot in range(MIN_SLOT, MAX_SLOT + 1):
        if _slot_blocked_by_corpse(slot, side):
            (result[slot] as Array).append("corpse")
    return result

func _assign_missing_positions(characters: Array) -> void:
    var next_slot := 0
    for value: Variant in characters:
        if not value is Dictionary:
            continue
        var character: Dictionary = value
        if character.has("combat_position"):
            continue
        character["combat_position"] = clampi(next_slot, MIN_SLOT, MAX_SLOT)
        next_slot += 1

func _slot_blocked_by_corpse(slot: int, side: String) -> bool:
    var ge01 := get_node_or_null("/root/GE01Runtime")
    if ge01 == null or not ge01.has_method("tactical_corpse_context"):
        return false
    var context: Dictionary = ge01.call("tactical_corpse_context")
    var ids: Array = context.keys()
    return not bool(_corpse_runtime.call("can_move_to_slot", slot, ids, side))

func _preferred_enemy_slot(enemy: Dictionary) -> int:
    var species := str(enemy.get("species_id", ""))
    if species in ["ash_roamer", "ghoul_hungry", "ghoul_voracious", "mutilated_guardian"]:
        return 0
    if species == "ash_bearer":
        return 1
    if str(enemy.get("archetype", "")) in ["ranged", "support"]:
        return 3
    return 1
