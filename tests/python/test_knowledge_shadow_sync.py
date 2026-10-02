import hashlib
import json
from pathlib import Path

from tools.quality.evidence_ledger import EvidenceLedger
from tools.quality.knowledge_supabase_sync import (
    ParitySnapshot,
    _decision_dimension,
    prepare_existing_history,
    sync_knowledge_once,
    verify_parity,
)
from tools.quality.provenance_chain import ProvenanceChain
from tools.quality.replication_outbox import pending_events


def _digest(rows):
    raw = json.dumps(rows, sort_keys=False, separators=(",", ":"), ensure_ascii=False)
    return hashlib.sha256(raw.encode("utf-8")).hexdigest()


class FakeRemote:
    def __init__(self, *, failures: int = 0):
        self.failures = failures
        self.events = []

    def apply_event(self, event):
        if self.failures:
            self.failures -= 1
            raise RuntimeError("synthetic_remote_failure")
        self.events.append(event)

    def parity_snapshot(self, *, space_slug="litd"):
        assert space_slug == "litd"
        evidence = sorted(
            [
                [event.payload["evidence_id"], event.payload["canonical_hash"]]
                for event in self.events
                if event.event_type == "evidence_registered"
            ]
        )
        decisions = sorted(
            [
                [event.payload["sequence"], event.payload["entry_hash"]]
                for event in self.events
                if event.event_type == "evidence_decision"
            ]
        )
        provenance = sorted(
            [
                [event.payload["node_id"], event.payload["payload_hash"]]
                for event in self.events
                if event.event_type == "provenance_node"
            ]
        )
        return ParitySnapshot(
            evidence_count=len(evidence),
            evidence_digest=_digest(evidence),
            decision_count=len(decisions),
            decision_digest=_digest(decisions),
            provenance_count=len(provenance),
            provenance_digest=_digest(provenance),
        )


def test_local_writes_create_durable_outbox_events(tmp_path: Path):
    ledger = EvidenceLedger(tmp_path / "ledger.sqlite3")
    ledger.register_evidence("EV-001", "a" * 64, "https://example.com/source")
    ledger.append_decision("EV-001", "ACCEPTED_FOR_ROUTING", "validated")

    events = pending_events(ledger.connection)
    assert [event.event_type for event in events] == [
        "evidence_registered",
        "evidence_decision",
    ]
    assert ledger.pending_replication_count() == 2
    assert ledger.verify_chain() is True
    ledger.close()


def test_provenance_write_is_queued_in_same_local_store(tmp_path: Path):
    chain = ProvenanceChain(tmp_path / "provenance.sqlite3")
    chain.append(
        node_id="source",
        stage="SOURCE",
        evidence_id="EV-001",
        payload={"evidence_ref": "EV-001"},
    )

    events = pending_events(chain.connection)
    assert len(events) == 1
    assert events[0].event_type == "provenance_node"
    assert events[0].payload["evidence_id"] == "EV-001"
    assert chain.verify_integrity() is True
    chain.close()


def test_existing_history_backfill_is_idempotent_and_non_destructive(tmp_path: Path):
    ledger = EvidenceLedger(tmp_path / "ledger.sqlite3")
    ledger.register_evidence("EV-001", "b" * 64, "https://example.com/source")
    decision = ledger.append_decision("EV-001", "LITD_LIBRARY", "litd_specific_knowledge")
    ledger.connection.execute("DELETE FROM replication_outbox")
    ledger.connection.commit()

    chain = ProvenanceChain(tmp_path / "provenance.sqlite3")
    chain.append(
        node_id="source",
        stage="SOURCE",
        evidence_id="EV-001",
        payload={"evidence_ref": "EV-001"},
    )
    chain.connection.execute("DELETE FROM replication_outbox")
    chain.connection.commit()

    before_hash = ledger.connection.execute(
        "SELECT entry_hash FROM decision_ledger WHERE sequence=?",
        (decision.sequence,),
    ).fetchone()[0]
    before_node_hash = chain.connection.execute(
        "SELECT payload_hash FROM provenance_nodes WHERE node_id='source'"
    ).fetchone()[0]

    assert prepare_existing_history(ledger, chain) == (2, 1)
    assert prepare_existing_history(ledger, chain) == (0, 0)

    after_hash = ledger.connection.execute(
        "SELECT entry_hash FROM decision_ledger WHERE sequence=?",
        (decision.sequence,),
    ).fetchone()[0]
    after_node_hash = chain.connection.execute(
        "SELECT payload_hash FROM provenance_nodes WHERE node_id='source'"
    ).fetchone()[0]

    assert after_hash == before_hash
    assert after_node_hash == before_node_hash
    assert ledger.pending_replication_count() == 2
    assert chain.pending_replication_count() == 1

    ledger.close()
    chain.close()


def test_remote_failure_leaves_event_pending_for_retry(tmp_path: Path):
    ledger = EvidenceLedger(tmp_path / "ledger.sqlite3")
    ledger.register_evidence("EV-001", "c" * 64, "https://example.com/source")
    chain = ProvenanceChain(tmp_path / "provenance.sqlite3")

    remote = FakeRemote(failures=1)
    ledger_report, provenance_report = sync_knowledge_once(ledger, chain, remote)

    assert ledger_report.failed == 1
    assert ledger_report.remaining == 1
    assert provenance_report.last_error == "ledger_sync_failed"

    ledger_report, _ = sync_knowledge_once(ledger, chain, remote)
    assert ledger_report.failed == 0
    assert ledger_report.remaining == 0
    assert ledger.pending_replication_count() == 0

    row = ledger.connection.execute(
        "SELECT attempts, delivered_at, last_error FROM replication_outbox"
    ).fetchone()
    assert row["attempts"] == 2
    assert row["delivered_at"] is not None
    assert row["last_error"] is None

    ledger.close()
    chain.close()


def test_ledger_drains_before_provenance_and_parity_matches(tmp_path: Path):
    ledger = EvidenceLedger(tmp_path / "ledger.sqlite3")
    ledger.register_evidence("EV-001", "d" * 64, "https://example.com/source")
    ledger.append_decision("EV-001", "ACCEPTED_FOR_ROUTING", "validated")

    chain = ProvenanceChain(tmp_path / "provenance.sqlite3")
    chain.append(
        node_id="source",
        stage="SOURCE",
        evidence_id="EV-001",
        payload={"evidence_ref": "EV-001"},
    )

    remote = FakeRemote()
    ledger_report, provenance_report = sync_knowledge_once(ledger, chain, remote)

    assert ledger_report.remaining == 0
    assert provenance_report.remaining == 0
    assert [event.event_type for event in remote.events] == [
        "evidence_registered",
        "evidence_decision",
        "provenance_node",
    ]
    assert verify_parity(ledger, chain, remote).matches is True

    ledger.close()
    chain.close()


def test_decision_dimensions_preserve_non_ingest_history():
    assert _decision_dimension("ACCEPTED_FOR_ROUTING") == ("ingest", "accepted")
    assert _decision_dimension("LITD_LIBRARY") == ("routing", None)
    assert _decision_dimension("MANUAL_REVIEW") == ("other", None)
