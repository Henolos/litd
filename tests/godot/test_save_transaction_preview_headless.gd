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
    if failures == 0:
        print("SAVE_TRANSACTION_PREVIEW_PASS")
    quit(1 if failures else 0)
