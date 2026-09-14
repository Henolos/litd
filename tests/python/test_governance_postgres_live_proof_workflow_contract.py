from pathlib import Path


WORKFLOW = Path('.github/workflows/governance-postgres-live-proof.yml')


def text() -> str:
    return WORKFLOW.read_text(encoding='utf-8')


def test_live_postgres_proof_is_manual_only():
    body = text()
    assert 'workflow_dispatch:' in body
    assert 'push:' not in body
    assert 'pull_request:' not in body
    assert 'schedule:' not in body


def test_live_postgres_proof_uses_protected_environment_and_secret():
    body = text()
    assert 'environment: governance-production' in body
    assert 'secrets.GOVERNANCE_DATABASE_URL' in body
    assert 'GOVERNANCE_DATABASE_URL is required' in body


def test_live_postgres_proof_applies_only_canonical_migration():
    body = text()
    assert 'supabase/migrations/20260912162000_governance_receipt_registry.sql' in body
    assert 'psql "$GOVERNANCE_DATABASE_URL" -X -v ON_ERROR_STOP=1 -f "$MIGRATION_FILE"' in body


def test_live_postgres_proof_executes_harness_fail_closed():
    body = text()
    assert 'scripts/governance/run_postgres_receipt_live_proof.sh' in body
    assert body.count('set -euo pipefail') >= 4
    assert '"$PROOF_SCRIPT"' in body


def test_live_postgres_proof_always_preserves_evidence():
    body = text()
    assert 'if: ${{ always() }}' in body
    assert 'actions/upload-artifact@v4' in body
    assert 'retention-days: 90' in body
    assert 'run_url=' in body
