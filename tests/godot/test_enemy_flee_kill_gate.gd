extends SceneTree

const RUNTIME_SCRIPT := preload("res://scripts/core/veilleurs_tactical_combat_runtime.gd")

func _initialize() -> void:
    var runtime = RUNTIME_SCRIPT.new()
    var setup: Dictionary = runtime.setup_first_combat()
    if not bool(setup.get("ok", false)):
        _fail("combat setup failed: %s" % str(setup))
        return
    var enemy_id := "ENT_ENEMY_GOULE_AFFAMEE"
    var hero_id := "ENT_WATCHER_marec"
    var enemy: Dictionary = runtime.combatants[enemy_id]
    enemy["hp"] = 1
    runtime.combatants[enemy_id] = enemy
    var decision: Dictionary = runtime.enemy_ai.decide(runtime, enemy_id)
    if str(decision.get("action", "")) == "flee":
        _fail("enemy fled without killing a hero")
        return
    enemy["hero_kills"] = 1
    runtime.combatants[enemy_id] = enemy
    decision = runtime.enemy_ai.decide(runtime, enemy_id)
    if str(decision.get("action", "")) != "flee":
        _fail("eligible critically wounded enemy did not flee: %s" % str(decision))
        return
    var saved: Dictionary = runtime.serialize()
    var restored = RUNTIME_SCRIPT.new()
    if not restored.deserialize(saved):
        _fail("combat restore failed")
        return
    if int((restored.combatants[enemy_id] as Dictionary).get("hero_kills", -1)) != 1:
        _fail("hero kill counter lost after save/restore")
        return
    var other_enemy_id := "ENT_ENEMY_ECORCHEUSE"
    var other_enemy: Dictionary = restored.combatants[other_enemy_id]
    other_enemy["hp"] = 1
    restored.combatants[other_enemy_id] = other_enemy
    if str(restored.enemy_ai.decide(restored, other_enemy_id).get("action", "")) == "flee":
        _fail("another enemy inherited the kill permission")
        return
    print("PASS: no flee without own kill, flee after kill, persistence, no shared kill")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
