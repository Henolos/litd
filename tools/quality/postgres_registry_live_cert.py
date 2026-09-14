#!/usr/bin/env python3
"""Live certification harness for the durable governance receipt registry.

Requires a PostgreSQL DSN via GOVERNANCE_DATABASE_URL. The harness uses only
synthetic receipts and never writes a Core, merges code, or applies project data.
It emits a JSON evidence report suitable for retention as a CI artifact.
"""
from __future__ import annotations

import concurrent.futures
import hashlib
import json
import os
import secrets
import sys
from dataclasses import asdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from tools.quality.postgres_receipt_consumption_registry import PostgresReceiptConsumptionRegistry


def sha(label: str) -> str:
    return hashlib.sha256(label.encode("utf-8")).hexdigest()


def now() -> str:
    return datetime.now(timezone.utc).isoformat()


def main() -> int:
    dsn = os.environ.get("GOVERNANCE_DATABASE_URL", "").strip()
    if not dsn:
        print("GOVERNANCE_DATABASE_URL is required", file=sys.stderr)
        return 2
    try:
        import psycopg  # type: ignore
    except Exception as exc:
        print(f"psycopg import failed: {exc}", file=sys.stderr)
        return 3

    run_id = secrets.token_hex(8)
    evidence: dict[str, Any] = {"kind": "GOVERNANCE_POSTGRES_LIVE_CERTIFICATION", "run_id": run_id, "started_at": now(), "tests": []}

    def connect():
        return psycopg.connect(dsn, autocommit=False)

    project = f"LITD_CERT_{run_id}"
    route = "LITD_LIBRARY"
    receipt = sha(f"receipt:{run_id}")
    source = sha(f"source:{run_id}")
    context = sha(f"context:{run_id}")

    with connect() as conn:
        reg = PostgresReceiptConsumptionRegistry(conn, project_id=project, target_route=route)
        reg.register_receipt(receipt_id=f"cert:{run_id}:base", receipt_hash=receipt, receipt_kind="CERT_SYNTHETIC", source_hash=source, context_hash=context, expected_consumer="CERT_CONSUMER")
        first = reg.consume(receipt, consumer="CERT_CONSUMER", actor="live-cert", current_context_hash=context)
        second = reg.consume(receipt, consumer="CERT_CONSUMER", actor="live-cert", current_context_hash=context)
        ok = first.accepted and not second.accepted and second.reason == "replay_detected"
        evidence["tests"].append({"name": "identical_replay", "passed": ok, "first": asdict(first), "second": asdict(second)})

    stale_receipt = sha(f"stale:{run_id}")
    with connect() as conn:
        reg = PostgresReceiptConsumptionRegistry(conn, project_id=project, target_route=route)
        reg.register_receipt(receipt_id=f"cert:{run_id}:stale", receipt_hash=stale_receipt, receipt_kind="CERT_SYNTHETIC", source_hash=source, context_hash=context, expected_consumer="CERT_CONSUMER")
        stale = reg.consume(stale_receipt, consumer="CERT_CONSUMER", actor="live-cert", current_context_hash=sha(f"other-context:{run_id}"))
        evidence["tests"].append({"name": "stale_context", "passed": (not stale.accepted and stale.reason == "stale_context"), "result": asdict(stale)})

    revoked_receipt = sha(f"revoked:{run_id}")
    with connect() as conn:
        reg = PostgresReceiptConsumptionRegistry(conn, project_id=project, target_route=route)
        reg.register_receipt(receipt_id=f"cert:{run_id}:revoked", receipt_hash=revoked_receipt, receipt_kind="CERT_SYNTHETIC", source_hash=source, context_hash=context, expected_consumer="CERT_CONSUMER")
        reg.invalidate_receipt(revoked_receipt, kind="REVOKED", reason="live certification", actor="live-cert")
        revoked = reg.consume(revoked_receipt, consumer="CERT_CONSUMER", actor="live-cert", current_context_hash=context)
        evidence["tests"].append({"name": "revocation", "passed": (not revoked.accepted and revoked.reason == "receipt_revoked"), "result": asdict(revoked)})

    cross_receipt = sha(f"cross:{run_id}")
    with connect() as conn:
        litd = PostgresReceiptConsumptionRegistry(conn, project_id=project, target_route=route)
        litd.register_receipt(receipt_id=f"cert:{run_id}:cross", receipt_hash=cross_receipt, receipt_kind="CERT_SYNTHETIC", source_hash=source, context_hash=context, expected_consumer="CERT_CONSUMER")
    with connect() as conn:
        company = PostgresReceiptConsumptionRegistry(conn, project_id=f"COMPANY_CERT_{run_id}", target_route="COMPANY_LIBRARY")
        cross = company.consume(cross_receipt, consumer="CERT_CONSUMER", actor="live-cert", current_context_hash=context)
        evidence["tests"].append({"name": "cross_project_rejection", "passed": (not cross.accepted and cross.reason == "unknown_receipt"), "result": asdict(cross)})

    concurrent_receipt = sha(f"concurrent:{run_id}")
    with connect() as conn:
        reg = PostgresReceiptConsumptionRegistry(conn, project_id=project, target_route=route)
        reg.register_receipt(receipt_id=f"cert:{run_id}:concurrent", receipt_hash=concurrent_receipt, receipt_kind="CERT_SYNTHETIC", source_hash=source, context_hash=context, expected_consumer="CERT_CONSUMER")

    def attempt(i: int):
        with connect() as conn:
            reg = PostgresReceiptConsumptionRegistry(conn, project_id=project, target_route=route)
            return reg.consume(concurrent_receipt, consumer="CERT_CONSUMER", actor=f"live-cert-{i}", current_context_hash=context)

    with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:
        results = list(pool.map(attempt, range(4)))
    winners = [r for r in results if r.accepted]
    losers = [r for r in results if not r.accepted]
    concurrent_ok = len(winners) == 1 and len(losers) == 3 and all(r.reason == "replay_detected" for r in losers)
    evidence["tests"].append({"name": "concurrent_double_consumption", "passed": concurrent_ok, "results": [asdict(r) for r in results]})

    evidence["finished_at"] = now()
    evidence["passed"] = all(t["passed"] for t in evidence["tests"])
    canonical = json.dumps(evidence, sort_keys=True, separators=(",", ":"))
    evidence["evidence_sha256"] = hashlib.sha256(canonical.encode("utf-8")).hexdigest()
    Path("artifacts/governance").mkdir(parents=True, exist_ok=True)
    Path("artifacts/governance/postgres-live-certification.json").write_text(json.dumps(evidence, indent=2, sort_keys=True), encoding="utf-8")
    print(json.dumps({"passed": evidence["passed"], "evidence_sha256": evidence["evidence_sha256"]}))
    return 0 if evidence["passed"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
