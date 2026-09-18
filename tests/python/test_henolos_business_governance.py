import pytest

from tools.quality.governance_domain_isolation import DomainIsolationViolation
from tools.quality.guardian_authority_contract import CANONICAL_AUTHORITY
from tools.quality.henolos_business_governance import (
    BusinessGovernanceViolation,
    assert_business_governance_binding,
)


def valid_business_record():
    return {
        "primary_domain": "HENOLOS_BUSINESS",
        "affected_domains": ["HENOLOS_BUSINESS"],
        "risk_class": "NORMAL",
        "data_classes_crossing_boundary": [],
        "cross_domain_interfaces": [],
        "credentials_or_authority_boundaries": [],
        "guardian_authority": dict(CANONICAL_AUTHORITY),
        "business_scopes": ["service_policy"],
        "contains_raw_client_payload": False,
        "contains_plaintext_secret": False,
        "external_resource_state": "READY",
        "real_state_verified": False,
        "staging_uses_real_client_data": False,
    }


def test_valid_business_policy_binding():
    assert_business_governance_binding(valid_business_record())


def test_business_binding_rejects_other_primary_domain():
    record = valid_business_record()
    record["primary_domain"] = "LITD"
    record["affected_domains"] = ["LITD"]
    with pytest.raises(BusinessGovernanceViolation, match="HENOLOS_BUSINESS"):
        assert_business_governance_binding(record)


def test_business_cannot_widen_global_guardian_authority():
    record = valid_business_record()
    record["guardian_authority"]["automatic_application_allowed"] = True
    with pytest.raises(ValueError, match="authority violation"):
        assert_business_governance_binding(record)


@pytest.mark.parametrize("scope", [
    "production", "identity_auth", "secrets", "personal_data",
    "client_data", "destructive_operation", "global_governance",
])
def test_sensitive_business_scopes_require_critical(scope):
    record = valid_business_record()
    record["business_scopes"] = [scope]
    with pytest.raises(BusinessGovernanceViolation, match="requires CRITICAL"):
        assert_business_governance_binding(record)


def test_raw_client_payload_is_forbidden():
    record = valid_business_record()
    record["contains_raw_client_payload"] = True
    with pytest.raises(BusinessGovernanceViolation, match="raw client payload"):
        assert_business_governance_binding(record)


def test_plaintext_secret_is_forbidden():
    record = valid_business_record()
    record["contains_plaintext_secret"] = True
    with pytest.raises(BusinessGovernanceViolation, match="plaintext secret"):
        assert_business_governance_binding(record)


def test_ready_does_not_require_real_state_verification():
    assert_business_governance_binding(valid_business_record())


def test_external_closed_requires_real_state_verification():
    record = valid_business_record()
    record["external_resource_state"] = "CLOSED"
    with pytest.raises(BusinessGovernanceViolation, match="real-state verification"):
        assert_business_governance_binding(record)


def test_verified_external_closed_is_accepted():
    record = valid_business_record()
    record["external_resource_state"] = "CLOSED"
    record["real_state_verified"] = True
    assert_business_governance_binding(record)


def test_staging_defaults_to_synthetic_data():
    record = valid_business_record()
    record["staging_uses_real_client_data"] = True
    with pytest.raises(BusinessGovernanceViolation, match="synthetic data"):
        assert_business_governance_binding(record)


def test_cross_domain_business_still_uses_isolation_contract():
    record = valid_business_record()
    record["affected_domains"] = ["HENOLOS_BUSINESS", "HENOLOS_INFRASTRUCTURE"]
    record["risk_class"] = "SENSITIVE"
    with pytest.raises(DomainIsolationViolation, match="interfaces must be explicit"):
        assert_business_governance_binding(record)
