extends RefCounted
class_name VeilleursEnemyPerception

static func snapshot(runtime: Variant, enemy_id: String) -> Dictionary:
    if runtime == null or not runtime.combatants.has(enemy_id):
        return {"ok":false,"reason":"unknown_enemy"}
    var enemy: Dictionary = runtime.combatants[enemy_id]
    var visible_targets: Array = []
    for target_id_value: Variant in runtime.alive_ids("watcher"):
        var target_id := str(target_id_value)
        var target: Dictionary = runtime.combatants.get(target_id, {})
        visible_targets.append({"id":target_id,"hp":int(target.get("hp",0)),"max_hp":int(target.get("max_hp",1)),"distance":int(runtime.grid.distance(enemy_id,target_id))})
    return {"ok":true,"enemy_id":enemy_id,"round":int(runtime.round_index),"role":str(enemy.get("combat_role","assault")),"targets":visible_targets}
