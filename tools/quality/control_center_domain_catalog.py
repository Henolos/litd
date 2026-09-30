#!/usr/bin/env python3
"""Build a read-only, repository-backed catalog of Control Center domain views."""
from __future__ import annotations

from hashlib import sha256
from pathlib import Path
from typing import Any

DOMAIN_SPECS = (
    {
        "id": "LITD",
        "kind": "domain",
        "authority_scope": "LITD",
        "sources": (
            "docs/governance/GLOBAL_GOVERNANCE_DOMAIN_ISOLATION.md",
            "tools/quality/governance_domain_isolation.py",
        ),
    },
    {
        "id": "HENOLOS_BUSINESS",
        "kind": "domain",
        "authority_scope": "HENOLOS_BUSINESS",
        "sources": (
            "docs/governance/HENOLOS_BUSINESS_GOVERNANCE_BINDING.md",
            "tools/quality/henolos_business_governance.py",
        ),
    },
    {
        "id": "HENOLOS_INFRASTRUCTURE",
        "kind": "domain",
        "authority_scope": "HENOLOS_INFRASTRUCTURE",
        "sources": (
            "docs/governance/HENOLOS_INFRASTRUCTURE_GOVERNANCE_BINDING.md",
            "tools/quality/henolos_infrastructure_governance.py",
        ),
    },
    {
        "id": "SECURITY_COMPLIANCE",
        "kind": "overlay",
        "authority_scope": "GLOBAL_GUARDIAN",
        "sources": (
            "tools/quality/guardian_authority_contract.py",
            "tools/quality/guardian_change_gate.py",
        ),
    },
    {
        "id": "VEILLEURS_KNOWLEDGE",
        "kind": "overlay",
        "authority_scope": "LITD",
        "sources": (
            "tools/quality/autonomous_veilleur.py",
            "docs/knowledge/source-registry.json",
        ),
    },
)


def _source_ref(root: Path, relative: str) -> dict[str, Any]:
    path = root / relative
    if not path.is_file():
        return {"path": relative, "present": False, "sha256": None}
    payload = path.read_bytes()
    return {"path": relative, "present": True, "sha256": sha256(payload).hexdigest()}


def collect(root: str | Path = ".") -> dict[str, Any]:
    """Collect only repository metadata; never import domain payloads or secrets."""
    base = Path(root)
    views: list[dict[str, Any]] = []
    for spec in DOMAIN_SPECS:
        refs = [_source_ref(base, relative) for relative in spec["sources"]]
        views.append(
            {
                "id": spec["id"],
                "kind": spec["kind"],
                "authority_scope": spec["authority_scope"],
                "status": "AVAILABLE" if all(ref["present"] for ref in refs) else "SOURCE_MISSING",
                "source_refs": refs,
                "contains_payload_data": False,
                "contains_secret_values": False,
                "mutation_authority": False,
            }
        )
    return {
        "source": "repository_domain_catalog_read_only",
        "views": views,
        "domain_count": sum(view["kind"] == "domain" for view in views),
        "overlay_count": sum(view["kind"] == "overlay" for view in views),
        "authority": "observation_only",
    }
