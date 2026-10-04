extends Control
class_name VeilleursVerticalSliceQAV09

const SLICE_SCRIPT := preload("res://scripts/core/veilleurs_vertical_slice_runtime_v09.gd")
const SAVE_SCRIPT := preload("res://scripts/core/veilleurs_vertical_slice_save_v09.gd")
const TACTICAL_UI_SCENE := preload("res://scenes/veilleurs/v06_tactical_combat.tscn")
const QA_SCENE := "res://scenes/qa/qa_validation_room.tscn"

const DUNGEONS := {
    "dungeon_first_map_hall_of_first_accord":"Premier Accord — procédural",
    "DUNGEON_KHAR_SEN":"Khar-Sen",
    "DUNGEON_SEUIL_ERODE":"Seuil érodé",
    "DUNGEON_CLOITRE_VOIX":"Cloître des voix",
    "DUNGEON_JARDIN_MUES":"Jardin des mues",
    "DUNGEON_TRIBUNAL_CENDRES":"Tribunal des cendres",
    "DUNGEON_ARCHIVES_AVEUGLES":"Archives aveugles"
}

var slice: VeilleursVerticalSliceRuntimeV09
var save_bridge: VeilleursVerticalSliceSaveV09
var room_view: SubViewportContainer
var room_viewport: SubViewport
var room_root: Node3D
var room_events_label: Label

var status_label: Label
var message_label: Label
var actions: HFlowContainer
var recruit_actions: VBoxContainer
var tactical_ui: VeilleursTacticalUI
var selected_watcher := "ENT_WATCHER_marec"
var selected_target := ""
var selected_zone := "torso"
var skill_ids: Array[String] = []
var ally_target: OptionButton
var selected_ally := ""

func _ready() -> void:
    _build_shell()
    slice = SLICE_SCRIPT.new() as VeilleursVerticalSliceRuntimeV09
    save_bridge = SAVE_SCRIPT.new() as VeilleursVerticalSliceSaveV09
    _start_dungeon("DUNGEON_KHAR_SEN")

func _build_shell() -> void:
    var background := ColorRect.new()
    background.color = Color(0.025, 0.027, 0.035, 1.0)
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(background)

    var root := VBoxContainer.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.offset_left = 12
    root.offset_top = 8
    root.offset_right = -12
    root.offset_bottom = -8
    root.add_theme_constant_override("separation", 8)
    add_child(root)

    var header := HBoxContainer.new()
    root.add_child(header)
    var title := Label.new()
    title.text = "LITD : LES VEILLEURS — VERTICAL SLICE v0.9"
    title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    title.add_theme_font_size_override("font_size", 21)
    header.add_child(title)
    var save_button := Button.new()
    save_button.text = "Sauvegarder"
    save_button.custom_minimum_size = Vector2(112, 46)
    save_button.pressed.connect(_on_save)
    header.add_child(save_button)
    var load_button := Button.new()
    load_button.text = "Reprendre"
    load_button.custom_minimum_size = Vector2(104, 46)
    load_button.pressed.connect(_on_load)
    header.add_child(load_button)
    var back_button := Button.new()
    back_button.text = "Retour QA"
    back_button.custom_minimum_size = Vector2(104, 46)
    back_button.pressed.connect(func() -> void: get_tree().change_scene_to_file(QA_SCENE))
    header.add_child(back_button)

    var dungeon_bar := HFlowContainer.new()
    dungeon_bar.add_theme_constant_override("h_separation", 6)
    dungeon_bar.add_theme_constant_override("v_separation", 6)
    root.add_child(dungeon_bar)
    for dungeon_id_value: Variant in DUNGEONS.keys():
        var dungeon_id := str(dungeon_id_value)
        var button := Button.new()
        button.text = str(DUNGEONS[dungeon_id])
        button.custom_minimum_size = Vector2(150, 44)
        button.pressed.connect(func() -> void: _start_dungeon(dungeon_id))
        dungeon_bar.add_child(button)

    status_label = Label.new()
    status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    status_label.custom_minimum_size = Vector2(0, 54)
    root.add_child(status_label)
    room_view = SubViewportContainer.new()
    room_view.custom_minimum_size = Vector2(0, 220)
    room_view.stretch = true
    room_view.visible = false
    root.add_child(room_view)
    room_viewport = SubViewport.new()
    room_viewport.size = Vector2i(640, 220)
    room_viewport.own_world_3d = true
    room_viewport.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
    room_view.add_child(room_viewport)
    room_events_label = Label.new()
    room_events_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    room_events_label.visible = false
    root.add_child(room_events_label)

    actions = HFlowContainer.new()
    actions.add_theme_constant_override("h_separation", 6)
    actions.add_theme_constant_override("v_separation", 6)
    root.add_child(actions)

    recruit_actions = VBoxContainer.new()
    recruit_actions.add_theme_constant_override("separation", 4)
    root.add_child(recruit_actions)

    tactical_ui = TACTICAL_UI_SCENE.instantiate() as VeilleursTacticalUI
    tactical_ui.size_flags_vertical = Control.SIZE_EXPAND_FILL
    tactical_ui.tactical_cell_pressed.connect(_on_cell)
    tactical_ui.skill_slot_pressed.connect(_on_skill)
    tactical_ui.body_zone_pressed.connect(_on_zone)
    tactical_ui.retreat_pressed.connect(_on_retreat)
    root.add_child(tactical_ui)

    ally_target = OptionButton.new()
    ally_target.custom_minimum_size = Vector2(180, 44)
    ally_target.visible = false
    ally_target.item_selected.connect(_on_ally_target)
    root.add_child(ally_target)

    message_label = Label.new()
    message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    message_label.custom_minimum_size = Vector2(0, 52)
    root.add_child(message_label)

func _start_dungeon(dungeon_id: String) -> void:
    if slice == null:
        return
    var result := slice.start_dungeon(dungeon_id, 9001 + posmod(dungeon_id.hash(), 10000))
    if not bool(result.get("ok", false)):
        message_label.text = "Donjon indisponible : %s" % str(result.get("reason", "inconnu"))
        return
    selected_watcher = "ENT_WATCHER_marec"
    selected_target = ""
    selected_ally = ""
    selected_zone = "torso"
    message_label.text = "%s chargé." % str(DUNGEONS.get(dungeon_id, dungeon_id))
    _render_node()

func _render_node() -> void:
    tactical_ui.visible = false
    ally_target.visible = false
    _clear(actions)
    _clear(recruit_actions)
    if slice == null:
        return
    var snapshot := slice.current_snapshot()
    var node: Dictionary = snapshot.get("dungeon", {})
    _display_room(node)
    var progress: Dictionary = snapshot.get("progress", {})
    status_label.text = "%s — %s\nNœud %s | %d/%d visités | extraction : %s" % [
        str(DUNGEONS.get(str(progress.get("dungeon_id", "")), str(progress.get("dungeon_id", "")))),
        str(node.get("title_fr", node.get("node_id", ""))),
        str(node.get("node_id", "")),
        int(progress.get("visited_count", 0)),
        int(progress.get("total_nodes", 0)),
        "oui" if bool(progress.get("can_extract", false)) else "non"
    ]
    var unresolved := _unresolved_recruitment()
    if unresolved > 0:
        _render_recruitment()
        return
    if not (snapshot.get("active_encounter", {}) as Dictionary).is_empty():
        _add_action("Lancer le combat", _launch_combat)
        for escape_id: String in slice.campaign.dungeon.available_next():
            _add_action("Replier vers " + escape_id.replace("_", " "), func() -> void: _enter_next(escape_id))
        return
    var flags: Dictionary = slice.campaign.dungeon.node_flags.get(str(node.get("node_id", "")), {})
    if not bool(flags.get("completed", false)):
        _add_action("Résoudre ce lieu", _resolve_noncombat_node)
        return
    if not slice.campaign.dungeon.procedural_plan.is_empty():
        _add_action("Chercher les passages", func() -> void:
            var discovered := slice.campaign.dungeon.discover_current_passages()
            message_label.text = "Passages découverts : %d" % discovered.get("discovered", []).size()
            _render_node())
    for next_id: String in slice.campaign.dungeon.available_next():
        var next_node: Dictionary = slice.campaign.dungeon.nodes_by_id.get(next_id, {})
        var label := "→ %s" % str(next_node.get("title_fr", next_id))
        _add_action(label, func() -> void: _enter_next(next_id))
    if slice.campaign.dungeon.can_extract():
        _add_action("Extraire", _extract)

func _resolve_noncombat_node() -> void:
    var result := slice.campaign.resolve_current_node("cleared", {})
    message_label.text = "Lieu résolu." if bool(result.get("ok", false)) else "Échec : %s" % str(result.get("reason", "inconnu"))
    _render_node()

func _enter_next(node_id: String) -> void:
    var result := slice.enter_next(node_id)
    message_label.text = "Progression vers %s." % node_id if bool(result.get("ok", false)) else "Transition refusée : %s" % str(result.get("reason", "inconnue"))
    _render_node()

func _launch_combat() -> void:
    var setup := slice.launch_current_encounter({})
    if not bool(setup.get("ok", false)):
        message_label.text = "Combat impossible : %s" % str(setup.get("reason", "inconnu"))
        return
    tactical_ui.visible = true
    room_view.visible = false
    room_events_label.visible = false
    _clear(actions)
    _clear(recruit_actions)
    _repair_selection()
    if bool(setup.get("nemesis_injected", false)):
        message_label.text = "Rémanence : %s revient dans cette rencontre." % str(setup.get("nemesis_name", "un ancien adversaire"))
    else:
        message_label.text = "Combat engagé."
    _refresh_combat()

func _refresh_combat() -> void:
    if slice == null or slice.combat == null:
        return
    var runtime: Variant = slice.combat
    tactical_ui.bind_snapshot({"runtime":runtime.serialize()})
    skill_ids.clear()
    var row: Dictionary = runtime.combatants.get(selected_watcher, {})
    var level := int(row.get("level", 1))
    var chosen_tree := str(row.get("chosen_tree", ""))
    var candidates: Array = runtime.content_db.skills_for(selected_watcher)
    for value: Variant in candidates:
        if not (value is Dictionary):
            continue
        var skill: Dictionary = value
        if int(skill.get("unlock_level", 99)) > level:
            continue
        if chosen_tree != "" and str(skill.get("tree_id", "")) != chosen_tree:
            continue
        skill_ids.append(str(skill.get("skill_id", "")))
    skill_ids.sort()
    while skill_ids.size() > 4:
        skill_ids.pop_back()
    var labels: Array[String] = []
    for skill_id: String in skill_ids:
        labels.append(str(runtime.content_db.skill(skill_id).get("name_fr", skill_id)))
    tactical_ui.set_skill_labels(labels)
    _refresh_ally_targets(runtime)
    var phase_text := ""
    if runtime.has_method("boss_phase_snapshot"):
        var phase: Dictionary = runtime.call("boss_phase_snapshot")
        if str(phase.get("boss_id", "")) != "":
            phase_text = " | boss phase %d" % int(phase.get("phase", 1))
            var pending := int(phase.get("pending_phase", 0))
            if pending > 0:
                phase_text += " → %d télégraphiée" % pending
    status_label.text = "Combat — round %d | %s → %s | zone %s%s" % [int(runtime.round_index), _display(selected_watcher), _display(selected_target), selected_zone, phase_text]

func _on_cell(cell: Vector2i) -> void:
    if slice == null or slice.combat == null:
        return
    var runtime: Variant = slice.combat
    var occupant: String = str(runtime.grid.occupant(cell))
    var team := str(runtime.combatants.get(occupant, {}).get("team", ""))
    if team == "watcher":
        selected_watcher = occupant
        _refresh_combat()
        return
    if team == "enemy":
        selected_target = occupant
        _refresh_combat()
        return
    var origin: Vector2i = runtime.grid.position_of(selected_watcher)
    if absi(origin.x - cell.x) + absi(origin.y - cell.y) != 1:
        message_label.text = "Déplacement refusé : case adjacente requise."
        return
    if runtime.has_method("can_move_to") and not bool(runtime.call("can_move_to", cell)):
        message_label.text = "Cette case est interdite ou occupée."
        return
    if runtime.grid.move(selected_watcher, cell):
        message_label.text = "%s se déplace." % _display(selected_watcher)
        _refresh_combat()

func _on_zone(zone: String) -> void:
    selected_zone = zone
    _refresh_combat()

func _on_skill(slot: int) -> void:
    if slice == null or slice.combat == null or slot < 0 or slot >= skill_ids.size():
        return
    var runtime: Variant = slice.combat
    var skill_id := skill_ids[slot]
    var skill: Dictionary = runtime.content_db.skill(skill_id)
    var action: String = runtime.skill_behavior.effective_action(skill)
    var target_id := selected_target
    if action in ["heal", "support"]:
        target_id = selected_ally if selected_ally != "" else selected_watcher
        var verdict: Dictionary = runtime.preview_skill(selected_watcher, target_id, skill_id, selected_zone)
        if not bool(verdict.get("ok", false)):
            message_label.text = "Cible alliée hors de portée."
            return
    elif action in ["guard", "passive_modifier", "move", "transform"]:
        target_id = selected_watcher
    if target_id == "" or not runtime.combatants.has(target_id):
        message_label.text = "Sélectionnez une cible valide."
        return
    var result: Dictionary = runtime.resolve_skill(selected_watcher, target_id, skill_id, selected_zone, -1)
    if not bool(result.get("ok", false)):
        message_label.text = "Action refusée : %s" % str(result.get("reason", "inconnue"))
        return
    message_label.text = "%s utilise %s." % [_display(selected_watcher), str(skill.get("name_fr", skill_id))]
    _check_combat_end_or_enemy_phase()

func _refresh_ally_targets(runtime: Variant) -> void:
    ally_target.clear()
    ally_target.add_item("Cible alliée : lanceur")
    ally_target.set_item_metadata(0, "")
    var selected := 0
    for watcher: String in runtime.alive_ids("watcher"):
        ally_target.add_item("Cible alliée : " + _display(watcher))
        var index := ally_target.item_count - 1
        ally_target.set_item_metadata(index, watcher)
        if watcher == selected_ally:
            selected = index
    if selected == 0:
        selected_ally = ""
    ally_target.select(selected)
    ally_target.visible = false
    for skill_id: String in skill_ids:
        if runtime.skill_behavior.effective_action(runtime.content_db.skill(skill_id)) in ["heal", "support"]:
            ally_target.visible = true
            break

func _on_ally_target(index: int) -> void:
    if index >= 0 and index < ally_target.item_count:
        selected_ally = str(ally_target.get_item_metadata(index))

func _enemy_phase() -> void:
    if slice == null or slice.combat == null:
        return
    var runtime: Variant = slice.combat
    for enemy_id: String in runtime.alive_ids("enemy"):
        runtime.enemy_step(enemy_id)
    runtime.next_round()

func _check_combat_end_or_enemy_phase() -> void:
    var runtime: Variant = slice.combat
    if runtime.alive_ids("enemy").is_empty():
        _finish_combat("victory")
        return
    _enemy_phase()
    if runtime.alive_ids("watcher").is_empty():
        _finish_combat("defeat")
        return
    _repair_selection()
    _refresh_combat()

func _finish_combat(outcome: String) -> void:
    var result := slice.resolve_active_combat(outcome, {})
    tactical_ui.visible = false
    selected_target = ""
    if not bool(result.get("ok", false)):
        message_label.text = "Résolution du combat impossible."
        return
    var return_data: Dictionary = result.get("nemesis_return", {})
    var extra := ""
    if bool(return_data.get("injected", false)):
        extra = " L'adversaire mémoriel a conservé son identité."
    message_label.text = "%s.%s" % ["Victoire" if outcome == "victory" else ("Retraite" if outcome == "retreat" else "Défaite"), extra]
    _render_node()

func _on_retreat() -> void:
    if slice != null and slice.combat != null:
        _finish_combat("retreat")

func _render_recruitment() -> void:
    _clear(recruit_actions)
    var options := slice.recruitment_options()
    for index in range(options.size()):
        var candidate: Dictionary = options[index]
        if bool(candidate.get("resolved", false)):
            continue
        var row := HBoxContainer.new()
        var label := Label.new()
        label.text = "%s — %s" % [str(candidate.get("name", candidate.get("entity_id", "Adversaire"))), str(candidate.get("remanence_stage", "normal"))]
        label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        row.add_child(label)
        for action in ["recruit", "spare", "leave"]:
            var button := Button.new()
            button.text = {"recruit":"Recruter", "spare":"Épargner", "leave":"Laisser"}[action]
            button.custom_minimum_size = Vector2(96, 40)
            var captured_index := index
            var captured_action: String = str(action)
            button.pressed.connect(func() -> void: _decide_recruitment(captured_index, captured_action))
            row.add_child(button)
        recruit_actions.add_child(row)

func _decide_recruitment(index: int, action: String) -> void:
    var result := slice.resolve_recruitment_decision(index, action, {})
    if bool(result.get("ok", false)):
        message_label.text = "Décision enregistrée : %s." % action
    else:
        message_label.text = "Décision impossible : %s" % str(result.get("reason", "conditions_non_remplies"))
    _render_node()

func _extract() -> void:
    var summary := slice.campaign.complete_expedition({"gold":250, "materials":20, "essence":0})
    message_label.text = "Extraction terminée : +%d or, +%d matériaux." % [int(summary.get("gold", 0)), int(summary.get("materials", 0))]
    status_label.text = "Expédition terminée. Choisissez un donjon pour repartir."
    _clear(actions)
    _clear(recruit_actions)

func _on_save() -> void:
    message_label.text = "Vertical slice sauvegardé." if save_bridge.save_slice(slice) else "Échec de sauvegarde."

func _on_load() -> void:
    if not save_bridge.has_save():
        message_label.text = "Aucune sauvegarde v0.9 disponible."
        return
    var restored := SLICE_SCRIPT.new() as VeilleursVerticalSliceRuntimeV09
    if not save_bridge.load_into(restored):
        message_label.text = "Sauvegarde invalide ou incompatible."
        return
    slice = restored
    _repair_selection()
    if slice.combat != null:
        tactical_ui.visible = true
        _refresh_combat()
        message_label.text = "Combat et Rémanence restaurés."
    else:
        message_label.text = "Donjon et Rémanence restaurés."
        _render_node()

func _repair_selection() -> void:
    if slice == null or slice.combat == null:
        return
    var runtime: Variant = slice.combat
    if not runtime.combatants.has(selected_watcher) or int((runtime.combatants[selected_watcher] as Dictionary).get("hp", 0)) <= 0:
        var watchers: Array[String] = runtime.alive_ids("watcher")
        if not watchers.is_empty():
            selected_watcher = watchers[0]
    if selected_target == "" or not runtime.combatants.has(selected_target) or int((runtime.combatants[selected_target] as Dictionary).get("hp", 0)) <= 0:
        var enemies: Array[String] = runtime.alive_ids("enemy")
        selected_target = enemies[0] if not enemies.is_empty() else ""

func _display(entity_id: String) -> String:
    if slice == null or slice.combat == null:
        return entity_id
    var row: Dictionary = slice.combat.combatants.get(entity_id, {})
    return str(row.get("name", entity_id))

func _unresolved_recruitment() -> int:
    var count := 0
    for candidate: Dictionary in slice.recruitment_options():
        if not bool(candidate.get("resolved", false)):
            count += 1
    return count

func _add_action(text: String, callback: Callable) -> void:
    var button := Button.new()
    button.text = text
    button.custom_minimum_size = Vector2(160, 44)
    button.pressed.connect(callback)
    actions.add_child(button)

func _clear(container: Node) -> void:
    for child: Node in container.get_children():
        child.queue_free()

func _display_room(node: Dictionary) -> void:
    if room_root != null:
        room_root.free()
        room_root = null
    var path := str(node.get("scene_path", ""))
    room_view.visible = path != ""
    room_events_label.visible = room_view.visible
    if path == "":
        return
    var packed := load(path) as PackedScene
    if packed == null:
        room_view.visible = false
        return
    room_root = Node3D.new()
    room_viewport.add_child(room_root)
    var room := packed.instantiate() as Node3D
    room_root.add_child(room)
    room.set_meta("room_events", node.get("room_events", []).duplicate(true))
    var camera := Camera3D.new()
    camera.projection = Camera3D.PROJECTION_ORTHOGONAL
    camera.size = 42
    camera.position = Vector3(26, 32, 30)
    room_root.add_child(camera)
    camera.look_at(Vector3.ZERO)
    camera.current = true
    var light := DirectionalLight3D.new()
    light.rotation_degrees = Vector3(-55, -30, 0)
    light.light_energy = 1.5
    room_root.add_child(light)
    var descriptions: Array[String] = []
    for event in node.get("room_events", []):
        descriptions.append("%s : %s" % [str(event.get("slot_id", "")).replace("_", " "), str(event.get("variant", "")).replace("_", " ")])
    room_events_label.text = " · ".join(descriptions)
