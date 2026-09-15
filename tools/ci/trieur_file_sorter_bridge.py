#!/usr/bin/env python3
"""Cross-check Trieur lifecycle registry against the physical file sorter manifest."""
from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
TRIEUR = ROOT / "governance" / "trieur_policy.json"
MANIFEST = ROOT / "data" / "maintenance" / "canonical_files.json"


def fail(message: str) -> None:
    print(f"TRIEUR_SORTER_BRIDGE_ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)


def load(path: Path) -> dict:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        fail(f"cannot load {path.relative_to(ROOT)}: {exc}")
    if not isinstance(data, dict):
        fail(f"{path.relative_to(ROOT)} must be a JSON object")
    return data


def is_under_managed_root(path: str, managed_roots: set[str]) -> bool:
    normalized = path.replace("\\", "/").lstrip("./")
    return any(normalized == root or normalized.startswith(root + "/") for root in managed_roots)


def main() -> None:
    trieur = load(TRIEUR)
    sorter = load(MANIFEST)

    canonical_paths = set(map(str, sorter.get("canonical_paths", [])))
    obsolete = sorter.get("obsolete_records", [])
    if not isinstance(obsolete, list):
        fail("obsolete_records must be a list")

    obsolete_paths = {
        str(record.get("path", "")).strip()
        for record in obsolete
        if isinstance(record, dict) and str(record.get("path", "")).strip()
    }

    entries = trieur.get("entries", [])
    if not isinstance(entries, list):
        fail("Trieur entries must be a list")

    managed_roots = {
        str(root).replace("\\", "/").strip("/")
        for root in trieur.get("managed_roots", [])
        if str(root).strip()
    }
    canonical_registry_paths: set[str] = set()

    for entry in entries:
        if not isinstance(entry, dict):
            continue
        entry_id = str(entry.get("id", "")).strip()
        path = str(entry.get("path", "")).strip()
        status = str(entry.get("status", "")).strip()
        if not entry_id or not path:
            continue

        if status == "canonical":
            canonical_registry_paths.add(path)
            if path not in canonical_paths:
                fail(f"canonical Trieur entry {entry_id} is not protected by file sorter canonical_paths: {path}")
            if path in obsolete_paths:
                fail(f"canonical Trieur entry {entry_id} is also marked obsolete by file sorter: {path}")

        if status in {"superseded", "archived"} and path in canonical_paths:
            fail(f"inactive Trieur entry {entry_id} is still protected as canonical by file sorter: {path}")

    unmanaged_by_trieur = sorted(
        path
        for path in canonical_paths
        if is_under_managed_root(path, managed_roots) and path not in canonical_registry_paths
    )
    if unmanaged_by_trieur:
        fail(
            "file sorter canonical_paths inside Trieur managed_roots are missing canonical registry entries: "
            + ", ".join(unmanaged_by_trieur)
        )

    required_infra = {
        "governance/trieur_policy.json",
        "data/maintenance/canonical_files.json",
        "tools/ci/trieur_governance_gate.py",
        "tools/ci/trieur_safe_archive.py",
        "tools/ci/trieur_file_sorter_bridge.py",
    }
    missing = sorted(required_infra - canonical_paths)
    if missing:
        fail("governance infrastructure missing from canonical_paths: " + ", ".join(missing))

    print(
        "TRIEUR_SORTER_BRIDGE_OK: lifecycle canon and physical file-sorter protections are bidirectionally aligned for managed roots."
    )


if __name__ == "__main__":
    main()
