#!/usr/bin/env python3
"""Canonical fail-closed authority contract owned by Guardian.

Authority invariants live here once and are consumed by governed stages. Receipt
field names remain stable while duplicated literal definitions are retired only
after fail-closed equivalence has been established.
"""
from __future__ import annotations

from typing import Any

CANONICAL_AUTHORITY = {
    "core_write_allowed": False,
    "automatic_code_write_allowed": False,
    "automatic_merge_allowed": False,
    "automatic_application_allowed": False,
    "automatic_rollback_allowed": False,
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
            raise ValueError(f"authority violation:{key}")


def assert_guarantees_equivalent(payload: dict[str, Any], *, require: tuple[str, ...] = ()) -> None:
    for key in require:
        if key not in REQUIRED_GUARANTEES:
            raise ValueError(f"unknown canonical guarantee:{key}")
        if payload.get(key) is not REQUIRED_GUARANTEES[key]:
            raise ValueError(f"Guardian guarantee mismatch:{key}")
