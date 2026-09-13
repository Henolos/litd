import os
from concurrent.futures import ThreadPoolExecutor

import pytest

from tools.quality.postgres_receipt_consumption_registry import PostgresReceiptConsumptionRegistry
from tools.quality.receipt_registry_factory import DATABASE_URL_ENV, open_governance_registry

DATABASE_URL = os.environ.get(DATABASE_URL_ENV)
pytestmark = pytest.mark.skipif(not DATABASE_URL, reason="PostgreSQL integration URL not configured")
CONSUMER = "GUARDIAN_CHANGE_GATE"
SOURCE_HASH = "b" * 64
CONTEXT_HASH = "c" * 64


def registry():
    return PostgresReceiptConsumptionRegistry(DATABASE_URL, allow_insecure_localhost=True)


def register(receipt_hash: str, receipt_id: str) -> None:
    db = registry()
    try:
        db.register_receipt(
            receipt_id=receipt_id,
            receipt_hash=receipt_hash,
            receipt_kind="LITD_VEILLEUR_REVIEW_RESOLUTION_RECEIPT",
            source_hash=SOURCE_HASH,
            context_hash=CONTEXT_HASH,
            expected_consumer=CONSUMER,
        )
    finally:
        db.close()


def test_postgres_consumes_once_and_preserves_chain():
    receipt_hash = "1" * 64
    register(receipt_hash, "postgres:once")
    db = registry()
    try:
        first = db.consume(receipt_hash, consumer=CONSUMER, actor="worker-1",
                           current_context_hash=CONTEXT_HASH)
        second = db.consume(receipt_hash, consumer=CONSUMER, actor="worker-2",
                            current_context_hash=CONTEXT_HASH)
        assert first.accepted is True
        assert first.reason == "consumed_once"
        assert second.accepted is False
        assert second.reason == "replay_detected"
        assert db.consumption_count(receipt_hash) == 1
        assert db.verify_audit_chain() is True
    finally:
        db.close()


def test_eight_concurrent_consumers_have_one_winner():
    receipt_hash = "2" * 64
    register(receipt_hash, "postgres:concurrent")

    def attempt(index: int):
        db = registry()
        try:
            return db.consume(receipt_hash, consumer=CONSUMER,
                              actor=f"worker-{index}", current_context_hash=CONTEXT_HASH)
        finally:
            db.close()

    with ThreadPoolExecutor(max_workers=8) as pool:
        results = list(pool.map(attempt, range(8)))
    assert sum(item.accepted for item in results) == 1
    assert sum(item.reason == "replay_detected" for item in results) == 7
    db = registry()
    try:
        assert db.consumption_count(receipt_hash) == 1
        assert db.verify_audit_chain() is True
    finally:
        db.close()


def test_stale_and_wrong_consumer_do_not_burn_receipt():
    receipt_hash = "3" * 64
    register(receipt_hash, "postgres:rejections")
    db = registry()
    try:
        stale = db.consume(receipt_hash, consumer=CONSUMER, actor="worker",
                           current_context_hash="d" * 64)
        wrong = db.consume(receipt_hash, consumer="APPLICATION_DECISION_GATE",
                           actor="worker", current_context_hash=CONTEXT_HASH)
        assert stale.reason == "stale_context"
        assert wrong.reason == "unexpected_consumer"
        assert db.consumption_count(receipt_hash) == 0
        assert db.verify_audit_chain() is True
    finally:
        db.close()


def test_revocation_is_enforced():
    receipt_hash = "4" * 64
    register(receipt_hash, "postgres:revoked")
    db = registry()
    try:
        db.invalidate_receipt(receipt_hash, kind="REVOKED",
                              reason="provenance invalidated", actor="guardian")
        result = db.consume(receipt_hash, consumer=CONSUMER, actor="worker",
                            current_context_hash=CONTEXT_HASH)
        assert result.accepted is False
        assert result.reason == "receipt_revoked"
        assert db.consumption_count(receipt_hash) == 0
    finally:
        db.close()


def test_factory_forbids_sqlite_fallback(monkeypatch):
    monkeypatch.delenv(DATABASE_URL_ENV, raising=False)
    with pytest.raises(RuntimeError, match="SQLite fallback is forbidden"):
        open_governance_registry()

