import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def load(path):
    return json.loads((ROOT / path).read_text())


def test_ngplus_data_opens_all_three_skill_trees_from_first_return():
    data = load('data/world/new_game_plus.json')
    rules = data['skill_tree_rules']
    assert data['schema_version'] >= 3
    assert rules['multitree_from_cycle'] == 1
    assert rules['branches'] == ['offense', 'defense', 'special']
    assert {'heroes', 'regular_creature_companions', 'boss_recruits'} <= set(rules['applies_to'])
    assert {'skill_point_cost', 'required_level', 'in_branch_prerequisites'} <= set(rules['still_required'])
