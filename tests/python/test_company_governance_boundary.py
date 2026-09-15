from dataclasses import replace

import pytest

from tools.quality.company_governance_boundary import (
    COMPANY_PROJECT_ID,
    COMPANY_TARGET_ROUTE,
    CompanyGovernanceBoundary,
    build_company_receipt,
)
from tools.quality.postgres_receipt_consumption_registry import ConsumptionResult


class FakeRegistry:
    def __init__(self, project_id=COMPANY_PROJECT_ID, target_route=COMPANY_TARGET_ROUTE):
        self.project_id = project_id
        self.target_route = target_route
        self.registered = []
        self.consumed = []

    def register_receipt(self, **kwargs):
        self.registered.append(kwargs)

    def consume(self, receipt_hash, *, consumer, actor, current_context_hash):
        self.consumed.append((receipt_hash, consumer, actor, current_context_hash))
        return ConsumptionResult(True, "ACCEPTED", "consumed_once", receipt_hash, "d" * 64)


def receipt():
    return build_company_receipt(
        receipt_id="company:test:1",
        receipt_kind="COMPANY_GUARDIAN_RECEIPT",
        source_hash="a" * 64,
        context_hash="b" * 64,
        expected_consumer="COMPANY_APPLICATION_REVIEW",
    )


def test_company_receipt_binds_project_route_and_consumer():
    row = receipt()
    assert row.project_id == "COMPANY"
    assert row.target_route == "COMPANY_LIBRARY"
    assert row.expected_consumer == "COMPANY_APPLICATION_REVIEW"
    assert row.verify_integrity() is True


def test_company_boundary_rejects_litd_registry():
    with pytest.raises(ValueError, match="project scope mismatch"):
        CompanyGovernanceBoundary(FakeRegistry(project_id="LITD", target_route="LITD_LIBRARY"))


def test_company_boundary_rejects_wrong_route():
    with pytest.raises(ValueError, match="route scope mismatch"):
        CompanyGovernanceBoundary(FakeRegistry(target_route="GENERAL_LIBRARY"))


def test_company_boundary_registers_only_company_scoped_receipt():
    fake = FakeRegistry()
    boundary = CompanyGovernanceBoundary(fake)
    row = receipt()
    boundary.register(row)
    assert fake.registered == [
        {
            "receipt_id": row.receipt_id,
            "receipt_hash": row.receipt_hash,
            "receipt_kind": row.receipt_kind,
            "source_hash": row.source_hash,
            "context_hash": row.context_hash,
            "expected_consumer": row.expected_consumer,
        }
    ]


def test_company_boundary_rejects_scope_substitution_before_registry():
    fake = FakeRegistry()
    boundary = CompanyGovernanceBoundary(fake)
    with pytest.raises(ValueError, match="project scope mismatch"):
        boundary.register(replace(receipt(), project_id="LITD"))
    assert fake.registered == []


def test_company_boundary_rejects_stale_hash_tampering_before_registry():
    fake = FakeRegistry()
    boundary = CompanyGovernanceBoundary(fake)
    with pytest.raises(ValueError, match="integrity mismatch"):
        boundary.register(replace(receipt(), context_hash="c" * 64))
    assert fake.registered == []


def test_company_boundary_rejects_wrong_consumer_before_registry():
    fake = FakeRegistry()
    boundary = CompanyGovernanceBoundary(fake)
    with pytest.raises(ValueError, match="consumer mismatch"):
        boundary.consume(
            receipt(),
            consumer="LITD_APPLICATION_REVIEW",
            actor="tester",
            current_context_hash="b" * 64,
        )
    assert fake.consumed == []


def test_company_boundary_consumes_through_registry_and_never_escalates_authority():
    fake = FakeRegistry()
    boundary = CompanyGovernanceBoundary(fake)
    row = receipt()
    result = boundary.consume(
        row,
        consumer=row.expected_consumer,
        actor="tester",
        current_context_hash=row.context_hash,
    )
    assert result.accepted is True
    assert fake.consumed == [
        (row.receipt_hash, row.expected_consumer, "tester", row.context_hash)
    ]
    assert boundary.core_write_allowed is False
    assert boundary.automatic_merge_allowed is False
    assert boundary.automatic_application_allowed is False


def test_company_boundary_supports_all_governed_lifecycle_receipt_kinds():
    kinds = {
        "COMPANY_INGRESS_RECEIPT",
        "COMPANY_LIBRARY_REVIEW_RECEIPT",
        "COMPANY_GUARDIAN_RECEIPT",
        "COMPANY_BOUNDED_IMPLEMENTATION_RECEIPT",
        "COMPANY_APPLICATION_DECISION_RECEIPT",
        "COMPANY_PROVENANCE_CHECKPOINT_RECEIPT",
    }
    for kind in kinds:
        row = build_company_receipt(
            receipt_id=f"company:{kind.lower()}",
            receipt_kind=kind,
            source_hash="1" * 64,
            context_hash="2" * 64,
            expected_consumer="COMPANY_LOCAL_CONSUMER",
        )
        assert row.verify_integrity() is True


def test_unsupported_receipt_kind_fails_closed():
    with pytest.raises(ValueError, match="unsupported COMPANY receipt kind"):
        build_company_receipt(
            receipt_id="company:bad",
            receipt_kind="LITD_GUARDIAN_RECEIPT",
            source_hash="a" * 64,
            context_hash="b" * 64,
            expected_consumer="COMPANY_LOCAL_CONSUMER",
        )
