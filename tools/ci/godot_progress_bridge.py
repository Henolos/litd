#!/usr/bin/env python3
from __future__ import annotations

import json
import os
import re
import subprocess
import sys
import urllib.error
import urllib.request

PROGRESS_RE = re.compile(
    r"GODOT_PROGRESS step=(?P<step>\d+)/(?:\s*)?(?P<total>\d+) percent=(?P<percent>\d+) status=(?P<status>[A-Z]+) file=(?P<file>\S+)"
)


def post_status(state: str, description: str) -> None:
    token = os.getenv("GODOT_PROGRESS_TOKEN")
    repo = os.getenv("GITHUB_REPOSITORY")
    sha = os.getenv("GODOT_PROGRESS_SHA")
    target_url = os.getenv("GODOT_PROGRESS_TARGET_URL", "")
    if not token or not repo or not sha:
        return

    payload = {
        "state": state,
        "context": "godot-progress",
        "description": description[:140],
        "target_url": target_url,
    }
    request = urllib.request.Request(
        f"https://api.github.com/repos/{repo}/statuses/{sha}",
        data=json.dumps(payload).encode("utf-8"),
        headers={
            "Accept": "application/vnd.github+json",
            "Authorization": f"Bearer {token}",
            "X-GitHub-Api-Version": "2022-11-28",
            "User-Agent": "litd-godot-progress-bridge",
        },
        method="POST",
    )
    try:
        with urllib.request.urlopen(request, timeout=10):
            pass
    except (urllib.error.URLError, TimeoutError) as exc:
        print(f"GODOT_PROGRESS_BRIDGE_WARNING {exc}", file=sys.stderr, flush=True)


def state_for(status: str, percent: int) -> str:
    """Keep intermediate file completions pending; only global completion is success."""
    if status == "ERROR":
        return "failure"
    if status == "DONE" and percent >= 100:
        return "success"
    return "pending"


def main() -> int:
    command = ["bash", "tools/build/run_godot_ci.sh"]
    process = subprocess.Popen(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1,
    )

    last_progress = None
    assert process.stdout is not None
    for line in process.stdout:
        print(line, end="", flush=True)
        match = PROGRESS_RE.search(line)
        if not match:
            continue
        data = match.groupdict()
        last_progress = data
        description = (
            f"{data['step']}/{data['total']} {data['percent']}% "
            f"{data['status']} {data['file']}"
        )
        post_status(state_for(data["status"], int(data["percent"])), description)

    return_code = process.wait()
    if return_code == 0:
        if last_progress:
            post_status(
                "success",
                f"{last_progress['total']}/{last_progress['total']} 100% DONE Godot CI",
            )
        else:
            post_status("success", "Godot CI terminée")
    else:
        if last_progress:
            post_status(
                "failure",
                f"{last_progress['step']}/{last_progress['total']} ERROR {last_progress['file']}",
            )
        else:
            post_status("failure", f"Godot CI échouée (code {return_code})")
    return return_code


if __name__ == "__main__":
    raise SystemExit(main())
