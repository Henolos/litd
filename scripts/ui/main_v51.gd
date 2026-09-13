extends "res://scripts/ui/main_v50.gd"

# v51 — P0 UX issu du premier playtest externe.
# Objectifs :
# - rendre l'action principale du hub immédiatement identifiable ;
# - transformer le départ en expédition en parcours guidé ;
# - permettre de choisir la prochaine salle sans ouvrir la macro-carte ;
# - conserver la macro-carte comme vue d'ensemble optionnelle.

var expedition_macro_map_open_v51 := false

func show_sanctuary() -> void:
    super.show_sanctuary()
    _install_hub_primary_action_v51()

func _install_hub_primary_action_v51() -> void:
    if not is_instance_valid(content):
        return
    var old := content.get_node_or_null("PlaytestPrimaryActionV51")
    if old != null:
        old.queue_free()

    var panel := PanelContainer.new()
    panel.name = "PlaytestPrimaryActionV51"
    panel.position = Vector2(800, 500)
    panel.size = Vector2(430, 150)
    panel.z_index = 80
    panel.add_theme_stylebox_override("panel", panel_style(Color(0.012, 0.014, 0.020, 0.96)))
    content.add_child(panel)

    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation", 8)
    panel.add_child(box)
    box.add_child(make_label("QUE VOULEZ-VOUS FAIRE ?", 15, CANON_GOLD))
    box.add_child(make_label("Pour poursuivre l'aventure, préparez votre groupe puis franchissez la Porte.", 13, CANON_TEXT))
    var depart := make_button("PARTIR EN MISSION", func(): GameState.request_screen("expedition"), Vector2(390, 52))
    depart.tooltip_text = "Préparer puis lancer une expédition"
    box.add_child(depart)

func show_expedition() -> void:
    if not ExpeditionManager.expedition_active:
        expedition_macro_map_open_v51 = false
        _render_guided_departure_v51()
        _add_screen_kicker("EXPÉDITION")
        return

    if expedition_macro_map_open_v51:
        super.show_expedition()
        _install_return_to_direct_navigation_v51()
        return

    _render_direct_room_navigation_v51()
    _add_screen_kicker("EXPÉDITION")

func _render_guided_departure_v51() -> void:
    _canonical_backdrop(
        "PRÉPARER L'EXPÉDITION",
        "Trois repères suffisent : équipe, réserves, départ. La macro-carte n'est pas nécessaire ici."
    )

    var step_one := VBoxContainer.new()
    step_one.position = Vector2(60, 135)
    step_one.size = Vector2(550, 190)
    step_one.add_theme_constant_override("separation", 8)
    content.add_child(step_one)
    step_one.add_child(make_label("1 · ÉQUIPE", 18, CANON_GOLD))
    var hero_names: Array[String] = []
    for hero_value: Variant in GameState.party:
        var hero: Dictionary = hero_value
        hero_names.append(str(hero.get("name", "Veilleur")))
    step_one.add_child(make_label(" · ".join(hero_names), 17, CANON_TEXT))
    step_one.add_child(make_label("Vérifiez les fiches, compétences et équipements si nécessaire.", 13, CANON_MUTED))
    step_one.add_child(make_button("VOIR L'ÉQUIPE", func(): GameState.request_screen("hero_profile"), Vector2(300, 46)))

    var supplies: Dictionary = ExpeditionManager.inventory
    var step_two := VBoxContainer.new()
    step_two.position = Vector2(60, 355)
    step_two.size = Vector2(550, 205)
    step_two.add_theme_constant_override("separation", 8)
    content.add_child(step_two)
    step_two.add_child(make_label("2 · RÉSERVES", 18, CANON_GOLD))
    step_two.add_child(make_label(
        "Nourriture %d · Eau %d · Bandages %d\nLumière %d · Médecine %d" % [
            int(supplies.get("food", 0)),
            int(supplies.get("water", 0)),
            int(supplies.get("bandages", 0)),
            int(supplies.get("light", 0)),
            int(supplies.get("medicine", 0))
        ],
        15,
        CANON_TEXT
    ))
    step_two.add_child(make_label("Le départ réapprovisionne actuellement l'expédition selon les règles du prototype.", 12, CANON_MUTED))

    var mission := PanelContainer.new()
    mission.position = Vector2(665, 135)
    mission.size = Vector2(535, 425)
    mission.add_theme_stylebox_override("panel", panel_style(Color(0.012, 0.014, 0.020, 0.94)))
    content.add_child(mission)
    var mission_box := VBoxContainer.new()
    mission_box.add_theme_constant_override("separation", 13)
    mission.add_child(mission_box)
    mission_box.add_child(make_label("3 · MISSION", 18, CANON_GOLD))
    mission_box.add_child(make_label("SOUS LE PREMIER VOILE", 27, CANON_TEXT))
    mission_box.add_child(make_label(
        "Explorez le donjon, choisissez vos salles au fil de la progression et extrayez votre butin avant de pousser trop loin.",
        14,
        CANON_MUTED
    ))
    mission_box.add_child(make_label("MORT PERMANENTE · LUMIÈRE · EXTRACTION", 13, CANON_GOLD))
    var launch := make_button("LANCER L'EXPÉDITION", func(): _start_roguelike_expedition(), Vector2(485, 62))
    launch.tooltip_text = "Commencer Sous le Premier Voile"
    mission_box.add_child(launch)
    mission_box.add_child(make_button("RETOUR AU HUB", func(): GameState.request_screen("sanctuary"), Vector2(485, 46)))

func _render_direct_room_navigation_v51() -> void:
    _ensure_physical_first_veil()
    var runtime: Node = ExpeditionManager.roguelike_runtime
    if runtime == null:
        GameState.add_log("Le runtime roguelike est indisponible.")
        return

    var active_run: Dictionary = runtime.active_run
    var dungeon: Array = first_veil_dungeon.visible_layout(runtime)
    var current_room_id := str(active_run.get("current_room_id", ""))
    var visited: Array = active_run.get("visited", [])
    var risk: Dictionary = ExpeditionManager.current_risk_profile()

    _canonical_backdrop(
        "OÙ ALLER MAINTENANT ?",
        "Choisissez directement une sortie. Ouvrez la macro-carte seulement si vous voulez voir l'ensemble du donjon."
    )

    var status := VBoxContainer.new()
    status.position = Vector2(60, 130)
    status.size = Vector2(470, 420)
    status.add_theme_constant_override("separation", 10)
    content.add_child(status)
    status.add_child(make_label("ÉTAT DE L'EXPÉDITION", 18, CANON_GOLD))
    status.add_child(make_label(
        "Profondeur %d\nLumière %d\nInventaire %d/%d\nDanger ×%.2f · Butin ×%.2f" % [
            int(risk.get("depth", 1)),
            int(risk.get("light", 0)),
            ExpeditionManager.inventory_slots_used(),
            ExpeditionManager.inventory_capacity(),
            float(risk.get("danger_multiplier", 1.0)),
            float(risk.get("loot_multiplier", 1.0))
        ],
        16,
        CANON_TEXT
    ))

    var current: Dictionary = first_veil_dungeon.room_by_id(runtime, current_room_id)
    var current_name := "Entrée du donjon"
    if not current.is_empty():
        current_name = str(current.get("name", _room_type_label(str(current.get("type", "unknown")))))
    status.add_child(make_label("POSITION ACTUELLE\n%s" % current_name, 15, CANON_TEXT))

    var map_button := make_button("VOIR LA MACRO-CARTE", func(): _open_macro_map_v51(), Vector2(360, 48))
    map_button.tooltip_text = "Vue d'ensemble du donjon ; facultative pour se déplacer"
    status.add_child(map_button)

    var extract := make_button("EXTRAIRE LE BUTIN", func(): _extract_roguelike_run("extracted"), Vector2(360, 44))
    extract.disabled = visited.is_empty()
    status.add_child(extract)

    var exits_panel := VBoxContainer.new()
    exits_panel.position = Vector2(585, 130)
    exits_panel.size = Vector2(620, 440)
    exits_panel.add_theme_constant_override("separation", 11)
    content.add_child(exits_panel)
    exits_panel.add_child(make_label("SORTIES ACCESSIBLES", 20, CANON_GOLD))
    exits_panel.add_child(make_label("Touchez une destination pour avancer.", 13, CANON_MUTED))

    var reachable: Array[Dictionary] = []
    for room_value: Variant in dungeon:
        var room: Dictionary = room_value
        var room_id := str(room.get("id", ""))
        if _room_is_reachable(room_id, current_room_id, visited, dungeon):
            reachable.append(room)

    if reachable.is_empty():
        exits_panel.add_child(make_label("Aucune sortie accessible pour le moment.", 15, CANON_MUTED))
    else:
        var index := 1
        for room in reachable:
            var room_id := str(room.get("id", ""))
            var room_type := str(room.get("type", "unknown"))
            var depth := int(room.get("depth", 1))
            var room_name := str(room.get("name", _room_type_label(room_type)))
            var label := "ENTRER DANS LE DONJON · %s" % room_name if visited.is_empty() else "SORTIE %d · %s · PROFONDEUR %d" % [index, room_name, depth]
            var room_button := make_button(label, func(id_value = room_id): _enter_roguelike_room(str(id_value)), Vector2(570, 64))
            room_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
            exits_panel.add_child(room_button)
            index += 1

func _open_macro_map_v51() -> void:
    expedition_macro_map_open_v51 = true
    show_screen("expedition")

func _close_macro_map_v51() -> void:
    expedition_macro_map_open_v51 = false
    show_screen("expedition")

func _install_return_to_direct_navigation_v51() -> void:
    if not is_instance_valid(content):
        return
    var button := make_button("← SORTIES DIRECTES", func(): _close_macro_map_v51(), Vector2(210, 42))
    button.position = Vector2(1030, 8)
    button.z_index = 100
    content.add_child(button)
