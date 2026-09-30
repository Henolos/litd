extends RefCounted
class_name VeilleursEnemyMemory

static func snapshot(enemy: Dictionary) -> Dictionary:
    return {"stage":str(enemy.get("remanence_stage","normal")),"adaptations":(enemy.get("adaptations",[]) as Array).duplicate(true),"observed_patterns":(enemy.get("observed_patterns",{}) as Dictionary).duplicate(true)}
