extends Node

const Proc := preload("res://scripts/core/combat/veilleurs_equipment_proc_resolver.gd")
const Status := preload("res://scripts/core/combat/veilleurs_status_resolver.gd")
const Runtime := preload("res://scripts/core/veilleurs_tactical_combat_runtime_v2.gd")

func _ready() -> void:
    var attacker := {"equipment_bonuses":{"bleed_chance":100,"stun_chance":100}}
    var target := {"hp":40,"max_hp":40,"afflictions":{}}
    var first: Dictionary = Proc.resolve_after_hit(attacker, target, "equipment-proc-contract")
    assert((target.afflictions as Dictionary).is_empty(), "equipment proc resolver must not mutate input target")
    assert((first.events as Array).size() == 2, "both configured proc receipts must be emitted")
    var first_target: Dictionary = first.target
    assert(Status.has(first_target, "bleed"), "100% bleed proc must use canonical bleed")
    assert(Status.has(first_target, "stun"), "100% stun proc must use canonical stun")
    assert(int(first_target.afflictions.stun) == 1, "equipment stun owns no custom duration")

    var repeated: Dictionary = Proc.resolve_after_hit(attacker, first_target, "equipment-proc-contract")
    assert(int(repeated.target.afflictions.stun) == 1, "repeated equipment proc must not extend active stun")

    var recovery_target: Dictionary = repeated.target
    recovery_target.afflictions = Status.finish_turn(recovery_target)
    assert(not Status.has(recovery_target, "stun"), "stun must expire through canonical resolver")
    assert(int(recovery_target.affliction_immunities.stun) == 1, "canonical recovery immunity must be granted")
    var during_immunity: Dictionary = Proc.resolve_after_hit(attacker, recovery_target, "equipment-proc-contract")
    assert(not Status.has(during_immunity.target, "stun"), "equipment proc must respect stun recovery immunity")
    var stun_receipts: Array = (during_immunity.events as Array).filter(func(event: Dictionary) -> bool: return str(event.get("affliction", "")) == "stun")
    assert(stun_receipts.size() == 1 and bool(stun_receipts[0].get("immune", false)), "stun receipt must expose canonical immunity")

    var resistant := {"hp":40,"max_hp":40,"afflictions":{},"affliction_resistances":{"bleed":{"duration":100}}}
    var resisted: Dictionary = Proc.resolve_after_hit({"equipment_bonuses":{"bleed_chance":100}}, resistant, "resist")
    assert(not Status.has(resisted.target, "bleed"), "equipment proc must respect canonical duration resistance")
    assert(bool(resisted.events[0].get("resisted", false)), "resistance must be visible in proc receipt")

    var deterministic_attacker := {"equipment_bonuses":{"bleed_chance":37}}
    var roll_a: Dictionary = Proc.resolve_after_hit(deterministic_attacker, target, "stable-seed")
    var roll_b: Dictionary = Proc.resolve_after_hit(deterministic_attacker, target, "stable-seed")
    assert(roll_a.events == roll_b.events, "same combat seed must reproduce equipment proc receipt")

    var dead: Dictionary = Proc.resolve_after_hit(attacker, {"hp":0,"max_hp":40,"afflictions":{}}, "dead")
    assert((dead.events as Array).is_empty(), "dead targets must not receive equipment procs")

    var runtime := Runtime.new()
    var setup: Dictionary = runtime.setup_first_combat()
    assert(bool(setup.get("ok", false)), "canonical tactical runtime must initialize")
    var attacker_id := "ENT_WATCHER_mathilde"
    var target_id := "ENT_ENEMY_GOULE_AFFAMEE"
    var runtime_attacker: Dictionary = runtime.combatants[attacker_id]
    runtime_attacker["equipment_bonuses"] = {"bleed_chance":100,"stun_chance":100}
    runtime_attacker["weapon_power"] = 1
    runtime.combatants[attacker_id] = runtime_attacker
    var skill := {"skill_id":"EQUIPMENT_PROC_CONTRACT","skill_index":1,"effect_spec":{"damage_multiplier":0.1}}
    var hit: Dictionary = runtime.call("_resolve_damage_v2", attacker_id, target_id, skill, "torso", 1)
    assert(bool(hit.get("hit", false)), "forced canonical hit must land")
    assert((hit.get("equipment_procs", []) as Array).size() == 2, "confirmed hit must expose equipment proc receipts")
    var runtime_target: Dictionary = runtime.combatants[target_id]
    assert(Status.has(runtime_target, "bleed") and Status.has(runtime_target, "stun"), "runtime must persist canonical equipment afflictions")

    print("VEILLEURS_EQUIPMENT_AFFLICTION_PROCS_OK")
    get_tree().quit(0)
