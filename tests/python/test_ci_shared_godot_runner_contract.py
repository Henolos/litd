from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def test_technical_suite_uses_shared_checked_runner_and_result_sentinels():
    runner = (ROOT / 'tools/build/run_godot_ci.sh').read_text()
    assert runner.count('tools/ci/run_godot_checked.sh') == 7
    for token in ['SAVE_RUNTIME_CONTRACT_PASS', 'SAVE_NEGATIVE_CONTRACT_PASS', 'SAVE_ROUNDTRIP_CONTRACT_PASS', 'SAVE_RECOVERY_REGRESSION_OK', 'SAVE_SLOT0_DELETE_REGRESSION_OK', 'TECHNICAL_FOUNDATION_OK', 'COMBAT_A_EXPERIMENT_OK']:
        assert '--expect ' + token in runner


def test_destructive_storage_checks_have_an_isolated_user_directory():
    runner = (ROOT / 'tools/build/run_godot_ci.sh').read_text()
    assert 'export XDG_DATA_HOME="$sandbox_dir"' in runner
    assert 'export LITD_SAVE_TEST_SANDBOX="$sandbox_dir"' in runner
    assert 'export LITD_SAVE_DELETE_SANDBOX="$sandbox_dir"' in runner
