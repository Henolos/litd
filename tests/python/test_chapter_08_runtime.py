import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def load(path):
    return json.loads((ROOT / path).read_text())




def test_each_foreign_power_has_official_and_non_official_voices():
    chapter = load('data/levels/chapter_08_outer_world.json')
    world = load('data/levels/chapter_08_world.json')
    assert len(world['records']) == 16
    powers = {'varkhane','namar','azravel','kor_em'}
    for power in powers:
        records = [r for r in world['records'] if r['power'] == power]
        assert len(records) == 4
        assert any(r['kind'] in {'civilian','dissident'} for r in records)
        assert any(r['kind'] in {'official','technical'} for r in records)
    rules = chapter['investigation']
    assert rules['minimum_per_power'] >= 3
    assert rules['civilian_or_dissident_per_power'] >= 1
    assert rules['independent_source_families'] >= 6


def test_canonical_foreign_allies_and_collective_guilt_rule_are_preserved():
    chapter = load('data/levels/chapter_08_outer_world.json')
    names = {a['name'] for a in chapter['foreign_allies']}
    assert names == {'Capitaine Varek Sorn','Navigatrice Issel Pell','Frère Oren Val','Docteure Keira Om'}
    assert 'peuples' in chapter['theme'].lower()
    assert 'culpabilité' in chapter['theme'].lower()
    assert sum(1 for r in load('data/levels/chapter_08_world.json')['records'] if 'no_collective_guilt' in r.get('supports', [])) >= 8
