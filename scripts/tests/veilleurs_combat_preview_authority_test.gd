extends Node

const RUNTIME := preload("res://scripts/core/veilleurs_tactical_combat_runtime_v2.gd")

var failures: Array[String] = []

func _ready() -> void:
    var runtime = RUNTIME.new()
    var setup: Dictionary = runtime.setup_first_combat()
    _expect(bool(setup.get("ok", false)), "combat setup")
    if not bool(setup.get("ok", false)):
        _finish()
        return
    var attacker_id := "ENT_WATCHER_MATHILDE"
    var target_id := ""
    for enemy_id: String in runtime.alive_ids("enemy"):
        target_id = enemy_id
        break
    var skills: Array = runtime.content_db.skills_for(attacker_id)
    var skill_id := ""
    for value in skills:
        if value is Dictionary:
            var skill: Dictionary = value
            var action: String = str(runtime.skill_behavior.effective_action(skill))
            if action not in ["passive_modifier", "guard", "heal", "support", "observe", "psychological", "control", "move", "transform"]:
                skill_id = str(skill.get("skill_id", skill.get("id", "")))
                break
    _expect(target_id != "", "enemy target")
    _expect(skill_id != "", "damage skill")
    if target_id != "" and skill_id != "":
        var preview: Dictionary = runtime.preview_skill(attacker_id, target_id, skill_id, "torso")
        _expect(preview.has("ok"), "preview verdict")
        if bool(preview.get("ok", false)):
            _expect(preview.has("hit_chance"), "resolver hit chance")
            _expect(preview.has("damage"), "resolver damage")
            var before := (runtime.combatants[target_id] as Dictionary).duplicate(true)
            runtime.preview_skill(attacker_id, target_id, skill_id, "torso")
            var after: Dictionary = runtime.combatants[target_id]
            _expect(int(before.get("hp", -1)) == int(after.get("hp", -2)), "preview must not mutate hp")
    _finish()

func _finish() -> void:
    if failures.is_empty():
        print("VEILLEURS_COMBAT_PREVIEW_AUTHORITY_OK")
        get_tree().quit(0)
        return
    for failure in failures:
        push_error(failure)
    get_tree().quit(1)

func _expect(value: bool, message: String) -> void:
    if not value:
        failures.append(message)
