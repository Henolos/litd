#!/usr/bin/env python3
"""Plan and safely apply Trieur archival moves.

Default mode is dry-run. Applying an archive requires all guardrails:
- entry status must already be archived;
- entry must opt in with archive_enabled=true and provide archive_target;
- archive_target must stay under archive_root;
- destination must not already exist;
- apply is forbidden on main/master;
- TRIEUR_ARCHIVE_ACK must equal I_UNDERSTAND_ARCHIVE_MOVE;
- copied bytes are SHA-256 verified before the source is removed;
- this tool never permanently deletes content: it only moves it under archive/.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
POLICY_FILE = ROOT / "governance" / "trieur_policy.json"
ACK = "I_UNDERSTAND_ARCHIVE_MOVE"


def fail(message: str) -> None:
    print(f"TRIEUR_ARCHIVE_ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)


def load_policy() -> dict:
    try:
        data = json.loads(POLICY_FILE.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        fail(f"cannot load policy: {exc}")
    if not isinstance(data, dict):
        fail("policy must be a JSON object")
    return data


def current_branch() -> str:
    env_ref = os.getenv("GITHUB_REF_NAME", "").strip()
    if env_ref:
        return env_ref
    try:
        return subprocess.check_output(
            ["git", "branch", "--show-current"], cwd=ROOT, text=True
        ).strip()
    except Exception:
        return "unknown"


def resolved_inside(path: Path, parent: Path) -> bool:
    try:
        path.resolve().relative_to(parent.resolve())
        return True
    except ValueError:
        return False


def file_hash(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def tree_hash(path: Path) -> str:
    if path.is_file():
        return file_hash(path)
    digest = hashlib.sha256()
    for child in sorted(p for p in path.rglob("*") if p.is_file()):
        digest.update(str(child.relative_to(path)).encode("utf-8"))
        digest.update(file_hash(child).encode("ascii"))
    return digest.hexdigest()


def archive_candidates(policy: dict) -> list[tuple[str, Path, Path]]:
    archive_root = ROOT / str(policy.get("archive_root", "archive"))
    entries = policy.get("entries", [])
    if not isinstance(entries, list):
        fail("entries must be a list")

    candidates: list[tuple[str, Path, Path]] = []
    for entry in entries:
        if not isinstance(entry, dict):
            continue
        if entry.get("status") != "archived" or entry.get("archive_enabled") is not True:
            continue

        entry_id = str(entry.get("id", "")).strip()
        source_text = str(entry.get("path", "")).strip()
        target_text = str(entry.get("archive_target", "")).strip()
        if not entry_id or not source_text or not target_text:
            fail("archived opt-in entries require id, path and archive_target")

        source = ROOT / source_text
        target = ROOT / target_text
        if not source.exists():
            fail(f"{entry_id}: source does not exist: {source_text}")
        if not resolved_inside(source, ROOT):
            fail(f"{entry_id}: source escapes repository root")
        if not resolved_inside(target, archive_root):
            fail(f"{entry_id}: archive_target must be under {archive_root.relative_to(ROOT)}")
        if target.exists():
            fail(f"{entry_id}: archive destination already exists: {target_text}")
        if source.resolve() == target.resolve():
            fail(f"{entry_id}: source and target are identical")
        candidates.append((entry_id, source, target))
    return candidates


def apply_move(entry_id: str, source: Path, target: Path) -> None:
    before = tree_hash(source)
    target.parent.mkdir(parents=True, exist_ok=True)

    if source.is_dir():
        shutil.copytree(source, target)
    else:
        shutil.copy2(source, target)

    after = tree_hash(target)
    if before != after:
        if target.is_dir():
            shutil.rmtree(target)
        else:
            target.unlink(missing_ok=True)
        fail(f"{entry_id}: integrity verification failed; copied target rolled back")

    if source.is_dir():
        shutil.rmtree(source)
    else:
        source.unlink()
    print(f"ARCHIVED {entry_id}: {source.relative_to(ROOT)} -> {target.relative_to(ROOT)} sha256={after}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--apply", action="store_true", help="perform guarded archive moves")
    args = parser.parse_args()

    policy = load_policy()
    candidates = archive_candidates(policy)

    if not candidates:
        print("TRIEUR_ARCHIVE_OK: no archive-enabled entries to move.")
        return

    for entry_id, source, target in candidates:
        print(f"PLAN {entry_id}: {source.relative_to(ROOT)} -> {target.relative_to(ROOT)}")

    if not args.apply:
        print(f"TRIEUR_ARCHIVE_DRY_RUN: {len(candidates)} guarded move(s) planned; nothing changed.")
        return

    branch = current_branch().lower()
    if branch in {"main", "master"}:
        fail("archive apply is forbidden on main/master; use a dedicated branch and PR")
    if os.getenv("TRIEUR_ARCHIVE_ACK") != ACK:
        fail(f"archive apply requires TRIEUR_ARCHIVE_ACK={ACK}")

    for entry_id, source, target in candidates:
        apply_move(entry_id, source, target)

    print(f"TRIEUR_ARCHIVE_APPLIED: {len(candidates)} move(s) completed with integrity verification.")


if __name__ == "__main__":
    main()
