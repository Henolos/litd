#!/usr/bin/env python3
"""Run live adversarial proof for the durable governance receipt registry.

The script expects a PostgreSQL DSN in GOVERNANCE_DATABASE_URL. It never prints
or persists the DSN. Each scenario uses fresh random receipt identities so the
append-only registry remains valid and the evidence can be retained safely.
"""
from __future__ import annotations

import json
import os
import sys
from concurrent.futures import ThreadPoolExecutor
from datetime import datetime, timezone
from hashlib import sha256
from pathlib import Path
from typing import Any
from uuid import uuid4

import psycopg

from tools.quality.postgres_receipt_consumption_registry import (
    PostgresReceiptConsumptionRegistry,
)

PROJECT_ID = "LITD"
TARGET_ROUTE = "LITD_LIBRARY"
CONSUMER = "LIVE_PROOF_CONSUMER"


def _now() -> str:
    return datetime.now(timezone.utc).isoformat()


def _h(label: str) -> str:
    return sha256(f"{label}:{uuid4().hex}".encode("utf-8")).hexdigest()


def _connect(dsn: str):
    return psycopg.connect(dsn, autocommit=False)


def _register(registry: PostgresReceiptConsumptionRegistry, *, label: str, context_hash: str) -> str:
    receipt_hash = _h(label)
    registry.register_receipt(
        receipt_id=f"live-proof:{label}:{uuid4().hex}",
        receipt_hash=receipt_hash,
        receipt_kind="LITD_LIVE_PROOF_RECEIPT",
        source_hash=_h(f"source:{label}"),
        context_hash=context_hash,
        expected_consumer=CONSUMER,
    )
    return receipt_hash


def _result_dict(result: Any) -> dict[str, Any]:
    return {
        "accepted": result.accepted,
        "status": result.status,
        "reason": result.reason,
        "receipt_hash": result.receipt_hash,
        "audit_entry_hash": result.audit_entry_hash,
    }


def run(dsn: str) -> dict[str, Any]:
    evidence: dict[str, Any] = {
        "kind": "LITD_POSTGRES_RECEIPT_REGISTRY_LIVE_PROOF",
        "project_id": PROJECT_ID,
        "target_route": TARGET_ROUTE,
        "started_at": _now(),
        "scenarios": {},
    }

    with _connect(dsn) as connection:
        registry = PostgresReceiptConsumptionRegistry(
            connection, project_id=PROJECT_ID, target_route=TARGET_ROUTE
        )

        ctx = _h("context:replay")
        receipt = _register(registry, label="replay", context_hash=ctx)
        first = registry.consume(receipt, consumer=CONSUMER, actor="live-proof", current_context_hash=ctx)
        replay = registry.consume(receipt, consumer=CONSUMER, actor="live-proof", current_context_hash=ctx)
        assert first.accepted is True and first.reason == "consumed_once"
        assert replay.accepted is False and replay.reason == "replay_detected"
        evidence["scenarios"]["identical_replay"] = {
            "first": _result_dict(first),
            "replay": _result_dict(replay),
            "passed": True,
        }

        registered_ctx = _h("context:registered")
        stale_ctx = _h("context:stale")
        receipt = _register(registry, label="stale", context_hash=registered_ctx)
        stale = registry.consume(receipt, consumer=CONSUMER, actor="live-proof", current_context_hash=stale_ctx)
        assert stale.accepted is False and stale.reason == "stale_context"
        evidence["scenarios"]["stale_context"] = {"result": _result_dict(stale), "passed": True}

        ctx = _h("context:revoked")
        receipt = _register(registry, label="revoked", context_hash=ctx)
        registry.invalidate_receipt(receipt, kind="REVOKED", reason="live-proof", actor="live-proof")
        revoked = registry.consume(receipt, consumer=CONSUMER, actor="live-proof", current_context_hash=ctx)
        assert revoked.accepted is False and revoked.reason == "receipt_revoked"
        evidence["scenarios"]["revoked"] = {"result": _result_dict(revoked), "passed": True}

        ctx = _h("context:superseded")
        receipt = _register(registry, label="superseded", context_hash=ctx)
        replacement = _h("replacement")
        registry.invalidate_receipt(
            receipt,
            kind="SUPERSEDED",
            reason="live-proof",
            actor="live-proof",
            replacement_receipt_hash=replacement,
        )
        superseded = registry.consume(receipt, consumer=CONSUMER, actor="live-proof", current_context_hash=ctx)
        assert superseded.accepted is False and superseded.reason == "receipt_superseded"
        evidence["scenarios"]["superseded"] = {"result": _result_dict(superseded), "passed": True}

        ctx = _h("context:cross-project")
        receipt = _register(registry, label="cross-project", context_hash=ctx)
        other = PostgresReceiptConsumptionRegistry(
            connection, project_id="COMPANY", target_route=TARGET_ROUTE
        )
        cross_project = other.consume(
            receipt, consumer=CONSUMER, actor="live-proof", current_context_hash=ctx
        )
        assert cross_project.accepted is False and cross_project.reason == "project_scope_mismatch"
        evidence["scenarios"]["cross_project"] = {
            "result": _result_dict(cross_project),
            "passed": True,
        }

    concurrent_ctx = _h("context:concurrent")
    with _connect(dsn) as connection:
        registry = PostgresReceiptConsumptionRegistry(
            connection, project_id=PROJECT_ID, target_route=TARGET_ROUTE
        )
        concurrent_receipt = _register(
            registry, label="concurrent", context_hash=concurrent_ctx
        )

    def consume_concurrently(index: int) -> dict[str, Any]:
        with _connect(dsn) as connection:
            registry = PostgresReceiptConsumptionRegistry(
                connection, project_id=PROJECT_ID, target_route=TARGET_ROUTE
            )
            result = registry.consume(
                concurrent_receipt,
                consumer=CONSUMER,
                actor=f"live-proof-worker-{index}",
                current_context_hash=concurrent_ctx,
            )
            return _result_dict(result)

    with ThreadPoolExecutor(max_workers=8) as pool:
        concurrent_results = list(pool.map(consume_concurrently, range(8)))
    winners = [row for row in concurrent_results if row["accepted"]]
    losers = [row for row in concurrent_results if not row["accepted"]]
    assert len(winners) == 1
    assert all(row["reason"] == "replay_detected" for row in losers)
    evidence["scenarios"]["concurrent_double_consumption"] = {
        "attempts": len(concurrent_results),
        "accepted": len(winners),
        "rejected": len(losers),
        "results": concurrent_results,
        "passed": True,
    }

    evidence["completed_at"] = _now()
    evidence["all_passed"] = all(
        bool(item.get("passed")) for item in evidence["scenarios"].values()
    )
    canonical = json.dumps(evidence, sort_keys=True, separators=(",", ":"), ensure_ascii=False)
    evidence["evidence_hash"] = sha256(canonical.encode("utf-8")).hexdigest()
    return evidence


def main() -> int:
    dsn = os.environ.get("GOVERNANCE_DATABASE_URL", "").strip()
    if not dsn:
        print("GOVERNANCE_DATABASE_URL is required", file=sys.stderr)
        return 2
    output = Path(os.environ.get("GOVERNANCE_LIVE_PROOF_OUTPUT", "reports/postgres-receipt-registry-live-proof.json"))
    output.parent.mkdir(parents=True, exist_ok=True)
    evidence = run(dsn)
    output.write_text(json.dumps(evidence, ensure_ascii=False, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(json.dumps({"all_passed": evidence["all_passed"], "evidence_hash": evidence["evidence_hash"]}, sort_keys=True))
    return 0 if evidence["all_passed"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
