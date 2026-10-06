extends Node3D
class_name FirstAccordPlayableWorld

const RUNTIME := preload("res://scripts/world/first_accord_hybrid_runtime_plan.gd")
const BUILDER := preload("res://scripts/world/first_accord_dungeon_map_builder.gd")
const PARTY_SCENE := preload("res://scenes/world/terre_des_cendres/exploration_party_placeholder.tscn")
const SENSOR_SCRIPT := preload("res://scripts/world/veilleurs_ge01_room_sensor.gd")

@export var campaign_seed := 42

var plan: Dictionary = {}
var physical: Dictionary = {}
var party: Node3D
var current_room_id := ""

func _ready() -> void:
    plan = RUNTIME.build({"campaign_seed":campaign_seed})
    if not bool(plan.get("ok", false)) or bool(plan.get("fallback", false)):
        push_error("FirstAccordPlayableWorld: no valid physical plan")
        return
    physical = BUILDER.generate_from_plan(self, plan)
    if not bool(physical.get("ok", false)):
        push_error("FirstAccordPlayableWorld: " + str(physical.get("reason", "physical_error")))
        return
    var rooms := (physical["root"] as Node).get_node("Rooms")
    current_room_id = str(plan.get("entry_id", ""))
    var entry: Node3D = rooms.get_node_or_null(current_room_id)
    if entry == null:
        push_error("FirstAccordPlayableWorld: entry room missing")
        return
    party = PARTY_SCENE.instantiate() as Node3D
    if party == null:
        push_error("FirstAccordPlayableWorld: exploration party missing")
        return
    party.name = "FirstAccordParty"
    add_child(party)
    party.global_position = entry.global_position + Vector3.UP * 0.7
    var sensors := Node3D.new()
    sensors.name = "RoomSensors"
    add_child(sensors)
    for room in rooms.get_children():
        var sensor := SENSOR_SCRIPT.new() as VeilleursGE01RoomSensor
        sensor.configure(str(room.name), room.position, Vector3(14, 2.5, 12))
        sensor.party_entered.connect(_on_room_entered)
        sensors.add_child(sensor)

func _on_room_entered(room_id: String) -> void:
    if room_id == current_room_id:
        return
    current_room_id = room_id
    # Encounters and rewards stay definitions until their canonical combat and
    # inventory bridges can accept the authored IDs; walking cannot grant them.
