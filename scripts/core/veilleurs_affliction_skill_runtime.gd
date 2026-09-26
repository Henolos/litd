extends Node
class_name VeilleursAfflictionSkillRuntime

const HIT_RESOLVER := preload("res://scripts/core/combat/veilleurs_hit_resolver.gd")
const STATUS_RESOLVER := preload("res://scripts/core/combat/veilleurs_status_resolver.gd")
const RESOLVER_IDS := ["generic_affliction_attack", "generic_affliction_control"]

func handles(skill: Dictionary) -> bool:
    return str(skill.get("resolver_id", "")) in RESOLVER_IDS

func profile_for(_hero: Dictionary, node: Dictionary) -> Dictionary:
    var delivery := str(node.get("affliction_delivery", "control"))
    var power := float(node.get("power_0_5", 0.0))
    var profile := {
        "effect": "attack" if delivery == "attack" else "affliction",
        "target": "enemy_choice",
        "target_selection": "manual",
        "accuracy": int(node.get("base_accuracy_pct", 85)),
        "affliction": str(node.get("affliction", "")),
        "duration": int(node.get("affliction_duration", 2)),
        "affliction_delivery": delivery,
        "build_role": str(node.get("build_role", "")),
        "allowed_positions": _parse_positions(str(node.get("canonical_positions", "")))
    }
    if delivery == "attack":
        profile["power"] = 0.72 + power * 0.145
    return profile

func resolve(hero: Dictionary, target: Dictionary, skill: Dictionary, damage: int = 0, _party: Array = []) -> Dictionary:
    if target.is_empty():
        return {"ok": false, "reason": "target_required", "skill_id": str(skill.get("id", ""))}
    var delivery := str(skill.get("affliction_delivery", "control"))
    if int(target.get("hp", 0)) <= 0:
        if delivery == "attack" and damage > 0:
            return {"ok": true, "action": "affliction", "skill_id": str(skill.get("id", "")), "hit": true, "applied": false, "reason": "target_defeated"}
        return {"ok": false, "reason": "target_required", "skill_id": str(skill.get("id", ""))}
    var kind := str(skill.get("affliction", ""))
    var turns := int(skill.get("affliction_duration", skill.get("duration", 0)))
    if kind not in STATUS_RESOLVER.AFFLICTIONS or turns <= 0:
        return {"ok": false, "reason": "invalid_affliction", "skill_id": str(skill.get("id", ""))}

    var hit := true
    var roll := -1
    var accuracy := int(skill.get("accuracy", skill.get("base_accuracy_pct", 85)))
    if delivery == "attack":
        hit = damage > 0
    else:
        var hit_result: Dictionary = HIT_RESOLVER.resolve(
            hero,
            {"id": str(skill.get("id", "")), "accuracy": accuracy},
            target,
            "torso",
            maxi(1, int(GameState.battle_rounds) + 1)
        )
        hit = bool(hit_result.get("hit", false))
        roll = int(hit_result.get("roll", -1))
        accuracy = int(hit_result.get("accuracy", accuracy))

    if not hit:
        return {
            "ok": true,
            "action": "affliction",
            "skill_id": str(skill.get("id", "")),
            "hit": false,
            "applied": false,
            "affliction": kind,
            "roll": roll,
            "accuracy": accuracy
        }

    var applied: Dictionary = STATUS_RESOLVER.apply_affliction(target, kind, turns)
    if not bool(applied.get("ok", false)):
        return applied
    target["afflictions"] = applied.get("afflictions", {})
    return {
        "ok": true,
        "action": "affliction",
        "skill_id": str(skill.get("id", "")),
        "hit": true,
        "applied": true,
        "affliction": kind,
        "turns": int(applied.get("turns", turns)),
        "build_role": str(skill.get("build_role", "")),
        "roll": roll,
        "accuracy": accuracy
    }

func _parse_positions(text: String) -> Array[int]:
    var clean := text.strip_edges().replace("–", "-")
    if clean == "":
        return []
    var tokens := clean.split("-", false)
    if tokens.size() == 2:
        var start_text := str(tokens[0]).strip_edges().trim_prefix("P")
        var end_text := str(tokens[1]).strip_edges().trim_prefix("P")
        if start_text.is_valid_int() and end_text.is_valid_int():
            var start_value := clampi(int(start_text), 1, 4)
            var end_value := clampi(int(end_text), 1, 4)
            var result: Array[int] = []
            for value in range(mini(start_value, end_value), maxi(start_value, end_value) + 1):
                result.append(value - 1)
            return result
    var single := clean.trim_prefix("P")
    if single.is_valid_int():
        return [clampi(int(single), 1, 4) - 1]
    return []
