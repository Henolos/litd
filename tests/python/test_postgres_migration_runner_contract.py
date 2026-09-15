from pathlib import Path


WORKFLOW = Path(".github/workflows/governance-postgres-apply-migration.yml")


def test_migration_runner_is_manual_guarded_and_serialized() -> None:
    text = WORKFLOW.read_text(encoding="utf-8")
    assert "workflow_dispatch:" in text
    assert "APPLY_GOVERNANCE_MIGRATION_20260915110500" in text
    assert "governance-postgres-schema-migration" in text
    assert "cancel-in-progress: false" in text
    assert "environment: governance-live-cert" in text
    assert "GOVERNANCE_DATABASE_URL" in text
    assert "exit 2" in text


def test_migration_runner_applies_only_exact_governed_migration_transactionally() -> None:
    text = WORKFLOW.read_text(encoding="utf-8")
    migration = "supabase/migrations/20260915110500_governance_authorized_project_routes.sql"
    assert migration in text
    assert "--single-transaction" in text
    assert "--set=ON_ERROR_STOP=1" in text
    assert "supabase db push" not in text
    assert "supabase/migrations/*.sql" not in text


def test_migration_runner_verifies_project_routes_and_retains_evidence() -> None:
    text = WORKFLOW.read_text(encoding="utf-8")
    assert "is_project_route_authorized(text,text)" in text
    assert "is_project_route_authorized('LITD','LITD_LIBRARY')" in text
    assert "is_project_route_authorized('COMPANY','COMPANY_LIBRARY')" in text
    assert "is_project_route_authorized('COMPANY','LITD_LIBRARY')" in text
    assert "governance-postgres-migration-evidence.json" in text
    assert "actions/upload-artifact@v4" in text
    assert "retention-days: 90" in text
    assert "if-no-files-found: error" in text
