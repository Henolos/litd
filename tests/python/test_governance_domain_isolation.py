import pytest

from tools.quality.governance_domain_isolation import (
    DomainIsolationViolation,
    assert_domain_isolation,
)


def valid_single_domain():
    return {
        "primary_domain": "LITD",
        "affected_domains": ["LITD"],
        "risk_class": "NORMAL",
        "data_classes_crossing_boundary": [],
        "cross_domain_interfaces": [],
        "credentials_or_authority_boundaries": [],
    }


def valid_cross_domain():
    return {
        "primary_domain": "HENOLOS_BUSINESS",
        "affected_domains": ["HENOLOS_BUSINESS", "HENOLOS_INFRASTRUCTURE"],
        "risk_class": "SENSITIVE",
        "data_classes_crossing_boundary": ["synthetic_staging_data"],
        "cross_domain_interfaces": ["business-staging -> infrastructure-database"],
        "credentials_or_authority_boundaries": [
            {"reference": "secret-manager://staging/database", "domain": "HENOLOS_INFRASTRUCTURE"}
        ],
        "isolation_verification": {"verified": True},
        "domain_specific_rollback_impact": {
            "HENOLOS_BUSINESS": "remove staging binding",
            "HENOLOS_INFRASTRUCTURE": "revoke staging database binding",
        },
    }


def test_single_domain_normal_is_valid():
    assert_domain_isolation(valid_single_domain())


def test_cross_domain_requires_sensitive_minimum():
    record = valid_cross_domain()
    record["risk_class"] = "NORMAL"
    with pytest.raises(DomainIsolationViolation, match="SENSITIVE minimum"):
        assert_domain_isolation(record)


def test_client_data_crossing_boundary_requires_critical():
    record = valid_cross_domain()
    record["data_classes_crossing_boundary"] = ["client_data"]
    with pytest.raises(DomainIsolationViolation, match="requires CRITICAL"):
        assert_domain_isolation(record)


def test_critical_client_data_boundary_is_valid_when_explicit():
    record = valid_cross_domain()
    record["risk_class"] = "CRITICAL"
    record["data_classes_crossing_boundary"] = ["client_data"]
    assert_domain_isolation(record)


def test_cross_domain_requires_explicit_interface():
    record = valid_cross_domain()
    record["cross_domain_interfaces"] = []
    with pytest.raises(DomainIsolationViolation, match="interfaces must be explicit"):
        assert_domain_isolation(record)


def test_cross_domain_requires_verified_isolation():
    record = valid_cross_domain()
    record["isolation_verification"] = {"verified": False}
    with pytest.raises(DomainIsolationViolation, match="must pass"):
        assert_domain_isolation(record)


def test_secret_values_are_forbidden_from_change_record():
    record = valid_cross_domain()
    record["credentials_or_authority_boundaries"] = [
        {
            "reference": "secret-manager://staging/database",
            "domain": "HENOLOS_INFRASTRUCTURE",
            "secret_value": "must-never-be-here",
        }
    ]
    with pytest.raises(DomainIsolationViolation, match="secret values are forbidden"):
        assert_domain_isolation(record)


def test_credential_reference_cannot_escape_affected_domains():
    record = valid_single_domain()
    record["credentials_or_authority_boundaries"] = [
        {"reference": "secret-manager://business/client", "domain": "HENOLOS_BUSINESS"}
    ]
    with pytest.raises(DomainIsolationViolation, match="outside affected domains"):
        assert_domain_isolation(record)


def test_cross_domain_requires_rollback_for_every_domain():
    record = valid_cross_domain()
    del record["domain_specific_rollback_impact"]["HENOLOS_INFRASTRUCTURE"]
    with pytest.raises(DomainIsolationViolation, match="rollback impact"):
        assert_domain_isolation(record)
