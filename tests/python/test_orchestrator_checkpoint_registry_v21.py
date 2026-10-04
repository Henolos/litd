from pathlib import Path


MIGRATION = Path("supabase/migrations/20261004104500_orchestrator_checkpoint_registry_v21.sql")
SQL_TEST = Path("supabase/tests/orchestrator_checkpoint_registry_v21.sql")


def test_orchestrator_v21_extends_execution_core_instead_of_parallel_registry():
    sql = MIGRATION.read_text(encoding="utf-8")
    assert "alter table henolos_execution.checkpoints" in sql.lower()
    assert "create table" not in sql.lower()
    assert "governance_private.orchestrator_checkpoints" not in sql
    assert "append_orchestrator_checkpoint_v21" in sql
    assert "henolos_execution.leases" in sql
    assert "stale_mandate_version" in sql
    assert "idempotent_replay" in sql
    assert "idempotency_conflict" in sql
    assert "closure_not_verified" in sql
    assert "security definer" in sql.lower()
    assert "set search_path = ''" in sql
    assert "grant execute on function henolos_execution.append_orchestrator_checkpoint_v21" in sql
    assert "to service_role" in sql


def test_orchestrator_v21_has_transactional_sql_contract():
    sql = SQL_TEST.read_text(encoding="utf-8")
    assert sql.lstrip().startswith("-- Synthetic transactional contract")
    assert "\nbegin;" in sql
    assert "acquire_lease" in sql
    assert "idempotent_replay" in sql
    assert "idempotency_conflict" in sql
    assert "stale_mandate_version" in sql
    assert "closure_not_verified" in sql
    assert "ORCHESTRATOR_CHECKPOINT_WRITTEN" in sql
    assert sql.rstrip().endswith("rollback;")
