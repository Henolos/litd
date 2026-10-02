extends RefCounted
class_name VeilleursCombatSandboxCanonicalAdapter

const HIT_RESOLVER := preload("res://scripts/core/combat/veilleurs_hit_resolver.gd")
const DAMAGE_RESOLVER := preload("res://scripts/core/combat/veilleurs_damage_resolver.gd")
const ANATOMY_RESOLVER := preload("res://scripts/core/combat/veilleurs_anatomy_resolver.gd")
const STATUS_RESOLVER := preload("res://scripts/core/combat/veilleurs_status_resolver.gd")
const DEATH_RESOLVER := preload("res://scripts/core/combat/veilleurs_death_resolver.gd")
const TARGET_RESOLVER := preload("res://scripts/core/combat/veilleurs_target_resolver.gd")

static func resolve_enemy_action(hero: Dictionary, action: Dictionary, target: Dictionary, zone: String, round_index: int, enemies: Array[Dictionary]) -> Dictionary:
    var normalized: String = TARGET_RESOLVER.normalize_zone(zone)
    if str(action.get("effect", "")) == "inflict_affliction":
        return _resolve_affliction(hero, action, target, normalized, round_index)
    var hit_result: Dictionary = HIT_RESOLVER.resolve(hero, action, target, normalized, round_index)
    if not bool(hit_result.get("hit", false)):
        return {"ok":true,"kind":"attack","hit":false,"roll":int(hit_result.get("roll", 0)),"accuracy":int(hit_result.get("accuracy", 75)),"zone":normalized,"target":str(target.get("id", ""))}
    var damage_result: Dictionary = DAMAGE_RESOLVER.resolve(hero, action, target, normalized)
    var damage: int = int(damage_result.get("damage", 1))
    var severity: int = int(damage_result.get("severity", 1))
    var armor_factor: float = float(damage_result.get("armor_factor", 1.0))
    var resulting_hp: int = maxi(0, int(target.get("hp", 0)) - damage)
    var anatomy_result: Dictionary = ANATOMY_RESOLVER.resolve(target.get("anatomy", {}), normalized, severity, armor_factor, action)
    var status_result: Dictionary = STATUS_RESOLVER.resolve_after_hit(target, action, severity, resulting_hp)
    target["hp"] = resulting_hp
    target["anatomy"] = anatomy_result.get("anatomy", {})
    target["pain_state"] = status_result.get("pain_state", "strong")
    target["bleeding_state"] = status_result.get("bleeding_state", target.get("bleeding_state", "none"))
    target["public_vital_state"] = status_result.get("public_vital_state", "stable")
    target["vital_state"] = status_result.get("vital_state", target["public_vital_state"])
    DEATH_RESOLVER.resolve_actor(target, "enemy", enemies)
    if action.has("affliction"):
        var applied: Dictionary = STATUS_RESOLVER.apply_affliction(target, str(action["affliction"]), int(action.get("duration", 2)))
        if bool(applied.get("ok", false)):
            target["afflictions"] = applied["afflictions"]
    return {"ok":true,"kind":"attack","hit":true,"damage":damage,"severity":severity,"zone":normalized,"target":str(target.get("id", "")),"functional_loss":str(anatomy_result.get("functional_loss", "functional")),"affliction":str(action.get("affliction", "")),"zone_state":anatomy_result.get("zone_state", {})}

static func _resolve_affliction(hero: Dictionary, action: Dictionary, target: Dictionary, zone: String, round_index: int) -> Dictionary:
    var kind: String = str(action.get("affliction", ""))
    var turns: int = int(action.get("duration", 0))
    if kind not in STATUS_RESOLVER.AFFLICTIONS or turns <= 0:
        return {"ok":false,"reason":"invalid_affliction"}
    var hit_result: Dictionary = HIT_RESOLVER.resolve(hero, action, target, zone, round_index)
    if not bool(hit_result.get("hit", false)):
        return {"ok":true,"kind":"affliction","hit":false,"target":str(target.get("id", "")),"roll":hit_result.get("roll", 0)}
    var applied: Dictionary = STATUS_RESOLVER.apply_affliction(target, kind, turns)
    target["afflictions"] = applied["afflictions"]
    return {"ok":true,"kind":"affliction","hit":true,"target":str(target.get("id", "")),"affliction":kind,"turns":applied["turns"],"resisted":applied["resisted"]}
