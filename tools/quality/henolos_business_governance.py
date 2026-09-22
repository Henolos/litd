from __future__ import annotations

from collections.abc import Mapping
from typing import Any

from tools.quality.governance_domain_isolation import assert_domain_isolation
from tools.quality.guardian_authority_contract import (
    CANONICAL_AUTHORITY,
    assert_authority_equivalent,
)

BUSINESS_DOMAIN = "HENOLOS_BUSINESS"
CRITICAL_BUSINESS_SCOPES = frozenset({
    "production",
    "identity_auth",
    "secrets",
    "personal_data",
    "client_data",
    "destructive_operation",
    "global_governance",
})


class BusinessGovernanceViolation(ValueError):
    pass


def assert_business_governance_binding(record: Mapping[str, Any]) -> None:
    """Validate HENOLOS Business binding without granting execution authority."""
    assert_domain_isolation(record)

    if record.get("primary_domain") != BUSINESS_DOMAIN:
        raise BusinessGovernanceViolation("primary_domain must be HENOLOS_BUSINESS")

    authority = record.get("guardian_authority")
    if not isinstance(authority, dict):
        raise BusinessGovernanceViolation("guardian_authority required")

    assert_authority_equivalent(
        authority,
        require=tuple(CANONICAL_AUTHORITY),
    )

    scopes = record.get("business_scopes", [])
    if not isinstance(scopes, list) or any(not isinstance(scope, str) for scope in scopes):
        raise BusinessGovernanceViolation("business_scopes must be a list of strings")

    if CRITICAL_BUSINESS_SCOPES.intersection(scopes) and record.get("risk_class") != "CRITICAL":
        raise BusinessGovernanceViolation("critical HENOLOS Business scope requires CRITICAL")

    if record.get("contains_raw_client_payload") is True:
        raise BusinessGovernanceViolation("raw client payload forbidden in governance record")
    if record.get("contains_plaintext_secret") is True:
        raise BusinessGovernanceViolation("plaintext secret forbidden in governance record")

    if record.get("external_resource_state") == "CLOSED" and record.get("real_state_verified") is not True:
        raise BusinessGovernanceViolation("external resource cannot close without real-state verification")

    if record.get("staging_uses_real_client_data") is True and record.get("real_client_data_required") is not True:
        raise BusinessGovernanceViolation("staging must use synthetic data when real client data is unnecessary")
