import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]




def test_responsibility_requires_crossed_evidence():
    data = json.loads((ROOT / 'data/levels/chapter_03_threshold.json').read_text())
    rules = data['evidence_rules']
    assert rules['required_evidence'] >= 9
    assert rules['required_actor_links'] == 6
    assert rules['independent_source_groups'] >= 4
    assert rules['contradictions_required'] >= 2
    assert all(a['culpability'] and a['counterpoint'] for a in data['actors'])


def test_threshold_echo_has_three_outcomes_and_ancient_symbol_reveal():
    data = json.loads((ROOT / 'data/levels/chapter_03_threshold.json').read_text())
    assert data['boss']['name'] == "L'Écho du Seuil"
    assert len(data['boss']['phases']) == 3
    assert data['boss']['signature'] == 'Zéro Seconde'
    assert {c['id'] for c in data['boss_choices']} == {'break','record','prolong'}
    assert data['ancient_symbol_revelation']['unlock'] == 'chapter_04_first_rupture'
