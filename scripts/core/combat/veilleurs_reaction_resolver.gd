extends RefCounted
class_name VeilleursReactionResolver

static func observe_enemy(enemy: Dictionary, hero: Dictionary, zone: String, attack_result: Dictionary) -> Dictionary:
    var patterns: Dictionary = (enemy.get("observed_patterns", {}) as Dictionary).duplicate(true)
    var key := "%s:%s" % [str(hero.get("id", "")), zone]
    patterns[key] = int(patterns.get(key, 0)) + 1
    if int(patterns[key]) >= 2:
        return {"patterns":patterns,"guarded_zone":zone,"reaction":{"observed":true,"hypothesis":"repeated_zone","confidence":"medium","decision":"guard_zone","zone":zone}}
    if bool(attack_result.get("hit", false)) and str(attack_result.get("functional_loss", "")) == "impaired":
        return {"patterns":patterns,"reaction":{"observed":true,"hypothesis":"functional_injury","confidence":"low","decision":"exploit_wounded_actor","hero":str(hero.get("id"))}}
    return {"patterns":patterns,"reaction":{"observed":true,"hypothesis":"insufficient_pattern","confidence":"low","decision":"none"}}
