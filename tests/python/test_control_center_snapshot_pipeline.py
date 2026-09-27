import pytest

from tools.quality.control_center_snapshot_pipeline import build_snapshot


def _github(*, merged=False, runs=None):
    return {
        "pr": {
            "number": 10,
            "state": "closed" if merged else "open",
            "merged": merged,
            "head_sha": "a" * 40,
            "updated_at": "2026-09-27T00:00:00Z",
        },
        "workflow_runs": runs or [],
        "source": "github_api_read_only",
    }


def _memory(receipts=None, registry=None):
    return {
        "closure_receipts": receipts or [],
        "registry_evidence": registry or [],
        "source": "repository_memory_read_only",
        "authority": "read_only_memory_collection",
    }


def test_pipeline_connects_both_read_only_sources():
    receipt = {
        "kind": "LITD_APPLICATION_CLOSURE_RECEIPT",
        "status": "APPLIED_MEASURED_PROVENANCE_VERIFIED",
        "closure_hash": "b" * 64,
        "blockers": [],
    }
    snapshot = build_snapshot(
        _github(merged=True),
        _memory([receipt], [{"id": "EVD-1"}]),
        project="LITD",
        change_record="CC-002",
    )

    assert snapshot["status"] == "COMPLETED"
    assert snapshot["last_evidence"] == "closure:" + "b" * 64
    assert snapshot["sources"] == {
        "github": "github_api_read_only",
        "memory": "repository_memory_read_only",
        "registry_evidence_count": 1,
    }
    assert snapshot["authority"] == "read_only_control_center_snapshot"


def test_pipeline_preserves_waiting_ci_without_memory_completion():
    snapshot = build_snapshot(
        _github(runs=[{"id": 1, "name": "CI", "status": "queued", "conclusion": None}]),
        _memory(),
        project="LITD",
    )
    assert snapshot["status"] == "WAITING_CI"
    assert snapshot["evidence"]["complete"] is False


@pytest.mark.parametrize(
    ("github_source", "memory_source"),
    [
        ({"source": "decorative"}, _memory()),
        (_github(), {"source": "decorative"}),
    ],
)
def test_pipeline_rejects_untrusted_source_labels(github_source, memory_source):
    with pytest.raises(ValueError):
        build_snapshot(github_source, memory_source, project="LITD")
