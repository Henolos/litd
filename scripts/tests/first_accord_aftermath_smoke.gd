extends Node

const WORLD := preload("res://scenes/dungeons/first_accord_playable_blockout.tscn")
var failures: Array[String] = []

func check(ok: bool, label: String) -> void:
    if not ok:
        failures.append(label)
        push_error(label)

func button_for(world: FirstAccordPlayableWorld, index: int, action: String) -> Button:
    for button in world.aftermath_ui.find_children("*", "Button", true, false):
        if int(button.get_meta("candidate_index", -1)) == index and str(button.get_meta("decision", "")) == action:
            return button
    return null

func _ready() -> void:
    call_deferred("_test")

func _test() -> void:
    RemanenceRuntime.reset_new_game()
    VeilleursRuntime.reset_new_game()
    GameState.current_screen = "sanctuary"
    var world := WORLD.instantiate() as FirstAccordPlayableWorld
    world.campaign_seed = 101
    add_child(world)
    world.interact_current_room()
    world._on_room_entered("gallery_of_names")
    var room: Node3D = world.physical["root"].get_node("Rooms/gallery_of_names")
    world.party.global_position = room.global_position + Vector3(2, 0.7, 1)
    world.party.rotation.y = 0.43
    var exact_return := world.party.global_transform
    var original_plan: Dictionary = JSON.parse_string(JSON.stringify(world.plan))
    world.interact_current_room()
    # Plumbing fixture: resolving with survivors exposes the canonical candidate
    # list. Actual victory commands remain covered by physical_combat_smoke.
    world.runtime.resolve_active_combat("victory")
    world.combat_ui._render_node()
    check(world.aftermath_ui != null and world.runtime.combat == null, "result replaces combat interface")
    check(world.party.global_transform == exact_return, "exact physical transform retained under result")
    check(world.unresolved_aftermath() > 0, "living canonical candidates presented")
    check(not world.dismiss_aftermath(), "cannot discard unresolved decisions")
    check(not world.interact_current_room().get("ok", false), "result blocks next encounter")
    world._on_room_entered("debate_chamber")
    check(world.current_room_id == "gallery_of_names", "result blocks progression that would overwrite candidates")
    var rewards := world.runtime.campaign.dungeon.collected_rewards()
    var candidates := world.runtime.recruitment_options()
    button_for(world, 0, "recruit").pressed.emit()
    check(world.unresolved_aftermath() == candidates.size(), "failed recruitment retains candidate for another decision")
    button_for(world, 0, "spare").pressed.emit()
    check(bool(world.runtime.recruitment_options()[0].get("resolved", false)), "spare button records canonical decision")
    var decisions := world.runtime.recruitment_decisions.size()
    check(not world.resolve_aftermath_decision(0, "spare").get("ok", false) and world.runtime.recruitment_decisions.size() == decisions, "duplicate decision rejected")
    world.capture_state()
    check(SaveManager.save_game(), "save result with partially resolved candidates")
    world.free()
    check(SaveManager.load_game(), "reload result save through production SaveManager")
    world = WORLD.instantiate() as FirstAccordPlayableWorld
    add_child(world)
    check(world.aftermath_ui != null, "restores pending result interface")
    check(world.party.global_transform == exact_return, "result reload restores exact physical transform")
    check(world.runtime.recruitment_options()[0].get("decision", "") == "spare", "resolved decision survives reload")
    check(button_for(world, 0, "spare") == null, "resolved candidate is not offered twice")
    for index in world.runtime.recruitment_options().size():
        if not bool(world.runtime.recruitment_options()[index].get("resolved", false)):
            button_for(world, index, "leave").pressed.emit()
    check(not world.aftermath_ui.continue_button.disabled, "all decisions unlock return button")
    world.aftermath_ui.continue_button.pressed.emit()
    check(world.aftermath_ui == null and world.party.process_mode != Node.PROCESS_MODE_DISABLED, "return button resumes exploration")
    check(world.party.global_transform == exact_return, "return does not reposition party")
    world._on_room_entered("vestibule", true)
    check(world.current_room_id == "gallery_of_names", "stale sensor cannot change room after restoring party")
    check(world.pending_aftermath.is_empty() and not VeilleursRuntime.physical_state.has("aftermath"), "acknowledged result cannot reopen on resume")
    check(world.runtime.campaign.dungeon.collected_rewards() == rewards, "result does not duplicate rewards")
    check(JSON.parse_string(JSON.stringify(world.plan)) == original_plan, "result reload does not regenerate plan")
    world.free()
    VeilleursRuntime.reset_new_game()
    print("FIRST_ACCORD_AFTERMATH: ", "OK" if failures.is_empty() else failures)
    get_tree().quit(0 if failures.is_empty() else 1)
