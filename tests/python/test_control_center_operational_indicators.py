from tools.quality.control_center_operational_indicators import collect, collect_from_runs


def test_collects_only_allowlisted_latest_workflow_evidence():
    runs = [
        {
            "id": 10,
            "name": "Veilleurs Playtest Readiness",
            "status": "completed",
            "conclusion": "success",
            "event": "push",
            "head_branch": "main",
            "head_sha": "a" * 40,
            "created_at": "2026-10-01T10:00:00Z",
            "updated_at": "2026-10-01T10:01:00Z",
        },
        {
            "id": 9,
            "name": "Veilleurs Playtest Readiness",
            "status": "completed",
            "conclusion": "failure",
            "event": "push",
            "head_branch": "main",
            "head_sha": "b" * 40,
            "created_at": "2026-10-01T09:00:00Z",
            "updated_at": "2026-10-01T09:01:00Z",
        },
        {
            "id": 8,
            "name": "Repository Governance Audit",
            "status": "in_progress",
            "conclusion": None,
            "event": "schedule",
            "head_branch": "main",
            "head_sha": "c" * 40,
            "created_at": "2026-10-01T08:00:00Z",
            "updated_at": "2026-10-01T08:00:30Z",
        },
        {"id": 7, "name": "Unrelated Workflow", "status": "completed", "conclusion": "success"},
    ]

    result = collect_from_runs(runs)
    by_signal = {row["signal"]: row for row in result["indicators"]}

    assert result["source"] == "github_actions_latest_run_read_only"
    assert result["semantics"] == "latest_workflow_evidence_not_domain_health"
    assert result["authority"] == "observation_only"
    assert by_signal["Veilleurs Playtest Readiness"]["evidence_state"] == "PASS"
    assert by_signal["Veilleurs Playtest Readiness"]["run_id"] == 10
    assert by_signal["Repository Governance Audit"]["evidence_state"] == "RUNNING"
    assert by_signal["HENOLOS Business Governance Binding"]["evidence_state"] == "NO_EVIDENCE"
    assert "Unrelated Workflow" not in by_signal


def test_failed_completed_run_is_failure_evidence():
    result = collect_from_runs([
        {
            "id": 22,
            "name": "Veilleur Autonomous Discovery",
            "status": "completed",
            "conclusion": "failure",
        }
    ])
    row = next(x for x in result["indicators"] if x["signal"] == "Veilleur Autonomous Discovery")
    assert row["view_id"] == "VEILLEURS_KNOWLEDGE"
    assert row["evidence_state"] == "FAIL"


def test_collector_uses_read_only_actions_endpoint():
    seen = {}

    def getter(url, token):
        seen["url"] = url
        seen["token"] = token
        return {"workflow_runs": []}

    result = collect("Henolos/litd", "token", getter=getter)
    assert seen["url"] == "https://api.github.com/repos/Henolos/litd/actions/runs?per_page=100"
    assert seen["token"] == "token"
    assert result["authority"] == "observation_only"
