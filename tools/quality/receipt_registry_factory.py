#!/usr/bin/env python3
"""Fail-closed production factory for the durable governance registry."""
from __future__ import annotations

import os

from tools.quality.postgres_receipt_consumption_registry import PostgresReceiptConsumptionRegistry

DATABASE_URL_ENV = "LITD_GOVERNANCE_DATABASE_URL"


def open_governance_registry() -> PostgresReceiptConsumptionRegistry:
    conninfo = os.environ.get(DATABASE_URL_ENV, "").strip()
    if not conninfo:
        raise RuntimeError(f"{DATABASE_URL_ENV} is required; SQLite fallback is forbidden")
    return PostgresReceiptConsumptionRegistry(conninfo)

