extends Node

const WORLD := preload("res://scenes/dungeons/first_accord_playable_blockout.tscn")
const PLAYER_HELPERS := preload("res://scripts/tests/first_accord_playthrough_smoke.gd")
var failures: Array[String] = []

func check(ok: bool, label: String) -> void:
    if not ok:
        failures.append(label)
        push_error(label)

func _ready() -> void:
    call_deferred("_test")

func _test() -> void:
    RemanenceRuntime.reset_new_game()
    VeilleursRuntime.reset_new_game()
    var world := WORLD.instantiate() as FirstAccordPlayableWorld
    world.campaign_seed = 101
    add_child(world)
    world._on_room_entered("gallery_of_names")
    check(world.current_room_id == "vestibule", "walking must not bypass unresolved room")
    check(bool(world.interact_current_room().get("ok", false)), "resolve physical entry")
    world._on_room_entered("gallery_of_names")
    check(world.current_room_id == "gallery_of_names", "sensor updates canonical room")
    var gallery: Node3D = (world.physical["root"] as Node).get_node("Rooms/gallery_of_names")
    world.party.global_position = gallery.global_position + Vector3(3.25, 0.7, 1.5)
    var return_transform := world.party.global_transform
    check(bool(world.interact_current_room().get("ok", false)), "physical encounter launches canonical combat")
    check(world.runtime == VeilleursRuntime.runtime, "shared production runtime")
    check(world.party.process_mode == Node.PROCESS_MODE_DISABLED, "exploration frozen during combat")
    check(not bool(world.discover_current_passages().get("ok", false)), "search rejected during canonical combat")
    check(not bool(world.interact_current_room().get("ok", false)), "duplicate interaction rejected")
    var ui = world.combat_ui
    var helpers = PLAYER_HELPERS.new()
    var actions := 0
    while world.runtime.combat != null and actions < 120:
        var choice: Dictionary = helpers.best_attack(ui, "focus")
        if choice.is_empty():
            helpers.approach(ui)
            choice = helpers.best_attack(ui, "focus")
        if choice.is_empty():
            break
        ui._on_cell(ui.slice.combat.grid.position_of(str(choice["watcher"])))
        ui._on_cell(ui.slice.combat.grid.position_of(str(choice["target"])))
        ui._on_zone(str(choice["zone"]))
        ui._on_skill(ui.skill_ids.find(str(choice["skill"])))
        actions += 1
    check(world.runtime.combat == null, "combat resolves through real player commands")
    check(bool(world.runtime.campaign.dungeon.node_flags.get("gallery_of_names", {}).get("completed", false)), "victory clears physical room")
    check(world.party.global_transform == return_transform, "exact return transform")
    check(world.aftermath_ui != null, "combat presents canonical result before returning")
    check(world.dismiss_aftermath(), "acknowledge result after defeated enemies")
    check(world.party.process_mode != Node.PROCESS_MODE_DISABLED, "exploration resumes")
    check(not bool(world.interact_current_room().get("ok", false)), "cleared encounter cannot repeat")
    check(not world.last_result.get("remanence", {}).is_empty(), "canonical remanence resolution retained")
    helpers.free()
    await get_tree().process_frame
    world._on_room_entered("debate_chamber")
    var debate: Node3D = (world.physical["root"] as Node).get_node("Rooms/debate_chamber")
    world.party.global_position = debate.global_position + Vector3.UP * 0.7
    check(bool(world.interact_current_room().get("ok", false)), "second physical encounter")
    world.capture_state()
    var saved: Dictionary = JSON.parse_string(JSON.stringify(VeilleursRuntime.serialize()))
    var saved_position := world.party.global_position
    world.free()
    var legacy := saved.duplicate(true)
    legacy.erase("physical_state")
    check(VeilleursRuntime.deserialize(legacy) and VeilleursRuntime.physical_state.is_empty(), "legacy saves remain compatible")
    check(VeilleursRuntime.deserialize(saved), "canonical save round trip")
    world = WORLD.instantiate() as FirstAccordPlayableWorld
    add_child(world)
    check(world.current_room_id == "debate_chamber", "restore saved physical room")
    check(world.party.global_position == saved_position, "restore exact saved position")
    check(world.combat_ui != null and world.runtime.combat != null, "restore active canonical combat UI")
    world.combat_ui._on_retreat()
    check(not bool(world.runtime.campaign.dungeon.node_flags.get("debate_chamber", {}).get("completed", false)), "retreat must not clear room")
    check(world.runtime.combat == null, "retreat returns to exploration")
    check(world.dismiss_aftermath(), "acknowledge retreat result")
    world._on_room_entered("gallery_of_names")
    check(world.current_room_id == "gallery_of_names", "retreat keeps visited return route")
    world.free()
    VeilleursRuntime.reset_new_game()
    print("FIRST_ACCORD_PHYSICAL_COMBAT: ", "OK" if failures.is_empty() else failures, " actions=", actions)
    get_tree().quit(0 if failures.is_empty() else 1)
