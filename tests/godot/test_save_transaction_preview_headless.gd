extends SceneTree

var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool, message: String) -> void:
    if not ok:
        failures += 1
        push_error(message)

func _run() -> void:
    var manager := root.get_node("SaveManager")
    var before := {"heroes": [{"id": "hero-a", "alive": true}], "gold": 5}
    var after := {"heroes": [{"id": "hero-a", "alive": false}], "gold": 8}
    var record := {
        "campaign_id": "campaign-1",
        "transaction_id": "action-42",
        "base_revision": 3,
        "current_revision": 3,
        "result_revision": 4,
        "pre_state_sha256": manager.canonical_sha256("campaign-1", 3, before),
        "post_state_sha256": manager.canonical_sha256("campaign-1", 4, after),
        "result_state": after
    }
    var preview: Dictionary = manager.preview_committed_transaction(before, record, [])
    _check(not preview.is_empty(), "Coherent transaction must preview successfully")
    _check(preview.get("revision", -1) == 4, "Revision must advance")
    _check(preview.get("persistent_state", {}) == after, "Whole resolved state must be preserved")
    _check(preview.get("applied_transaction_ids", []) == ["action-42"], "Transaction id must be recorded")
    _check(before["heroes"][0]["alive"], "Preview must not mutate the original state")
    preview["persistent_state"]["gold"] = 999
    _check(after["gold"] == 8, "Preview must copy the result state")
    _check(manager.preview_committed_transaction(before, record, ["action-42"]).is_empty(), "Duplicate transaction must be rejected")
    var altered := record.duplicate(true)
    altered["post_state_sha256"] = "0".repeat(64)
    _check(manager.preview_committed_transaction(before, altered, []).is_empty(), "Post-state corruption must be rejected")
    altered = record.duplicate(true)
    altered["pre_state_sha256"] = "0".repeat(64)
    _check(manager.preview_committed_transaction(before, altered, []).is_empty(), "Pre-state corruption must be rejected")
    altered = record.duplicate(true)
    altered["result_revision"] = 5
    _check(manager.preview_committed_transaction(before, altered, []).is_empty(), "Revision gaps must be rejected")
    altered = record.duplicate(true)
    altered["current_revision"] = 2
    _check(manager.preview_committed_transaction(before, altered, []).is_empty(), "Stale current revision must be rejected")
    altered = record.duplicate(true)
    altered["result_state"] = {"metadata": {"timestamp": "volatile"}}
    _check(manager.preview_committed_transaction(before, altered, []).is_empty(), "Transient data must be rejected")
    altered = record.duplicate(true)
    altered["transaction_id"] = ""
    _check(manager.preview_committed_transaction(before, altered, []).is_empty(), "Missing transaction identity must be rejected")
    var sandbox := OS.get_environment("LITD_SAVE_TEST_SANDBOX")
    var normalized_sandbox := sandbox.replace("\\", "/").trim_suffix("/")
    var normalized_user_data := OS.get_user_data_dir().replace("\\", "/")
    if sandbox.is_empty() or sandbox != OS.get_environment("XDG_DATA_HOME") or not normalized_user_data.begins_with(normalized_sandbox + "/"):
        _check(false, "Journal tests require isolated user data root")
        quit(1)
        return
    var journal_dir := "user://litd_transaction_lab/ci_fixture"
    _check(manager.journal_append_preview(journal_dir, before, record, []), "Journal must write a verified revision")
    _check(not manager.journal_append_preview(journal_dir, before, record, []), "Journal must not overwrite an existing revision")
    # Interrupt every append and recovery boundary in the preview journal.
    var write_stages := ["before_open", "after_open", "during_store", "after_store", "after_flush", "before_rename", "after_rename"]
    for stage: String in write_stages:
        var stage_dir := "user://litd_transaction_lab/write_" + stage
        _check(DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(stage_dir)) == OK, "Create write-stage fixture: " + stage)
        _check(not manager.journal_append_preview(stage_dir, before, record, [], stage), "Injected write interruption must stop at " + stage)
        var stage_recovery: Dictionary = manager.journal_recover_preview(stage_dir, "campaign-1", 3, before)
        if stage == "after_rename":
            _check(stage_recovery.get("revision") == 4 and stage_recovery.get("persistent_state") == after, "Post-rename interruption must recover committed record")
            var repeat_recovery: Dictionary = manager.journal_recover_preview(stage_dir, "campaign-1", 3, before)
            _check(repeat_recovery == stage_recovery, "Repeated recovery must be deterministic after " + stage)
        else:
            _check(stage_recovery.get("revision") == 3 and stage_recovery.get("persistent_state") == before, "Pre-commit interruption must preserve base state at " + stage)
        var stage_files := DirAccess.get_files_at(stage_dir)
        for stage_file: String in stage_files:
            _check(DirAccess.remove_absolute(ProjectSettings.globalize_path(stage_dir.path_join(stage_file))) == OK, "Remove write-stage artifact: " + stage_file)
        _check(DirAccess.remove_absolute(ProjectSettings.globalize_path(stage_dir)) == OK, "Remove write-stage fixture: " + stage)
    # A committed entry must fail closed at each recovery boundary, then recover
    # identically when the interrupted read is retried from its original base.
    var recovery_stage_dir := "user://litd_transaction_lab/recovery_stages"
    _check(DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(recovery_stage_dir)) == OK, "Create recovery-stage fixture")
    _check(manager.journal_append_preview(recovery_stage_dir, before, record, []), "Create recovery-stage committed entry")
    var recovery_stages := ["after_read", "after_checksum", "after_decode", "before_apply", "after_apply"]
    for recovery_stage: String in recovery_stages:
        _check(manager.journal_recover_preview(recovery_stage_dir, "campaign-1", 3, before, recovery_stage).is_empty(), "Injected recovery interruption must fail closed at " + recovery_stage)
        var retried: Dictionary = manager.journal_recover_preview(recovery_stage_dir, "campaign-1", 3, before)
        _check(retried.get("revision") == 4 and retried.get("persistent_state") == after and retried.get("applied_transaction_ids") == ["action-42"], "Recovery retry must produce the same committed result after " + recovery_stage)
    for recovery_file: String in DirAccess.get_files_at(recovery_stage_dir):
        _check(DirAccess.remove_absolute(ProjectSettings.globalize_path(recovery_stage_dir.path_join(recovery_file))) == OK, "Remove recovery-stage artifact")
    _check(DirAccess.remove_absolute(ProjectSettings.globalize_path(recovery_stage_dir)) == OK, "Remove recovery-stage fixture")
    # Simulate process stops during journal write and during recovery. A pending
    # temp file is never a committed revision; a truncated committed file fails closed.
    var interrupted_dir := "user://litd_transaction_lab/interrupted"
    _check(DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(interrupted_dir)) == OK, "Create interruption fixture")
    var interrupted_pending := interrupted_dir.path_join("revision_0000000004.json.pending")
    var pending_file := FileAccess.open(interrupted_pending, FileAccess.WRITE)
    if pending_file != null:
        pending_file.store_string("partial")
        pending_file.close()
    var before_recovery: Dictionary = manager.journal_recover_preview(interrupted_dir, "campaign-1", 3, before)
    _check(before_recovery.get("revision") == 3 and before_recovery.get("persistent_state") == before, "Interrupted write must recover only the last committed base")
    _check(DirAccess.remove_absolute(ProjectSettings.globalize_path(interrupted_pending)) == OK, "Remove interrupted pending file")
    _check(manager.journal_append_preview(interrupted_dir, before, record, []), "Retry after interrupted write must commit")
    var interrupted_path := interrupted_dir.path_join("revision_0000000004.json")
    var committed_text := FileAccess.get_file_as_string(interrupted_path)
    var damaged_file := FileAccess.open(interrupted_path, FileAccess.WRITE)
    if damaged_file != null:
        damaged_file.store_string(committed_text.left(maxi(1, committed_text.length() / 2)))
        damaged_file.close()
    _check(manager.journal_recover_preview(interrupted_dir, "campaign-1", 3, before).is_empty(), "Interrupted recovery read must fail closed on truncated committed record")
    var repair_file := FileAccess.open(interrupted_path, FileAccess.WRITE)
    if repair_file != null:
        repair_file.store_string(committed_text)
        repair_file.close()
    var resumed: Dictionary = manager.journal_recover_preview(interrupted_dir, "campaign-1", 3, before)
    _check(resumed.get("revision") == 4 and resumed.get("persistent_state") == after, "Recovery retry must resume from the intact committed record")
    _check(DirAccess.remove_absolute(ProjectSettings.globalize_path(interrupted_path)) == OK, "Clean interrupted journal record")
    _check(DirAccess.remove_absolute(ProjectSettings.globalize_path(interrupted_dir)) == OK, "Clean interruption fixture")
    var recovered: Dictionary = manager.journal_recover_preview(journal_dir, "campaign-1", 3, before)
    _check(recovered.get("revision") == 4, "Recovery must advance to committed revision")
    _check(recovered.get("persistent_state") == after, "Recovery must restore resolved state")
    _check(recovered.get("applied_transaction_ids") == ["action-42"], "Recovery must retain transaction IDs")
    _check(manager.journal_recover_preview(journal_dir, "campaign-wrong", 3, before).is_empty(), "Wrong campaign must be rejected")
    var journal_path := journal_dir.path_join("revision_0000000004.json")
    var original_text := FileAccess.get_file_as_string(journal_path)
    var corrupted := FileAccess.open(journal_path, FileAccess.WRITE)
    if corrupted != null:
        corrupted.store_string(original_text + "corruption")
        corrupted.close()
    _check(manager.journal_recover_preview(journal_dir, "campaign-1", 3, before).is_empty(), "Corrupt journal must be rejected")
    var restored_file := FileAccess.open(journal_path, FileAccess.WRITE)
    if restored_file != null:
        restored_file.store_string(original_text)
        restored_file.close()
    _check(manager.journal_recover_preview(journal_dir, "campaign-1", 3, before).get("revision") == 4, "Restored journal must recover")
    _check(DirAccess.remove_absolute(ProjectSettings.globalize_path(journal_path)) == OK, "Test journal cleanup")
    _check(DirAccess.remove_absolute(ProjectSettings.globalize_path(journal_dir)) == OK, "Test directory cleanup")
    if failures == 0:
        print("SAVE_TRANSACTION_PREVIEW_PASS")
    quit(1 if failures else 0)
