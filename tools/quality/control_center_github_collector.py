#!/usr/bin/env python3
"""Read-only GitHub collector for Control Center source payloads."""
from __future__ import annotations

import json
import os
import urllib.request
from typing import Any


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


def collect(repo: str, pr_number: int, token: str) -> dict[str, Any]:
    base = f"https://api.github.com/repos/{repo}"
    pr = _get(f"{base}/pulls/{pr_number}", token)
    sha = pr["head"]["sha"]
    runs = _get(f"{base}/actions/runs?head_sha={sha}&event=pull_request&per_page=100", token)
    return {
        "pr": {
            "number": pr["number"],
            "state": pr["state"],
            "merged": bool(pr.get("merged")),
            "head_sha": sha,
            "updated_at": pr.get("updated_at"),
        },
        "workflow_runs": [
            {
                "id": run.get("id"),
                "name": run.get("name"),
                "status": run.get("status"),
                "conclusion": run.get("conclusion"),
            }
            for run in runs.get("workflow_runs", [])
        ],
        "source": "github_api_read_only",
    }


def main() -> int:
    repo = os.environ["CONTROL_CENTER_REPOSITORY"]
    pr_number = int(os.environ["CONTROL_CENTER_PR"])
    token = os.environ["GITHUB_TOKEN"]
    print(json.dumps(collect(repo, pr_number, token), sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
