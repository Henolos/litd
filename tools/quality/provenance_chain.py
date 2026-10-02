#!/usr/bin/env python3
"""End-to-end provenance chain for LITD knowledge and Core-impacting changes."""
from __future__ import annotations

import json
import sqlite3
from dataclasses import dataclass
from datetime import datetime, timezone
from hashlib import sha256
from pathlib import Path
from typing import Any

from tools.quality.replication_outbox import (
    enqueue_event,
    init_outbox,
    pending_count,
)


STAGES = (
    "SOURCE",
    "DOCUMENT",
    "DISCOVERY",
    "ROUTING_DECISION",
    "CORE_DECISION",
    "COMMIT",
    "TEST",
    "MEASUREMENT",
)

KNOWLEDGE_SPACE = "litd"


@dataclass(frozen=True)
class ProvenanceNode:
    node_id: str
    stage: str
    parent_id: str | None
    evidence_id: str | None
    payload_hash: str


class ProvenanceChain:
    """SQLite-backed provenance graph with append-only immutable nodes.

    SQLite remains the local authority during the Supabase transition. Each
    provenance append also creates an outbox event in the same transaction so
    remote synchronization can be retried without mutating historical nodes.
    """

    def __init__(self, path: str | Path):
        self.connection = sqlite3.connect(str(path))
        self.connection.row_factory = sqlite3.Row
        self._init_schema()

    def _init_schema(self) -> None:
        self.connection.executescript(
            """
            PRAGMA foreign_keys=ON;
            CREATE TABLE IF NOT EXISTS provenance_nodes (
                node_id TEXT PRIMARY KEY,
                stage TEXT NOT NULL,
                parent_id TEXT REFERENCES provenance_nodes(node_id),
                evidence_id TEXT,
                external_ref TEXT,
                payload_json TEXT NOT NULL,
                payload_hash TEXT NOT NULL,
                recorded_at TEXT NOT NULL
            );
            CREATE UNIQUE INDEX IF NOT EXISTS provenance_unique_external_ref
            ON provenance_nodes(stage, external_ref)
            WHERE external_ref IS NOT NULL;
            CREATE INDEX IF NOT EXISTS provenance_evidence_idx
            ON provenance_nodes(evidence_id, stage);
            CREATE TRIGGER IF NOT EXISTS provenance_no_update
            BEFORE UPDATE ON provenance_nodes
            BEGIN
                SELECT RAISE(ABORT, 'provenance_is_append_only');
            END;
            CREATE TRIGGER IF NOT EXISTS provenance_no_delete
            BEFORE DELETE ON provenance_nodes
            BEGIN
                SELECT RAISE(ABORT, 'provenance_is_append_only');
            END;
            """
        )
        init_outbox(self.connection)
        self.connection.commit()

    def close(self) -> None:
        self.connection.close()

    @staticmethod
    def _hash_payload(payload: dict[str, Any]) -> str:
        raw = json.dumps(payload, sort_keys=True, separators=(",", ":"), ensure_ascii=False)
        return sha256(raw.encode("utf-8")).hexdigest()

    def _get(self, node_id: str) -> sqlite3.Row | None:
        return self.connection.execute(
            "SELECT * FROM provenance_nodes WHERE node_id=?", (node_id,)
        ).fetchone()

    def append(
        self,
        *,
        node_id: str,
        stage: str,
        payload: dict[str, Any],
        parent_id: str | None = None,
        evidence_id: str | None = None,
        external_ref: str | None = None,
    ) -> ProvenanceNode:
        if stage not in STAGES:
            raise ValueError(f"invalid_provenance_stage:{stage}")
        if not node_id.strip():
            raise ValueError("empty_node_id")

        parent = self._get(parent_id) if parent_id else None
        if stage == "SOURCE":
            if parent_id is not None:
                raise ValueError("source_must_be_root")
        else:
            if parent is None:
                raise ValueError("missing_parent")
            expected_parent_stage = STAGES[STAGES.index(stage) - 1]
            if parent["stage"] != expected_parent_stage:
                raise ValueError(
                    f"invalid_parent_stage:{stage}:expected:{expected_parent_stage}:got:{parent['stage']}"
                )

        effective_evidence_id = evidence_id
        if parent is not None and parent["evidence_id"] is not None:
            if effective_evidence_id is None:
                effective_evidence_id = parent["evidence_id"]
            elif effective_evidence_id != parent["evidence_id"]:
                raise ValueError("evidence_id_mismatch")

        payload_hash = self._hash_payload(payload)
        recorded_at = datetime.now(timezone.utc).isoformat()
        try:
            self.connection.execute(
                "INSERT INTO provenance_nodes(node_id, stage, parent_id, evidence_id, external_ref, payload_json, payload_hash, recorded_at) "
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
                (
                    node_id,
                    stage,
                    parent_id,
                    effective_evidence_id,
                    external_ref,
                    json.dumps(payload, sort_keys=True, ensure_ascii=False),
                    payload_hash,
                    recorded_at,
                ),
            )
            enqueue_event(
                self.connection,
                event_type="provenance_node",
                event_key=f"provenance:{node_id}",
                payload={
                    "space_slug": KNOWLEDGE_SPACE,
                    "node_id": node_id,
                    "stage": stage,
                    "parent_node_id": parent_id,
                    "evidence_id": effective_evidence_id,
                    "external_ref": external_ref,
                    "payload": payload,
                    "payload_hash": payload_hash,
                    "recorded_at": recorded_at,
                },
            )
            self.connection.commit()
        except Exception:
            self.connection.rollback()
            raise
        return ProvenanceNode(node_id, stage, parent_id, effective_evidence_id, payload_hash)

    def backfill_replication_outbox(self) -> int:
        """Queue all pre-outbox provenance nodes without rewriting history."""
        inserted = 0
        try:
            rows = self.connection.execute(
                "SELECT node_id, stage, parent_id, evidence_id, external_ref, payload_json, payload_hash, recorded_at "
                "FROM provenance_nodes ORDER BY recorded_at, node_id"
            ).fetchall()
            for row in rows:
                inserted += int(
                    enqueue_event(
                        self.connection,
                        event_type="provenance_node",
                        event_key=f"provenance:{row['node_id']}",
                        payload={
                            "space_slug": KNOWLEDGE_SPACE,
                            "node_id": row["node_id"],
                            "stage": row["stage"],
                            "parent_node_id": row["parent_id"],
                            "evidence_id": row["evidence_id"],
                            "external_ref": row["external_ref"],
                            "payload": json.loads(row["payload_json"]),
                            "payload_hash": row["payload_hash"],
                            "recorded_at": row["recorded_at"],
                        },
                    )
                )
            self.connection.commit()
        except Exception:
            self.connection.rollback()
            raise
        return inserted

    def pending_replication_count(self) -> int:
        return pending_count(self.connection)

    def trace(self, node_id: str) -> list[ProvenanceNode]:
        nodes: list[ProvenanceNode] = []
        current = self._get(node_id)
        while current is not None:
            nodes.append(
                ProvenanceNode(
                    current["node_id"],
                    current["stage"],
                    current["parent_id"],
                    current["evidence_id"],
                    current["payload_hash"],
                )
            )
            current = self._get(current["parent_id"]) if current["parent_id"] else None
        nodes.reverse()
        return nodes

    def verify_integrity(self) -> bool:
        rows = self.connection.execute(
            "SELECT * FROM provenance_nodes ORDER BY recorded_at, node_id"
        ).fetchall()
        for row in rows:
            payload = json.loads(row["payload_json"])
            if self._hash_payload(payload) != row["payload_hash"]:
                return False
            if row["stage"] == "SOURCE":
                if row["parent_id"] is not None:
                    return False
                continue
            parent = self._get(row["parent_id"])
            if parent is None:
                return False
            expected_parent_stage = STAGES[STAGES.index(row["stage"]) - 1]
            if parent["stage"] != expected_parent_stage:
                return False
            if parent["evidence_id"] is not None and row["evidence_id"] != parent["evidence_id"]:
                return False
        return True

    def chain_complete_through(self, node_id: str, stage: str) -> bool:
        if stage not in STAGES:
            return False
        trace = self.trace(node_id)
        expected = list(STAGES[: STAGES.index(stage) + 1])
        return [node.stage for node in trace] == expected

    def can_reach_core(self, routing_node_id: str) -> bool:
        node = self._get(routing_node_id)
        return bool(node and node["stage"] == "ROUTING_DECISION")

    def can_apply_without_core_decision(self, node_id: str) -> bool:
        """Hard invariant: application/commit cannot bypass CORE_DECISION."""
        trace = self.trace(node_id)
        stages = [node.stage for node in trace]
        return "COMMIT" in stages and "CORE_DECISION" not in stages
