from pathlib import Path


WORKFLOW = Path(".github/workflows/governance-postgres-live-cert.yml")
MIGRATION_WORKFLOW = Path(".github/workflows/governance-postgres-apply-migration.yml")
HARNESS = Path("tools/quality/postgres_registry_live_cert.py")
PROOF_MIGRATION = Path("supabase/migrations/20260915064500_governance_audit_chain_verification.sql")
PROJECT_ROUTE_MIGRATION = Path("supabase/migrations/20260915110500_governance_authorized_project_routes.sql")
ADAPTER = Path("tools/quality/postgres_receipt_consumption_registry.py")
COMPANY_ADAPTER = Path("tools/quality/company_postgres_receipt_consumption_registry.py")


def test_live_certification_is_manual_and_fail_closed() -> None:
    text = WORKFLOW.read_text(encoding="utf-8")
    assert "workflow_dispatch:" in text
    assert "GOVERNANCE_DATABASE_URL" in text
    assert "Fail closed when live database secret is absent" in text
    assert "exit 2" in text


def test_live_certification_retains_evidence() -> None:
    text = WORKFLOW.read_text(encoding="utf-8")
    assert "actions/upload-artifact@043fb46d1a93c77aae656e7c1c64a875d1fc6a0a" in text
    assert "postgres-live-certification.json" in text
    assert "retention-days: 90" in text
    assert "if-no-files-found: error" in text


def test_migration_workflow_targets_exact_company_boundary_migration() -> None:
    text = MIGRATION_WORKFLOW.read_text(encoding="utf-8")
    assert "workflow_dispatch:" in text
    assert "APPLY_GOVERNANCE_MIGRATION_20260915110500" in text
    assert "20260915110500_governance_authorized_project_routes.sql" in text
    assert "is_project_route_authorized('LITD','LITD_LIBRARY')" in text
    assert "is_project_route_authorized('COMPANY','COMPANY_LIBRARY')" in text
    assert "is_project_route_authorized('COMPANY','LITD_LIBRARY')" in text
    assert "retention-days: 90" in text


def test_harness_covers_complete_p0_registry_scenarios() -> None:
    text = HARNESS.read_text(encoding="utf-8")
    for scenario in (
        "identical_replay",
        "stale_context",
        "revocation",
        "supersession",
        "company_native_consumption",
        "unauthorized_project_route_registration",
        "cross_project_litd_to_company",
        "cross_project_company_to_litd",
        "wrong_target_route",
        "concurrent_double_consumption",
        "append_only_guards",
        "audit_chain_integrity",
    ):
        assert scenario in text
    assert 'project = "LITD"' in text
    assert "CompanyPostgresReceiptConsumptionRegistry" in text
    assert "CERT_SYNTHETIC" in text
    assert 'reason == "project_scope_mismatch"' in text
    assert 'reason == "target_route_mismatch"' in text
    assert 'reason == "receipt_superseded"' in text
    assert '"unauthorized_project_route" in unauthorized_error' in text


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


def test_project_route_authorization_is_private_and_fail_closed() -> None:
    text = PROJECT_ROUTE_MIGRATION.read_text(encoding="utf-8").lower()
    assert "('litd', 'litd_library')" in text
    assert "('company', 'company_library')" in text
    assert "registered_receipts_authorized_scope" in text
    assert "unauthorized_project_route" in text
    assert "authorized_project_routes_append_only" in text
    assert "is_project_route_authorized" in text
    assert "grant select" not in text
    assert "grant insert" not in text
    assert "grant update" not in text
    assert "grant delete" not in text


def test_adapter_uses_proof_rpcs_without_direct_table_access() -> None:
    text = ADAPTER.read_text(encoding="utf-8")
    assert "verify_consumption_audit_chain()" in text
    assert "probe_append_only_guards(%s,%s,%s,%s)" in text
    assert "select * from governance_private" not in text.lower()
    assert "update governance_private" not in text.lower()
    assert "delete from governance_private" not in text.lower()
    assert "insert into governance_private" not in text.lower()


def test_company_adapter_is_hard_bound_to_company_scope() -> None:
    text = COMPANY_ADAPTER.read_text(encoding="utf-8")
    assert 'COMPANY_PROJECT_ID = "COMPANY"' in text
    assert 'COMPANY_TARGET_ROUTE = "COMPANY_LIBRARY"' in text
    assert "project_id=COMPANY_PROJECT_ID" in text
    assert "target_route=COMPANY_TARGET_ROUTE" in text
    assert "is_project_route_authorized(%s,%s)" in text
