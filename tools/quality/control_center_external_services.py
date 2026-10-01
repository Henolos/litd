#!/usr/bin/env python3
"""Normalize external service observations without granting collection authority."""
from __future__ import annotations

from typing import Any

ALLOWED_STATES = {
    "ACTIVE_HEALTHY",
    "ADVISORY",
    "DEGRADED",
    "UNHEALTHY",
    "VISIBILITY_UNAVAILABLE",
    "NOT_CONFIGURED",
}
ALLOWED_VIEWS = {"HENOLOS_BUSINESS", "HENOLOS_INFRASTRUCTURE", "SECURITY_COMPLIANCE"}


def normalize(observation: dict[str, Any]) -> dict[str, Any]:
    view_id = str(observation.get("view_id", ""))
    if view_id not in ALLOWED_VIEWS:
        raise ValueError("external service observation has invalid view")

    state = str(observation.get("state", ""))
    if state not in ALLOWED_STATES:
        raise ValueError("external service observation has invalid state")

    source = str(observation.get("source", ""))
    if not source:
        raise ValueError("external service observation requires a source")

    return {
        "view_id": view_id,
        "service": str(observation.get("service", "")),
        "state": state,
        "source": source,
        "observed_at": observation.get("observed_at"),
        "project_ref": observation.get("project_ref"),
        "region": observation.get("region"),
        "security_advisory_count": int(observation.get("security_advisory_count", 0)),
        "performance_advisory_count": int(observation.get("performance_advisory_count", 0)),
        "visibility": str(observation.get("visibility", "available")),
        "contains_payload_data": False,
        "contains_secret_values": False,
        "mutation_authority": False,
    }


def unavailable(*, view_id: str, service: str, source: str, observed_at: str | None = None) -> dict[str, Any]:
    return normalize(
        {
            "view_id": view_id,
            "service": service,
            "state": "VISIBILITY_UNAVAILABLE",
            "source": source,
            "observed_at": observed_at,
            "visibility": "unavailable",
        }
    )


def build(observations: list[dict[str, Any]]) -> dict[str, Any]:
    return {
        "source": "external_service_observations",
        "authority": "observation_only",
        "semantics": "external_service_evidence_not_governance_closure",
        "observations": [normalize(item) for item in observations],
    }
