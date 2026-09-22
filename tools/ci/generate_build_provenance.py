#!/usr/bin/env python3
"""Generate build-time provenance for LITD playable artifacts."""
from __future__ import annotations

import argparse
import json
import os
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
TRIEUR_POLICY = ROOT / "governance" / "trieur_policy.json"


def canon_version() -> int:
    data = json.loads(TRIEUR_POLICY.read_text(encoding="utf-8"))
    entries = data.get("entries", [])
    versions = [int(e.get("canon_version", 0)) for e in entries if isinstance(e, dict) and e.get("status") == "canonical"]
    return max(versions, default=0)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", default="build/web/build-provenance.json")
    parser.add_argument("--sha", default=os.getenv("GITHUB_SHA", ""))
    parser.add_argument("--branch", default=os.getenv("GITHUB_REF_NAME", ""))
    parser.add_argument("--run-id", default=os.getenv("GITHUB_RUN_ID", ""))
    args = parser.parse_args()

    sha = args.sha.strip()
    if len(sha) < 7:
        raise SystemExit("BUILD_PROVENANCE_ERROR: missing/invalid git SHA")

    payload = {
        "schema_version": 1,
        "git_sha": sha,
        "git_short_sha": sha[:12],
        "build_timestamp_utc": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
        "canon_version": canon_version(),
        "source_branch": args.branch.strip(),
        "workflow_run_id": str(args.run_id).strip(),
        "freshness_contract": "playtest artifact is current only when git_sha equals the deployment source SHA",
    }

    output = ROOT / args.output
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"BUILD_PROVENANCE_OK sha={sha} canon={payload['canon_version']} output={output.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
