extends Node

const RUNTIME := preload("res://scripts/core/veilleurs_vertical_slice_runtime_v09.gd")
const ID := "dungeon_first_map_hall_of_first_accord"
var failures: Array[String] = []

func check(condition: bool, label: String) -> void:
    if not condition:
        failures.append(label)
        push_error(label)

func _ready() -> void:
    for seed in range(6):
        var run := RUNTIME.new()
        var started := run.start_dungeon(ID, seed + 101)
        check(bool(started.get("ok", false)), "start:%d" % seed)
        if not bool(started.get("ok", false)):
            continue
        for node in run.campaign.dungeon.nodes_by_id.values():
            var scene := load(str(node.get("scene_path", ""))) as PackedScene
            check(scene != null, "module_scene_missing")
            if scene != null:
                var instance := scene.instantiate()
                add_child(instance)
                check(instance.get_child_count() > 0, "empty_module_scene")
                instance.free()
        var plan: Dictionary = run.campaign.dungeon.procedural_plan
        check(not plan.is_empty(), "pipeline_not_used")
        var saved: Dictionary = JSON.parse_string(JSON.stringify(run.serialize()))
        var restored := RUNTIME.new()
        check(restored.deserialize(saved), "restore:%d" % seed)
        check(JSON.parse_string(JSON.stringify(restored.campaign.dungeon.procedural_plan)) == JSON.parse_string(JSON.stringify(plan)), "saved_plan_changed")
        check(not bool(run.enter_next("warden_sanctum").get("ok", false)), "boss_bypass")
        var corrupt := saved.duplicate(true)
        corrupt["campaign"]["dungeon"]["procedural_plan"]["playable_data_revision"] = "changed"
        check(not RUNTIME.new().deserialize(corrupt), "changed_combat_data_accepted")
        var failed_start := run.campaign.start_dungeon("MISSING_DUNGEON", 9)
        check(not bool(failed_start.get("ok", false)) and run.campaign.dungeon.procedural_plan == plan, "failed_start_replaced_expedition")
        for room_id in ["vestibule", "gallery_of_names", "debate_chamber", "collapsed_passage", "three_pillars_hall", "warden_sanctum"]:
            if run.campaign.dungeon.current_node != room_id:
                check(bool(run.enter_next(room_id).get("ok", false)), "enter:" + room_id)
            var dungeon = run.campaign.dungeon
            if not dungeon.active_encounter.is_empty():
                check(not bool(run.campaign.resolve_current_node("cleared", {}).get("ok", false)), "combat_skipped")
                var setup := run.launch_current_encounter()
                check(bool(setup.get("ok", false)), "launch:" + room_id + ":" + str(setup))
                if not bool(setup.get("ok", false)):
                    continue
                var enemies := 0
                for row in run.combat.combatants.values():
                    if row.get("team", "") == "enemy":
                        enemies += 1
                        check(row.get("body") != null, "enemy_body_missing")
                check(enemies > 0 and enemies <= 4, "enemy_rank_capacity")
                if seed == 0:
                    var target := str(run.combat.alive_ids("enemy")[0])
                    check(run.combat.grid.move(target, Vector2i(1, 1)), "attack_fixture_position")
                    var attacked := false
                    for skill in run.combat.content_db.skills_for("ENT_WATCHER_marec"):
                        if str(run.combat.skill_behavior.effective_action(skill)) == "attack":
                            var action: Dictionary = run.combat.resolve_skill("ENT_WATCHER_marec", target, str(skill["skill_id"]), "left_arm", 1)
                            check(bool(action.get("ok", false)), "generated_combat_body_attack:" + str(action))
                            attacked = true
                            break
                    check(attacked, "generated_combat_no_usable_attack")
                    if int(run.combat.combatants[target].get("hp", 0)) > 0:
                        check(bool(run.combat.enemy_step(target).get("ok", false)), "generated_combat_enemy_action")
                    if room_id == "warden_sanctum":
                        run.combat.next_round()
                        check(bool(run.combat.last_boss_rule.get("ok", false)), "warden_rule_not_applied")
                var active_combat = run.combat
                check(not bool(run.start_dungeon("MISSING_DUNGEON", 9).get("ok", false)) and run.combat == active_combat, "failed_start_lost_combat")
                var midcombat := RUNTIME.new()
                check(midcombat.deserialize(JSON.parse_string(JSON.stringify(run.serialize()))), "midcombat_restore")
                check(midcombat.combat != null, "saved_combat_missing")
                check(midcombat.campaign.dungeon.current_node == room_id, "saved_room_changed")
                if room_id == "gallery_of_names":
                    check(bool(run.resolve_active_combat("retreat").get("ok", false)), "retreat")
                    check(not bool(dungeon.node_flags.get(room_id, {}).get("completed", false)), "retreat_completed_room")
                    check(not bool(run.campaign.resolve_current_node("cleared", {}).get("ok", false)), "retreat_combat_bypass")
                    check(dungeon.available_next().has("vestibule"), "retreat_no_escape")
                    check(bool(run.enter_next("vestibule").get("ok", false)), "retreat_transition")
                    check(bool(run.enter_next(room_id).get("ok", false)), "retry_transition")
                    check(bool(run.launch_current_encounter().get("ok", false)), "retry_combat")
                # Resolution plumbing; action legality is covered by the existing
                # anatomy, target, affliction and resolver contract suites.
                check(bool(run.resolve_active_combat("victory").get("ok", false)), "resolve:" + room_id)
            else:
                check(bool(run.campaign.resolve_current_node("cleared", {}).get("ok", false)), "clear:" + room_id)
            check(not bool(run.campaign.resolve_current_node("cleared", {}).get("ok", false)), "duplicate_rewards")
            for edge in plan.get("edges", []):
                if str(edge.get("from", "")) == room_id and bool(edge.get("hidden", false)):
                    check(not dungeon.available_next().has(str(edge.get("to", ""))), "secret_visible_before_search")
            check(bool(dungeon.discover_current_passages().get("ok", false)), "discover")
            for edge in plan.get("edges", []):
                if str(edge.get("from", "")) == room_id and bool(edge.get("hidden", false)):
                    var secret_id := str(edge.get("to", ""))
                    check(dungeon.available_next().has(secret_id), "secret_not_unlocked")
                    check(bool(run.enter_next(secret_id).get("ok", false)), "secret_enter")
                    check(bool(run.campaign.resolve_current_node("cleared", {}).get("ok", false)), "secret_resolve")
                    check(dungeon.available_next().has(room_id), "secret_no_return")
                    check(bool(run.enter_next(room_id).get("ok", false)), "secret_return")
                    check(dungeon.active_encounter.is_empty(), "cleared_room_respawned")
        check(run.campaign.dungeon.can_extract(), "boss_extraction")
        check(bool(run.campaign.complete_expedition().get("ok", false)), "extract")
        check(not bool(run.campaign.complete_expedition().get("ok", false)), "duplicate_extraction")
    _check_returning_enemy()
    VeilleursRuntime.reset_new_game()
    var ui_scene := load("res://scenes/veilleurs/vertical_slice.tscn") as PackedScene
    var ui = ui_scene.instantiate()
    add_child(ui)
    await get_tree().process_frame
    check(VeilleursRuntime.runtime.campaign.current_dungeon_id == ID, "production_boot_not_procedural")
    check(ui.room_view.visible and ui.room_root != null, "room_view_not_materialized")
    check(ui.room_events_label.text != "", "room_variations_not_displayed")
    ui.free()
    print("DUNGEON_PLAYABLE_PIPELINE: ", "OK" if failures.is_empty() else failures)
    get_tree().quit(0 if failures.is_empty() else 1)

func _check_returning_enemy() -> void:
    var run := RUNTIME.new()
    check(bool(run.start_dungeon(ID, 787).get("ok", false)), "nemesis_fixture_start")
    run.campaign.dungeon.enter("collapsed_passage")
    run.combat_node_id = "collapsed_passage"
    var selected: Dictionary = run.campaign.dungeon.active_encounter
    var members: Array = selected.get("composition", [])
    if members.is_empty():
        check(false, "nemesis_fixture_composition")
        return
    var region := ID.to_lower()
    var persistent := RemanenceRuntime.prepare_enemy({"species_id":members[0]["definition_id"], "name":"Retour du Premier Accord"}, region)
    var state: Dictionary = RemanenceRuntime.entities[persistent]
    state["stage"] = "nemesis"
    state["score"] = 20
    state["encounters"] = 3
    RemanenceRuntime.entities[persistent] = state
    var materialized: Dictionary = {}
    for seed in range(100):
        run.campaign.dungeon.node_flags.erase("collapsed_passage")
        materialized = run._materialize_procedural_encounter(selected, region, seed)
        if bool(materialized.get("nemesis_injected", false)):
            break
    check(bool(materialized.get("nemesis_injected", false)), "shared_history_nemesis_not_used")
    check(materialized.get("composition", []).size() == members.size(), "nemesis_added_enemy")
    check(materialized.get("actual_threat") == selected.get("actual_threat"), "nemesis_changed_definition_budget")
    check(run._materialize_procedural_encounter(selected, region, 9999) == materialized, "nemesis_rerolled")
    # A second room cannot return the same persistent identity again.
    run.campaign.dungeon.node_flags["debate_chamber"] = run.campaign.dungeon.node_flags["collapsed_passage"].duplicate(true)
    run.campaign.dungeon.node_flags.erase("collapsed_passage")
    var blocked := run._materialize_procedural_encounter(selected, region, 0)
    check(not bool(blocked.get("nemesis_injected", false)), "nemesis_reused_identity")
