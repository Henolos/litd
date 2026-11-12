import hashlib
import json
from pathlib import Path
import pytest
from tools.qa.reconstruction_audit import MANIFEST, validate


@pytest.fixture
def foundation(tmp_path):
    def write(name, content):
        path = tmp_path / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content)
    write('universe/lore/remanence.json', '{"idea":"preserved"}')
    write('scripts/core/save_manager.gd', 'extends Node\n')
    write('scripts/core/game_settings.gd', 'extends Node\n')
    write('project.godot', '[autoload]\nSaveManager="*res://scripts/core/save_manager.gd"\nGameSettings="*res://scripts/core/game_settings.gd"\n')
    reference = 'universe/lore/remanence.json'
    write(MANIFEST, json.dumps({
        'preserved_reference_files':[{'path':reference,'sha256':hashlib.sha256((tmp_path/reference).read_bytes()).hexdigest()}],
        'removed_runtime_files':['scripts/ui/main.gd'],
        'technical_scripts':['scripts/core/save_manager.gd','scripts/core/game_settings.gd'],
    }))
    return tmp_path


def test_intact_foundation_and_lore_validate(foundation):
    assert validate(foundation) == []
    assert validate(foundation, 'lore') == []


def test_reference_corruption_is_rejected(foundation):
    (foundation/'universe/lore/remanence.json').write_text('changed')
    assert any(x.startswith('reference_changed:') for x in validate(foundation))


def test_missing_storage_service_is_rejected(foundation):
    (foundation/'scripts/core/save_manager.gd').unlink()
    assert any(x.startswith('technical_script_scope:') for x in validate(foundation))
    assert any(x.startswith('broken_resource:') for x in validate(foundation))


def test_deleted_gameplay_cannot_return(foundation):
    path=foundation/'scripts/ui/main.gd'
    path.parent.mkdir()
    path.write_text('extends Node\n')
    assert 'retired_runtime_returned:scripts/ui/main.gd' in validate(foundation)


def test_game_bootstrap_cannot_return(foundation):
    with (foundation/'project.godot').open('a') as handle:
        handle.write('\nrun/main_scene="res://scenes/Main.tscn"\n')
    assert 'retired_game_bootstrap_returned' in validate(foundation)


def test_real_repository_matches_reset_manifest():
    assert validate() == []
