extends CanvasLayer
## Local playtest marker. F8 opens a bug/feedback form; no network upload.
const REPORT_PATH := "user://playtest_reports.jsonl"
var dialog: ConfirmationDialog
var category: OptionButton
var notes: TextEdit
var was_paused := false
var marker_sequence := 0
var session_id := ""

func _ready() -> void:
    session_id = "%s-%d" % [Time.get_datetime_string_from_system(true).replace(":", "-"), Time.get_ticks_msec()]
    layer = 120
    process_mode = Node.PROCESS_MODE_ALWAYS
    dialog = ConfirmationDialog.new()
    dialog.title = "Signaler un probleme ou une suggestion"
    dialog.ok_button_text = "Enregistrer"
    dialog.cancel_button_text = "Annuler"
    dialog.process_mode = Node.PROCESS_MODE_ALWAYS
    add_child(dialog)
    var content := VBoxContainer.new()
    dialog.add_child(content)
    category = OptionButton.new()
    category.add_item("Bug / probleme")
    category.add_item("Suggestion / amelioration")
    content.add_child(category)
    notes = TextEdit.new()
    notes.custom_minimum_size = Vector2(480, 140)
    notes.placeholder_text = "Que s'est-il passe ? Que devrais-je observer ?"
    content.add_child(notes)
    dialog.confirmed.connect(_save_marker)
    dialog.visibility_changed.connect(_on_dialog_visibility_changed)

func _unhandled_key_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F8:
        if dialog.visible:
            dialog.hide()
        else:
            notes.text = ""
            was_paused = get_tree().paused
            get_tree().paused = true
            dialog.popup_centered()
        get_viewport().set_input_as_handled()

func _on_dialog_visibility_changed() -> void:
    if not dialog.visible:
        get_tree().paused = was_paused

func _save_marker() -> void:
    var record := {
        "timestamp_utc": Time.get_datetime_string_from_system(true),
        "session_id": session_id,
        "marker_id": "%s-%04d" % [session_id, marker_sequence + 1],
        "kind": "bug" if category.selected == 0 else "suggestion",
        "description": notes.text.strip_edges(),
        "screen": GameState.current_screen,
        "battle_round": GameState.battle_rounds,
        "expedition_room": GameState.expedition_room,
        "scene": get_tree().current_scene.scene_file_path if get_tree().current_scene else "",
        "engine": Engine.get_version_info().get("string", "unknown")
    }
    var mode := FileAccess.READ_WRITE if FileAccess.file_exists(REPORT_PATH) else FileAccess.WRITE_READ
    var file := FileAccess.open(REPORT_PATH, mode)
    if file == null:
        push_error("Playtest report could not be opened: %s" % FileAccess.get_open_error())
        return
    file.seek_end()
    if not file.store_line(JSON.stringify(record)):
        push_error("Playtest report write failed: %s" % FileAccess.get_error())
        file.close()
        return
    file.close()
    marker_sequence += 1
    print("PLAYTEST_MARKER ", JSON.stringify(record))
