extends "res://scripts/core/veilleurs_combat_sandbox_runtime.gd"
class_name VeilleursCombatSandboxRuntimeV2


func perform_action(action_id: String, target_index: int, zone: String = "torso") -> Dictionary:
    var action := _action_by_id(action_id)
    if action.is_empty():
        return {"ok": false, "reason": "unknown_action"}
    if TARGET_RESOLVER.requires_body_zone(action):
        if target_index < 0 or target_index >= enemies.size():
            return {"ok": false, "reason": "invalid_target"}
        var target: Dictionary = enemies[target_index]
        var normalized := TARGET_RESOLVER.normalize_zone(zone)
        if not TARGET_RESOLVER.can_target_body_zone(action, target, normalized):
            return {"ok": false, "reason": "body_zone_not_targetable", "zone": normalized}
        return super.perform_action(action_id, target_index, normalized)
    return super.perform_action(action_id, target_index, zone)

func _action_by_id(action_id: String) -> Dictionary:
    for value: Variant in available_actions():
        if value is Dictionary and str((value as Dictionary).get("id", "")) == action_id:
            return (value as Dictionary).duplicate(true)
    return {}
