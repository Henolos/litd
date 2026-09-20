extends "res://scripts/core/ui_roguelike_journey_smoke_test_v2.gd"

# v3 / P0 playtest : le parcours joueur valide désormais le départ guidé et les
# déplacements salle par salle sans imposer la macro-carte. La carte reste testée
# comme vue d'ensemble optionnelle, puis la progression reprend par les passages.

const CANONICAL_PORTRAIT_PATHS := [
    "res://assets/heroes/canonical/mathilde.svg",
    "res://assets/heroes/canonical/marec.svg",
    "res://assets/heroes/canonical/anouk.svg",
    "res://assets/heroes/canonical/aurelien.svg"
]

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
    var physical_passages_taken := 0
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
            _check(not _macro_map_open_v51(), "Room-to-room traversal must not silently reopen the macro map state")
            var action_button: Button = _find_physical_room_action_button()
            if action_button != null:
                action_button.pressed.emit()
                await _frames(5)
                continue
            var passage_button: Button = _find_physical_passage_button()
            _check(passage_button != null, "Cleared physical room must expose a passage to continue without the macro map")
            if passage_button == null:
                break
            physical_passages_taken += 1
            passage_button.pressed.emit()
            await _frames(5)
            continue
        if GameState.current_screen == "expedition":
            _check(not _macro_map_open_v51(), "Direct navigation may appear between rooms but must not switch to the macro map")
            var direct_button: Button = _find_direct_room_button()
            _check(direct_button != null, "Direct navigation must keep an unexplored reachable room available")
            if direct_button == null:
                break
            direct_button.pressed.emit()
            await _frames(5)
            continue
        break

    # Le seed de test peut légitimement placer un combat dès la salle atteinte
    # après le premier passage. Le contrat P0 est donc vérifié sur la propriété
    # essentielle : au moins une transition physique salle→passage→salle sans
    # réouverture de la macro-carte, puis arrivée en combat par ce même flux.
    _check(physical_passages_taken >= 1, "Player must traverse physical rooms through at least one direct passage without opening the macro map")
    _check(GameState.current_screen == "combat", "Physical route must eventually start combat without requiring the macro map")
    if GameState.current_screen == "combat":
        _check(_canonical_portraits_visible(), "Combat must render dedicated portraits for Mathilde, Marec, Anouk and Aurélien")
        _check(_legacy_hero_portraits_hidden(), "Legacy hero/class portraits must stay hidden when the canonical quartet is rendered")
        _check(_find_button("1 · Trait net", false) != null, "Dungeon combat must expose Mathilde's canonical first tactical skill")
        _check(_find_button("1 · Frappe", false) == null, "Canonical quartet must not fall back to the generic Frappe starter")
        _check(_find_button("CAPTURER", true) != null, "Dungeon combat must expose capture")
        _check(GameState.battle_enemies.size() >= 1, "Combat room must create enemies")

func _macro_map_open_v51() -> bool:
    var scene: Node = get_tree().current_scene
    if scene == null:
        return false
    return bool(scene.get("expedition_macro_map_open_v51"))

func _canonical_portraits_visible() -> bool:
    var scene: Node = get_tree().current_scene
    if scene == null:
        return false
    var found: Dictionary = {}
    for path_value in CANONICAL_PORTRAIT_PATHS:
        found[str(path_value)] = false
    for node_value in scene.find_children("*", "TextureRect", true, false):
        var portrait := node_value as TextureRect
        if portrait == null or portrait.texture == null or not portrait.is_visible_in_tree():
            continue
        var resource_path := str(portrait.texture.resource_path)
        if found.has(resource_path):
            found[resource_path] = true
    for path_value in CANONICAL_PORTRAIT_PATHS:
        if not bool(found.get(str(path_value), false)):
            return false
    return true

func _legacy_hero_portraits_hidden() -> bool:
    var scene: Node = get_tree().current_scene
    if scene == null:
        return false
    for node_value in scene.find_children("*", "TextureRect", true, false):
        var portrait := node_value as TextureRect
        if portrait == null or portrait.texture == null or not portrait.is_visible_in_tree():
            continue
        var resource_path := str(portrait.texture.resource_path)
        if resource_path.begins_with("res://assets/heroes/") and not resource_path.begins_with("res://assets/heroes/canonical/"):
            return false
    return true

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
