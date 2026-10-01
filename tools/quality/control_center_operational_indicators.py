#!/usr/bin/env python3
"""Collect bounded read-only operational indicators from GitHub Actions metadata."""
from __future__ import annotations

import json
import urllib.request
from typing import Any, Callable

PROBES = (
    ("LITD", "Veilleurs Playtest Readiness"),
    ("LITD", "Veilleurs Maturity Dashboard"),
    ("LITD", "Godot Live Status"),
    ("HENOLOS_BUSINESS", "HENOLOS Business Governance Binding"),
    ("HENOLOS_INFRASTRUCTURE", "HENOLOS Infrastructure Governance Binding"),
    ("SECURITY_COMPLIANCE", "Guardian Change Gate Contract"),
    ("SECURITY_COMPLIANCE", "Repository Governance Audit"),
    ("VEILLEURS_KNOWLEDGE", "Veilleur Autonomous Discovery"),
)


def _get(url: str, token: str) -> Any:
    request = urllib.request.Request(
        url,
        headers={
            "Accept": "application/vnd.github+json",
            "Authorization": f"Bearer {token}",
            "X-GitHub-Api-Version": "2022-11-28",
            "User-Agent": "henolos-control-center-indicators",
        },
    )
    with urllib.request.urlopen(request, timeout=20) as response:
        return json.load(response)


def _evidence_state(run: dict[str, Any] | None) -> str:
    if run is None:
        return "NO_EVIDENCE"
    status = str(run.get("status", "")).lower()
    conclusion = run.get("conclusion")
    if status != "completed":
        return "RUNNING"
    return "PASS" if conclusion == "success" else "FAIL"


def collect_from_runs(runs: list[dict[str, Any]]) -> dict[str, Any]:
    latest: dict[str, dict[str, Any]] = {}
    for run in runs:
        name = str(run.get("name", ""))
        if name and name not in latest:
            latest[name] = run

    indicators: list[dict[str, Any]] = []
    for view_id, workflow_name in PROBES:
        run = latest.get(workflow_name)
        indicators.append(
            {
                "view_id": view_id,
                "signal": workflow_name,
                "evidence_state": _evidence_state(run),
                "run_id": None if run is None else run.get("id"),
                "event": None if run is None else run.get("event"),
                "head_branch": None if run is None else run.get("head_branch"),
                "head_sha": None if run is None else run.get("head_sha"),
                "created_at": None if run is None else run.get("created_at"),
                "updated_at": None if run is None else run.get("updated_at"),
                "conclusion": None if run is None else run.get("conclusion"),
            }
        )

    return {
        "source": "github_actions_latest_run_read_only",
        "semantics": "latest_workflow_evidence_not_domain_health",
        "authority": "observation_only",
        "indicators": indicators,
    }


def collect(
    repo: str,
    token: str,
    *,
    getter: Callable[[str, str], Any] = _get,
) -> dict[str, Any]:
    payload = getter(
        f"https://api.github.com/repos/{repo}/actions/runs?per_page=100",
        token,
    )
    runs = payload.get("workflow_runs", []) if isinstance(payload, dict) else []
    if not isinstance(runs, list):
        raise ValueError("workflow_runs must be a list")
    return collect_from_runs(runs)
