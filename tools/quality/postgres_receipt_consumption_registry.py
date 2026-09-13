#!/usr/bin/env python3
"""Durable PostgreSQL implementation of the governance receipt registry.

Authority-bearing mutations are delegated to the security-definer functions
installed by the Supabase migrations. Remote plaintext connections are refused.
"""
from __future__ import annotations

from dataclasses import dataclass
from typing import Any

try:
    import psycopg
    from psycopg.conninfo import conninfo_to_dict
    from psycopg.rows import dict_row
except ImportError as exc:  # pragma: no cover - deployment packaging guard
    psycopg = None
    conninfo_to_dict = None
    dict_row = None
    _IMPORT_ERROR = exc
else:
    _IMPORT_ERROR = None

PROJECT_ID = "LITD"
TARGET_ROUTE = "LITD_LIBRARY"
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
    """Project-scoped, single-use receipt registry backed by PostgreSQL."""

    def __init__(self, conninfo: str, *, project_id: str = PROJECT_ID,
                 target_route: str = TARGET_ROUTE,
                 allow_insecure_localhost: bool = False) -> None:
        if psycopg is None:
            raise RuntimeError("psycopg is required for the PostgreSQL registry") from _IMPORT_ERROR
        if project_id != PROJECT_ID:
            raise ValueError("registry project scope mismatch")
        if target_route != TARGET_ROUTE:
            raise ValueError("registry route scope mismatch")
        if not isinstance(conninfo, str) or not conninfo.strip():
            raise ValueError("PostgreSQL connection string is required")
        parsed = conninfo_to_dict(conninfo)
        host = str(parsed.get("host", "")).casefold()
        sslmode = str(parsed.get("sslmode", "prefer")).casefold()
        local = host in {"localhost", "127.0.0.1", "::1"}
        if sslmode not in {"require", "verify-ca", "verify-full"} and not (
            allow_insecure_localhost and local
        ):
            raise ValueError("remote PostgreSQL transport must require TLS")
        self.project_id = project_id
        self.target_route = target_route
        self.connection = psycopg.connect(conninfo, autocommit=True, row_factory=dict_row)

    def close(self) -> None:
        self.connection.close()

    def register_receipt(self, *, receipt_id: str, receipt_hash: str,
                         receipt_kind: str, source_hash: str, context_hash: str,
                         expected_consumer: str) -> None:
        if not receipt_id.strip() or not receipt_kind.strip() or not expected_consumer.strip():
            raise ValueError("receipt identity, kind and expected consumer are required")
        for label, value in (("receipt_hash", receipt_hash), ("source_hash", source_hash),
                             ("context_hash", context_hash)):
            if not _hex64(value):
                raise ValueError(f"{label} must be 64 lowercase hex")
        with self.connection.transaction():
            self.connection.execute(
                "select governance_private.register_receipt(%s,%s,%s,%s,%s,%s,%s,%s)",
                (receipt_id.strip(), receipt_hash, receipt_kind.strip(), self.project_id,
                 self.target_route, source_hash, context_hash, expected_consumer.strip()),
            )

    def invalidate_receipt(self, receipt_hash: str, *, kind: str, reason: str,
                           actor: str, replacement_receipt_hash: str | None = None) -> None:
        if kind not in {"REVOKED", "SUPERSEDED"}:
            raise ValueError("unsupported invalidation kind")
        if not reason.strip() or not actor.strip():
            raise ValueError("invalidation reason and actor are required")
        if kind == "SUPERSEDED" and not _hex64(replacement_receipt_hash):
            raise ValueError("supersession requires replacement receipt hash")
        with self.connection.transaction():
            self.connection.execute(
                "select governance_private.invalidate_receipt(%s,%s,%s,%s,%s,%s,%s)",
                (receipt_hash, self.project_id, self.target_route, kind, reason.strip(),
                 actor.strip(), replacement_receipt_hash),
            )

    def consume(self, receipt_hash: str, *, consumer: str, actor: str,
                current_context_hash: str) -> ConsumptionResult:
        if not _hex64(receipt_hash):
            raise ValueError("receipt_hash must be 64 lowercase hex")
        if not _hex64(current_context_hash):
            raise ValueError("current_context_hash must be 64 lowercase hex")
        if not consumer.strip() or not actor.strip():
            raise ValueError("consumer and actor are required")
        with self.connection.transaction():
            row = self.connection.execute(
                "select * from governance_private.consume_receipt(%s,%s,%s,%s,%s,%s)",
                (receipt_hash, self.project_id, self.target_route, consumer.strip(),
                 actor.strip(), current_context_hash),
            ).fetchone()
        if row is None:
            raise RuntimeError("consume_receipt returned no result")
        return ConsumptionResult(bool(row["accepted"]), str(row["status"]),
                                 str(row["reason"]), receipt_hash,
                                 str(row["audit_entry_hash"]))

    def consumption_count(self, receipt_hash: str) -> int:
        row = self.connection.execute(
            "select count(*) as count from governance_private.receipt_consumptions where receipt_hash=%s",
            (receipt_hash,),
        ).fetchone()
        return int(row["count"])

    def verify_audit_chain(self) -> bool:
        row = self.connection.execute(
            "select governance_private.verify_consumption_audit_chain() as valid"
        ).fetchone()
        return bool(row["valid"])
