import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def load(path):
    return json.loads((ROOT / path).read_text())




def test_chapter_five_crosses_military_civilian_and_saan_sources():
    chapter = load('data/levels/chapter_05_great_closure.json')
    world = load('data/levels/chapter_05_world.json')
    assert len(world['fragments']) == 14
    categories = {f['category'] for f in world['fragments']}
    assert {'military','civilian','saan'} <= categories
    rules = chapter['investigation']
    assert rules['required_fragments'] >= 8
    assert rules['independent_source_families'] >= 4
    assert rules['civilian_sources_min'] >= 2
    assert rules['saan_sources_min'] >= 2






def test_chapter_five_unlocks_absents_and_deep_vestiges():
    chapter = load('data/levels/chapter_05_great_closure.json')
    index = load('data/world/deep_vestiges.json')
    assert chapter['unlock'] == 'chapter_06_absent'
    by_id = {v['id']: v for v in index['vestiges']}
    assert by_id['vestige_or_silex_black_glass']['unlock']['flag'] == 'c05_weaponized_reality_confirmed'
    assert by_id['vestige_saan_last_seal']['unlock']['flag'] == 'c05_saan_network_confirmed'
