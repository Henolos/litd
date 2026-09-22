from tools.quality.control_center_snapshot import build_snapshot, derive_status


def test_waiting_ci_wins_for_active_checks():
    assert derive_status({"checks": [{"status": "in_progress"}]}) == "WAITING_CI"


def test_human_decision_is_explicit_blocker():
    assert derive_status({"needs_human": True, "checks": []}) == "BLOCKED_DECISION"


def test_failed_check_maps_to_retrying():
    assert derive_status({"checks": [{"status": "completed", "conclusion": "failure"}]}) == "FAILED_RETRYING"


def test_completion_requires_evidence():
    assert derive_status({"completed": True, "evidence_complete": True}) == "COMPLETED"
    assert derive_status({"completed": True, "evidence_complete": False}) == "RUNNING"


def test_snapshot_is_observational_and_counts_checks():
    snap = build_snapshot({
        "project": "LITD",
        "change_record": "CC-001",
        "phase": "verification",
        "current_action": "CI",
        "pr": 432,
        "head_sha": "a" * 40,
        "checks": [
            {"status": "completed", "conclusion": "success"},
            {"status": "in_progress", "conclusion": None},
        ],
        "needs_human": False,
        "updated_at": "2026-09-20T09:00:00+02:00",
    })
    assert snap["status"] == "WAITING_CI"
    assert snap["checks"] == {"passed": 1, "total": 2}
    assert snap["authority"] == "read_only_observation"
