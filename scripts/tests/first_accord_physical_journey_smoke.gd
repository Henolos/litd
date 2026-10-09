extends Node

const WORLD := preload("res://scenes/dungeons/first_accord_playable_blockout.tscn")
const HELPERS := preload("res://scripts/tests/first_accord_playthrough_smoke.gd")
const EARLY_PATH := ["vestibule", "gallery_of_names"]
const FULL_PATH := ["vestibule", "gallery_of_names", "debate_chamber", "collapsed_passage", "three_pillars_hall", "warden_sanctum"]

func _ready() -> void:
    call_deferred("_run")

func _fail(message: String) -> void:
    push_error("FIRST_ACCORD_PHYSICAL_JOURNEY: " + message)
    get_tree().quit(1)

func _run() -> void:
    RemanenceRuntime.reset_new_game()
    var facade := VeilleursRuntime
    facade.reset_new_game()
    GameState.current_screen = "sanctuary"
    var world: FirstAccordPlayableWorld = WORLD.instantiate() as FirstAccordPlayableWorld
    var full := OS.get_cmdline_user_args().has("--full")
    var seed := 102 if full else 101
    for arg in OS.get_cmdline_user_args():
        if arg.begins_with("--seed="):
            seed = int(arg.trim_prefix("--seed="))
    world.campaign_seed = seed
    add_child(world)
    var helpers = HELPERS.new()
    var submissions := 0
    var combats := 0
    for room_id in FULL_PATH if full else EARLY_PATH:
        if world.current_room_id != room_id:
            world._on_room_entered(room_id)
        if world.current_room_id != room_id:
            _fail("canonical route blocked at " + room_id)
            return
        var room: Node3D = world.physical["root"].get_node("Rooms/" + room_id)
        world.party.global_position = room.global_position + Vector3.UP * 0.7
        if not bool(world.interact_current_room().get("ok", false)):
            _fail("room interaction failed at " + room_id)
            return
        if world.runtime.combat != null:
            combats += 1
            var ui = world.combat_ui
            var actions := 0
            var focus := ""
            while world.runtime.combat != null and actions < 130:
                if not full:
                    for enemy_id in world.runtime.combat.alive_ids("enemy"):
                        if bool(world.runtime.combat.subdue_status(enemy_id).get("ok", false)):
                            ui._on_cell(ui.slice.combat.grid.position_of(enemy_id))
                            ui.submission_control._refresh()
                            if ui.submission_control.button.disabled:
                                _fail("submission button refuses vulnerable enemy")
                                return
                            ui.submission_control.button.pressed.emit()
                            submissions += 1
                            break
                if world.runtime.combat == null:
                    break
                if full and not world.runtime.combat.alive_ids("enemy").has(focus):
                    focus = helpers.weakest_enemy(world.runtime.combat)
                var choice: Dictionary = helpers.best_attack(ui, "focus", focus)
                if choice.is_empty() and not full:
                    choice = helpers.survival_action(ui, "guard_control", actions, {})
                if choice.is_empty():
                    var moved: bool = helpers.approach(ui, focus)
                    choice = helpers.best_attack(ui, "focus", focus)
                    if choice.is_empty() and moved:
                        actions += 1
                        continue
                if choice.is_empty():
                    break
                ui._on_cell(ui.slice.combat.grid.position_of(str(choice["watcher"])))
                ui._on_cell(ui.slice.combat.grid.position_of(str(choice["target"])))
                ui._on_zone(str(choice["zone"]))
                ui._on_skill(ui.skill_ids.find(str(choice["skill"])))
                actions += 1
            if world.runtime.combat != null:
                _fail("combat did not finish at %s after %d actions, allies=%s enemies=%s message=%s" % [room_id, actions, world.runtime.combat.alive_ids("watcher"), world.runtime.combat.alive_ids("enemy"), ui.message_label.text])
                return
            for index in world.runtime.recruitment_options().size():
                if not bool(world.runtime.recruitment_options()[index].get("resolved", false)):
                    var spare_button: Button
                    for button: Button in world.aftermath_ui.find_children("*", "Button", true, false):
                        if int(button.get_meta("candidate_index", -1)) == index and str(button.get_meta("decision", "")) == "spare":
                            spare_button = button
                            break
                    if spare_button == null:
                        _fail("living remanence has no spare action at " + room_id)
                        return
                    spare_button.pressed.emit()
                    if not bool(world.runtime.recruitment_options()[index].get("resolved", false)):
                        _fail("remanence decision refused at " + room_id)
                        return
            if not world.dismiss_aftermath():
                _fail("cannot return to physical room " + room_id)
                return
        if not bool(world.runtime.campaign.dungeon.node_flags.get(room_id, {}).get("completed", false)):
            _fail("room not completed: " + room_id)
            return
        if room_id == "gallery_of_names":
            var exact: Transform3D = world.party.global_transform
            world.capture_state()
            if not SaveManager.save_game():
                _fail("mid-run save failed")
                return
            world.free()
            if not SaveManager.load_game():
                _fail("mid-run reload failed")
                return
            world = WORLD.instantiate()
            add_child(world)
            if world.party.global_transform != exact or world.current_room_id != room_id:
                _fail("physical transform or room changed after reload")
                return
    if (not full and (submissions == 0 or combats != 1)) or (full and (combats != 5 or not bool(world.runtime.campaign.dungeon.node_flags.get("warden_sanctum", {}).get("completed", false)))):
        _fail("expected combat, remanence, or Warden completion missing")
        return
    var reward: Dictionary = world.runtime.campaign.dungeon.collected_rewards()
    var completion: Dictionary = {}
    if full:
        var authored: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/dungeons/first_accord_combat.json"))
        completion = authored.get("completion_rewards", {})
    var refuge_before: Dictionary = world.runtime.campaign.refuge.resources.duplicate(true)
    var exit_room := "warden_sanctum" if full else "vestibule"
    if not full:
        world._on_room_entered(exit_room)
        if world.current_room_id != exit_room:
            _fail("visited route cannot return to vestibule")
            return
    var exit = world.get_node("ExtractionInteractions/" + exit_room + "_exit")
    world.party.global_position = exit.global_position + Vector3(0, -0.3, 1.0)
    if not bool(exit.perform_interaction(world.party).get("success", false)):
        _fail("physical extraction failed")
        return
    for resource in reward:
        var expected := int(refuge_before.get(resource, 0)) + int(reward[resource]) + int(completion.get(resource, 0))
        if int(world.last_extraction.get(resource, -1)) != expected - int(refuge_before.get(resource, 0)) or int(world.runtime.campaign.refuge.resources.get(resource, 0)) != expected:
            _fail("extraction credited incorrect " + resource)
            return
    if facade.is_active() or not facade.physical_state.is_empty():
        _fail("extraction did not clear the physical expedition")
        return
    if bool(exit.perform_interaction(world.party).get("success", false)):
        _fail("extraction paid twice")
        return
    if reward.is_empty() or not SaveManager.save_game() or not SaveManager.load_game() or facade.is_active():
        _fail("rewards or extracted save are invalid")
        return
    for resource in reward:
        if int(facade.runtime.campaign.refuge.resources.get(resource, 0)) != int(refuge_before.get(resource, 0)) + int(reward[resource]) + int(completion.get(resource, 0)):
            _fail("extracted reward changed after save reload: " + resource)
            return
    helpers.free()
    print("FIRST_ACCORD_PHYSICAL_JOURNEY: OK full=", full, " seed=", seed, " combats=", combats, " submissions=", submissions)
    get_tree().quit(0)
