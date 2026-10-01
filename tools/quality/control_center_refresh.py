#!/usr/bin/env python3
"""Refresh the Control Center snapshot from bounded read-only sources."""
from __future__ import annotations

import argparse
import json
import os
import urllib.request
from pathlib import Path
from typing import Any

from tools.quality.control_center_domain_catalog import collect as collect_domains
from tools.quality.control_center_github_collector import collect as collect_github
from tools.quality.control_center_memory_collector import collect as collect_memory
from tools.quality.control_center_snapshot_pipeline import build_snapshot

TITLE_PREFIX = "HENOLOS Control Center"


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


def resolve_latest_control_center_pr(repo: str, token: str) -> int:
    pulls = _get(
        f"https://api.github.com/repos/{repo}/pulls?state=all&sort=updated&direction=desc&per_page=100",
        token,
    )
    for pr in pulls:
        if str(pr.get("title", "")).startswith(TITLE_PREFIX):
            return int(pr["number"])
    raise RuntimeError("no Control Center pull request found")


def refresh(repo: str, token: str, root: str | Path = ".") -> dict[str, Any]:
    pr_number = resolve_latest_control_center_pr(repo, token)
    github = collect_github(repo, pr_number, token)
    memory = collect_memory(root)
    domains = collect_domains(root)
    snapshot = build_snapshot(
        github,
        memory,
        project="HENOLOS_CONTROL_CENTER",
        change_record=f"PR-{pr_number}",
        phase="verification",
    )
    snapshot["domain_catalog"] = domains
    snapshot["refresh"] = {
        "tracked_pr": pr_number,
        "mode": "scheduled_read_only",
    }
    return snapshot


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", default="reports/control-center-snapshot.json")
    args = parser.parse_args()
    result = refresh(
        os.environ["CONTROL_CENTER_REPOSITORY"],
        os.environ["GITHUB_TOKEN"],
    )
    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(json.dumps({"status": result["status"], "tracked_pr": result["refresh"]["tracked_pr"]}, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
