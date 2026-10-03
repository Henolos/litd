extends Node

const BUILDER := preload("res://scripts/world/ashlands_blockout_builder.gd")
const FLOW := preload("res://scripts/core/veilleurs_khar_sen_flow_bridge.gd")

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
    var slots := builder.get_node_or_null("GeneratedBlockout/EncounterSlots")
    if not bool(plan.get("ok", false)) or slots == null:
        push_error("First Accord plan/physical encounter slots unavailable")
        get_tree().quit(1)
        return
    var expected := 0
    for node in plan.get("nodes", []):
        if str(node.get("encounter", {}).get("materialization_status", "")) == "composition_ready" and node.get("id", "") in ["gallery_of_names", "debate_chamber", "collapsed_passage", "three_pillars_hall", "broken_guardroom"]:
            expected += 1
    if slots.get_child_count() != expected or expected < 4:
        push_error("Physical triggers do not match the materialized rooms: %d vs %d" % [slots.get_child_count(), expected])
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
    print("FIRST_ACCORD_TACTICAL_ENTRY_OK: %d physical encounters and tactical return" % expected)
    get_tree().quit(0)
