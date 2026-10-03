extends "res://scripts/ui/veilleurs_vertical_slice_qa_v09.gd"
class_name VeilleursVerticalSliceUI

const MAIN_SCENE := "res://scenes/Main.tscn"

func _ready() -> void:
    super._ready()
    slice = VeilleursRuntime.runtime
    _promote_shell()
    if VeilleursRuntime.is_active():
        _repair_selection()
        if slice.combat != null:
            tactical_ui.visible = true
            _refresh_combat()
            message_label.text = "Expédition reprise."
        else:
            _render_node()
            message_label.text = "Expédition reprise."
    else:
        _start_dungeon("dungeon_first_map_hall_of_first_accord")

func _on_save() -> void:
    message_label.text = "Partie sauvegardée." if SaveManager.save_game() else "Échec de sauvegarde."

func _on_load() -> void:
    if not SaveManager.load_game():
        message_label.text = "Aucune sauvegarde compatible disponible."
        return
    slice = VeilleursRuntime.runtime
    _repair_selection()
    if slice.combat != null:
        tactical_ui.visible = true
        _refresh_combat()
        message_label.text = "Combat et Rémanence restaurés."
    elif VeilleursRuntime.is_active():
        message_label.text = "Expédition et Rémanence restaurées."
        _render_node()
    else:
        message_label.text = "La sauvegarde chargée n'est pas une expédition Les Veilleurs."

func _render_node() -> void:
    super._render_node()
    if slice == null:
        return
    var snapshot := slice.current_snapshot()
    var node: Dictionary = snapshot.get("dungeon", {})
    var progress: Dictionary = snapshot.get("progress", {})
    status_label.text = _player_status_text(node, progress)

    var generic_action := _find_button_with_text(self, "Résoudre ce lieu")
    if generic_action != null:
        generic_action.text = _player_primary_action_label(node)
    _set_dungeon_selector_visible(false)

func _extract() -> void:
    super._extract()
    _set_dungeon_selector_visible(true)

func _player_status_text(node: Dictionary, progress: Dictionary) -> String:
    var dungeon_name := str(DUNGEONS.get(str(progress.get("dungeon_id", "")), str(progress.get("dungeon_id", ""))))
    var place_name := str(node.get("title_fr", "Lieu inconnu"))
    var extraction := "Extraction disponible" if bool(progress.get("can_extract", false)) else "Extraction indisponible"
    return "%s — %s\nProgression %d/%d · %s" % [
        dungeon_name,
        place_name,
        int(progress.get("visited_count", 0)),
        int(progress.get("total_nodes", 0)),
        extraction
    ]

func _player_primary_action_label(node: Dictionary) -> String:
    match str(node.get("kind", "")):
        "archive":
            return "EXAMINER LES ARCHIVES"
        "event":
            return "EXAMINER LA SITUATION"
        "choice":
            return "ÉTUDIER LES PASSAGES"
        "extraction":
            return "SÉCURISER LA SORTIE"
        "objective":
            return "EXAMINER L'OBJECTIF"
        _:
            return "EXPLORER LE LIEU"

func _set_dungeon_selector_visible(value: bool) -> void:
    for dungeon_name_value: Variant in DUNGEONS.values():
        var button := _find_button_with_text(self, str(dungeon_name_value))
        if button != null:
            button.visible = value

func _promote_shell() -> void:
    var labels := find_children("*", "Label", true, false)
    for value: Node in labels:
        var label := value as Label
        if label != null and label.text.begins_with("LITD : LES VEILLEURS — VERTICAL SLICE"):
            label.text = "LITD : LES VEILLEURS"
            break

    var old_back := _find_button_with_text(self, "Retour QA")
    if old_back != null:
        old_back.visible = false
        var quit_button := Button.new()
        quit_button.text = "Retour"
        quit_button.custom_minimum_size = Vector2(104, 46)
        quit_button.pressed.connect(_return_to_main)
        old_back.get_parent().add_child(quit_button)

func _find_button_with_text(root: Node, text: String) -> Button:
    for child: Node in root.get_children():
        if child is Button and (child as Button).text == text:
            return child as Button
        var nested := _find_button_with_text(child, text)
        if nested != null:
            return nested
    return null

func _return_to_main() -> void:
    if VeilleursRuntime.is_active():
        SaveManager.autosave("sortie des Veilleurs")
    get_tree().change_scene_to_file(MAIN_SCENE)
