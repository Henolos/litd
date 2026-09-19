from __future__ import annotations

from collections.abc import Mapping
from typing import Any

ALLOWED_DOMAINS = frozenset({"LITD", "HENOLOS_BUSINESS", "HENOLOS_INFRASTRUCTURE"})
RISK_ORDER = {"NORMAL": 0, "SENSITIVE": 1, "CRITICAL": 2}
CRITICAL_DATA_CLASSES = frozenset({"client_data", "personal_data", "secrets", "credentials"})


class DomainIsolationViolation(ValueError):
    pass


def _require_nonempty_string(value: Any, field: str) -> str:
    if not isinstance(value, str) or not value.strip():
        raise DomainIsolationViolation(f"invalid or missing {field}")
    return value.strip()


def assert_domain_isolation(record: Mapping[str, Any]) -> None:
    primary = _require_nonempty_string(record.get("primary_domain"), "primary_domain")
    if primary not in ALLOWED_DOMAINS:
        raise DomainIsolationViolation("unknown primary_domain")

    affected = record.get("affected_domains")
    if not isinstance(affected, list) or not affected:
        raise DomainIsolationViolation("affected_domains must be a non-empty list")
    if any(domain not in ALLOWED_DOMAINS for domain in affected):
        raise DomainIsolationViolation("unknown affected domain")
    if len(set(affected)) != len(affected):
        raise DomainIsolationViolation("duplicate affected domain")
    if primary not in affected:
        raise DomainIsolationViolation("primary_domain must be affected")

    risk = _require_nonempty_string(record.get("risk_class"), "risk_class")
    if risk not in RISK_ORDER:
        raise DomainIsolationViolation("unknown risk_class")

    cross_domain = len(affected) > 1
    if cross_domain and RISK_ORDER[risk] < RISK_ORDER["SENSITIVE"]:
        raise DomainIsolationViolation("cross-domain change requires SENSITIVE minimum")

    data_classes = record.get("data_classes_crossing_boundary", [])
    if not isinstance(data_classes, list) or any(not isinstance(item, str) for item in data_classes):
        raise DomainIsolationViolation("invalid data_classes_crossing_boundary")

    critical_boundary = bool(CRITICAL_DATA_CLASSES.intersection(data_classes))
    if cross_domain and critical_boundary and risk != "CRITICAL":
        raise DomainIsolationViolation("sensitive data boundary requires CRITICAL")

    interfaces = record.get("cross_domain_interfaces", [])
    if cross_domain and (not isinstance(interfaces, list) or not interfaces):
        raise DomainIsolationViolation("cross-domain interfaces must be explicit")

    credential_refs = record.get("credentials_or_authority_boundaries", [])
    if not isinstance(credential_refs, list):
        raise DomainIsolationViolation("invalid credentials_or_authority_boundaries")
    for reference in credential_refs:
        if not isinstance(reference, Mapping):
            raise DomainIsolationViolation("credential boundary must be a reference object")
        if "secret_value" in reference or "credential_value" in reference:
            raise DomainIsolationViolation("secret values are forbidden in Change Records")
        _require_nonempty_string(reference.get("reference"), "credential boundary reference")
        domain = _require_nonempty_string(reference.get("domain"), "credential boundary domain")
        if domain not in affected:
            raise DomainIsolationViolation("credential boundary outside affected domains")

    if cross_domain:
        isolation = record.get("isolation_verification")
        if not isinstance(isolation, Mapping):
            raise DomainIsolationViolation("isolation_verification required")
        if isolation.get("verified") is not True:
            raise DomainIsolationViolation("isolation verification must pass")

        rollback = record.get("domain_specific_rollback_impact")
        if not isinstance(rollback, Mapping):
            raise DomainIsolationViolation("domain-specific rollback impact required")
        for domain in affected:
            _require_nonempty_string(rollback.get(domain), f"rollback impact for {domain}")
