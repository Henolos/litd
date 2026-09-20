#!/usr/bin/env python3
"""Read-only governance-evidence interpretation for the HENOLOS Control Center."""
from __future__ import annotations

from typing import Any

VERIFIED_CLOSURE_STATUSES = {"APPLIED_MEASURED_PROVENANCE_VERIFIED"}


def evaluate_evidence(receipts: list[dict[str, Any]]) -> dict[str, Any]:
    """Return evidence completeness without mutating or trusting decorative flags."""
    verified = []
    for receipt in receipts:
        kind = receipt.get("kind")
        status = receipt.get("status")
        closure_hash = receipt.get("closure_hash")
        if (
            kind == "LITD_APPLICATION_CLOSURE_RECEIPT"
            and status in VERIFIED_CLOSURE_STATUSES
            and isinstance(closure_hash, str)
            and len(closure_hash) == 64
            and all(c in "0123456789abcdef" for c in closure_hash)
            and receipt.get("blockers") == []
        ):
            verified.append(receipt)

    latest = verified[-1] if verified else None
    return {
        "evidence_complete": latest is not None,
        "last_evidence": f"closure:{latest['closure_hash']}" if latest else None,
        "verified_receipts": len(verified),
        "authority": "read_only_evidence_interpretation",
    }
