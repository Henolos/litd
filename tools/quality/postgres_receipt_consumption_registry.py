#!/usr/bin/env python3
"""PostgreSQL adapter for durable governance single-use receipt consumption.

This adapter targets the already-governed `governance_private` Supabase schema.
It uses only the server-role RPC functions exposed by the migration: no direct
reads or writes to private tables, no secret loading, no Core write, no merge,
and no application authority are introduced here.
"""
from __future__ import annotations

from dataclasses import dataclass
from typing import Any

HEX64 = set("0123456789abcdef")


def _hex64(value: Any) -> bool:
    return isinstance(value, str) and len(value) == 64 and all(ch in HEX64 for ch in value)


@dataclass(frozen=True)
class ConsumptionResult:
    accepted: bool
    status: str
    reason: str
    receipt_hash: str
    audit_entry_hash: str


class PostgresReceiptConsumptionRegistry:
    """DB-API adapter for the durable Supabase/PostgreSQL registry contract."""

    def __init__(self, connection: Any, *, project_id: str, target_route: str):
        if not project_id or not project_id.strip():
            raise ValueError("project_id required")
        if not target_route or not target_route.strip():
            raise ValueError("target_route required")
        self.connection = connection
        self.project_id = project_id.strip()
        self.target_route = target_route.strip()

    def register_receipt(
        self,
        *,
        receipt_id: str,
        receipt_hash: str,
        receipt_kind: str,
        source_hash: str,
        context_hash: str,
        expected_consumer: str,
    ) -> None:
        if not receipt_id.strip() or not receipt_kind.strip() or not expected_consumer.strip():
            raise ValueError("receipt identity, kind and expected consumer are required")
        for label, value in (("receipt_hash", receipt_hash), ("source_hash", source_hash), ("context_hash", context_hash)):
            if not _hex64(value):
                raise ValueError(f"{label} must be 64 lowercase hex")
        try:
            with self.connection.cursor() as cursor:
                cursor.execute(
                    "select governance_private.register_receipt(%s,%s,%s,%s,%s,%s,%s,%s)",
                    (
                        receipt_id.strip(),
                        receipt_hash,
                        receipt_kind.strip(),
                        self.project_id,
                        self.target_route,
                        source_hash,
                        context_hash,
                        expected_consumer.strip(),
                    ),
                )
            self.connection.commit()
        except Exception:
            self.connection.rollback()
            raise

    def invalidate_receipt(
        self,
        receipt_hash: str,
        *,
        kind: str,
        reason: str,
        actor: str,
        replacement_receipt_hash: str | None = None,
    ) -> None:
        if not _hex64(receipt_hash):
            raise ValueError("receipt_hash must be 64 lowercase hex")
        if kind not in {"REVOKED", "SUPERSEDED"}:
            raise ValueError("unsupported invalidation kind")
        if not reason.strip() or not actor.strip():
            raise ValueError("invalidation reason and actor are required")
        if kind == "SUPERSEDED" and not _hex64(replacement_receipt_hash):
            raise ValueError("supersession requires replacement receipt hash")
        if replacement_receipt_hash is not None and not _hex64(replacement_receipt_hash):
            raise ValueError("replacement receipt hash must be 64 lowercase hex")
        try:
            with self.connection.cursor() as cursor:
                cursor.execute(
                    "select governance_private.invalidate_receipt(%s,%s,%s,%s,%s,%s,%s)",
                    (
                        receipt_hash,
                        self.project_id,
                        self.target_route,
                        kind,
                        reason.strip(),
                        actor.strip(),
                        replacement_receipt_hash,
                    ),
                )
            self.connection.commit()
        except Exception:
            self.connection.rollback()
            raise

    def consume(
        self,
        receipt_hash: str,
        *,
        consumer: str,
        actor: str,
        current_context_hash: str,
    ) -> ConsumptionResult:
        if not _hex64(receipt_hash):
            raise ValueError("receipt_hash must be 64 lowercase hex")
        if not _hex64(current_context_hash):
            raise ValueError("current_context_hash must be 64 lowercase hex")
        if not consumer.strip() or not actor.strip():
            raise ValueError("consumer and actor are required")
        try:
            with self.connection.cursor() as cursor:
                cursor.execute(
                    """
                    select accepted,status,reason,audit_entry_hash
                    from governance_private.consume_receipt(%s,%s,%s,%s,%s,%s)
                    """,
                    (
                        receipt_hash,
                        self.project_id,
                        self.target_route,
                        consumer.strip(),
                        actor.strip(),
                        current_context_hash,
                    ),
                )
                row = cursor.fetchone()
            if row is None:
                raise RuntimeError("governance_private.consume_receipt returned no result")
            self.connection.commit()
            return ConsumptionResult(
                accepted=bool(row[0]),
                status=str(row[1]),
                reason=str(row[2]),
                receipt_hash=receipt_hash,
                audit_entry_hash=str(row[3]),
            )
        except Exception:
            self.connection.rollback()
            raise
