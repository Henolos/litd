from pathlib import Path


WORKFLOW = Path(".github/workflows/governance-postgres-live-cert.yml")
HARNESS = Path("tools/quality/postgres_registry_live_cert.py")
PROOF_MIGRATION = Path("supabase/migrations/20260915064500_governance_audit_chain_verification.sql")
ADAPTER = Path("tools/quality/postgres_receipt_consumption_registry.py")


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


def test_harness_covers_complete_p0_registry_scenarios() -> None:
    text = HARNESS.read_text(encoding="utf-8")
    for scenario in (
        "identical_replay",
        "stale_context",
        "revocation",
        "supersession",
        "cross_project_litd_to_company",
        "cross_project_company_to_litd",
        "wrong_target_route",
        "concurrent_double_consumption",
        "append_only_guards",
        "audit_chain_integrity",
    ):
        assert scenario in text
    assert "LITD_CERT_" in text
    assert "COMPANY_CERT_" in text
    assert "CERT_SYNTHETIC" in text
    assert 'reason == "project_scope_mismatch"' in text
    assert 'reason == "target_route_mismatch"' in text
    assert 'reason == "receipt_superseded"' in text


def test_proof_rpcs_are_bounded_and_do_not_expose_private_rows() -> None:
    text = PROOF_MIGRATION.read_text(encoding="utf-8")
    assert "verify_consumption_audit_chain" in text
    assert "probe_append_only_guards" in text
    assert "security definer" in text.lower()
    assert "previous_hash_mismatch" in text
    assert "entry_hash_mismatch" in text
    assert "chain_valid" in text
    assert "when sqlstate '55000'" in text
    assert "grant execute" in text.lower()
    assert "to service_role" in text
    assert "grant select" not in text.lower()
    assert "grant update" not in text.lower()
    assert "grant delete" not in text.lower()


def test_adapter_uses_proof_rpcs_without_direct_table_access() -> None:
    text = ADAPTER.read_text(encoding="utf-8")
    assert "verify_consumption_audit_chain()" in text
    assert "probe_append_only_guards(%s,%s,%s,%s)" in text
    assert "select * from governance_private" not in text.lower()
    assert "update governance_private" not in text.lower()
    assert "delete from governance_private" not in text.lower()
    assert "insert into governance_private" not in text.lower()
