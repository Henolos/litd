#!/usr/bin/env python3
"""Compose GitHub state and governance MEMORY into one read-only snapshot."""
from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

from tools.quality.control_center_github_source import snapshot_from_github
from tools.quality.control_center_governance_evidence import evaluate_evidence


def compose(
    pr: dict[str, Any],
    workflow_runs: list[dict[str, Any]],
    receipts: list[dict[str, Any]],
    *,
    project: str,
    change_record: str | None = None,
    phase: str = "verification",
    needs_human: bool = False,
    blocker: str | None = None,
) -> dict[str, Any]:
    evidence = evaluate_evidence(receipts)
    snapshot = snapshot_from_github(
        pr,
        workflow_runs,
        project=project,
        change_record=change_record,
        phase=phase,
        evidence_complete=evidence["evidence_complete"],
        last_evidence=evidence["last_evidence"],
        needs_human=needs_human,
        blocker=blocker,
    )
    snapshot["evidence"] = {
        "verified_receipts": evidence["verified_receipts"],
        "complete": evidence["evidence_complete"],
    }
    snapshot["schema_version"] = 1
    return snapshot


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--pr", required=True)
    parser.add_argument("--workflows", required=True)
    parser.add_argument("--receipts", required=True)
    parser.add_argument("--project", required=True)
    parser.add_argument("--change-record")
    parser.add_argument("--phase", default="verification")
    parser.add_argument("--output", default="reports/control-center-snapshot.json")
    args = parser.parse_args()
    load = lambda p: json.loads(Path(p).read_text(encoding="utf-8"))
    result = compose(load(args.pr), load(args.workflows), load(args.receipts),
                     project=args.project, change_record=args.change_record, phase=args.phase)
    out = Path(args.output)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(json.dumps({"status": result["status"], "output": str(out)}, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
