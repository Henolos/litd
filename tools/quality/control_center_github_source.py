#!/usr/bin/env python3
"""Normalize read-only GitHub API payloads for the HENOLOS Control Center."""
from __future__ import annotations

from typing import Any

from tools.quality.control_center_snapshot import build_snapshot


def source_from_github(
    pr: dict[str, Any],
    workflow_runs: list[dict[str, Any]],
    *,
    project: str,
    change_record: str | None = None,
    phase: str = "verification",
    last_evidence: str | None = None,
    evidence_complete: bool = False,
    needs_human: bool = False,
    blocker: str | None = None,
) -> dict[str, Any]:
    """Map GitHub PR/workflow responses to the canonical observational source model."""
    checks = [
        {
            "name": run.get("name"),
            "status": run.get("status"),
            "conclusion": run.get("conclusion"),
            "run_id": run.get("id"),
        }
        for run in workflow_runs
    ]
    open_pr = pr.get("state") == "open" and pr.get("merged") is not True
    current_action = "waiting_for_ci" if any(c["status"] != "completed" for c in checks) else (
        "merge_review" if open_pr else "post_merge_evidence"
    )
    updated = pr.get("updated_at")
    return {
        "project": project,
        "change_record": change_record,
        "phase": phase,
        "current_action": current_action,
        "pr": pr.get("number"),
        "head_sha": pr.get("head_sha"),
        "checks": checks,
        "completed": pr.get("merged") is True,
        "evidence_complete": evidence_complete,
        "last_evidence": last_evidence,
        "blocker": blocker,
        "needs_human": needs_human,
        "updated_at": updated,
    }


def snapshot_from_github(pr: dict[str, Any], workflow_runs: list[dict[str, Any]], **context: Any) -> dict[str, Any]:
    return build_snapshot(source_from_github(pr, workflow_runs, **context))
