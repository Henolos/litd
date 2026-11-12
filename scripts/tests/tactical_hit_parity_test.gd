extends SceneTree

const RUNTIME := preload("res://scripts/core/veilleurs_tactical_combat_runtime.gd")
const HIT := preload("res://scripts/core/combat/veilleurs_hit_resolver.gd")

# Frozen legacy formula from main before the refactor. Do not call HIT here:
# comparing two callers of the same resolver would not detect a shared regression.
static func legacy_hit_chance(attacker: Dictionary, target: Dictionary, skill: Dictionary, zone: String, zone_mods: Dictionary, clamps: Dictionary) -> int:
    var attacker_stats: Dictionary = attacker.get("stats", {})
    var target_stats: Dictionary = target.get("stats", {})
    var chance := 75.0
    chance += (float(attacker_stats.get("PRE", 50)) - float(target_stats.get("MOB", 50))) * 0.45
    chance += float(skill.get("precision_mod", 0))
    chance += float(zone_mods.get(zone, 0))
    return clampi(int(round(chance)), int(clamps.get("min_percent", 10)), int(clamps.get("max_percent", 97)))

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var runtime = RUNTIME.new()
    var db = runtime.content_db
    if db.watchers_by_id.size() != 4 or db.enemies_by_id.size() != 24:
        _fail("expected four heroes and twenty-four enemies")
        return
    var zone_mods: Dictionary = db.combat_constants.get("zone_accuracy_mod", {})
    var zones: Array[String] = []
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
                if not _check(runtime, attacker, target, {"precision_mod": 0}, zone, zone_mods, clamps, "hero/enemy %s/%s" % [hero_id, enemy_id]):
                    return
                cases += 1
    # Cover rounding, clamping, missing defaults, nonzero precision and unknown zones.
    var samples: Array[Dictionary] = [
        {"a": {"stats": {"PRE": -100}}, "t": {"stats": {"MOB": 150}}, "s": {"precision_mod": -13}},
        {"a": {"stats": {"PRE": 200}}, "t": {"stats": {"MOB": -100}}, "s": {"precision_mod": 13}},
        {"a": {"stats": {"PRE": 51}}, "t": {"stats": {"MOB": 50}}, "s": {"precision_mod": 0}},
        {"a": {"stats": {"PRE": 49}}, "t": {"stats": {"MOB": 50}}, "s": {"precision_mod": 0}},
        {"a": {"stats": {"PRE": 50}}, "t": {"stats": {"MOB": 50}}, "s": {"precision_mod": 7}},
        {"a": {}, "t": {}, "s": {}},
        {"a": {"stats": {}}, "t": {"stats": {}}, "s": {}},
    ]
    for sample in samples:
        for zone in zones + ["unknown_zone"]:
            if not _check(runtime, sample["a"], sample["t"], sample["s"], zone, zone_mods, clamps, "edge case %d" % cases):
                return
            cases += 1
    print("TACTICAL_HIT_PARITY_OK cases=%d heroes=4 enemies=24 zones=%d independent_legacy=true" % [cases, zones.size()])
    _finish.call_deferred(0)

func _check(runtime: RefCounted, attacker: Dictionary, target: Dictionary, skill: Dictionary, zone: String, zone_mods: Dictionary, clamps: Dictionary, label: String) -> bool:
    var expected := legacy_hit_chance(attacker, target, skill, zone, zone_mods, clamps)
    var actual := int(runtime.call("_hit_chance", attacker, target, skill, zone))
    var resolver := int(HIT.resolve_tactical(attacker, skill, target, zone, zone_mods, clamps, 0, 0, false, 1)["accuracy"])
    if actual != expected or resolver != expected:
        _fail("%s zone=%s: legacy=%d runtime=%d resolver=%d" % [label, zone, expected, actual, resolver])
        return false
    return true

func _fail(message: String) -> void:
    push_error(message)
    _finish.call_deferred(1)

func _finish(exit_code: int) -> void:
    # The project autoloads start audio even for this arithmetic-only test.
    # Use their existing teardown APIs before shutting down the audio server.
    var playbacks: Array[WeakRef] = []
    for player: Node in root.find_children("*", "AudioStreamPlayer", true, false):
        if player.has_stream_playback():
            playbacks.append(weakref(player.get_stream_playback()))
    root.get_node("AudioDirector").reset_runtime()
    root.get_node("LayeredMusicRuntime").reset_runtime()
    root.get_node("PrototypeAudioBank").clear_cache()
    # stop() queues audio-server cleanup; a single process frame may precede
    # the next audio mix. Observe release rather than sleeping a fixed delay.
    var deadline := Time.get_ticks_msec() + 2000
    while _has_live_playback(playbacks):
        if Time.get_ticks_msec() >= deadline:
            push_error("Audio playback did not release before parity test shutdown")
            exit_code = 1
            break
        await process_frame
    quit(exit_code)

func _has_live_playback(playbacks: Array[WeakRef]) -> bool:
    for playback: WeakRef in playbacks:
        if playback.get_ref() != null:
            return true
    return false
