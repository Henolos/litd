extends EncounterTrigger
class_name FirstAccordTacticalTrigger

const FLOW := preload("res://scripts/core/veilleurs_khar_sen_flow_bridge.gd")
const TACTICAL_SCENE := "res://scenes/veilleurs/v061_tactical_demo.tscn"
const RETURN_SCENE := "res://scenes/world/terre_des_cendres/zone_16_salles_du_premier_accord.tscn"

var encounter: Dictionary = {}
var room_id := ""
var run_seed := 0

func start_encounter() -> bool:
    if not can_start() or encounter.get("composition", []).is_empty():
        return false
    var flow := FLOW.new() as VeilleursKharSenFlowBridge
    var return_position := [0.0, 0.0, 50.0]
    for party in get_tree().get_nodes_in_group("player_party"):
        if party is Node3D:
            var point := (party as Node3D).global_position
            return_position = [point.x, point.y, point.z]
            break
    if not flow.begin_combat({"run_seed": run_seed, "return_position": return_position}, encounter, room_id, RETURN_SCENE, "first_accord"):
        return false
    if not super.start_encounter():
        flow.clear()
        return false
    var error := get_tree().change_scene_to_file(TACTICAL_SCENE)
    if error != OK:
        flow.clear()
        armed = true
        return false
    return true
