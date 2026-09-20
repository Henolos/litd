from unittest.mock import patch

from tools.quality.control_center_github_collector import collect


@patch("tools.quality.control_center_github_collector._get")
def test_collects_exact_pr_head_and_runs(get):
    get.side_effect = [
        {"number": 438, "state": "open", "merged": False,
         "head": {"sha": "a"*40}, "updated_at": "2026-09-20T00:00:00Z"},
        {"workflow_runs": [{"id": 1, "name": "CI", "status": "completed", "conclusion": "success"}]},
    ]
    result = collect("Henolos/litd", 438, "token")
    assert result["pr"]["head_sha"] == "a"*40
    assert result["workflow_runs"][0]["name"] == "CI"
    assert result["source"] == "github_api_read_only"
    assert "head_sha=" + "a"*40 in get.call_args_list[1].args[0]


@patch("tools.quality.control_center_github_collector._get")
def test_collector_does_not_invent_evidence(get):
    get.side_effect = [
        {"number": 1, "state": "closed", "merged": True,
         "head": {"sha": "b"*40}, "updated_at": "now"},
        {"workflow_runs": []},
    ]
    result = collect("Henolos/litd", 1, "token")
    assert "evidence_complete" not in result
    assert "receipts" not in result
