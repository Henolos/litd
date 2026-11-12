import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def load(path):
    return json.loads((ROOT / path).read_text())


def test_chapter_seven_has_eight_stage_justice_loop_and_unlock():
    data = load('data/levels/chapter_07_living_responsible.json')
    assert data['chapter_id'] == 'chapter_07_living_responsible'
    assert len(data['stages']) == 8
    assert data['unlock'] == 'chapter_08_outer_world'
    assert {'cross_examination','campfire','miniboss','boss','return'} <= {s['type'] for s in data['stages']}












def test_chapter_seven_unlocks_public_hearing_without_collective_guilt():
    data = load('data/levels/chapter_07_living_responsible.json')
    layers = load('data/levels/sanctuary_state_layers.json')
    assert 'sans accuser leurs populations' in data['end_revelation']
    public = next(layer for layer in layers['layers'] if layer['id'] == 'public_hearing')
    assert 'sanctuary_public_hearing_unlocked' in public['when']['campaign_any_flag']
