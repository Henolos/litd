from tools.quality.control_center_github_source import snapshot_from_github, source_from_github


PR = {
    "number": 433,
    "state": "open",
    "merged": False,
    "head_sha": "a" * 40,
    "updated_at": "2026-09-20T09:00:00Z",
}


def test_real_github_shape_waiting_ci():
    source = source_from_github(
        PR,
        [{"id": 1, "name": "CI", "status": "in_progress", "conclusion": None}],
        project="HENOLOS_GLOBAL_GOVERNANCE",
    )
    assert source["current_action"] == "waiting_for_ci"
    assert source["checks"][0]["run_id"] == 1
    assert source["head_sha"] == "a" * 40


def test_all_green_open_pr_moves_to_merge_review():
    snap = snapshot_from_github(
        PR,
        [{"id": 1, "name": "CI", "status": "completed", "conclusion": "success"}],
        project="HENOLOS_GLOBAL_GOVERNANCE",
    )
    assert snap["status"] == "RUNNING"
    assert snap["current_action"] == "merge_review"
    assert snap["checks"] == {"passed": 1, "total": 1}


def test_merged_is_not_complete_without_governance_evidence():
    merged = {**PR, "state": "closed", "merged": True}
    snap = snapshot_from_github(
        merged, [], project="LITD", evidence_complete=False
    )
    assert snap["status"] == "RUNNING"
    assert snap["current_action"] == "post_merge_evidence"


def test_merged_with_evidence_can_close():
    merged = {**PR, "state": "closed", "merged": True}
    snap = snapshot_from_github(
        merged, [], project="LITD", evidence_complete=True, last_evidence="receipt:abc"
    )
    assert snap["status"] == "COMPLETED"
    assert snap["last_evidence"] == "receipt:abc"
