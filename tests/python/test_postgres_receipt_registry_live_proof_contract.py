from pathlib import Path
import re


SCRIPT = Path("tools/quality/run_postgres_receipt_registry_live_proof.py")
WORKFLOW = Path(".github/workflows/postgres-receipt-registry-live-proof.yml")


def test_live_proof_covers_required_p0_scenarios():
    text = SCRIPT.read_text(encoding="utf-8")
    for token in (
        '"identical_replay"',
        '"stale_context"',
        '"revoked"',
        '"superseded"',
        '"cross_project"',
        '"concurrent_double_consumption"',
        'ThreadPoolExecutor(max_workers=8)',
        'assert len(winners) == 1',
        'replay_detected',
        'project_scope_mismatch',
        'receipt_revoked',
        'receipt_superseded',
    ):
        assert token in text, token


def test_live_proof_never_persists_database_secret():
    script = SCRIPT.read_text(encoding="utf-8")
    workflow = WORKFLOW.read_text(encoding="utf-8")
    assert 'GOVERNANCE_DATABASE_URL' in script
    assert '${{ secrets.GOVERNANCE_DATABASE_URL }}' in workflow
    assert 'print(dsn' not in script
    assert '"dsn"' not in script
    assert 'env:' in workflow


def test_live_proof_retains_hashed_evidence_artifact():
    script = SCRIPT.read_text(encoding="utf-8")
    workflow = WORKFLOW.read_text(encoding="utf-8")
    assert 'evidence["evidence_hash"]' in script
    assert 'reports/postgres-receipt-registry-live-proof.json' in workflow
    assert re.search(r'actions/upload-artifact@[0-9a-f]{40}\s+# v6', workflow)
    assert 'retention-days: 30' in workflow


def test_live_proof_is_manual_only():
    workflow = WORKFLOW.read_text(encoding="utf-8")
    assert 'workflow_dispatch:' in workflow
    assert 'pull_request:' not in workflow
    assert 'push:' not in workflow
