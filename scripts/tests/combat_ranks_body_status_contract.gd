extends SceneTree

const POSITIONS = preload("res://scripts/core/combat_position_runtime.gd")
const BODY = preload("res://scripts/core/veilleurs_body_component.gd")
const TARGET = preload("res://scripts/core/combat/veilleurs_target_resolver.gd")
const STATUS = preload("res://scripts/core/combat/veilleurs_status_resolver.gd")

func _initialize() -> void:
    call_deferred("_run")

func _assert(value: bool, message: String) -> void:
    if not value:
        push_error("COMBAT_CONTRACT_FAIL: " + message)
        quit(1)

func _run() -> void:
    var enemies: Array = [
        {"id":"front", "hp":0, "combat_position":0},
        {"id":"middle", "hp":10, "combat_position":2},
        {"id":"rear", "hp":10, "combat_position":3}
    ]
    var positions = POSITIONS.new()
    _assert(positions.compact_enemy_formation(enemies), "formation should compact")
    _assert(int(enemies[1]["combat_position"]) == 0, "first survivor must occupy E1")
    _assert(int(enemies[2]["combat_position"]) == 1, "second survivor must occupy E2")
    _assert(not positions.compact_enemy_formation(enemies), "second compaction must be idempotent")

    var body = BODY.new()
    _assert(body.apply_trauma("left_arm", 999, 5).get("severed", false), "left arm must sever")
    _assert(not body.functional_flags()["can_use_two_handed"], "severed arm blocks two-handed use")
    var actor = {"hp":20, "body":body}
    _assert(not TARGET.validate_tactical_actor(null, "", {}).get("ok", false), "invalid runtime rejected")
    var target = {"hp":20, "body":body}
    _assert(not TARGET.can_target_body_zone({"target":"enemy_zone"}, target, "left_arm"), "missing arm cannot be targeted")

    var stunned = {"afflictions":{}}
    var first: Dictionary = STATUS.apply_affliction(stunned, "stun", 2)
    stunned["afflictions"] = first["afflictions"]
    var repeated: Dictionary = STATUS.apply_affliction(stunned, "stun", 9)
    _assert(int(repeated["afflictions"]["stun"]) == 2, "stun must not refresh while active")
    stunned["afflictions"] = STATUS.finish_turn(stunned)
    stunned["afflictions"] = STATUS.finish_turn(stunned)
    _assert(int(stunned.get("affliction_immunities", {}).get("stun", 0)) == 1, "stun recovery immunity")
    _assert(STATUS.apply_affliction(stunned, "stun", 2).get("immune", false), "stun blocked during immunity")

    var silenced = {"afflictions":{"silence":2}}
    _assert(STATUS.action_block(silenced, {"effect":"trame_bolt"}) == "silenced", "silence blocks trame")
    _assert(STATUS.action_block(silenced, {"effect":"attack"}) == "", "silence does not block basic attack")
    print("COMBAT_CONTRACT_OK")
    quit(0)
