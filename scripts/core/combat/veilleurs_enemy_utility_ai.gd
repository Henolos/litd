extends RefCounted
class_name VeilleursEnemyUtilityAI

static func decide(enemy: Dictionary, heroes: Array, memory: Dictionary = {}) -> Dictionary:
    var alive: Array = []
    for hero in heroes:
        if int((hero as Dictionary).get("hp", 0)) > 0: alive.append(hero)
    if alive.is_empty(): return {"ok":false,"reason":"no_target"}
    var target: Dictionary = alive[0]
    for candidate_value in alive:
        var candidate: Dictionary = candidate_value
        if int(candidate.get("hp", 0)) < int(target.get("hp", 0)): target = candidate
    var target_index := heroes.find(target)
    var zone := "torso"
    var wounded_zone := str(memory.get("preferred_wounded_zone", ""))
    if wounded_zone in ["head", "torso", "left_arm", "right_arm", "left_leg", "right_leg"]: zone = wounded_zone
    return {"ok":true,"intent":{"actor_id":str(enemy.get("id", "")),"action_id":"basic_attack","target_side":"enemy","target_index":target_index,"zone":zone},"reason":"lowest_hp_target"}
