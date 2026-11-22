#!/usr/bin/env python3
"""Import approved guild NPC artwork from the supplied ZIP, verifying SHA-256."""
from __future__ import annotations
import argparse
import hashlib
import json
from pathlib import Path
from zipfile import ZipFile

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "assets/characters/guild_npcs/tavernier_medecin_sha256_manifest.json"

def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("archive", type=Path, help="LITD1_guilde_tavernier_medecin_assets_a_integrer.zip")
    args = parser.parse_args()
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    with ZipFile(args.archive) as archive:
        prepared = []
        for item in manifest["assets"]:
            target = ROOT / item["target_path"]
            filename = target.name
            payload = archive.read(filename)
            actual = hashlib.sha256(payload).hexdigest()
            if actual != item["sha256"] or len(payload) != item["bytes"]:
                raise SystemExit(f"INVALID HASH/SIZE: {filename}")
            if target.exists() and hashlib.sha256(target.read_bytes()).hexdigest() != actual:
                raise SystemExit(f"EXISTING FILE CONFLICT: {target}")
            prepared.append((target, payload))
        for target, payload in prepared:
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(payload)
            print(f"OK {target.relative_to(ROOT)} SHA256={hashlib.sha256(payload).hexdigest()}")
    print("Import local terminé. Vérifier git status puis committer les PNG sur la branche de PR.")

if __name__ == "__main__":
    main()
