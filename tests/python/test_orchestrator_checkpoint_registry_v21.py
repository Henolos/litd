from pathlib import Path


MIGRATION = Path("supabase/migrations/20261004104500_orchestrator_checkpoint_registry_v21.sql")
SQL_TEST = Path("supabase/tests/orchestrator_checkpoint_registry_v21.sql")


def test_orchestrator_checkpoint_registry_contract_is_fail_closed():
    sql = MIGRATION.read_text(encoding="utf-8")
    assert "governance_private.orchestrator_checkpoints" in sql
    assert "governance_private.orchestrator_checkpoint_audit" in sql
    assert "pg_advisory_xact_lock" in sql
    assert "stale_checkpoint_version" in sql
    assert "idempotent_replay" in sql
    assert "idempotency_conflict" in sql
    assert "authorized_project_routes" in sql
    assert "enable row level security" in sql
    assert "revoke all on governance_private.orchestrator_checkpoints" in sql
    assert "grant execute on function governance_private.write_orchestrator_checkpoint" in sql
    assert "to service_role" in sql
    assert "COMPLETED" in sql and "VERIFYING" in sql


def test_orchestrator_checkpoint_registry_has_transactional_sql_contract():
    sql = SQL_TEST.read_text(encoding="utf-8")
    assert sql.lstrip().startswith("-- Synthetic transactional contract")
    assert "\nbegin;" in sql
    assert "idempotent_replay" in sql
    assert "stale_checkpoint_version" in sql
    assert "checkpoint_version <> 2" in sql
    assert "verify_orchestrator_checkpoint_audit_chain" in sql
    assert sql.rstrip().endswith("rollback;")
