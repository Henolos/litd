from __future__ import annotations
from collections.abc import Mapping
from typing import Any
from tools.quality.governance_domain_isolation import assert_domain_isolation
from tools.quality.guardian_authority_contract import CANONICAL_AUTHORITY, assert_authority_equivalent

INFRASTRUCTURE_DOMAIN = "HENOLOS_INFRASTRUCTURE"
CRITICAL_INFRASTRUCTURE_SCOPES = frozenset({"production","identity_auth","secrets","backup_restore","destructive_operation","network_security_boundary","client_data","personal_data","global_governance"})

class InfrastructureGovernanceViolation(ValueError):
    pass

def assert_infrastructure_governance_binding(record: Mapping[str, Any]) -> None:
    assert_domain_isolation(record)
    if record.get("primary_domain") != INFRASTRUCTURE_DOMAIN:
        raise InfrastructureGovernanceViolation("primary_domain must be HENOLOS_INFRASTRUCTURE")
    authority = record.get("guardian_authority")
    if not isinstance(authority, dict):
        raise InfrastructureGovernanceViolation("guardian_authority required")
    assert_authority_equivalent(authority, require=tuple(CANONICAL_AUTHORITY))
    scopes = record.get("infrastructure_scopes", [])
    if not isinstance(scopes, list) or any(not isinstance(scope, str) for scope in scopes):
        raise InfrastructureGovernanceViolation("infrastructure_scopes must be a list of strings")
    if CRITICAL_INFRASTRUCTURE_SCOPES.intersection(scopes) and record.get("risk_class") != "CRITICAL":
        raise InfrastructureGovernanceViolation("critical infrastructure scope requires CRITICAL")
    if record.get("contains_plaintext_secret") is True:
        raise InfrastructureGovernanceViolation("plaintext secret forbidden in governance record")
    if record.get("contains_raw_client_payload") is True:
        raise InfrastructureGovernanceViolation("raw client payload forbidden in governance record")
    if record.get("external_resource_state") == "CLOSED":
        if record.get("real_state_verified") is not True:
            raise InfrastructureGovernanceViolation("external resource cannot close without real-state verification")
        if record.get("rollback_ready") is not True:
            raise InfrastructureGovernanceViolation("external resource cannot close without rollback readiness")
    credential_refs = record.get("credentials_or_authority_boundaries", [])
    if credential_refs and record.get("least_privilege_verified") is not True:
        raise InfrastructureGovernanceViolation("credential boundary requires least-privilege verification")
