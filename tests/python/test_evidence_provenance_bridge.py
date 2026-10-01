import json
import sqlite3
from pathlib import Path

import pytest

from tools.quality.evidence_ledger import EvidenceLedger
from tools.quality.evidence_provenance_bridge import start_provenance_from_evidence
from tools.quality.provenance_chain import ProvenanceChain
from tools.quality.veilleur_v2_ingest import canonical_content_hash, validate_and_record


def _event(evidence_id: str = "EV-001") -> dict:
    title = "Verified Godot performance note"
    summary = "A verified source relevant to LITD performance."
    source_url = "https://example.com/source"
    return {
        "project_id": "LITD",
        "target_route": "LITD_LIBRARY",
        "evidence_id": evidence_id,
        "title": title,
        "summary": summary,
        "source_url": source_url,
        "source_verified": True,
        "source_confidence": 0.95,
        "discovered_at": "2026-10-01T12:00:00Z",
        "published_at": "2026-09-30T12:00:00Z",
        "domain_hints": ["godot", "performance"],
        "content_hash": canonical_content_hash(
            title, summary, source_url, "LITD", "LITD_LIBRARY"
        ),
    }


def _accepted_ledger(tmp_path: Path) -> EvidenceLedger:
    ledger = EvidenceLedger(tmp_path / "ledger.sqlite3")
    decision = validate_and_record(_event(), ledger)
    assert decision.accepted is True
    return ledger


def test_registered_evidence_starts_provenance_with_same_identity(tmp_path: Path):
    ledger = _accepted_ledger(tmp_path)
    chain = ProvenanceChain(tmp_path / "provenance.sqlite3")

    source = start_provenance_from_evidence(
        ledger, chain, evidence_id="EV-001", node_id="source-EV-001"
    )

    assert source.stage == "SOURCE"
    assert source.evidence_id == "EV-001"

    row = chain.connection.execute(
        "SELECT evidence_id, external_ref, payload_json FROM provenance_nodes WHERE node_id=?",
        ("source-EV-001",),
    ).fetchone()
    assert row["evidence_id"] == "EV-001"
    assert row["external_ref"] == "evidence:EV-001"

    payload = json.loads(row["payload_json"])
    assert payload == {
        "evidence_ref": "EV-001",
        "project_id": "LITD",
        "target_route": "LITD_LIBRARY",
    }
    assert "source_url" not in payload
    assert "canonical_hash" not in payload

    chain.close()
    ledger.close()


def test_unregistered_evidence_cannot_start_provenance(tmp_path: Path):
    ledger = EvidenceLedger(tmp_path / "ledger.sqlite3")
    chain = ProvenanceChain(tmp_path / "provenance.sqlite3")

    with pytest.raises(ValueError, match="evidence_not_registered"):
        start_provenance_from_evidence(
            ledger, chain, evidence_id="EV-MISSING", node_id="source-missing"
        )

    assert chain.connection.execute("SELECT COUNT(*) FROM provenance_nodes").fetchone()[0] == 0
    chain.close()
    ledger.close()


def test_descendants_inherit_evidence_identity(tmp_path: Path):
    ledger = _accepted_ledger(tmp_path)
    chain = ProvenanceChain(tmp_path / "provenance.sqlite3")
    source = start_provenance_from_evidence(
        ledger, chain, evidence_id="EV-001", node_id="source"
    )

    document = chain.append(
        node_id="document",
        stage="DOCUMENT",
        parent_id=source.node_id,
        payload={"document": "normalized"},
    )
    discovery = chain.append(
        node_id="discovery",
        stage="DISCOVERY",
        parent_id=document.node_id,
        payload={"finding": "candidate"},
    )

    assert document.evidence_id == "EV-001"
    assert discovery.evidence_id == "EV-001"
    assert chain.verify_integrity() is True

    chain.close()
    ledger.close()


def test_descendant_cannot_switch_evidence_identity(tmp_path: Path):
    ledger = _accepted_ledger(tmp_path)
    chain = ProvenanceChain(tmp_path / "provenance.sqlite3")
    source = start_provenance_from_evidence(
        ledger, chain, evidence_id="EV-001", node_id="source"
    )

    with pytest.raises(ValueError, match="evidence_id_mismatch"):
        chain.append(
            node_id="document",
            stage="DOCUMENT",
            parent_id=source.node_id,
            evidence_id="EV-OTHER",
            payload={"document": "normalized"},
        )

    chain.close()
    ledger.close()


def test_integrity_detects_evidence_identity_tampering(tmp_path: Path):
    ledger = _accepted_ledger(tmp_path)
    db = tmp_path / "provenance.sqlite3"
    chain = ProvenanceChain(db)
    source = start_provenance_from_evidence(
        ledger, chain, evidence_id="EV-001", node_id="source"
    )
    chain.append(
        node_id="document",
        stage="DOCUMENT",
        parent_id=source.node_id,
        payload={"document": "normalized"},
    )
    chain.close()

    raw = sqlite3.connect(db)
    raw.execute("DROP TRIGGER provenance_no_update")
    raw.execute(
        "UPDATE provenance_nodes SET evidence_id='EV-TAMPERED' WHERE node_id='document'"
    )
    raw.commit()
    raw.close()

    reopened = ProvenanceChain(db)
    assert reopened.verify_integrity() is False

    reopened.close()
    ledger.close()
