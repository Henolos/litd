extends SceneTree
## Headless smoke test for the F8 playtest report marker.
const MARKER_SCRIPT := preload("res://scripts/qa/playtest_issue_marker.gd")
const REPORT_PATH := "user://playtest_reports.jsonl"

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var marker := MARKER_SCRIPT.new()
    root.add_child(marker)
    await process_frame
    if marker.dialog == null or marker.category == null or marker.notes == null:
        push_error("Playtest marker form was not initialized")
        quit(1)
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
        quit(1)
        return
    var file := FileAccess.open(REPORT_PATH, FileAccess.READ)
    file.seek(initial_size)
    var line := file.get_line()
    file.close()
    var record = JSON.parse_string(line)
    if not record is Dictionary or record.get("description", "") != "QA smoke test" or record.get("kind", "") != "bug":
        push_error("Playtest report content invalid")
        quit(1)
        return
    if marker.marker_sequence != 1:
        push_error("Marker counter did not advance")
        quit(1)
        return
    print("PLAYTEST_MARKER_SMOKE_OK")
    quit(0)
