import json
from pathlib import Path
ROOT = Path(__file__).resolve().parents[2]

def test_chapter_four_has_eight_stage_reference_loop():
    data = json.loads((ROOT/'data/levels/chapter_04_first_rupture.json').read_text())
    assert data['chapter_id'] == 'chapter_04_first_rupture'
    assert len(data['stages']) == 8
    types = [s['type'] for s in data['stages']]
    assert 'exploration' in types and 'campfire' in types and 'miniboss' in types and 'boss' in types and 'return' in types
    assert data['unlock'] == 'chapter_05_great_closure'





def test_chorus_has_three_moral_outcomes():
    data = json.loads((ROOT/'data/levels/chapter_04_first_rupture.json').read_text())
    assert {c['id'] for c in data['boss_choices']} == {'release','communicate','preserve'}
    assert data['boss']['name'] == 'Le Chœur Inachevé'
    assert data['boss']['signature'] == 'Nous étions plusieurs'
