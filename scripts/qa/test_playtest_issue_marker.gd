extends Node
## Headless smoke test for the F8 playtest report marker.
const MARKER_SCRIPT := preload("res://scripts/qa/playtest_issue_marker.gd")
const REPORT_PATH := "user://playtest_reports.jsonl"

func _ready() -> void:
    call_deferred("_run")

func _run() -> void:
    var marker := MARKER_SCRIPT.new()
    get_tree().root.add_child(marker)
    await get_tree().process_frame
    if marker.dialog == null or marker.category == null or marker.notes == null:
        push_error("Playtest marker form was not initialized")
        get_tree().quit(1)
        return
    var initial_size := 0
    if FileAccess.file_exists(REPORT_PATH):
        var before := FileAccess.open(REPORT_PATH, FileAccess.READ)
        initial_size = before.get_length()
        before.close()
    marker.category.select(0)
    marker.notes.text = "QA smoke test"
    marker._save_marker()
    if not FileAccess.file_exists(REPORT_PATH):
        push_error("Playtest report file not created")
        get_tree().quit(1)
        return
    var file := FileAccess.open(REPORT_PATH, FileAccess.READ)
    file.seek(initial_size)
    var line := file.get_line()
    file.close()
    var record = JSON.parse_string(line)
    if not record is Dictionary or record.get("description", "") != "QA smoke test" or record.get("kind", "") != "bug":
        push_error("Playtest report content invalid")
        get_tree().quit(1)
        return
    if marker.marker_sequence != 1:
        push_error("Marker counter did not advance")
        get_tree().quit(1)
        return
    # Verify F8 opens and closes the dialog and restores the original pause state.
    get_tree().paused = false
    var f8 := InputEventKey.new()
    f8.keycode = KEY_F8
    f8.pressed = true
    marker._unhandled_key_input(f8)
    if not marker.dialog.visible or not get_tree().paused:
        push_error("F8 did not open the form and pause gameplay")
        get_tree().quit(1)
        return
    marker._unhandled_key_input(f8)
    if marker.dialog.visible or get_tree().paused:
        push_error("F8 did not close the form and restore gameplay")
        get_tree().quit(1)
        return
    # An already paused game must remain paused after the form closes.
    get_tree().paused = true
    marker._unhandled_key_input(f8)
    marker._unhandled_key_input(f8)
    if not get_tree().paused:
        push_error("F8 incorrectly unpaused an already paused game")
        get_tree().quit(1)
        return
    get_tree().paused = false
    # A second report must append a suggestion with a distinct marker ID.
    marker.category.select(1)
    marker.notes.text = "QA suggestion test"
    marker._save_marker()
    if marker.marker_sequence != 2:
        push_error("Second report did not advance marker counter")
        get_tree().quit(1)
        return
    var appended := FileAccess.open(REPORT_PATH, FileAccess.READ)
    appended.seek(initial_size)
    var first = JSON.parse_string(appended.get_line())
    var second = JSON.parse_string(appended.get_line())
    appended.close()
    if not second is Dictionary or second.get("kind", "") != "suggestion" or second.get("description", "") != "QA suggestion test":
        push_error("Suggestion report was not appended correctly")
        get_tree().quit(1)
        return
    if first.get("marker_id", "") == second.get("marker_id", ""):
        push_error("Marker IDs are not unique within the session")
        get_tree().quit(1)
        return
    print("PLAYTEST_MARKER_SMOKE_OK")
    get_tree().quit(0)
