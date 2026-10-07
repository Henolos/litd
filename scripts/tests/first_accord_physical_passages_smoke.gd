extends Node

const WORLD := preload("res://scenes/dungeons/first_accord_playable_blockout.tscn")
var failures: Array[String] = []

func check(ok: bool, label: String) -> void:
    if not ok:
        failures.append(label)
        push_error(label)

func _ready() -> void:
    call_deferred("_test")

func _test() -> void:
    var discoveries := 0
    for seed_value in [101, 102, 103, 104, 105, 106]:
        RemanenceRuntime.reset_new_game()
        VeilleursRuntime.reset_new_game()
        var world := WORLD.instantiate() as FirstAccordPlayableWorld
        world.campaign_seed = seed_value
        add_child(world)
        var dungeon = world.runtime.campaign.dungeon
        var plan_before := JSON.stringify(world.plan)
        var connections: Node = (world.physical["root"] as Node).get_node("Connections")
        var initial_count := connections.get_child_count()
        check(not bool(world.discover_current_passages().get("ok", false)), "uncleared search denied")
        var hidden_edges: Array = []
        for edge in world.plan.get("edges", []):
            if bool(edge.get("hidden", false)) and str(edge.get("requires", "")) == "":
                hidden_edges.append(edge)
        check(not hidden_edges.is_empty(), "secret fixture exists")
        for edge in hidden_edges:
            var anchor := str(edge["from"])
            var secret := str(edge["to"])
            # Fixture isolates discovery/geometry from combat. The separate combat
            # smoke proves actual tactical victory; this test does not claim one.
            dungeon.enter(anchor)
            world.current_room_id = anchor
            dungeon.node_flags[anchor] = {"completed":true}
            dungeon.active_encounter.clear()
            check(secret not in dungeon.available_next(), "secret logically closed")
            var before := connections.get_child_count()
            var result := world.discover_current_passages()
            check(bool(result.get("ok", false)), "physical search succeeds")
            var found: Array = result.get("discovered", [])
            check(connections.get_child_count() == before + found.size(), "each discovery adds one corridor")
            check(secret in dungeon.available_next(), "secret logically open")
            var edge_found := false
            for corridor in connections.get_children():
                if str(corridor.get_meta("edge_id", "")) == anchor + ">" + secret:
                    edge_found = true
                    check(corridor.get_child_count() > 0, "secret corridor has physical tiles")
            check(edge_found, "hidden connector materialized")
            var after := connections.get_child_count()
            check(bool(world.discover_current_passages().get("ok", false)), "repeat search succeeds")
            check(connections.get_child_count() == after, "repeat search does not duplicate corridors")
            world._on_room_entered(secret)
            check(world.current_room_id == secret, "discovered secret accepts entry")
            world.interact_current_room()
            world._on_room_entered(anchor)
            check(world.current_room_id == anchor, "secret preserves return route")
            discoveries += found.size()
        check(JSON.stringify(world.plan) == plan_before, "discovery does not mutate generation plan")
        var expected_count := connections.get_child_count()
        check(expected_count == initial_count + dungeon.discovered_edges.size(), "locks remain absent")
        world.capture_state()
        var saved: Dictionary = JSON.parse_string(JSON.stringify(VeilleursRuntime.serialize()))
        world.free()
        check(VeilleursRuntime.deserialize(saved), "discoveries survive JSON save")
        world = WORLD.instantiate() as FirstAccordPlayableWorld
        add_child(world)
        connections = (world.physical["root"] as Node).get_node("Connections")
        check(connections.get_child_count() == expected_count, "saved secret corridors restored")
        for corridor in connections.get_children():
            for edge in world.plan.get("edges", []):
                if str(edge.get("requires", "")) != "":
                    check(str(corridor.get_meta("edge_id", "")) != str(edge["from"]) + ">" + str(edge["to"]), "search cannot unlock shortcut")
        world.free()
    VeilleursRuntime.reset_new_game()
    print("FIRST_ACCORD_PHYSICAL_PASSAGES: ", "OK" if failures.is_empty() else failures, " discoveries=", discoveries)
    get_tree().quit(0 if failures.is_empty() else 1)
