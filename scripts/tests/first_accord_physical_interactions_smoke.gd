extends Node

const WORLD := preload("res://scenes/dungeons/first_accord_playable_blockout.tscn")
var failures: Array[String] = []
var discoveries := 0
var shortcuts := 0

func check(ok: bool, label: String) -> void:
    if not ok:
        failures.append(label)
        push_error(label)

func _ready() -> void:
    call_deferred("_test")

func has_corridor(world: FirstAccordPlayableWorld, edge_id: String) -> bool:
    for link in world.physical["root"].get_node("Connections").get_children():
        if str(link.get_meta("edge_id", "")) == edge_id:
            check(not link.find_children("*", "CollisionShape3D", true, false).is_empty(), "passage has physical collision floor")
            return true
    return false

func interactable(world: FirstAccordPlayableWorld, edge_id: String, side: String) -> Area3D:
    for node in world.get_node("PassageInteractions").get_children():
        if node.edge_id() == edge_id and node.side_room == side:
            return node
    return null

func _test() -> void:
    for seed_value in [1, 7, 42, 101, 9001]:
        RemanenceRuntime.reset_new_game()
        VeilleursRuntime.reset_new_game()
        var world := WORLD.instantiate() as FirstAccordPlayableWorld
        world.campaign_seed = seed_value
        add_child(world)
        var interaction_results: Array[Dictionary] = []
        world.party.interaction_resolved.connect(func(result: Dictionary) -> void: interaction_results.append(result))
        var dungeon := world.runtime.campaign.dungeon
        var entry_exit: Area3D = world.get_node("ExtractionInteractions").get_node(str(world.plan["entry_id"]) + "_exit")
        check(not bool(world.extract_expedition(world.current_room_id).get("ok", false)), "extraction requires physical proximity")
        check(not bool(entry_exit.perform_interaction(null).get("success", false)), "only the party can extract")
        var original_plan: Dictionary = JSON.parse_string(JSON.stringify(world.plan))
        var shortcut_edge: Dictionary = {}
        for edge in world.plan["edges"]:
            if str(edge.get("requires", "")) == "unlock_from_deep_side":
                shortcut_edge = edge
        var shortcut_id := str(shortcut_edge["from"]) + ">" + str(shortcut_edge["to"])
        check(not has_corridor(world, shortcut_id), "shortcut closed initially")
        check(not bool(dungeon.unlock_shortcut(shortcut_id).get("ok", false)), "shortcut cannot open from entry")
        for room_id in world.plan["protected_story_order"]:
            if world.current_room_id != room_id:
                world._on_room_entered(room_id)
            var room: Node3D = world.physical["root"].get_node("Rooms").get_node(room_id)
            world.party.global_position = room.global_position + Vector3.UP * 0.7
            if room_id == str(shortcut_edge["from"]):
                check(not bool(dungeon.unlock_shortcut(shortcut_id).get("ok", false)), "deep side requires cleared room")
            # This fixture isolates passage/progression plumbing. Player combat
            # commands are exercised by first_accord_physical_combat_smoke.
            world.interact_current_room()
            if world.runtime.combat != null:
                if room_id == str(world.plan["objective_id"]):
                    var combat_exit: Area3D = world.get_node("ExtractionInteractions").get_node(room_id + "_exit")
                    world.party.global_position = combat_exit.global_position
                    check(not bool(combat_exit.perform_interaction(world.party).get("success", false)), "extraction blocked during combat")
                for node in world.get_node("PassageInteractions").get_children():
                    check(not bool(node.perform_interaction(world.party).get("success", false)), "passages blocked during combat")
                world.runtime.resolve_active_combat("victory")
                world.combat_ui._render_node()
                await get_tree().process_frame
            check(bool(dungeon.node_flags.get(room_id, {}).get("completed", false)), "fixture room clear")
            for edge in world.plan["edges"]:
                if str(edge["from"]) != room_id or (not bool(edge.get("hidden", false)) and str(edge.get("requires", "")) != "unlock_from_deep_side"):
                    continue
                var edge_id := str(edge["from"]) + ">" + str(edge["to"])
                check(not has_corridor(world, edge_id), "closed passage has no corridor")
                check(not dungeon.available_next().has(str(edge["to"])), "closed passage cannot advance")
                var target := interactable(world, edge_id, room_id)
                check(target != null, "passage has physical interaction")
                check(not bool(target.perform_interaction(world.party).get("success", false)), "remote interaction rejected")
                world.party.global_position = target.global_position + Vector3(0, -0.3, 1.4)
                world.party.look_at(target.global_position)
                await get_tree().physics_frame
                await get_tree().physics_frame
                world.party._refresh_interaction_target()
                var before := interaction_results.size()
                if bool(edge.get("hidden", false)):
                    world.action_button.pressed.emit()
                else:
                    var event := InputEventAction.new()
                    event.action = "interact"
                    event.pressed = true
                    world._unhandled_input(event)
                check(interaction_results.size() == before + 1, "button or keyboard performs exactly one interaction")
                var result: Dictionary = interaction_results.back() if not interaction_results.is_empty() else {}
                check(bool(result.get("success", false)) and result.get("interaction_id", "") == "accord:passage:" + edge_id, "real nearby party targeting opens passage")
                check(has_corridor(world, edge_id) and dungeon.available_next().has(str(edge["to"])), "opening updates collision and progression")
                var count: int = world.physical["root"].get_node("Connections").get_child_count()
                check(bool(target.perform_interaction(world.party).get("success", false)), "repeat interaction succeeds idempotently")
                check(world.physical["root"].get_node("Connections").get_child_count() == count, "repeat cannot duplicate corridor")
                if bool(edge.get("hidden", false)):
                    discoveries += 1
                    world._on_room_entered(str(edge["to"]))
                    var secret: Node3D = world.physical["root"].get_node("Rooms").get_node(str(edge["to"]))
                    world.party.global_position = secret.global_position + Vector3.UP * 0.7
                    check(bool(world.interact_current_room().get("ok", false)), "secret room interaction grants canonical rewards")
                    var loot := dungeon.collected_rewards().duplicate(true)
                    check(not bool(world.interact_current_room().get("ok", false)) and loot == dungeon.collected_rewards(), "secret rewards cannot repeat")
                    world._on_room_entered(room_id)
                    check(world.current_room_id == room_id, "secret has return route")
                else:
                    shortcuts += 1
                    world._on_room_entered(str(edge["to"]))
                    check(world.current_room_id == str(edge["to"]), "shortcut reaches entry")
                    world._on_room_entered(room_id)
                    check(world.current_room_id == room_id, "open shortcut usable from both sides")
                world.party.global_position = room.global_position + Vector3.UP * 0.7
            check(JSON.parse_string(JSON.stringify(world.plan)) == original_plan, "interactions do not regenerate plan")
        world.capture_state()
        var saved: Dictionary = JSON.parse_string(JSON.stringify(VeilleursRuntime.serialize()))
        var expected: int = world.physical["root"].get_node("Connections").get_child_count()
        world.free()
        check(VeilleursRuntime.deserialize(saved), "JSON save reload")
        world = WORLD.instantiate() as FirstAccordPlayableWorld
        add_child(world)
        check(world.physical["root"].get_node("Connections").get_child_count() == expected, "restores all opened physical passages")
        check(JSON.parse_string(JSON.stringify(world.plan)) == original_plan, "saved plan stays stable")
        check(has_corridor(world, shortcut_id), "shortcut survives reload")
        var exit: Area3D = world.get_node("ExtractionInteractions").get_node(str(world.plan["objective_id"]) + "_exit")
        check(not bool(exit.perform_interaction(world.party).get("success", false)), "distant exit cannot extract")
        world.party.global_position = exit.global_position + Vector3(0, -0.3, 1.0)
        var rewards := world.runtime.campaign.dungeon.collected_rewards()
        var extraction: Dictionary = exit.perform_interaction(world.party)
        check(bool(extraction.get("success", false)), "physical objective exit extracts canonical expedition")
        check(int(extraction.get("payload", {}).get("gold", -1)) >= int(rewards.get("gold", 0)), "canonical extraction includes collected rewards")
        check(world.runtime.campaign.current_dungeon_id == "" and VeilleursRuntime.physical_state.is_empty(), "extraction clears active run and physical resume")
        check(not bool(exit.perform_interaction(world.party).get("success", false)), "extraction cannot pay twice")
        check(str(VeilleursRuntime.serialize()["runtime"]["campaign"]["current_dungeon_id"]) == "", "post extraction save has no active dungeon")
        world.free()
        var legacy := saved.duplicate(true)
        for flags in legacy["runtime"]["campaign"]["dungeon"]["node_flags"].values():
            flags.erase("opened_shortcuts")
        check(VeilleursRuntime.deserialize(legacy), "older save without shortcut state loads")
        world = WORLD.instantiate() as FirstAccordPlayableWorld
        add_child(world)
        check(not has_corridor(world, shortcut_id), "older save does not invent opened shortcut")
        world.free()
        if seed_value == 101:
            VeilleursRuntime.reset_new_game()
            world = WORLD.instantiate() as FirstAccordPlayableWorld
            world.campaign_seed = seed_value
            add_child(world)
            var early_exit: Area3D = world.get_node("ExtractionInteractions").get_node(str(world.plan["entry_id"]) + "_exit")
            world.party.global_position = early_exit.global_position + Vector3(0, -0.3, 1.0)
            check(bool(early_exit.perform_interaction(world.party).get("success", false)), "entry permits voluntary extraction")
            check(not bool(world.runtime.campaign.dungeon.node_flags.get(str(world.plan["objective_id"]), {}).get("completed", false)), "early extraction does not grant boss victory")
            world.free()
    VeilleursRuntime.reset_new_game()
    print("FIRST_ACCORD_PHYSICAL_INTERACTIONS: ", "OK" if failures.is_empty() else failures, " secrets=", discoveries, " shortcuts=", shortcuts)
    get_tree().quit(0 if failures.is_empty() else 1)
