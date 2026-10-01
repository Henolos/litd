#!/usr/bin/env python3
"""Collect bounded read-only LITD operational signals for the Control Center."""
from __future__ import annotations

import json
import urllib.parse
import urllib.request
from typing import Any, Callable

LITD_SIGNAL_PATHS = (
    ".github/workflows/ci.yml",
    ".github/workflows/remanence-smoke.yml",
    ".github/workflows/godot-live-status.yml",
    ".github/workflows/veilleurs-playtest-readiness.yml",
    ".github/workflows/veilleurs-production-automation.yml",
    ".github/workflows/web-playtest-pages.yml",
)

_FAILURES = {"failure", "cancelled", "timed_out", "action_required", "startup_failure"}
_ACTIVE = {"queued", "in_progress", "waiting", "pending", "requested"}


def _get(url: str, token: str) -> Any:
    req = urllib.request.Request(
        url,
        headers={
            "Accept": "application/vnd.github+json",
            "Authorization": f"Bearer {token}",
            "X-GitHub-Api-Version": "2022-11-28",
            "User-Agent": "henolos-control-center",
        },
    )
    with urllib.request.urlopen(req, timeout=20) as response:
        return json.load(response)


def summarize(runs: list[dict[str, Any]], main_sha: str) -> dict[str, Any]:
    """Reduce GitHub Actions metadata to bounded LITD operational signals."""
    latest: dict[str, dict[str, Any]] = {}
    for run in runs:
        path = str(run.get("path", ""))
        if path not in LITD_SIGNAL_PATHS or path in latest:
            continue
        latest[path] = run

    signals: list[dict[str, Any]] = []
    has_active = False
    has_failure = False
    has_missing = False
    all_current = True

    for path in LITD_SIGNAL_PATHS:
        run = latest.get(path)
        if run is None:
            has_missing = True
            all_current = False
            signals.append(
                {
                    "path": path,
                    "name": None,
                    "status": "missing",
                    "conclusion": None,
                    "head_sha": None,
                    "event": None,
                    "created_at": None,
                    "on_current_main": False,
                }
            )
            continue

        status = str(run.get("status") or "")
        conclusion = run.get("conclusion")
        conclusion_text = str(conclusion) if conclusion is not None else None
        on_current = str(run.get("head_sha") or "") == main_sha
        all_current = all_current and on_current
        has_active = has_active or status in _ACTIVE
        has_failure = has_failure or (conclusion_text in _FAILURES)

        signals.append(
            {
                "path": path,
                "name": run.get("name"),
                "status": status or None,
                "conclusion": conclusion_text,
                "head_sha": run.get("head_sha"),
                "event": run.get("event"),
                "created_at": run.get("created_at"),
                "on_current_main": on_current,
            }
        )

    if has_active:
        overall = "RUNNING"
    elif has_failure:
        overall = "DEGRADED"
    elif has_missing:
        overall = "INCOMPLETE"
    elif all_current:
        overall = "HEALTHY_CURRENT"
    else:
        overall = "HEALTHY_LAST_KNOWN"

    return {
        "source": "github_actions_litd_read_only",
        "domain": "LITD",
        "status": overall,
        "main_sha": main_sha,
        "signals": signals,
        "signal_count": len(signals),
        "current_signal_count": sum(1 for signal in signals if signal["on_current_main"]),
        "contains_payload_data": False,
        "contains_secret_values": False,
        "mutation_authority": False,
        "authority": "observation_only",
    }


def collect(
    repo: str,
    token: str,
    *,
    getter: Callable[[str, str], Any] = _get,
) -> dict[str, Any]:
    """Read current main and recent Actions metadata without mutating GitHub."""
    quoted_repo = urllib.parse.quote(repo, safe="/")
    main = getter(f"https://api.github.com/repos/{quoted_repo}/commits/main", token)
    runs = getter(
        f"https://api.github.com/repos/{quoted_repo}/actions/runs?branch=main&per_page=100",
        token,
    )
    main_sha = str(main.get("sha") or "")
    if len(main_sha) != 40:
        raise ValueError("invalid main SHA")
    workflow_runs = runs.get("workflow_runs")
    if not isinstance(workflow_runs, list):
        raise ValueError("invalid workflow_runs payload")
    return summarize(workflow_runs, main_sha)
