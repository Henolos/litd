extends Node

const UI_SCRIPT := preload("res://scripts/ui/combat_sandbox_ui_v51.gd")

func _ready() -> void:
    var ui := UI_SCRIPT.new()
    var affliction_result: String = ui.call("_sandbox_result_text", {"ok":true,"kind":"affliction","hit":true,"affliction":"poison","target":"ennemi","turns":2})
    _check(affliction_result.contains("Poison appliquée") and not affliction_result.contains("0 dégâts"), "affliction feedback describes the effect")
    _check(str(ui.call("_sandbox_result_text", {"ok":true,"kind":"affliction","hit":false})).contains("RATÉE"), "missed affliction does not report an impact")
    var inspected: String = ui.call("_sandbox_afflictions_text", {"poison":2,"stun":1})
    _check(inspected.contains("Poison (2 tours)") and inspected.contains("Étourdissement (1 tour)"), "inspection shows timed afflictions")
    _check(ui.has_method("_sandbox_build_preview_v51"), "missing non-destructive preview builder")
    _check(ui.has_method("_sandbox_confirm_prepared_v51"), "missing explicit confirmation step")
    _check(ui.has_method("_restore_sandbox_focus_v51"), "missing deterministic focus restoration")
    ui.call("_ensure_sandbox_started")
    var before: Dictionary = (ui.get("_sandbox") as RefCounted).call("active_hero").duplicate(true)
    var actions: Array = (ui.get("_sandbox") as RefCounted).call("available_actions")
    _check(not actions.is_empty(), "sandbox exposes actions")
    if not actions.is_empty():
        var action: Dictionary = actions[0]
        ui.set("_sandbox_selected_action", str(action.get("id", "")))
        var target_type := str(action.get("target", "enemy"))
        if target_type.begins_with("enemy"):
            ui.set("_sandbox_selected_target", 0)
        elif target_type == "ally":
            ui.set("_sandbox_selected_ally", 0)
        var preview: Dictionary = ui.call("_sandbox_build_preview_v51")
        _check(str(preview.get("action_id", "")) == str(action.get("id", "")), "preview keeps prepared action")
        _check(int(preview.get("ap", -1)) == int(action.get("ap", 1)), "preview exposes AP cost")
        var after: Dictionary = (ui.get("_sandbox") as RefCounted).call("active_hero").duplicate(true)
        _check(before == after, "building preview must not mutate combat state")
    _check_prepared_validity(ui)
    ui.free()
    print("VEILLEURS_P0_FOCUS_PREVIEW_SMOKE_OK")
    get_tree().quit(0)

func _check(condition: bool, message: String) -> void:
    if condition:
        return
    push_error("VEILLEURS_P0_FOCUS_PREVIEW_SMOKE_FAIL: %s" % message)
    get_tree().quit(1)

func _check_prepared_validity(ui: Control) -> void:
    var runtime: RefCounted = ui.get("_sandbox")
    var hero: Dictionary = runtime.call("active_hero")
    var enemies: Array = runtime.get("enemies")
    # Controlled action isolates the rank/body contract from roster balancing.
    var action := {"id":"hud_contract_attack","name":"Test","effect":"attack","target":"enemy_zone","ap":1,"power":9,"accuracy":80,"allowed_body_zones":["torso"]}
    (hero["sandbox_actions"] as Array).append(action)
    ui.set("_sandbox_selected_action", action["id"])
    ui.set("_sandbox_selected_target", 0)
    ui.set("_sandbox_selected_zone", "torso")
    hero["ap"] = 2
    var before := _snapshot(runtime)
    var preview: Dictionary = ui.call("_sandbox_build_preview_v51")
    _check(bool(preview.get("ready", false)), "valid prepared attack enables confirmation")
    _check(preview.has("hit_chance") and preview.has("damage_on_hit"), "attack preview exposes resolver estimates")
    _check(not preview.has("roll") and not preview.has("hit"), "preview must not reveal the deterministic outcome")
    _check(before == _snapshot(runtime), "preview preserves actors, knowledge, round and trace")
    var expected_damage := int(preview.get("damage_on_hit", -1))
    var checked_hit := false
    for round_number in range(1, 101):
        runtime.set("round", round_number)
        var hit: Dictionary = VeilleursCombatSandboxCanonicalAdapter.HIT_RESOLVER.resolve(hero, action, enemies[0], "torso", round_number)
        if bool(hit.get("hit", false)):
            var result: Dictionary = runtime.call("perform_action", action["id"], 0, "torso")
            _check(int(result.get("damage", -2)) == expected_damage, "preview damage agrees with confirmed resolver")
            checked_hit = true
            break
    _check(checked_hit, "confirmed hit was exercised")
    runtime.call("setup")
    hero = runtime.call("active_hero")
    enemies = runtime.get("enemies")
    (hero["sandbox_actions"] as Array).append(action)
    ui.set("_sandbox_selected_target", 0)
    hero["ap"] = 0
    _check_blocked(ui, runtime, "not_enough_ap")
    hero["ap"] = 2
    hero["afflictions"] = {"stun":1}
    _check_blocked(ui, runtime, "stunned")
    hero["afflictions"] = {}
    enemies[0]["hp"] = 0
    _check_blocked(ui, runtime, "target_dead")
    enemies[0]["hp"] = enemies[0]["max_hp"]
    enemies[0]["combat_position"] = 3
    _check_blocked(ui, runtime, "enemy_not_targetable")
    enemies[0]["combat_position"] = 0
    ui.set("_sandbox_selected_zone", "head")
    _check_blocked(ui, runtime, "body_zone_not_targetable")
    ui.set("_sandbox_selected_zone", "torso")
    ui.set("_sandbox_selected_target", 99)
    _check_blocked(ui, runtime, "invalid_target")

func _check_blocked(ui: Control, runtime: RefCounted, reason: String) -> void:
    var before := _snapshot(runtime)
    var preview: Dictionary = ui.call("_sandbox_build_preview_v51")
    _check(not bool(preview.get("ready", true)), "%s disables confirmation" % reason)
    _check(str(preview.get("reason", "")) == reason, "%s is explained by the engine" % reason)
    var verdict: Dictionary = runtime.call("perform_action", str(ui.get("_sandbox_selected_action")), int(ui.get("_sandbox_selected_target")), str(ui.get("_sandbox_selected_zone")))
    _check(str(verdict.get("reason", "")) == reason, "execution agrees with blocked preview: %s" % reason)
    _check(before == _snapshot(runtime), "refusal and preview preserve combat state: %s" % reason)

func _snapshot(runtime: RefCounted) -> String:
    return JSON.stringify({"heroes":runtime.get("heroes"),"enemies":runtime.get("enemies"),"knowledge":runtime.get("party_knowledge"),"round":runtime.get("round"),"active":runtime.get("active_hero_index"),"trace":runtime.call("combat_trace")})
