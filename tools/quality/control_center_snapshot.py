#!/usr/bin/env python3
"""Derive a read-only HENOLOS Control Center snapshot from source state."""
from __future__ import annotations

from typing import Any

STATUSES = {"RUNNING", "WAITING_CI", "BLOCKED_DECISION", "COMPLETED", "FAILED_RETRYING"}


def derive_status(source: dict[str, Any]) -> str:
    if source.get("completed") is True and source.get("evidence_complete") is True:
        return "COMPLETED"
    if source.get("needs_human") is True:
        return "BLOCKED_DECISION"
    checks = source.get("checks") or []
    if any(c.get("status") in {"queued", "in_progress", "waiting", "pending", "requested"} for c in checks):
        return "WAITING_CI"
    if any(c.get("conclusion") in {"failure", "timed_out", "cancelled", "action_required", "startup_failure"} for c in checks):
        return "FAILED_RETRYING"
    return "RUNNING"


def build_snapshot(source: dict[str, Any]) -> dict[str, Any]:
    status = derive_status(source)
    checks = source.get("checks") or []
    passed = sum(c.get("conclusion") == "success" for c in checks)
    return {
        "project": source.get("project"),
        "change_record": source.get("change_record"),
        "phase": source.get("phase"),
        "current_action": source.get("current_action"),
        "status": status,
        "pr": source.get("pr"),
        "head_sha": source.get("head_sha"),
        "checks": {"passed": passed, "total": len(checks)},
        "last_evidence": source.get("last_evidence"),
        "blocker": source.get("blocker"),
        "needs_human": bool(source.get("needs_human")),
        "updated_at": source.get("updated_at"),
        "authority": "read_only_observation",
    }
