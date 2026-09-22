from inspect import signature
from pathlib import Path

import pytest

from tools.quality.company_postgres_receipt_consumption_registry import (
    COMPANY_PROJECT_ID,
    COMPANY_TARGET_ROUTE,
    CompanyPostgresReceiptConsumptionRegistry,
)


MIGRATION = Path("supabase/migrations/20260915110500_governance_authorized_project_routes.sql")


def test_company_consumer_is_permanently_bound_to_company_scope() -> None:
    registry = CompanyPostgresReceiptConsumptionRegistry(object())
    assert COMPANY_PROJECT_ID == "COMPANY"
    assert COMPANY_TARGET_ROUTE == "COMPANY_LIBRARY"
    assert registry.project_id == "COMPANY"
    assert registry.target_route == "COMPANY_LIBRARY"
    assert list(signature(CompanyPostgresReceiptConsumptionRegistry).parameters) == ["connection"]
    with pytest.raises(TypeError):
        CompanyPostgresReceiptConsumptionRegistry(object(), project_id="LITD")  # type: ignore[call-arg]


def test_shared_registry_authorizes_only_explicit_project_route_pairs() -> None:
    text = MIGRATION.read_text(encoding="utf-8")
    assert "('LITD', 'LITD_LIBRARY')" in text
    assert "('COMPANY', 'COMPANY_LIBRARY')" in text
    assert "registered_receipts_authorized_scope" in text
    assert "before insert on governance_private.registered_receipts" in text.lower()
    assert "unauthorized_project_route" in text
    assert "authorized_project_routes_append_only" in text
    assert "before update or delete on governance_private.authorized_project_routes" in text.lower()


def test_authorization_mapping_is_private_and_bounded() -> None:
    text = MIGRATION.read_text(encoding="utf-8").lower()
    assert "enable row level security" in text
    assert "revoke all on governance_private.authorized_project_routes from public, anon, authenticated, service_role" in text
    assert "is_project_route_authorized" in text
    assert "grant execute on function governance_private.is_project_route_authorized(text,text) to service_role" in text
    assert "grant select" not in text
    assert "grant insert" not in text
    assert "grant update" not in text
    assert "grant delete" not in text
