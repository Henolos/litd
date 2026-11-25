from pathlib import Path
from tools.ci.select_godot_domains import ALL_DOMAINS, domain_test_owners, select_domains


def test_unknown_and_project_changes_get_complete_technical_suite():
    for paths in [[], ['project.godot'], ['unknown/new.file']]:
        assert select_domains(paths) == list(ALL_DOMAINS) == ['technical']


def test_every_runner_target_exists_and_has_an_owner():
    owners = domain_test_owners()
    assert len(owners) == 7
    for path, domains in owners.items():
        assert Path(path).is_file()
        assert domains == {'technical'}


def test_storage_regressions_cannot_drop_out_of_runner():
    owners = domain_test_owners()
    assert 'scenes/tests/save_recovery_regression_smoke.tscn' in owners
    assert 'scenes/tests/save_slot0_delete_regression_smoke.tscn' in owners
    assert 'tests/godot/test_save_roundtrip_headless.gd' in owners
