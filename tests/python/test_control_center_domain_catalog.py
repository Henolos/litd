from pathlib import Path

from tools.quality.control_center_domain_catalog import collect


def _write(root: Path, relative: str, value: str = "evidence") -> None:
    path = root / relative
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(value, encoding="utf-8")


def test_catalog_keeps_domains_and_overlays_separate(tmp_path):
    sources = (
        "docs/governance/GLOBAL_GOVERNANCE_DOMAIN_ISOLATION.md",
        "tools/quality/governance_domain_isolation.py",
        "docs/governance/HENOLOS_BUSINESS_GOVERNANCE_BINDING.md",
        "tools/quality/henolos_business_governance.py",
        "docs/governance/HENOLOS_INFRASTRUCTURE_GOVERNANCE_BINDING.md",
        "tools/quality/henolos_infrastructure_governance.py",
        "tools/quality/guardian_authority_contract.py",
        "tools/quality/guardian_change_gate.py",
        "tools/quality/autonomous_veilleur.py",
        "docs/knowledge/source-registry.json",
    )
    for source in sources:
        _write(tmp_path, source)

    result = collect(tmp_path)
    views = {view["id"]: view for view in result["views"]}

    assert result["source"] == "repository_domain_catalog_read_only"
    assert result["authority"] == "observation_only"
    assert result["domain_count"] == 3
    assert result["overlay_count"] == 2
    assert views["VEILLEURS_KNOWLEDGE"]["kind"] == "overlay"
    assert views["VEILLEURS_KNOWLEDGE"]["authority_scope"] == "LITD"
    assert views["SECURITY_COMPLIANCE"]["kind"] == "overlay"
    assert views["SECURITY_COMPLIANCE"]["authority_scope"] == "GLOBAL_GUARDIAN"
    assert all(view["mutation_authority"] is False for view in views.values())
    assert all(view["contains_secret_values"] is False for view in views.values())


def test_catalog_reports_missing_source_without_inventing_health(tmp_path):
    _write(tmp_path, "docs/governance/GLOBAL_GOVERNANCE_DOMAIN_ISOLATION.md")

    result = collect(tmp_path)
    litd = next(view for view in result["views"] if view["id"] == "LITD")

    assert litd["status"] == "SOURCE_MISSING"
    assert any(ref["present"] is False for ref in litd["source_refs"])
