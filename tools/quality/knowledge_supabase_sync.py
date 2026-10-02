#!/usr/bin/env python3
"""Shadow synchronization from SQLite knowledge history to Supabase Postgres.

SQLite remains authoritative until an explicit cutover. The remote writer is
idempotent and consumes only durable outbox events created by the local stores.
"""
from __future__ import annotations

import hashlib
import json
import sqlite3
from dataclasses import dataclass
from typing import Any, Protocol

from tools.quality.evidence_ledger import EvidenceLedger
from tools.quality.provenance_chain import ProvenanceChain
from tools.quality.replication_outbox import (
    OutboxEvent,
    mark_delivered,
    mark_failed,
    pending_count,
    pending_events,
)


INGEST_STATUS_MAP = {
    "ACCEPTED_FOR_ROUTING": "accepted",
    "REJECTED": "rejected",
    "QUARANTINED": "quarantined",
    "DUPLICATE": "duplicate",
}


@dataclass(frozen=True)
class SyncReport:
    delivered: int
    failed: int
    remaining: int
    last_error: str | None = None


@dataclass(frozen=True)
class ParitySnapshot:
    evidence_count: int
    evidence_digest: str
    decision_count: int
    decision_digest: str
    provenance_count: int
    provenance_digest: str


@dataclass(frozen=True)
class ParityReport:
    local: ParitySnapshot
    remote: ParitySnapshot

    @property
    def matches(self) -> bool:
        return self.local == self.remote


class KnowledgeRemote(Protocol):
    def apply_event(self, event: OutboxEvent) -> None: ...

    def parity_snapshot(self, *, space_slug: str = "litd") -> ParitySnapshot: ...


def _digest(rows: list[list[Any]]) -> str:
    raw = json.dumps(rows, sort_keys=False, separators=(",", ":"), ensure_ascii=False)
    return hashlib.sha256(raw.encode("utf-8")).hexdigest()


def _decision_dimension(decision: str) -> tuple[str, str | None]:
    ingest_status = INGEST_STATUS_MAP.get(decision.upper())
    if ingest_status is not None:
        return "ingest", ingest_status
    if decision.upper().endswith("_LIBRARY"):
        return "routing", None
    return "other", None


class PostgresKnowledgeRemote:
    """Trusted backend adapter for the private knowledge schema.

    The connection should authenticate as a login role inheriting only the
    knowledge_sync role. No password or connection string is stored here.
    """

    def __init__(self, connection: Any):
        self.connection = connection

    def _space_id(self, cursor: Any, slug: str) -> Any:
        if slug != "litd":
            raise ValueError("unsupported_knowledge_space")
        cursor.execute(
            "SELECT id FROM knowledge.knowledge_spaces WHERE slug=%s",
            (slug,),
        )
        row = cursor.fetchone()
        if row is None:
            raise RuntimeError("knowledge_space_not_found")
        return row[0]

    def apply_event(self, event: OutboxEvent) -> None:
        cursor = self.connection.cursor()
        try:
            space_slug = str(event.payload.get("space_slug", ""))
            space_id = self._space_id(cursor, space_slug)

            if event.event_type == "evidence_registered":
                self._apply_evidence_registered(cursor, space_id, event.payload)
            elif event.event_type == "evidence_decision":
                self._apply_evidence_decision(cursor, space_id, event.payload)
            elif event.event_type == "provenance_node":
                self._apply_provenance_node(cursor, space_id, event.payload)
            else:
                raise ValueError(f"unsupported_replication_event:{event.event_type}")

            self.connection.commit()
        except Exception:
            self.connection.rollback()
            raise
        finally:
            cursor.close()

    def _apply_evidence_registered(self, cursor: Any, space_id: Any, payload: dict[str, Any]) -> None:
        cursor.execute(
            "INSERT INTO knowledge.sources(space_id, source_uri, retrieved_at) "
            "VALUES (%s, %s, %s) "
            "ON CONFLICT (space_id, source_uri) DO NOTHING",
            (space_id, payload["source_url"], payload["first_seen_at"]),
        )
        cursor.execute(
            "SELECT id FROM knowledge.sources WHERE space_id=%s AND source_uri=%s",
            (space_id, payload["source_url"]),
        )
        source = cursor.fetchone()
        if source is None:
            raise RuntimeError("source_upsert_failed")
        source_id = source[0]

        cursor.execute(
            "INSERT INTO knowledge.evidence_registry("
            "space_id, evidence_id, canonical_hash, source_id, first_seen_at, "
            "project_id, target_route, origin_store"
            ") VALUES (%s, %s, %s, %s, %s, %s, %s, 'sqlite') "
            "ON CONFLICT (space_id, evidence_id) DO NOTHING",
            (
                space_id,
                payload["evidence_id"],
                payload["canonical_hash"],
                source_id,
                payload["first_seen_at"],
                payload["project_id"],
                payload["target_route"],
            ),
        )
        cursor.execute(
            "SELECT e.canonical_hash, e.project_id, e.target_route, e.origin_store, s.source_uri "
            "FROM knowledge.evidence_registry e "
            "JOIN knowledge.sources s ON s.space_id=e.space_id AND s.id=e.source_id "
            "WHERE e.space_id=%s AND e.evidence_id=%s",
            (space_id, payload["evidence_id"]),
        )
        row = cursor.fetchone()
        expected = (
            payload["canonical_hash"],
            payload["project_id"],
            payload["target_route"],
            "sqlite",
            payload["source_url"],
        )
        if row is None or tuple(row) != expected:
            raise RuntimeError("remote_evidence_conflict")

    def _apply_evidence_decision(self, cursor: Any, space_id: Any, payload: dict[str, Any]) -> None:
        dimension, ingest_status = _decision_dimension(str(payload["decision"]))
        cursor.execute(
            "INSERT INTO knowledge.evidence_decisions("
            "space_id, evidence_id, decision, decision_dimension, ingest_status, reason, "
            "previous_hash, entry_hash, recorded_at, project_id, target_route, "
            "origin_store, origin_sequence"
            ") VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, 'sqlite', %s) "
            "ON CONFLICT (space_id, entry_hash) DO NOTHING",
            (
                space_id,
                payload["evidence_id"],
                payload["decision"],
                dimension,
                ingest_status,
                payload["reason"],
                payload["previous_hash"],
                payload["entry_hash"],
                payload["recorded_at"],
                payload["project_id"],
                payload["target_route"],
                payload["sequence"],
            ),
        )
        cursor.execute(
            "SELECT decision, decision_dimension, ingest_status, reason, previous_hash, "
            "project_id, target_route, origin_store, origin_sequence "
            "FROM knowledge.evidence_decisions "
            "WHERE space_id=%s AND entry_hash=%s",
            (space_id, payload["entry_hash"]),
        )
        row = cursor.fetchone()
        expected = (
            payload["decision"],
            dimension,
            ingest_status,
            payload["reason"],
            payload["previous_hash"],
            payload["project_id"],
            payload["target_route"],
            "sqlite",
            payload["sequence"],
        )
        if row is None or tuple(row) != expected:
            raise RuntimeError("remote_decision_conflict")

    def _apply_provenance_node(self, cursor: Any, space_id: Any, payload: dict[str, Any]) -> None:
        cursor.execute(
            "INSERT INTO knowledge.provenance_nodes("
            "space_id, node_id, stage, parent_node_id, evidence_id, external_ref, "
            "payload, payload_hash, recorded_at, origin_store"
            ") VALUES (%s, %s, %s, %s, %s, %s, %s::jsonb, %s, %s, 'sqlite') "
            "ON CONFLICT (space_id, node_id) DO NOTHING",
            (
                space_id,
                payload["node_id"],
                payload["stage"],
                payload["parent_node_id"],
                payload["evidence_id"],
                payload["external_ref"],
                json.dumps(payload["payload"], sort_keys=True, ensure_ascii=False),
                payload["payload_hash"],
                payload["recorded_at"],
            ),
        )
        cursor.execute(
            "SELECT stage, parent_node_id, evidence_id, external_ref, payload_hash, origin_store "
            "FROM knowledge.provenance_nodes WHERE space_id=%s AND node_id=%s",
            (space_id, payload["node_id"]),
        )
        row = cursor.fetchone()
        expected = (
            payload["stage"],
            payload["parent_node_id"],
            payload["evidence_id"],
            payload["external_ref"],
            payload["payload_hash"],
            "sqlite",
        )
        if row is None or tuple(row) != expected:
            raise RuntimeError("remote_provenance_conflict")

    def parity_snapshot(self, *, space_slug: str = "litd") -> ParitySnapshot:
        cursor = self.connection.cursor()
        try:
            space_id = self._space_id(cursor, space_slug)

            cursor.execute(
                "SELECT evidence_id, canonical_hash "
                "FROM knowledge.evidence_registry "
                "WHERE space_id=%s AND origin_store='sqlite' "
                "ORDER BY evidence_id",
                (space_id,),
            )
            evidence_rows = [[row[0], row[1]] for row in cursor.fetchall()]

            cursor.execute(
                "SELECT origin_sequence, entry_hash "
                "FROM knowledge.evidence_decisions "
                "WHERE space_id=%s AND origin_store='sqlite' "
                "ORDER BY origin_sequence, entry_hash",
                (space_id,),
            )
            decision_rows = [[row[0], row[1]] for row in cursor.fetchall()]

            cursor.execute(
                "SELECT node_id, payload_hash "
                "FROM knowledge.provenance_nodes "
                "WHERE space_id=%s AND origin_store='sqlite' "
                "ORDER BY node_id",
                (space_id,),
            )
            provenance_rows = [[row[0], row[1]] for row in cursor.fetchall()]
        finally:
            cursor.close()

        return ParitySnapshot(
            evidence_count=len(evidence_rows),
            evidence_digest=_digest(evidence_rows),
            decision_count=len(decision_rows),
            decision_digest=_digest(decision_rows),
            provenance_count=len(provenance_rows),
            provenance_digest=_digest(provenance_rows),
        )


def local_parity_snapshot(ledger: EvidenceLedger, chain: ProvenanceChain) -> ParitySnapshot:
    evidence_rows = [
        [row["evidence_id"], row["canonical_hash"]]
        for row in ledger.connection.execute(
            "SELECT evidence_id, canonical_hash FROM evidence_registry ORDER BY evidence_id"
        ).fetchall()
    ]
    decision_rows = [
        [row["sequence"], row["entry_hash"]]
        for row in ledger.connection.execute(
            "SELECT sequence, entry_hash FROM decision_ledger ORDER BY sequence, entry_hash"
        ).fetchall()
    ]
    provenance_rows = [
        [row["node_id"], row["payload_hash"]]
        for row in chain.connection.execute(
            "SELECT node_id, payload_hash FROM provenance_nodes ORDER BY node_id"
        ).fetchall()
    ]
    return ParitySnapshot(
        evidence_count=len(evidence_rows),
        evidence_digest=_digest(evidence_rows),
        decision_count=len(decision_rows),
        decision_digest=_digest(decision_rows),
        provenance_count=len(provenance_rows),
        provenance_digest=_digest(provenance_rows),
    )


def verify_parity(
    ledger: EvidenceLedger,
    chain: ProvenanceChain,
    remote: KnowledgeRemote,
) -> ParityReport:
    return ParityReport(
        local=local_parity_snapshot(ledger, chain),
        remote=remote.parity_snapshot(space_slug="litd"),
    )


def _drain_outbox(
    connection: sqlite3.Connection,
    remote: KnowledgeRemote,
    *,
    limit: int,
) -> SyncReport:
    delivered = 0
    failed = 0
    last_error: str | None = None

    for event in pending_events(connection, limit=limit):
        try:
            remote.apply_event(event)
        except Exception as exc:
            last_error = f"{type(exc).__name__}:{exc}"
            mark_failed(connection, event.id, last_error)
            connection.commit()
            failed = 1
            break
        else:
            mark_delivered(connection, event.id)
            connection.commit()
            delivered += 1

    return SyncReport(
        delivered=delivered,
        failed=failed,
        remaining=pending_count(connection),
        last_error=last_error,
    )


def sync_knowledge_once(
    ledger: EvidenceLedger,
    chain: ProvenanceChain,
    remote: KnowledgeRemote,
    *,
    limit: int = 100,
) -> tuple[SyncReport, SyncReport]:
    """Drain ledger first, then provenance to preserve remote dependencies."""
    ledger_report = _drain_outbox(ledger.connection, remote, limit=limit)
    if ledger_report.failed:
        return ledger_report, SyncReport(
            delivered=0,
            failed=0,
            remaining=chain.pending_replication_count(),
            last_error="ledger_sync_failed",
        )

    provenance_report = _drain_outbox(chain.connection, remote, limit=limit)
    return ledger_report, provenance_report


def prepare_existing_history(
    ledger: EvidenceLedger,
    chain: ProvenanceChain,
) -> tuple[int, int]:
    """Idempotently enqueue every pre-outbox SQLite record for migration."""
    return (
        ledger.backfill_replication_outbox(),
        chain.backfill_replication_outbox(),
    )


def connect_postgres(dsn: str, *, sslmode: str = "require") -> Any:
    """Create a Psycopg 3 connection without exposing credentials to logs."""
    try:
        import psycopg
    except ImportError as exc:  # pragma: no cover - optional runtime dependency
        raise RuntimeError(
            "psycopg is required for Supabase shadow sync; "
            "install the supabase-sync optional dependency"
        ) from exc
    return psycopg.connect(
        dsn,
        application_name="litd-knowledge-shadow-sync",
        sslmode=sslmode,
    )
