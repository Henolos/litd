extends Node

const BUILDER := preload("res://scripts/world/ashlands_blockout_builder.gd")
const FLOW := preload("res://scripts/core/veilleurs_khar_sen_flow_bridge.gd")
const LAYOUT := preload("res://scripts/world/first_accord_physical_layout.gd")
const MAP := preload("res://scripts/world/first_accord_dungeon_map_builder.gd")

func _ready() -> void:
    var flow := FLOW.new() as VeilleursKharSenFlowBridge
    flow.clear()
    ExpeditionManager.start_expedition(42)
    var builder := BUILDER.new() as AshlandsBlockoutBuilder
    builder.build_on_ready = false
    builder.spawn_player_placeholder = false
    builder.spawn_hud = false
    builder.zone_id = "zone_16_salles_du_premier_accord"
    add_child(builder)
    builder.build_zone()
    var plan := builder.first_accord_plan
    var layout := builder.first_accord_layout
    var slots := builder.get_node_or_null("GeneratedBlockout/EncounterSlots")
    if not bool(plan.get("ok", false)) or not bool(layout.get("ok", false)) or not bool(layout.get("fully_realized", false)) or slots == null:
        push_error("First Accord plan/physical encounter slots unavailable")
        get_tree().quit(1)
        return
    var expected := 0
    for node in plan.get("nodes", []):
        if str(node.get("encounter", {}).get("materialization_status", "")) == "composition_ready":
            expected += 1
    if slots.get_child_count() != expected or expected < 4 or layout.get("placements", {}).size() != plan.get("nodes", []).size():
        push_error("Physical triggers do not match the materialized rooms: %d vs %d" % [slots.get_child_count(), expected])
        get_tree().quit(1)
        return
    var generated_floor := builder.get_node_or_null("GeneratedBlockout/AuthoredDungeonMap/Floors/generated_branches")
    if generated_floor == null or generated_floor.get_child_count() != layout.get("generated_rooms", []).size():
        push_error("Generated optional rooms are missing from the physical map")
        get_tree().quit(1)
        return
    await get_tree().physics_frame
    for connection in layout.get("generated_connections", []):
        var waypoints: Array = connection.get("waypoints", [])
        for index in range(waypoints.size() - 1):
            var start: Vector3 = MAP._vec3(waypoints[index]) + Vector3.UP
            var finish: Vector3 = MAP._vec3(waypoints[index + 1]) + Vector3.UP
            var hit := builder.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(start, finish))
            if not hit.is_empty():
                push_error("Physical connection crosses a wall: %s segment %d" % [connection.get("id", ""), index])
                get_tree().quit(1)
                return
            var midpoint := (start + finish) * 0.5
            var ground := builder.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(midpoint + Vector3.UP, midpoint - Vector3.UP * 3.0))
            if ground.is_empty():
                push_error("Physical connection has no floor: %s segment %d" % [connection.get("id", ""), index])
                get_tree().quit(1)
                return
    var catalog := MAP._load_json(MAP.MAP_PATH)
    for seed_value in 100:
        var sample := FirstAccordHybridRuntimePlan.build({"campaign_seed":seed_value})
        var placement := LAYOUT.resolve(sample, catalog)
        if not bool(placement.get("ok", false)) or not bool(placement.get("fully_realized", false)) or placement.get("placements", {}).size() != sample.get("nodes", []).size() or placement != LAYOUT.resolve(sample, catalog):
            push_error("Non-deterministic or incomplete physical layout: %d" % seed_value)
            get_tree().quit(1)
            return
    var trigger := slots.get_child(0) as FirstAccordTacticalTrigger
    if trigger == null or trigger.use_combat_bridge or trigger.encounter.get("composition", []).size() != int(trigger.encounter.get("enemy_count", 0)):
        push_error("First Accord tactical trigger has no canonical composition")
        get_tree().quit(1)
        return
    if not flow.begin_combat({"run_seed": 42}, trigger.encounter, trigger.room_id, trigger.RETURN_SCENE, "first_accord"):
        push_error("Tactical handoff could not be written")
        get_tree().quit(1)
        return
    var pending := flow.pending()
    if str(pending.get("region_id", "")) != "first_accord" or str(pending.get("return_scene", "")) != trigger.RETURN_SCENE:
        push_error("Tactical handoff loses its return destination")
        get_tree().quit(1)
        return
    if not flow.finish_combat("victory", {"round": 1}, {}, {}):
        push_error("Tactical victory could not be returned")
        get_tree().quit(1)
        return
    builder.build_zone()
    var key := "first_accord:42:%s" % trigger.room_id
    if not AshlandsRuntime.is_encounter_cleared(key) or builder.get_node("GeneratedBlockout/EncounterSlots").get_child_count() != expected - 1:
        push_error("Victorious encounter was not cleared on zone return")
        get_tree().quit(1)
        return
    flow.clear()
    print("FIRST_ACCORD_TACTICAL_ENTRY_OK: %d physical encounters, %d generated rooms and tactical return" % [expected, generated_floor.get_child_count()])
    get_tree().quit(0)
