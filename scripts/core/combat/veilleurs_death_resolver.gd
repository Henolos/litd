extends RefCounted
class_name VeilleursDeathResolver

const POSITION_RUNTIME := preload("res://scripts/core/combat_position_runtime.gd")

static func resolve_actor(actor: Dictionary, side: String, enemies: Array = []) -> Dictionary:
    var hp := int(actor.get("hp", 0))
    if hp > 0:
        return {"died": false, "formation_changed": false}
    var already_dead := bool(actor.get("death_resolved", false))
    actor["death_resolved"] = true
    actor["hp"] = 0
    var formation_changed := false
    if side == "enemy" and not enemies.is_empty():
        var positions := POSITION_RUNTIME.new()
        formation_changed = positions.compact_enemy_formation(enemies)
    return {
        "died": not already_dead,
        "formation_changed": formation_changed,
        "side": side,
        "id": str(actor.get("id", actor.get("entity_id", "")))
    }
