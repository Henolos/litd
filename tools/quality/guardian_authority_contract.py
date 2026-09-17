#!/usr/bin/env python3
"""Canonical fail-closed authority contract owned by Guardian.

Phase 2 centralizes duplicated authority invariants without removing legacy
checks. Consumers can compare their receipts against this contract before the
legacy definitions are retired in later bounded phases.
"""
from __future__ import annotations

from typing import Any

CANONICAL_AUTHORITY = {
    "core_write_allowed": False,
    "automatic_code_write_allowed": False,
    "automatic_merge_allowed": False,
    "automatic_application_allowed": False,
    "automatic_target_change_allowed": False,
}

REQUIRED_GUARANTEES = {
    "tests_must_pass_before_application": True,
    "rollback_evidence_required": True,
}


def assert_authority_equivalent(payload: dict[str, Any], *, require: tuple[str, ...] = ()) -> None:
    """Fail closed unless every requested canonical invariant is explicit and equal."""
    for key in require:
        if key not in CANONICAL_AUTHORITY:
            raise ValueError(f"unknown canonical authority invariant:{key}")
        if payload.get(key) is not CANONICAL_AUTHORITY[key]:
            raise ValueError(f"authority invariant mismatch:{key}")


def assert_guarantees_equivalent(payload: dict[str, Any], *, require: tuple[str, ...] = ()) -> None:
    for key in require:
        if key not in REQUIRED_GUARANTEES:
            raise ValueError(f"unknown canonical guarantee:{key}")
        if payload.get(key) is not REQUIRED_GUARANTEES[key]:
            raise ValueError(f"Guardian guarantee mismatch:{key}")
