#!/usr/bin/env python3
"""Plan and safely apply Trieur archival moves with registry consistency."""
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


def save_policy(policy: dict) -> None:
    temp = POLICY_FILE.with_suffix(".json.tmp")
    text = json.dumps(policy, ensure_ascii=False, indent=2) + "\n"
    temp.write_text(text, encoding="utf-8")
    os.replace(temp, POLICY_FILE)


def current_branch() -> str:
    env_ref = os.getenv("GITHUB_REF_NAME", "").strip()
    if env_ref:
        return env_ref
    try:
        return subprocess.check_output(["git", "branch", "--show-current"], cwd=ROOT, text=True).strip()
    except Exception:
        return "unknown"


def resolved_inside(path: Path, parent: Path) -> bool:
    try:
        path.resolve().relative_to(parent.resolve())
        return True
    except ValueError:
        return False


def reject_symlinks(entry_id: str, source: Path) -> None:
    if source.is_symlink():
        fail(f"{entry_id}: symlink sources are forbidden")
    if source.is_dir():
        for child in source.rglob("*"):
            if child.is_symlink():
                fail(f"{entry_id}: symlink inside archive source is forbidden: {child.relative_to(ROOT)}")


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


def archive_candidates(policy: dict) -> list[tuple[int, str, Path, Path]]:
    archive_root = ROOT / str(policy.get("archive_root", "archive"))
    entries = policy.get("entries", [])
    if not isinstance(entries, list):
        fail("entries must be a list")

    candidates: list[tuple[int, str, Path, Path]] = []
    for index, entry in enumerate(entries):
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
        reject_symlinks(entry_id, source)
        candidates.append((index, entry_id, source, target))
    return candidates


def remove_path(path: Path) -> None:
    if path.is_dir():
        shutil.rmtree(path)
    else:
        path.unlink()


def restore_path(target: Path, source: Path) -> None:
    source.parent.mkdir(parents=True, exist_ok=True)
    shutil.move(str(target), str(source))


def apply_move(policy: dict, index: int, entry_id: str, source: Path, target: Path) -> None:
    before = tree_hash(source)
    source_rel = str(source.relative_to(ROOT))
    target_rel = str(target.relative_to(ROOT))
    target.parent.mkdir(parents=True, exist_ok=True)

    if source.is_dir():
        shutil.copytree(source, target)
    else:
        shutil.copy2(source, target)

    after = tree_hash(target)
    if before != after:
        remove_path(target)
        fail(f"{entry_id}: integrity verification failed; copied target rolled back")

    remove_path(source)

    entry = policy["entries"][index]
    previous = dict(entry)
    entry["previous_path"] = source_rel
    entry["path"] = target_rel
    entry["archive_state"] = "moved"
    entry["archive_enabled"] = False
    entry["archived_sha256"] = after

    try:
        save_policy(policy)
    except Exception as exc:
        policy["entries"][index] = previous
        try:
            restore_path(target, source)
        except Exception as rollback_exc:
            fail(f"{entry_id}: registry update failed ({exc}) and filesystem rollback also failed ({rollback_exc})")
        fail(f"{entry_id}: registry update failed; archive move rolled back: {exc}")

    print(f"ARCHIVED {entry_id}: {source_rel} -> {target_rel} sha256={after}; registry updated")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--apply", action="store_true", help="perform guarded archive moves")
    args = parser.parse_args()

    policy = load_policy()
    candidates = archive_candidates(policy)

    if not candidates:
        print("TRIEUR_ARCHIVE_OK: no archive-enabled entries to move.")
        return

    for _, entry_id, source, target in candidates:
        print(f"PLAN {entry_id}: {source.relative_to(ROOT)} -> {target.relative_to(ROOT)}")

    if not args.apply:
        print(f"TRIEUR_ARCHIVE_DRY_RUN: {len(candidates)} guarded move(s) planned; nothing changed.")
        return

    branch = current_branch().lower()
    if branch in {"main", "master"}:
        fail("archive apply is forbidden on main/master; use a dedicated branch and PR")
    if os.getenv("TRIEUR_ARCHIVE_ACK") != ACK:
        fail(f"archive apply requires TRIEUR_ARCHIVE_ACK={ACK}")

    for index, entry_id, source, target in candidates:
        apply_move(policy, index, entry_id, source, target)

    print(f"TRIEUR_ARCHIVE_APPLIED: {len(candidates)} move(s) completed with integrity verification and registry updates.")


if __name__ == "__main__":
    main()
