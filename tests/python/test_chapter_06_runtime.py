import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def test_chapter_six_has_eight_stage_loop_and_campaign_unlock():
    data = json.loads((ROOT / 'data/levels/chapter_06_absent.json').read_text())
    assert data['chapter_id'] == 'chapter_06_absent'
    assert len(data['stages']) == 8
    assert data['unlock'] == 'chapter_07_living_responsible'
    assert {s['type'] for s in data['stages']} >= {'exploration','investigation','creature_investigation','campfire','miniboss','contact','boss','return'}














def test_boundary_keeps_three_moral_outcomes():
    data = json.loads((ROOT / 'data/levels/chapter_06_absent.json').read_text())
    assert {c['id'] for c in data['boss_choices']} == {'force','resonate','withdraw'}
