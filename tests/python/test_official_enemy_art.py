"""Cross-check stable runtime identities against archived originals, not sheet numbers."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def test_runtime_bindings_match_enemy_identities_and_exact_archived_bytes():
    art = json.loads((ROOT / 'data/canonical_art_v41.json').read_text())
    manifest = json.loads((ROOT / 'docs/art/reconciled_bestiary_manifest_20261111.json').read_text())
    assets = {a['subject_id']: a for a in manifest['assets']}
    enemies = {str(e['id']): e for e in json.loads((ROOT / 'data/enemies.json').read_text())}
    bindings = art['enemy_reference_bindings']
    assert {k: v['subject_id'] for k, v in bindings.items()} == {
        '6': 'gorgon', '7': 'minotaur', '8': 'oni', '10': 'jorogumo', '11': 'yuki_onna'
    }
    for enemy_id, binding in bindings.items():
        assert enemies[enemy_id]['name'] == binding['enemy_name']
        source = assets[binding['subject_id']]
        x, y, w, h = binding['combat_region']
        assert 0 <= x < x + w <= source['width']
        assert 0 <= y < y + h <= source['height']
        assert h > w > 0
        assert binding['path'] == 'res://' + source['archived_path']
        assert hashlib.sha256((ROOT / source['archived_path']).read_bytes()).hexdigest() == source['expected_sha256']
        # Both numbers differ for every current match: numbering is not identity.
        assert int(enemy_id) != source['canonical_plate_number']
    # No source plate is assigned to the Tengu or either unrelated wolf/boss.
    assert {'9', '33', '38', '39'}.isdisjoint(bindings)
    # All legacy illustrations remain available for unresolved identities and rollback.
    assert len(list((ROOT / 'assets/enemies').glob('*.webp'))) == 39
    for enemy in enemies.values():
        assert (ROOT / 'assets/enemies' / enemy['art']).is_file()


def test_project_audit_accepts_a_real_godot_import_cache(tmp_path):
    from tools.qa.audit import run

    (tmp_path / '.godot').mkdir()
    (tmp_path / 'project.godot').write_text('[application]\nconfig/name="QA"\n')
    result = run(tmp_path)
    resources = next(r for r in result.results if r['name'] == 'Références res:// valides')
    assert resources['ok']
