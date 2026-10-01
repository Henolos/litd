#!/usr/bin/env python3
"""Fail-closed bridge from the Evidence Ledger to the Provenance Chain."""
from __future__ import annotations

from tools.quality.evidence_ledger import EvidenceLedger
from tools.quality.provenance_chain import ProvenanceChain, ProvenanceNode


def start_provenance_from_evidence(
    ledger: EvidenceLedger,
    chain: ProvenanceChain,
    *,
    evidence_id: str,
    node_id: str,
) -> ProvenanceNode:
    """Create the provenance root for an already registered evidence item.

    The Evidence Ledger remains the canonical registry for source URL, canonical
    hash and ingress audit. The Provenance Chain stores only a stable reference
    to that registered evidence and the project/route boundary needed to prevent
    cross-scope reuse.
    """
    if not evidence_id or not evidence_id.strip():
        raise ValueError("empty_evidence_id")

    evidence = ledger.get_evidence(evidence_id)
    if evidence is None:
        raise ValueError("evidence_not_registered")

    return chain.append(
        node_id=node_id,
        stage="SOURCE",
        evidence_id=evidence.evidence_id,
        external_ref=f"evidence:{evidence.evidence_id}",
        payload={
            "evidence_ref": evidence.evidence_id,
            "project_id": evidence.project_id,
            "target_route": evidence.target_route,
        },
    )
