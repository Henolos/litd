#!/usr/bin/env python3
"""Read-only durable MEMORY collector for the HENOLOS Control Center."""
from __future__ import annotations

import json
from pathlib import Path
from typing import Any

EVIDENCE_REGISTRY = Path("docs/knowledge/governance/registry/evidence_registry.json")
CLOSURE_GLOBS = (
    "reports/application-closure*.json",
    "docs/governance/receipts/application-closure*.json",
)


def _load_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def _registry_entries(root: Path) -> list[dict[str, Any]]:
    path = root / EVIDENCE_REGISTRY
    if not path.is_file():
        return []
    payload = _load_json(path)
    entries = payload.get("entries", [])
    if not isinstance(entries, list):
        raise ValueError("evidence registry entries must be a list")
    return [
        entry
        for entry in entries
        if isinstance(entry, dict)
        and isinstance(entry.get("id"), str)
        and isinstance(entry.get("type"), str)
        and entry.get("result") in {"PASS", "FAIL"}
        and isinstance(entry.get("uri"), str)
        and isinstance(entry.get("observed_at"), str)
        and isinstance(entry.get("change_id"), str)
    ]


def _closure_receipts(root: Path) -> list[dict[str, Any]]:
    receipts: list[dict[str, Any]] = []
    seen: set[Path] = set()
    for pattern in CLOSURE_GLOBS:
        for path in sorted(root.glob(pattern)):
            if path in seen or not path.is_file():
                continue
            seen.add(path)
            payload = _load_json(path)
            if isinstance(payload, dict) and payload.get("kind") == "LITD_APPLICATION_CLOSURE_RECEIPT":
                receipts.append(payload)
    return receipts


def collect(root: str | Path = ".") -> dict[str, Any]:
    """Collect only durable repository MEMORY sources; never infer completion."""
    base = Path(root)
    registry = _registry_entries(base)
    closures = _closure_receipts(base)
    return {
        "registry_evidence": registry,
        "closure_receipts": closures,
        "counts": {
            "registry_evidence": len(registry),
            "closure_receipts": len(closures),
        },
        "source": "repository_memory_read_only",
        "authority": "read_only_memory_collection",
    }


def main() -> int:
    print(json.dumps(collect(), ensure_ascii=False, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
