extends "res://scripts/core/mobile_touch_smoke_test.gd"

# Le nouvel écran d'expédition expose un retour explicite vers le hub.
# Le smoke tactile conserve les mêmes gestes et dimensions, mais cible le contrat
# sémantique RETOUR afin de rester robuste aux variantes de libellé visibles.

const TACTICAL_UI_SCENE := preload("res://scenes/veilleurs/v06_tactical_combat.tscn")

func _run_device_profile() -> void:
    EndgameState.reset_profile_progress()
    GameState.reset_new_game()
    CampaignState.reset_new_game()
    EquipmentManager.reset_new_game(8101)
    CreatureManager.reset_new_game(8102)
    AshlandsRuntime.reset_world_progression()
    if ExpeditionManager.expedition_active:
        ExpeditionManager.return_to_hub("mobile_touch_smoke_reset")
    ExpeditionManager.reset_to_full_resupply()
    AshlandsCombatBridge.active = false
    AshlandsCombatBridge.encounter_id = ""
    AshlandsCombatBridge.encounter_type = ""

    get_tree().root.size = active_window_size
    await _frames(3)

    var error := get_tree().change_scene_to_file(MAIN_SCENE)
    _check(error == OK, "Main scene must load on %s" % active_device_name)
    _check(await _wait_for_main(), "Main scene must become active on %s" % active_device_name)
    await _frames(4)

    _check(GameState.current_screen == "title", "Title must be visible on %s" % active_device_name)
    await _audit_visible_buttons("title")
    _check(await _touch_button("NOUVELLE PARTIE", true), "Touch must activate Nouvelle Partie on %s" % active_device_name)
    _check(GameState.current_screen == "sanctuary", "Touch Nouvelle Partie must open Sanctuary on %s" % active_device_name)

    await _audit_visible_buttons("sanctuary")
    _check(_count_buttons("INFIRMERIE\nSoins et blessures", true) == 1, "Sanctuary must expose exactly one Infirmary button on %s" % active_device_name)
    _check(_count_buttons("CHAPELLE\nPeur, folie et espoir", true) == 1, "Sanctuary must expose exactly one Chapel button on %s" % active_device_name)
    _check(_count_buttons("TAVERNE\nRecruter et rumeurs", true) == 1, "Sanctuary must expose exactly one Tavern button on %s" % active_device_name)
    _check(_count_buttons("MÉMORIAL\nHéros tombés", true) == 1, "Sanctuary must expose exactly one Memorial button on %s" % active_device_name)
    _check(await _touch_button("LA PORTE", false), "Touch must activate La Porte on %s" % active_device_name)
    _check(GameState.current_screen == "expedition", "Touch La Porte must open expedition screen on %s" % active_device_name)

    await _audit_visible_buttons("expedition")
    _check(await _touch_button("RETOUR", false), "Touch must return from expedition setup on %s" % active_device_name)
    _check(GameState.current_screen == "sanctuary", "Touch return must restore Sanctuary on %s" % active_device_name)

    for screen_name_value in ["company", "market", "creatures", "infirmary", "chapel", "tavern", "memorial"]:
        var screen_name := str(screen_name_value)
        GameState.request_screen(screen_name)
        await _frames(4)
        _check(GameState.current_screen == screen_name, "%s screen must render on %s" % [screen_name, active_device_name])
        await _audit_visible_buttons(screen_name)

    GameState.request_screen("sanctuary")
    await _frames(3)
    var main := get_tree().current_scene
    _check(main != null and main.name == "Main", "Main must still own UI before mobile combat on %s" % active_device_name)
    if main == null or main.name != "Main":
        return

    main.call("start_random_battle")
    await _frames(5)
    _check(GameState.current_screen == "combat", "Prototype combat must render for touch audit on %s" % active_device_name)
    await _audit_visible_buttons("combat")
    # Garde est désormais la compétence équipée du slot 3 et son bouton affiche
    # aussi ses rangs autorisés. Le test tactile cible donc le libellé visible actuel.
    _check(await _touch_button("3 · Garde", false), "Touch must activate equipped Guard in combat on %s" % active_device_name)
    _check(_log_contains("se met en garde"), "Combat touch must execute equipped Guard on %s" % active_device_name)

    await _audit_v09_mobile_contract()

func _audit_v09_mobile_contract() -> void:
    var original_text_scale := GameSettings.text_scale
    var original_ui_scale := GameSettings.ui_scale
    GameSettings.set_text_scale(1.4)
    GameSettings.set_ui_scale(1.4)
    await _frames(3)

    var tactical := TACTICAL_UI_SCENE.instantiate() as VeilleursTacticalUI
    _check(tactical != null, "v0.9 tactical UI must instantiate on %s" % active_device_name)
    if tactical == null:
        GameSettings.set_text_scale(original_text_scale)
        GameSettings.set_ui_scale(original_ui_scale)
        await _frames(2)
        return

    get_tree().root.add_child(tactical)
    await _frames(2)

    tactical.bind_snapshot({
        "runtime": {
            "round": 1,
            "grid": {
                "0:0": "ENT_WATCHER_TEST",
                "1:0": "ENT_ENEMY_ALPHA",
                "2:0": "ENT_ENEMY_BETA"
            },
            "combatants": {
                "ENT_WATCHER_TEST": {"name": "Marec", "team": "watcher", "hp": 40, "max_hp": 40, "level": 1},
                "ENT_ENEMY_ALPHA": {"name": "Goule alpha", "team": "enemy", "hp": 18, "max_hp": 20, "level": 1},
                "ENT_ENEMY_BETA": {
                    "name": "Goule bêta",
                    "team": "enemy",
                    "hp": 16,
                    "max_hp": 20,
                    "level": 1,
                    "statuses": {"PINNED": {"remaining": 1, "strength": 2}},
                    "mobility_penalty": 6,
                    "body": {
                        "states": {
                            "head": "L0",
                            "torso": "L0",
                            "left_arm": "L0",
                            "right_arm": "L5",
                            "left_leg": "L4",
                            "right_leg": "L0"
                        }
                    }
                }
            }
        },
        "turn_order": ["ENT_WATCHER_TEST", "ENT_ENEMY_ALPHA", "ENT_ENEMY_BETA"],
        "active_entity_id": "ENT_WATCHER_TEST",
        "selected_entity_id": "ENT_ENEMY_BETA",
        "selected_skill": {"id": "SK_TEST", "name": "Frappe", "targeting": {"range": 3, "target": "enemy"}},
        "targetable_ids": ["ENT_ENEMY_ALPHA", "ENT_ENEMY_BETA"],
        "selected_target_ids": ["ENT_ENEMY_BETA"],
        "intent_preview": {
            "action": "Frappe",
            "target": "Goule bêta",
            "body_region": "right_arm",
            "expected": "18–24 dégâts"
        }
    })
    await _frames(2)

    # Le contrat tactile courant est porté par VeilleursTacticalUI lui-même :
    # contrôles 6x5, zones corporelles, compétences et actions >= 44 px.
    # L'ancien helper apply_mobile_layout() n'existe plus ; la scène est ancrée
    # en plein écran et suit directement la taille du viewport.
    _check(tactical.touch_contract_ok(), "v0.9 tactical UI must satisfy its current touch contract on %s" % active_device_name)

    var interactive_count := 0
    for node_value in tactical.find_children("*", "Control", true, false):
        var control := node_value as Control
        if control == null or not control.is_visible_in_tree():
            continue
        if control.mouse_filter == Control.MOUSE_FILTER_IGNORE:
            continue
        if control is Button or control is TextureButton:
            interactive_count += 1
            _check(control.size.x >= 44.0, "v0.9 tactical target too narrow on %s" % active_device_name)
            _check(control.size.y >= 44.0, "v0.9 tactical target too short on %s" % active_device_name)
    _check(interactive_count > 0, "v0.9 tactical UI must expose touch targets on %s" % active_device_name)

    tactical.queue_free()
    await _frames(2)
    GameSettings.set_text_scale(original_text_scale)
    GameSettings.set_ui_scale(original_ui_scale)
    await _frames(2)
