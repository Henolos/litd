extends Node3D
class_name FirstAccordPlayableWorld

const DUNGEON_ID := "dungeon_first_map_hall_of_first_accord"
const COMBAT_UI := preload("res://scripts/ui/first_accord_physical_combat_ui.gd")
const BUILDER := preload("res://scripts/world/first_accord_dungeon_map_builder.gd")
const PARTY_SCENE := preload("res://scenes/world/terre_des_cendres/exploration_party_placeholder.tscn")
const SENSOR_SCRIPT := preload("res://scripts/world/veilleurs_ge01_room_sensor.gd")

@export var campaign_seed := 42

var plan: Dictionary = {}
var physical: Dictionary = {}
var party: Node3D
var current_room_id := ""
var runtime: VeilleursVerticalSliceRuntimeV09
var combat_ui: Control
var prompt: Label
var saved_transform := Transform3D.IDENTITY
var last_result: Dictionary = {}

func _ready() -> void:
    var resume := bool(VeilleursRuntime.physical_state.get("active", false)) and VeilleursRuntime.runtime.campaign.current_dungeon_id == DUNGEON_ID and int(VeilleursRuntime.physical_state.get("run_seed", -1)) == VeilleursRuntime.runtime.campaign.dungeon.run_seed
    if not resume:
        var started := VeilleursRuntime.start_dungeon(DUNGEON_ID, campaign_seed)
        if not bool(started.get("ok", false)):
            push_error("FirstAccordPlayableWorld: canonical expedition unavailable")
            return
    runtime = VeilleursRuntime.runtime
    plan = runtime.campaign.dungeon.procedural_plan.duplicate(true)
    if not bool(plan.get("ok", false)) or bool(plan.get("fallback", false)):
        push_error("FirstAccordPlayableWorld: no valid physical plan")
        return
    physical = BUILDER.generate_from_plan(self, plan)
    if not bool(physical.get("ok", false)):
        push_error("FirstAccordPlayableWorld: " + str(physical.get("reason", "physical_error")))
        return
    var synced := BUILDER.sync_discovered_passages(physical["root"], plan, runtime.campaign.dungeon.discovered_edges)
    if not bool(synced.get("ok", false)):
        push_error("FirstAccordPlayableWorld: passage restoration failed")
        return
    physical["open_connection_count"] = int(synced["open_connection_count"])
    var rooms := (physical["root"] as Node).get_node("Rooms")
    current_room_id = runtime.campaign.dungeon.current_node
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
    if resume:
        var position: Array = VeilleursRuntime.physical_state.get("position", [])
        if position.size() == 3:
            party.global_position = Vector3(float(position[0]), float(position[1]), float(position[2]))
        party.rotation.y = float(VeilleursRuntime.physical_state.get("yaw", 0.0))
    var sensors := Node3D.new()
    sensors.name = "RoomSensors"
    add_child(sensors)
    for room in rooms.get_children():
        var sensor := SENSOR_SCRIPT.new() as VeilleursGE01RoomSensor
        sensor.configure(str(room.name), room.position, Vector3(14, 2.5, 12))
        sensor.party_entered.connect(_on_room_entered)
        sensors.add_child(sensor)
    _build_hud()
    capture_state()
    if runtime.combat != null:
        _show_combat()
    _sync_prompt()

func _build_hud() -> void:
    var canvas := CanvasLayer.new()
    canvas.name = "FirstAccordHUD"
    add_child(canvas)
    var panel := VBoxContainer.new()
    panel.position = Vector2(16, 12)
    canvas.add_child(panel)
    prompt = Label.new()
    panel.add_child(prompt)
    var action := Button.new()
    action.text = "INTERAGIR"
    action.custom_minimum_size = Vector2(180, 48)
    action.pressed.connect(interact_current_room)
    panel.add_child(action)
    var search := Button.new()
    search.text = "FOUILLER LES PASSAGES"
    search.custom_minimum_size = Vector2(180, 48)
    search.pressed.connect(discover_current_passages)
    panel.add_child(search)
    var save := Button.new()
    save.text = "SAUVEGARDER"
    save.custom_minimum_size = Vector2(180, 48)
    save.pressed.connect(func() -> void:
        capture_state()
        prompt.text = "Partie sauvegardée" if SaveManager.save_game() else "Échec de sauvegarde")
    panel.add_child(save)

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("interact") and combat_ui == null:
        interact_current_room()
        get_viewport().set_input_as_handled()

func capture_state() -> void:
    if not is_instance_valid(party):
        return
    var p := party.global_position
    VeilleursRuntime.physical_state = {"active":true, "run_seed":runtime.campaign.dungeon.run_seed, "room_id":current_room_id, "position":[p.x,p.y,p.z], "yaw":party.rotation.y}

func _process(_delta: float) -> void:
    if combat_ui == null:
        capture_state()

func interact_current_room() -> Dictionary:
    if runtime == null or runtime.combat != null:
        return {"ok":false, "reason":"combat_active"}
    var flags: Dictionary = runtime.campaign.dungeon.node_flags.get(current_room_id, {})
    if bool(flags.get("completed", false)):
        return {"ok":false, "reason":"room_already_completed"}
    if runtime.campaign.dungeon.active_encounter.is_empty():
        last_result = runtime.campaign.resolve_current_node("cleared")
    else:
        last_result = runtime.launch_current_encounter()
        if bool(last_result.get("ok", false)):
            capture_state()
            _show_combat()
    _sync_prompt()
    return last_result.duplicate(true)

func discover_current_passages() -> Dictionary:
    if runtime == null or runtime.combat != null:
        return {"ok":false, "reason":"combat_active"}
    var result := runtime.campaign.dungeon.discover_current_passages()
    if not bool(result.get("ok", false)):
        prompt.text = "Terminez la salle avant de chercher ses passages."
        return result
    var synced := BUILDER.sync_discovered_passages(physical["root"], plan, runtime.campaign.dungeon.discovered_edges)
    if not bool(synced.get("ok", false)):
        return synced
    physical["open_connection_count"] = int(synced["open_connection_count"])
    capture_state()
    _sync_prompt()
    var found: Array = result.get("discovered", [])
    prompt.text += " · Passages découverts : %d" % found.size() if not found.is_empty() else " · Aucun nouveau passage"
    return result

func _show_combat() -> void:
    saved_transform = party.global_transform
    party.process_mode = Node.PROCESS_MODE_DISABLED
    var canvas := CanvasLayer.new()
    canvas.name = "FirstAccordCombat"
    canvas.layer = 100
    add_child(canvas)
    combat_ui = COMBAT_UI.new()
    combat_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    combat_ui.encounter_finished.connect(_on_combat_finished)
    canvas.add_child(combat_ui)

func _on_combat_finished(result: Dictionary) -> void:
    last_result = result.duplicate(true)
    var canvas := combat_ui.get_parent()
    combat_ui = null
    canvas.queue_free()
    party.global_transform = saved_transform
    if party is CharacterBody3D:
        party.velocity = Vector3.ZERO
    party.process_mode = Node.PROCESS_MODE_INHERIT
    capture_state()
    _sync_prompt()

func _sync_prompt() -> void:
    if prompt == null:
        return
    var flags: Dictionary = runtime.campaign.dungeon.node_flags.get(current_room_id, {})
    var state := "Salle terminée" if bool(flags.get("completed", false)) else ("Combat disponible" if not runtime.campaign.dungeon.active_encounter.is_empty() else "Explorer le lieu")
    prompt.text = "%s · %s" % [current_room_id.replace("_", " ").capitalize(), state]

func _on_room_entered(room_id: String) -> void:
    if room_id == current_room_id or runtime == null or runtime.combat != null:
        return
    var result := runtime.enter_next(room_id)
    if not bool(result.get("ok", false)):
        # Crossing geometry cannot bypass logical progression or unresolved combat.
        var room: Node3D = (physical["root"] as Node).get_node("Rooms").get_node(current_room_id)
        party.global_position = room.global_position + Vector3.UP * 0.7
        if party is CharacterBody3D:
            party.velocity = Vector3.ZERO
        return
    current_room_id = room_id
    capture_state()
    _sync_prompt()
