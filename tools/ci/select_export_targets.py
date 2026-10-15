#!/usr/bin/env python3
"""Conservative export matrix: main/tags/manual always build every platform.

PRs reuse canonical Godot CI for ordinary game changes and do not
rebuild the release matrix. Export configuration and unknown changes
build every platform.
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path

ALL = (
    {"preset": "Web", "artifact": "light-in-the-dark-web", "path": "build/web"},
    {"preset": "Windows Desktop", "artifact": "light-in-the-dark-windows", "path": "build/windows"},
    {"preset": "Linux/X11", "artifact": "light-in-the-dark-linux", "path": "build/linux"},
)


def select(paths: list[str]) -> list[dict[str, str]]:
    if not paths:
        return list(ALL)
    for raw in paths:
        path = raw.strip().replace("\\", "/").lower()
        if (
            path in {"project.godot", "export_presets.cfg", ".github/workflows/build.yml",
                     "tools/ci/select_export_targets.py"}
            or path.startswith("addons/")
            or not path.startswith(("scripts/", "scenes/", "data/", "assets/"))
        ):
            return list(ALL)
    return []


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--all", action="store_true")
    parser.add_argument("--files-from", type=Path)
    parser.add_argument("--github-output", type=Path)
    args = parser.parse_args()
    if not args.all and args.files_from is None:
        parser.error("--files-from required for PR selection")
    files = [] if args.all else [p for p in args.files_from.read_text().splitlines() if p.strip()]
    targets = list(ALL) if args.all else select(files)
    # Matrix expressions cannot be empty. The job is skipped via build_any=false.
    matrix = json.dumps({"include": targets or list(ALL)}, separators=(",", ":"))
    if args.github_output:
        with args.github_output.open("a") as handle:
            handle.write("matrix=" + matrix + "\n")
            handle.write("build_any=" + str(bool(targets)).lower() + "\n")
            handle.write("selected=" + str(len(targets)) + "\n")
    print(matrix)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
