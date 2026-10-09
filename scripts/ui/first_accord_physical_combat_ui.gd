extends "res://scripts/ui/veilleurs_vertical_slice_qa_v09.gd"

# Reuse canonical tactical controls and resolution without starting another run.
const SUBMISSION_CONTROL := preload("res://scripts/ui/veilleurs_submission_control_v09.gd")
signal encounter_finished(result: Dictionary)

var submission_control: VeilleursSubmissionControlV09

func _ready() -> void:
    _build_shell()
    slice = VeilleursRuntime.runtime
    submission_control = SUBMISSION_CONTROL.new() as VeilleursSubmissionControlV09
    submission_control.name = "SubmissionControl"
    add_child(submission_control)
    for button: Button in find_children("*", "Button", true, false):
        if button.text in DUNGEONS.values() or button.text in ["Reprendre", "Retour QA"]:
            button.hide()
    room_view.hide()
    room_events_label.hide()
    status_label.text = "Premier Accord · " + slice.campaign.dungeon.current_node.replace("_", " ")
    _repair_selection()
    _refresh_combat()

func _on_save() -> void:
    message_label.text = "Partie sauvegardée." if SaveManager.save_game() else "Échec de sauvegarde."

func _render_node() -> void:
    # Parent _finish_combat has already applied campaign and Rémanence results.
    if slice != null and slice.combat == null:
        encounter_finished.emit(slice.last_resolution.duplicate(true))
