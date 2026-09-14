from pathlib import Path


WORKFLOW = Path(".github/workflows/governance-postgres-live-cert.yml")
HARNESS = Path("tools/quality/postgres_registry_live_cert.py")


def test_live_certification_is_manual_and_fail_closed() -> None:
    text = WORKFLOW.read_text(encoding="utf-8")
    assert "workflow_dispatch:" in text
    assert "GOVERNANCE_DATABASE_URL" in text
    assert "Fail closed when live database secret is absent" in text
    assert "exit 2" in text


def test_live_certification_retains_evidence() -> None:
    text = WORKFLOW.read_text(encoding="utf-8")
    assert "actions/upload-artifact@v4" in text
    assert "postgres-live-certification.json" in text
    assert "retention-days: 90" in text
    assert "if-no-files-found: error" in text


def test_harness_covers_required_p0_scenarios() -> None:
    text = HARNESS.read_text(encoding="utf-8")
    for scenario in (
        "identical_replay",
        "stale_context",
        "revocation",
        "cross_project_rejection",
        "concurrent_double_consumption",
    ):
        assert scenario in text
    assert "LITD_CERT_" in text
    assert "COMPANY_CERT_" in text
    assert "CERT_SYNTHETIC" in text
    assert "consumption_count(" not in text
    assert 'cross.reason == "project_scope_mismatch"' in text
