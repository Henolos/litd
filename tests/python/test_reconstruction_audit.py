import hashlib
import json
from pathlib import Path
import pytest
from tools.qa.reconstruction_audit import AUTHORIZED_REVISIONS, MANIFEST, validate


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


def test_evidence_backed_reference_revision_preserves_original_hash(foundation):
    reference = foundation/'universe/lore/remanence.json'
    original = hashlib.sha256(reference.read_bytes()).hexdigest()
    reference.write_text('authorized update')
    authorized = hashlib.sha256(reference.read_bytes()).hexdigest()
    (foundation/'docs/knowledge/decisions').mkdir(parents=True)
    evidence = 'docs/knowledge/decisions/ADR-0009.md'
    (foundation/evidence).write_text('Approved roster decision.\n')
    (foundation/AUTHORIZED_REVISIONS).write_text(json.dumps({
        'schema_version': 1,
        'revisions': [{
            'path': 'universe/lore/remanence.json',
            'original_sha256': original,
            'authorized_sha256': authorized,
            'evidence_ref': evidence,
            'reason': 'The approved decision requires this reference to reflect the current canonical state.',
        }],
    }))
    assert validate(foundation) == []


def test_authorized_revision_cannot_hide_later_corruption(foundation):
    reference = foundation/'universe/lore/remanence.json'
    original = hashlib.sha256(reference.read_bytes()).hexdigest()
    reference.write_text('authorized update')
    authorized = hashlib.sha256(reference.read_bytes()).hexdigest()
    (foundation/'docs/knowledge/decisions').mkdir(parents=True)
    evidence = 'docs/knowledge/decisions/ADR-0009.md'
    (foundation/evidence).write_text('Approved roster decision.\n')
    (foundation/AUTHORIZED_REVISIONS).write_text(json.dumps({
        'schema_version': 1,
        'revisions': [{
            'path': 'universe/lore/remanence.json',
            'original_sha256': original,
            'authorized_sha256': authorized,
            'evidence_ref': evidence,
            'reason': 'The approved decision requires this reference to reflect the current canonical state.',
        }],
    }))
    reference.write_text('unreviewed later corruption')
    assert 'reference_changed:universe/lore/remanence.json' in validate(foundation)


def test_authorized_revision_with_wrong_frozen_hash_is_rejected(foundation):
    reference = foundation/'universe/lore/remanence.json'
    reference.write_text('authorized update')
    (foundation/'docs/knowledge/decisions').mkdir(parents=True)
    evidence = 'docs/knowledge/decisions/ADR-0009.md'
    (foundation/evidence).write_text('Approved roster decision.\n')
    (foundation/AUTHORIZED_REVISIONS).write_text(json.dumps({
        'schema_version': 1,
        'revisions': [{
            'path': 'universe/lore/remanence.json',
            'original_sha256': '0' * 64,
            'authorized_sha256': hashlib.sha256(reference.read_bytes()).hexdigest(),
            'evidence_ref': evidence,
            'reason': 'The approved decision requires this reference to reflect the current canonical state.',
        }],
    }))
    errors = validate(foundation)
    assert 'authorized_revision_0_hash_mismatch' in errors
    assert 'reference_changed:universe/lore/remanence.json' in errors


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


def test_approved_hub_is_a_valid_game_bootstrap(foundation):
    scene = foundation/'scenes/hub/game_hub.tscn'
    scene.parent.mkdir(parents=True)
    scene.write_text('[gd_scene format=3]\n')
    with (foundation/'project.godot').open('a') as handle:
        handle.write('\nrun/main_scene="res://scenes/hub/game_hub.tscn"\n')
    assert validate(foundation) == []


def test_declared_guild_ui_prototype_is_allowed_without_changing_reset_manifest(foundation):
    script = 'scripts/ui/guild_new_npcs_screen.gd'
    scene = 'scenes/hub/guild_new_npcs_screen.tscn'
    (foundation/script).parent.mkdir(parents=True)
    (foundation/script).write_text('extends Control\n')
    (foundation/scene).parent.mkdir(parents=True)
    (foundation/scene).write_text('[gd_scene format=3]\n')
    (foundation/'docs/reconstruction/GUILD_UI_PROTOTYPE_MANIFEST.json').write_text(json.dumps({
        'phase': 'guild_npc_ui_prototype', 'scripts': [script], 'scenes': [scene],
    }))
    assert validate(foundation) == []


def test_guild_ui_prototype_cannot_authorize_retired_runtime(foundation):
    (foundation/'docs/reconstruction/GUILD_UI_PROTOTYPE_MANIFEST.json').write_text(json.dumps({
        'phase': 'guild_npc_ui_prototype', 'scripts': ['scripts/ui/main.gd'], 'scenes': [],
    }))
    assert 'prototype_scope_invalid:scripts/ui/main.gd' in validate(foundation)


def test_real_repository_matches_reset_manifest():
    assert validate() == []
