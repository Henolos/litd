#!/usr/bin/env python3
"""Validate LITD trieur governance policy.

This gate is conservative by design: it validates declared lifecycle metadata and
prevents inactive content from being treated as runtime truth, but it does not
move or delete files automatically.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
POLICY_FILE = ROOT / "governance" / "trieur_policy.json"
RUNTIME_ROOTS = (ROOT / "data", ROOT / "scenes", ROOT / "scripts")
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


def validate_entries(policy: dict) -> None:
    statuses = set(policy.get("allowed_statuses", []))
    forbidden_runtime = set(policy.get("runtime_forbidden_statuses", []))
    entries = policy.get("entries", [])
    if not isinstance(entries, list):
        fail("entries must be a list")

    ids: set[str] = set()
    canon_keys: dict[str, str] = {}
    inactive_tokens: list[tuple[str, str]] = []

    for index, entry in enumerate(entries):
        if not isinstance(entry, dict):
            fail(f"entry #{index} must be an object")
        entry_id = str(entry.get("id", "")).strip()
        path = str(entry.get("path", "")).strip()
        status = str(entry.get("status", "")).strip()
        canonical_key = str(entry.get("canonical_key", "")).strip()
        replacement = str(entry.get("replaced_by", "")).strip()

        if not entry_id or not path or not status:
            fail(f"entry #{index} requires id, path and status")
        if entry_id in ids:
            fail(f"duplicate entry id: {entry_id}")
        ids.add(entry_id)
        if status not in statuses:
            fail(f"entry {entry_id} has unsupported status: {status}")
        if not (ROOT / path).exists():
            fail(f"entry {entry_id} points to missing path: {path}")

        if status == "superseded" and policy.get("rules", {}).get("superseded_requires_replacement", True):
            if not replacement:
                fail(f"superseded entry {entry_id} requires replaced_by")

        if canonical_key and status == "canonical":
            previous = canon_keys.get(canonical_key)
            if previous:
                fail(f"duplicate canonical_key {canonical_key}: {previous}, {entry_id}")
            canon_keys[canonical_key] = entry_id

        if status in forbidden_runtime:
            for token in entry.get("runtime_tokens", []):
                token_text = str(token).strip().lower()
                if token_text:
                    inactive_tokens.append((entry_id, token_text))

    if policy.get("rules", {}).get("runtime_must_not_reference_inactive_entries", True):
        reject_runtime_refs(inactive_tokens)


def reject_runtime_refs(inactive_tokens: list[tuple[str, str]]) -> None:
    violations: list[str] = []
    for root in RUNTIME_ROOTS:
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
    print("TRIEUR_GOVERNANCE_OK: lifecycle registry is coherent and runtime has no declared inactive references.")


if __name__ == "__main__":
    main()
