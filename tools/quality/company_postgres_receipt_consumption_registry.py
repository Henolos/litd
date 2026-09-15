#!/usr/bin/env python3
"""Strict COMPANY consumer for the shared PostgreSQL governance receipt registry.

The COMPANY consumer fixes its identity to COMPANY / COMPANY_LIBRARY. Callers
cannot override those values, which prevents accidental cross-project routing at
the adapter boundary. The database independently enforces the same mapping.
"""
from __future__ import annotations

from typing import Any

from tools.quality.postgres_receipt_consumption_registry import PostgresReceiptConsumptionRegistry

COMPANY_PROJECT_ID = "COMPANY"
COMPANY_TARGET_ROUTE = "COMPANY_LIBRARY"


class CompanyPostgresReceiptConsumptionRegistry(PostgresReceiptConsumptionRegistry):
    """PostgreSQL registry client permanently bound to the COMPANY scope."""

    def __init__(self, connection: Any):
        super().__init__(
            connection,
            project_id=COMPANY_PROJECT_ID,
            target_route=COMPANY_TARGET_ROUTE,
        )

    def verify_company_scope_authorized(self) -> bool:
        """Ask the bounded proof RPC whether COMPANY's canonical route is authorized."""
        try:
            with self.connection.cursor() as cursor:
                cursor.execute(
                    "select governance_private.is_project_route_authorized(%s,%s)",
                    (COMPANY_PROJECT_ID, COMPANY_TARGET_ROUTE),
                )
                row = cursor.fetchone()
            if row is None:
                raise RuntimeError("project-route authorization verifier returned no result")
            self.connection.commit()
            return bool(row[0])
        except Exception:
            self.connection.rollback()
            raise
