#!/usr/bin/env python3
"""Validate LITD Trieur lifecycle governance policy."""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
POLICY_FILE = ROOT / "governance" / "trieur_policy.json"
TEXT_EXTENSIONS = {".json", ".gd", ".tscn", ".tres", ".cfg", ".ini", ".txt", ".csv", ".yaml", ".yml"}


def fail(message: str) -> None:
    print(f"TRIEUR_GOVERNANCE_ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)


def load_policy() -> dict:
    try:
        payload = json.loads(POLICY_FILE.read_text(encoding="utf-8"))
    except FileNotFoundError:
        fail("missing governance/trieur_policy.json")
    except json.JSONDecodeError as exc:
        fail(f"invalid trieur policy JSON: {exc}")
    if not isinstance(payload, dict):
        fail("trieur policy must be a JSON object")
    return payload


def resolved_inside(path: Path, parent: Path) -> bool:
    try:
        path.resolve().relative_to(parent.resolve())
        return True
    except ValueError:
        return False


def validate_relative_repo_path(entry_id: str, raw_path: str) -> Path:
    candidate = Path(raw_path)
    if candidate.is_absolute():
        fail(f"entry {entry_id} path must be relative: {raw_path}")
    resolved = ROOT / candidate
    if not resolved_inside(resolved, ROOT):
        fail(f"entry {entry_id} path escapes repository root: {raw_path}")
    return resolved


def validate_replacement_graph(entries_by_id: dict[str, dict], rules: dict) -> None:
    if rules.get("replacement_must_exist", True):
        for entry_id, entry in entries_by_id.items():
            replacement = str(entry.get("replaced_by", "")).strip()
            if replacement and replacement not in entries_by_id:
                fail(f"entry {entry_id} replaced_by references unknown entry: {replacement}")
            if replacement == entry_id:
                fail(f"entry {entry_id} cannot replace itself")

    if not rules.get("replacement_cycles_forbidden", True):
        return

    for start in entries_by_id:
        seen: set[str] = set()
        current = start
        while current:
            if current in seen:
                chain = " -> ".join([*seen, current])
                fail(f"replacement cycle detected from {start}: {chain}")
            seen.add(current)
            replacement = str(entries_by_id.get(current, {}).get("replaced_by", "")).strip()
            if not replacement or replacement not in entries_by_id:
                break
            current = replacement


def validate_archive_fields(entry_id: str, entry: dict, archive_root: Path, rules: dict) -> None:
    status = str(entry.get("status", "")).strip()
    enabled = entry.get("archive_enabled") is True
    target_text = str(entry.get("archive_target", "")).strip()
    archive_state = str(entry.get("archive_state", "")).strip()

    if enabled and status != "archived":
        fail(f"entry {entry_id} enables archive while status is {status!r}, expected 'archived'")

    if enabled and rules.get("archive_requires_target", True) and not target_text:
        fail(f"entry {entry_id} enables archive but has no archive_target")

    if target_text:
        target = validate_relative_repo_path(entry_id, target_text)
        if rules.get("archive_target_must_be_under_archive_root", True) and not resolved_inside(target, archive_root):
            fail(f"entry {entry_id} archive_target must be under {archive_root.relative_to(ROOT)}")

    if archive_state and archive_state not in {"planned", "moved"}:
        fail(f"entry {entry_id} has unsupported archive_state: {archive_state}")

    if archive_state == "moved":
        if status != "archived":
            fail(f"entry {entry_id} archive_state=moved requires status=archived")
        path_text = str(entry.get("path", "")).strip()
        path = validate_relative_repo_path(entry_id, path_text)
        if rules.get("archived_must_live_under_archive_root_when_moved", True) and not resolved_inside(path, archive_root):
            fail(f"entry {entry_id} marked moved but path is outside archive root: {path_text}")
        if enabled:
            fail(f"entry {entry_id} is already moved and must not keep archive_enabled=true")


def validate_entries(policy: dict) -> None:
    statuses = set(policy.get("allowed_statuses", []))
    forbidden_runtime = set(policy.get("runtime_forbidden_statuses", []))
    entries = policy.get("entries", [])
    rules = policy.get("rules", {})
    archive_root = ROOT / str(policy.get("archive_root", "archive"))
    managed_roots = [ROOT / str(path) for path in policy.get("managed_roots", [])]

    if not statuses:
        fail("allowed_statuses must not be empty")
    if not isinstance(entries, list):
        fail("entries must be a list")
    if not isinstance(rules, dict):
        fail("rules must be an object")
    if rules.get("managed_paths_must_stay_in_managed_roots", True) and not managed_roots:
        fail("managed_roots must not be empty")

    entries_by_id: dict[str, dict] = {}
    canon_keys: dict[str, str] = {}
    inactive_tokens: list[tuple[str, str]] = []

    for index, entry in enumerate(entries):
        if not isinstance(entry, dict):
            fail(f"entry #{index} must be an object")

        entry_id = str(entry.get("id", "")).strip()
        path_text = str(entry.get("path", "")).strip()
        status = str(entry.get("status", "")).strip()
        canonical_key = str(entry.get("canonical_key", "")).strip()
        replacement = str(entry.get("replaced_by", "")).strip()

        if not entry_id or not path_text or not status:
            fail(f"entry #{index} requires id, path and status")
        if entry_id in entries_by_id:
            fail(f"duplicate entry id: {entry_id}")
        if status not in statuses:
            fail(f"entry {entry_id} has unsupported status: {status}")

        path = validate_relative_repo_path(entry_id, path_text)
        if not path.exists():
            fail(f"entry {entry_id} points to missing path: {path_text}")

        archive_state = str(entry.get("archive_state", "")).strip()
        if rules.get("managed_paths_must_stay_in_managed_roots", True) and archive_state != "moved":
            if not any(resolved_inside(path, root) for root in managed_roots):
                fail(f"entry {entry_id} path is outside managed_roots: {path_text}")

        if status == "superseded" and rules.get("superseded_requires_replacement", True) and not replacement:
            fail(f"superseded entry {entry_id} requires replaced_by")

        if canonical_key and status == "canonical" and rules.get("duplicate_canonical_keys_forbidden", True):
            previous = canon_keys.get(canonical_key)
            if previous:
                fail(f"duplicate canonical_key {canonical_key}: {previous}, {entry_id}")
            canon_keys[canonical_key] = entry_id

        tokens = entry.get("runtime_tokens", [])
        if tokens is not None and not isinstance(tokens, list):
            fail(f"entry {entry_id} runtime_tokens must be a list")
        if status in forbidden_runtime:
            for token in tokens or []:
                token_text = str(token).strip().lower()
                if token_text:
                    inactive_tokens.append((entry_id, token_text))

        validate_archive_fields(entry_id, entry, archive_root, rules)
        entries_by_id[entry_id] = entry

    validate_replacement_graph(entries_by_id, rules)

    if rules.get("runtime_must_not_reference_inactive_entries", True):
        reject_runtime_refs(inactive_tokens, managed_roots)


def reject_runtime_refs(inactive_tokens: list[tuple[str, str]], managed_roots: list[Path]) -> None:
    violations: list[str] = []
    runtime_roots = [root for root in managed_roots if root.name in {"data", "scenes", "scripts"}]
    for root in runtime_roots:
        if not root.exists():
            continue
        for path in root.rglob("*"):
            if not path.is_file() or path.suffix.lower() not in TEXT_EXTENSIONS:
                continue
            try:
                text = path.read_text(encoding="utf-8").lower()
            except UnicodeDecodeError:
                continue
            for entry_id, token in inactive_tokens:
                if token in text:
                    violations.append(f"{path.relative_to(ROOT)} references inactive {entry_id} via {token!r}")
    if violations:
        fail("inactive content referenced by runtime files:\n  - " + "\n  - ".join(violations))


def main() -> None:
    policy = load_policy()
    validate_entries(policy)
    print("TRIEUR_GOVERNANCE_OK: lifecycle registry is coherent, replacement graph is valid, and runtime has no declared inactive references.")


if __name__ == "__main__":
    main()
