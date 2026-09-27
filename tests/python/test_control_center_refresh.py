import tools.quality.control_center_refresh as refresh


def test_resolves_latest_control_center_pr(monkeypatch):
    monkeypatch.setattr(
        refresh,
        "_get",
        lambda url, token: [
            {"number": 99, "title": "Unrelated change"},
            {"number": 42, "title": "HENOLOS Control Center — persistent refresh"},
            {"number": 41, "title": "HENOLOS Control Center — older"},
        ],
    )
    assert refresh.resolve_latest_control_center_pr("Henolos/litd", "token") == 42


def test_refresh_uses_only_read_only_collectors(monkeypatch, tmp_path):
    monkeypatch.setattr(refresh, "resolve_latest_control_center_pr", lambda repo, token: 42)
    monkeypatch.setattr(
        refresh,
        "collect_github",
        lambda repo, number, token: {
            "pr": {
                "number": number,
                "state": "open",
                "merged": False,
                "head_sha": "a" * 40,
                "updated_at": "now",
            },
            "workflow_runs": [],
            "source": "github_api_read_only",
        },
    )
    monkeypatch.setattr(
        refresh,
        "collect_memory",
        lambda root: {
            "closure_receipts": [],
            "registry_evidence": [],
            "source": "repository_memory_read_only",
        },
    )

    snapshot = refresh.refresh("Henolos/litd", "token", tmp_path)

    assert snapshot["refresh"] == {"tracked_pr": 42, "mode": "scheduled_read_only"}
    assert snapshot["authority"] == "read_only_control_center_snapshot"
    assert snapshot["status"] == "RUNNING"
