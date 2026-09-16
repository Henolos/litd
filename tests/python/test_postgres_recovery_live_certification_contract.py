from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MIGRATION = ROOT / "supabase/migrations/20260916061000_governance_recovery_containment.sql"
RUNNER = ROOT / "tools/quality/postgres_recovery_live_cert.py"
MIGRATION_WORKFLOW = ROOT / ".github/workflows/governance-recovery-apply-migration.yml"
CERT_WORKFLOW = ROOT / ".github/workflows/governance-recovery-live-cert.yml"
RUNBOOK = ROOT / "docs/knowledge/GLOBAL_GOVERNANCE_LIVE_RECOVERY_RUNBOOK.md"


def text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_recovery_schema_is_private_and_scope_bound():
    sql = text(MIGRATION)
    assert "governance_private.recovery_drill_state" in sql
    assert "governance_private.recovery_audit" in sql
    assert "authorized_project_routes" in sql
    assert "enable row level security" in sql
    assert "revoke all on governance_private.recovery_drill_state from public, anon, authenticated, service_role" in sql
    assert "revoke all on governance_private.recovery_audit from public, anon, authenticated, service_role" in sql
    assert "recovery_audit_append_only" in sql


def test_recovery_authority_is_split_from_normal_service_role():
    sql = text(MIGRATION)
    assert "grant execute on function governance_private.attempt_recovery_drill_mutation" in sql
    for function in (
        "begin_recovery_drill",
        "contain_recovery_drill",
        "rollback_recovery_drill",
        "resume_recovery_drill",
        "close_recovery_drill",
    ):
        assert f"revoke execute on function governance_private.{function}" in sql
    assert "automatic_core_write_allowed" not in sql


def test_live_runner_executes_real_rollback_and_rotates_capability_generation():
    source = text(RUNNER)
    for required in (
        "representative_change",
        "contained_stale_capability",
        "contained_cross_project",
        "contained_wrong_route",
        "mutation_during_recovery",
        "pre_containment_capability_replay",
        "post_recovery_bounded_path",
        "rollback_recovery_drill",
        "resume_recovery_drill",
        "verify_recovery_audit_chain",
        "baseline_restored",
        "service_role_contain",
        "direct_table_access_denied",
    ):
        assert required in source
    assert '"core_write_allowed": False' in source
    assert '"automatic_merge_allowed": False' in source
    assert '"automatic_application_allowed": False' in source
    assert '"automatic_resume_allowed": False' in source


def test_workflows_are_manual_fail_closed_sha_bound_and_retain_evidence():
    migration = text(MIGRATION_WORKFLOW)
    cert = text(CERT_WORKFLOW)
    assert "workflow_dispatch" in migration and "workflow_dispatch" in cert
    assert "APPLY_GOVERNANCE_RECOVERY_MIGRATION_20260916061000" in migration
    assert "RUN_GOVERNANCE_RECOVERY_CERT_20260916061000" in cert
    assert "ref: ${{ github.sha }}" in migration
    assert "ref: ${{ github.sha }}" in cert
    assert "GOVERNANCE_DATABASE_URL" in migration and "GOVERNANCE_DATABASE_URL" in cert
    assert "retention-days: 90" in migration
    assert "retention-days: 90" in cert


def test_runbook_requires_independent_human_recovery_and_no_automatic_resume():
    runbook = text(RUNBOOK)
    assert "indépendante" in runbook
    assert "service_role" in runbook
    assert "décision humaine" in runbook
    assert "aucun droit d'écriture dans un Core" in runbook
    assert "LITD" in runbook and "COMPANY" in runbook
    assert "rollback" in runbook.lower()
