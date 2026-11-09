extends SceneTree

const RUNTIME := preload("res://scripts/core/veilleurs_tactical_combat_runtime.gd")
const HIT := preload("res://scripts/core/combat/veilleurs_hit_resolver.gd")
const ZONES := ["head", "torso", "left_arm", "right_arm", "left_leg", "right_leg"]

func _initialize() -> void:
    var runtime = RUNTIME.new()
    var db = runtime.content_db
    if db.watchers_by_id.size() != 4 or db.enemies_by_id.size() != 24:
        _fail("expected four heroes and twenty-four enemies")
        return
    var zones: Array[String] = []
    var zone_mods: Dictionary = db.combat_constants.get("zone_accuracy_mod", {})
    for key in zone_mods.keys():
        zones.append(str(key))
    if zones.is_empty():
        _fail("no zone modifiers loaded")
        return
    var clamps: Dictionary = db.combat_constants.get("hit_clamp", {})
    var cases := 0
    for hero_id in db.watchers_by_id.keys():
        var hero_def: Dictionary = db.watcher(str(hero_id))
        var attacker := {"stats": hero_def.get("stats", {})}
        for enemy_id in db.enemies_by_id.keys():
            var enemy_def: Dictionary = db.enemy(str(enemy_id))
            var target := {"stats": enemy_def.get("stats", {})}
            for zone in zones:
                var skill := {"precision_mod": 0}
                var actual := int(runtime.call("_hit_chance", attacker, target, skill, zone))
                var expected := int(HIT.resolve_tactical(attacker, skill, target, zone, zone_mods, clamps, 0, 0, false, 1)["accuracy"])
                if actual != expected:
                    _fail("hit chance mismatch: %s / %s / %s: %d vs %d" % [hero_id, enemy_id, zone, actual, expected])
                    return
                cases += 1
    for delta in [-150, -40, 0, 40, 150]:
        for zone in zones:
            var attacker := {"stats": {"PRE": 50 + delta}}
            var target := {"stats": {"MOB": 50}}
            var skill := {"precision_mod": 7}
            var actual := int(runtime.call("_hit_chance", attacker, target, skill, zone))
            var expected := int(HIT.resolve_tactical(attacker, skill, target, zone, zone_mods, clamps, 0, 0, false, 1)["accuracy"])
            if actual != expected:
                _fail("boundary mismatch at delta %d zone %s" % [delta, zone])
                return
            cases += 1
    print("TACTICAL_HIT_PARITY_OK cases=%d heroes=4 enemies=24 zones=%d" % [cases, zones.size()])
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
