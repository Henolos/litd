#!/usr/bin/env python3
"""Import the six approved guild NPC image binaries from a local ZIP into a Git checkout.

Usage: python tools/import_guild_npc_assets.py /path/to/LITD1_guild_npcs_planches_portraits_SHA256.zip
Run from the repository root on the feature/guild-npcs-registration-20261122 branch.
Does not push, merge, or run Godot. All SHA-256 checks must pass before any write.
"""
from __future__ import annotations
import hashlib
import json
from pathlib import Path
import subprocess
import sys
from zipfile import ZipFile

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "assets/characters/guild_npcs/manifest.json"
BRANCH = "feature/guild-npcs-registration-20261122"

def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: python tools/import_guild_npc_assets.py <assets.zip>", file=sys.stderr)
        return 2
    branch = subprocess.run(["git", "branch", "--show-current"], cwd=ROOT, text=True, capture_output=True, check=True).stdout.strip()
    if branch != BRANCH:
        print(f"Refusing to write on branch {branch!r}; expected {BRANCH}", file=sys.stderr)
        return 2
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    entries = []
    for item in manifest["assets"]:
        entries.append((item["path"], item["sha256"]))
        portrait = item["portrait"]
        entries.append((portrait["path"], portrait["sha256"]))
    archive = Path(sys.argv[1])
    with ZipFile(archive) as z:
        verified = []
        for path, expected in entries:
            if path.startswith("/") or ".." in Path(path).parts:
                raise ValueError(f"Unsafe manifest path: {path}")
            payload = z.read(path)
            actual = hashlib.sha256(payload).hexdigest()
            if actual != expected:
                raise ValueError(f"SHA-256 mismatch: {path}: {actual} != {expected}")
            verified.append((path, payload))
    for path, payload in verified:
        destination = ROOT / path
        if destination.exists() and hashlib.sha256(destination.read_bytes()).hexdigest() != hashlib.sha256(payload).hexdigest():
            raise FileExistsError(f"Existing file differs; refusing overwrite: {destination}")
    for path, payload in verified:
        destination = ROOT / path
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(payload)
        print(f"OK {hashlib.sha256(payload).hexdigest()}  {path}")
    print("Six verified assets copied. Review git status; commit and push only after inspection.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
