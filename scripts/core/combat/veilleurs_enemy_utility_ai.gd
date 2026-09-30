extends RefCounted
class_name VeilleursEnemyUtilityAI

const COMBAT_COMMAND := preload("res://scripts/core/combat/veilleurs_combat_command.gd")

static func to_combat_command(decision: Dictionary, actor_id: String, watcher_ids: Array) -> Dictionary:
    if str(decision.get("action","")) != "attack":
        return {"ok":false,"reason":"non_combat_action"}
    var target_id := str(decision.get("target",""))
    var target_index := watcher_ids.find(target_id)
    if target_index < 0:
        return {"ok":false,"reason":"unknown_target"}
    var command := COMBAT_COMMAND.make(actor_id, str(decision.get("action_id","enemy_attack")), "enemy", target_index, str(decision.get("zone","torso")))
    var validation := COMBAT_COMMAND.validate(command)
    if not bool(validation.get("ok",false)):
        return validation
    return {"ok":true,"command":command,"reason":str(decision.get("reason","utility_attack"))}
