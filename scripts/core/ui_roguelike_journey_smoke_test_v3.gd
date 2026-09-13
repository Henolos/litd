extends "res://scripts/core/ui_roguelike_journey_smoke_test_v2.gd"

# v3 / P0 playtest : le parcours joueur valide désormais le départ guidé et les
# déplacements salle par salle sans imposer la macro-carte. La carte reste testée
# comme vue d'ensemble optionnelle, puis la progression reprend par les passages.

func _drive_title_and_departure() -> void:
    _check(await _press_button("NOUVELLE PARTIE", true), "Player must start a new game through the UI")
    _check(ContentScopeDirector.grant_capability("capture"), "Advanced roguelike journey must unlock capture explicitly")
    _check(GameState.current_screen == "sanctuary", "New Game must open the Sanctuary")
    _check(_find_button("PARTIR EN MISSION", true) != null, "Hub must expose one obvious primary mission action")
    _check(await _press_button("PARTIR EN MISSION", true), "Player must reach expedition preparation from the hub primary action")
    _check(GameState.current_screen == "expedition", "Primary mission action must open expedition preparation")

    _check(_node_tree_contains_text(get_tree().current_scene, "1 · ÉQUIPE"), "Departure must expose the team step")
    _check(_node_tree_contains_text(get_tree().current_scene, "2 · RÉSERVES"), "Departure must expose the supplies step")
    _check(_node_tree_contains_text(get_tree().current_scene, "3 · MISSION"), "Departure must expose the mission step")
    for canonical_name in ["Mathilde", "Marec", "Anouk", "Aurélien"]:
        _check(_node_tree_contains_text(get_tree().current_scene, canonical_name), "Departure must expose canonical starting hero: %s" % canonical_name)
    _check(_find_button("LANCER L'EXPÉDITION", true) != null, "Guided departure must expose one explicit launch action")
    _check(await _press_button("LANCER L'EXPÉDITION", true), "Player must launch the expedition through the guided UI")
    _check(ExpeditionManager.expedition_active, "Visible launch must activate ExpeditionManager")

    var runtime: Variant = ExpeditionManager.roguelike_runtime
    _check(runtime != null, "Roguelike runtime must exist after launch")
    if runtime != null:
        runtime.start_run(424242)
        ExpeditionManager.expedition_seed = 424242
        var scene: Node = get_tree().current_scene
        if scene != null:
            scene.call("show_screen", "expedition")
        await _frames(4)

    _check(_node_tree_contains_text(get_tree().current_scene, "SORTIES ACCESSIBLES"), "Active expedition must expose direct room navigation")
    _check(_find_button("ENTRER DANS LE DONJON", false) != null, "Direct navigation must expose the physical entrance")
    _check(_find_button("VOIR LA MACRO-CARTE", true) != null, "Macro map must remain available as an optional overview")

    _check(await _press_button("VOIR LA MACRO-CARTE", true), "Player must be able to open the optional macro map")
    _check(_node_tree_contains_text(get_tree().current_scene, "CARTE MACRO"), "Optional overview must expose the macro map")
    _check(_node_tree_contains_text(get_tree().current_scene, "1 NŒUD = 1 SALLE VISITABLE"), "Macro map must preserve the physical-room contract")
    _check(_find_button("← SORTIES DIRECTES", true) != null, "Macro map must provide a direct return to room choices")
    _check(await _press_button("← SORTIES DIRECTES", true), "Player must be able to leave the map without choosing a map node")
    _check(_node_tree_contains_text(get_tree().current_scene, "SORTIES ACCESSIBLES"), "Direct choices must return after closing the optional map")

func _enter_first_room() -> void:
    _check(await _press_button("ENTRER DANS LE DONJON", false), "Player must enter the physical entrance without using a map node")
    _check(GameState.current_screen == "dungeon_room", "Direct room choice must open a real physical room")
    _check(_node_tree_contains_text(get_tree().current_scene, "ISSUES ET PASSAGES"), "Physical room must expose its passages")
    _check(await _press_button("FRANCHIR ET INSPECTER LE SEUIL", true), "Player must resolve the entrance from inside the room")
    _check(GameState.current_screen == "rewards", "Resolved room must open rewards")
    _check(await _press_button("RETOURNER DANS LA SALLE", true), "Rewards must return to the physical room")
    _check(GameState.current_screen == "dungeon_room", "Player must physically return to the cleared room")
    _check(_find_physical_passage_button() != null, "Cleared entrance must expose a physical passage without requiring the macro map")

func _reach_combat_room() -> void:
    for _step in range(40):
        if GameState.current_screen == "combat":
            break
        if GameState.current_screen == "rewards":
            var return_button: Button = _find_button("RETOURNER DANS LA SALLE", true)
            if return_button == null:
                break
            return_button.pressed.emit()
            await _frames(4)
            continue
        if GameState.current_screen == "dungeon_room":
            var action_button: Button = _find_physical_room_action_button()
            if action_button != null:
                action_button.pressed.emit()
                await _frames(5)
                continue
            var passage_button: Button = _find_physical_passage_button()
            _check(passage_button != null, "Cleared physical room must expose a passage to continue without the macro map")
            if passage_button == null:
                break
            passage_button.pressed.emit()
            await _frames(5)
            continue
        if GameState.current_screen == "expedition":
            var direct_button: Button = _find_direct_room_button()
            _check(direct_button != null, "Direct navigation must keep an unexplored reachable room available")
            if direct_button == null:
                break
            direct_button.pressed.emit()
            await _frames(5)
            continue
        break

    _check(GameState.current_screen == "combat", "Physical route must eventually start combat without requiring the macro map")
    if GameState.current_screen == "combat":
        _check(_find_button("1 · Frappe", false) != null, "Dungeon combat must expose the first equipped tactical skill")
        _check(_find_button("CAPTURER", true) != null, "Dungeon combat must expose capture")
        _check(GameState.battle_enemies.size() >= 1, "Combat room must create enemies")

func _find_physical_room_action_button() -> Button:
    var fragments: Array[String] = [
        "ENGAGER LE COMBAT",
        "TRAVERSER ET DÉJOUER LE PIÈGE",
        "RÉSOUDRE L'ÉNIGME",
        "FOUILLER LA SALLE",
        "EXPLORER ET INTERAGIR",
        "ROMPRE LE DERNIER SCEAU",
        "AFFRONTER L'ANGE"
    ]
    for fragment in fragments:
        var button: Button = _find_button(fragment, false)
        if button != null and not button.disabled and button.is_visible_in_tree():
            return button
    return null

func _find_physical_passage_button() -> Button:
    var scene: Node = get_tree().current_scene
    if scene == null:
        return null
    for node_value in scene.find_children("*", "Button", true, false):
        var button := node_value as Button
        if button == null or button.disabled or not button.is_visible_in_tree():
            continue
        if button.custom_minimum_size == Vector2(430, 48):
            return button
    return null

func _find_direct_room_button() -> Button:
    var scene: Node = get_tree().current_scene
    if scene == null:
        return null
    for node_value in scene.find_children("*", "Button", true, false):
        var button := node_value as Button
        if button == null or button.disabled or not button.is_visible_in_tree():
            continue
        if button.custom_minimum_size == Vector2(570, 64):
            return button
    return null
