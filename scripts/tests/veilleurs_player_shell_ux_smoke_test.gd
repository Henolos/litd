extends Node

const PLAYER_UI := preload("res://scripts/ui/veilleurs_vertical_slice.gd")

var failures: Array[String] = []

func _ready() -> void:
    call_deferred("_run")

func _run() -> void:
    var ui := PLAYER_UI.new()

    _check(ui.call("_player_primary_action_label", {"kind":"archive"}) == "EXAMINER LES ARCHIVES", "archive nodes expose a contextual player action")
    _check(ui.call("_player_primary_action_label", {"kind":"event"}) == "EXAMINER LA SITUATION", "event nodes expose a contextual player action")
    _check(ui.call("_player_primary_action_label", {"kind":"choice"}) == "ÉTUDIER LES PASSAGES", "choice nodes expose a contextual player action")
    _check(ui.call("_player_primary_action_label", {"kind":"objective"}) == "EXAMINER L'OBJECTIF", "objective nodes expose a contextual player action")
    _check(ui.call("_player_primary_action_label", {"kind":"entry"}) == "EXPLORER LE LIEU", "ordinary nodes keep a clear exploration action")

    var status := str(ui.call("_player_status_text",
        {"node_id":"KHAR_03", "title_fr":"Maison du registre fendu"},
        {"dungeon_id":"DUNGEON_KHAR_SEN", "visited_count":3, "total_nodes":9, "can_extract":false}
    ))
    _check(status.contains("Maison du registre fendu"), "player status keeps the authored place name")
    _check(status.contains("Progression 3/9"), "player status exposes useful run progress")
    _check(status.contains("Extraction indisponible"), "player status explains extraction availability")
    _check(not status.contains("KHAR_03"), "player status hides internal node identifiers")

    for dungeon_name_value: Variant in ui.DUNGEONS.values():
        var button := Button.new()
        button.text = str(dungeon_name_value)
        ui.add_child(button)
    ui.call("_set_dungeon_selector_visible", false)
    _check(_all_dungeon_buttons_match(ui, false), "active expedition hides global dungeon switching")
    ui.call("_set_dungeon_selector_visible", true)
    _check(_all_dungeon_buttons_match(ui, true), "completed expedition restores dungeon selection")

    ui.free()
    _finish()

func _all_dungeon_buttons_match(ui: Node, expected: bool) -> bool:
    for dungeon_name_value: Variant in ui.DUNGEONS.values():
        var button: Button = ui.call("_find_button_with_text", ui, str(dungeon_name_value))
        if button == null or button.visible != expected:
            return false
    return true

func _check(condition: bool, message: String) -> void:
    if not condition:
        failures.append(message)

func _finish() -> void:
    if failures.is_empty():
        print("VEILLEURS_PLAYER_SHELL_UX_SMOKE_OK")
        get_tree().quit(0)
        return
    for failure in failures:
        push_error("VEILLEURS_PLAYER_SHELL_UX_FAIL: %s" % failure)
    get_tree().quit(1)
