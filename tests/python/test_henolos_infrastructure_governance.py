import pytest
from tools.quality.governance_domain_isolation import DomainIsolationViolation
from tools.quality.guardian_authority_contract import CANONICAL_AUTHORITY
from tools.quality.henolos_infrastructure_governance import InfrastructureGovernanceViolation, assert_infrastructure_governance_binding

def valid_record():
    return {"primary_domain":"HENOLOS_INFRASTRUCTURE","affected_domains":["HENOLOS_INFRASTRUCTURE"],"risk_class":"NORMAL","data_classes_crossing_boundary":[],"cross_domain_interfaces":[],"credentials_or_authority_boundaries":[],"guardian_authority":dict(CANONICAL_AUTHORITY),"infrastructure_scopes":["configuration_policy"],"contains_plaintext_secret":False,"contains_raw_client_payload":False,"external_resource_state":"READY","real_state_verified":False,"rollback_ready":False,"least_privilege_verified":False}

def test_valid_configuration_binding(): assert_infrastructure_governance_binding(valid_record())

def test_rejects_other_primary_domain():
    r=valid_record(); r["primary_domain"]="HENOLOS_BUSINESS"; r["affected_domains"]=["HENOLOS_BUSINESS"]
    with pytest.raises(InfrastructureGovernanceViolation, match="HENOLOS_INFRASTRUCTURE"): assert_infrastructure_governance_binding(r)

def test_cannot_widen_guardian_authority():
    r=valid_record(); r["guardian_authority"]["automatic_merge_allowed"]=True
    with pytest.raises(ValueError, match="authority violation"): assert_infrastructure_governance_binding(r)

@pytest.mark.parametrize("scope",["production","identity_auth","secrets","backup_restore","destructive_operation","network_security_boundary","client_data","personal_data","global_governance"])
def test_critical_scopes_require_critical(scope):
    r=valid_record(); r["infrastructure_scopes"]=[scope]
    with pytest.raises(InfrastructureGovernanceViolation, match="requires CRITICAL"): assert_infrastructure_governance_binding(r)

def test_plaintext_secret_forbidden():
    r=valid_record(); r["contains_plaintext_secret"]=True
    with pytest.raises(InfrastructureGovernanceViolation, match="plaintext secret"): assert_infrastructure_governance_binding(r)

def test_raw_client_payload_forbidden():
    r=valid_record(); r["contains_raw_client_payload"]=True
    with pytest.raises(InfrastructureGovernanceViolation, match="raw client payload"): assert_infrastructure_governance_binding(r)

def test_closed_requires_real_state_verification():
    r=valid_record(); r["external_resource_state"]="CLOSED"; r["rollback_ready"]=True
    with pytest.raises(InfrastructureGovernanceViolation, match="real-state verification"): assert_infrastructure_governance_binding(r)

def test_closed_requires_rollback_readiness():
    r=valid_record(); r["external_resource_state"]="CLOSED"; r["real_state_verified"]=True
    with pytest.raises(InfrastructureGovernanceViolation, match="rollback readiness"): assert_infrastructure_governance_binding(r)

def test_verified_closed_is_accepted():
    r=valid_record(); r["external_resource_state"]="CLOSED"; r["real_state_verified"]=True; r["rollback_ready"]=True
    assert_infrastructure_governance_binding(r)

def test_credential_boundary_requires_least_privilege():
    r=valid_record(); r["credentials_or_authority_boundaries"]=[{"reference":"secret-manager://infra/deploy","domain":"HENOLOS_INFRASTRUCTURE"}]
    with pytest.raises(InfrastructureGovernanceViolation, match="least-privilege"): assert_infrastructure_governance_binding(r)

def test_cross_domain_still_uses_isolation_contract():
    r=valid_record(); r["affected_domains"]=["HENOLOS_INFRASTRUCTURE","HENOLOS_BUSINESS"]; r["risk_class"]="SENSITIVE"
    with pytest.raises(DomainIsolationViolation, match="interfaces must be explicit"): assert_infrastructure_governance_binding(r)
