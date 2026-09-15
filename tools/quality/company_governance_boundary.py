#!/usr/bin/env python3
"""Bounded COMPANY/HENOLOS governance boundary backed by the shared registry.

The local boundary owns only scope validation and receipt construction. Durable
single-use enforcement remains in the governed PostgreSQL registry. This module
never writes a Core, merges code, or applies a change automatically.
"""
from __future__ import annotations

import json
from dataclasses import dataclass
from hashlib import sha256
from typing import Any

from tools.quality.postgres_receipt_consumption_registry import (
    ConsumptionResult,
    PostgresReceiptConsumptionRegistry,
)

COMPANY_PROJECT_ID = "COMPANY"
COMPANY_TARGET_ROUTE = "COMPANY_LIBRARY"

COMPANY_RECEIPT_KINDS = frozenset(
    {
        "COMPANY_INGRESS_RECEIPT",
        "COMPANY_LIBRARY_REVIEW_RECEIPT",
        "COMPANY_GUARDIAN_RECEIPT",
        "COMPANY_BOUNDED_IMPLEMENTATION_RECEIPT",
        "COMPANY_APPLICATION_DECISION_RECEIPT",
        "COMPANY_PROVENANCE_CHECKPOINT_RECEIPT",
    }
)

HEX64 = set("0123456789abcdef")


def _hex64(value: Any) -> bool:
    return isinstance(value, str) and len(value) == 64 and all(ch in HEX64 for ch in value)


def _canonical_hash(payload: dict[str, Any]) -> str:
    raw = json.dumps(payload, sort_keys=True, separators=(",", ":"), ensure_ascii=False)
    return sha256(raw.encode("utf-8")).hexdigest()


@dataclass(frozen=True)
class CompanyGovernanceReceipt:
    receipt_id: str
    receipt_hash: str
    receipt_kind: str
    project_id: str
    target_route: str
    source_hash: str
    context_hash: str
    expected_consumer: str

    def canonical_payload(self) -> dict[str, str]:
        return {
            "receipt_id": self.receipt_id,
            "receipt_kind": self.receipt_kind,
            "project_id": self.project_id,
            "target_route": self.target_route,
            "source_hash": self.source_hash,
            "context_hash": self.context_hash,
            "expected_consumer": self.expected_consumer,
        }

    def verify_integrity(self) -> bool:
        return self.receipt_hash == _canonical_hash(self.canonical_payload())


def build_company_receipt(
    *,
    receipt_id: str,
    receipt_kind: str,
    source_hash: str,
    context_hash: str,
    expected_consumer: str,
) -> CompanyGovernanceReceipt:
    receipt_id = receipt_id.strip()
    receipt_kind = receipt_kind.strip()
    expected_consumer = expected_consumer.strip()
    if not receipt_id:
        raise ValueError("receipt_id required")
    if receipt_kind not in COMPANY_RECEIPT_KINDS:
        raise ValueError("unsupported COMPANY receipt kind")
    if not _hex64(source_hash) or not _hex64(context_hash):
        raise ValueError("source_hash and context_hash must be 64 lowercase hex")
    if not expected_consumer:
        raise ValueError("expected_consumer required")

    payload = {
        "receipt_id": receipt_id,
        "receipt_kind": receipt_kind,
        "project_id": COMPANY_PROJECT_ID,
        "target_route": COMPANY_TARGET_ROUTE,
        "source_hash": source_hash,
        "context_hash": context_hash,
        "expected_consumer": expected_consumer,
    }
    return CompanyGovernanceReceipt(receipt_hash=_canonical_hash(payload), **payload)


class CompanyGovernanceBoundary:
    """Fail-closed COMPANY consumer boundary for the shared PostgreSQL registry."""

    core_write_allowed = False
    automatic_merge_allowed = False
    automatic_application_allowed = False

    def __init__(self, registry: PostgresReceiptConsumptionRegistry):
        if registry.project_id != COMPANY_PROJECT_ID:
            raise ValueError("COMPANY boundary project scope mismatch")
        if registry.target_route != COMPANY_TARGET_ROUTE:
            raise ValueError("COMPANY boundary route scope mismatch")
        self.registry = registry

    def register(self, receipt: CompanyGovernanceReceipt) -> None:
        self._validate_receipt(receipt)
        self.registry.register_receipt(
            receipt_id=receipt.receipt_id,
            receipt_hash=receipt.receipt_hash,
            receipt_kind=receipt.receipt_kind,
            source_hash=receipt.source_hash,
            context_hash=receipt.context_hash,
            expected_consumer=receipt.expected_consumer,
        )

    def consume(
        self,
        receipt: CompanyGovernanceReceipt,
        *,
        consumer: str,
        actor: str,
        current_context_hash: str,
    ) -> ConsumptionResult:
        self._validate_receipt(receipt)
        if consumer.strip() != receipt.expected_consumer:
            raise ValueError("COMPANY receipt consumer mismatch")
        return self.registry.consume(
            receipt.receipt_hash,
            consumer=consumer,
            actor=actor,
            current_context_hash=current_context_hash,
        )

    @staticmethod
    def _validate_receipt(receipt: CompanyGovernanceReceipt) -> None:
        if receipt.project_id != COMPANY_PROJECT_ID:
            raise ValueError("COMPANY receipt project scope mismatch")
        if receipt.target_route != COMPANY_TARGET_ROUTE:
            raise ValueError("COMPANY receipt route scope mismatch")
        if receipt.receipt_kind not in COMPANY_RECEIPT_KINDS:
            raise ValueError("unsupported COMPANY receipt kind")
        if not receipt.verify_integrity():
            raise ValueError("COMPANY receipt integrity mismatch")
