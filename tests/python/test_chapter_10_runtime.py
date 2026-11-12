import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def load(path):
    return json.loads((ROOT / path).read_text())




def test_final_decision_documents_real_costs_and_multiple_voices():
    chapter = load('data/levels/chapter_10_final_choice.json')
    world = load('data/levels/chapter_10_world.json')
    assert len(chapter['council_groups']) == 7
    assert sum(1 for g in chapter['council_groups'] if g.get('always')) == 3
    assert len(world['stakes']) == 13
    assert len({s['source_family'] for s in world['stakes']}) >= 10
    assert chapter['decision_rules']['stakes_required'] >= 8
    assert chapter['decision_rules']['stake_families_required'] >= 5
    assert 'jamais créée' in chapter['decision_rules']['rule']
    conditional = {g['id']: g['min'] for g in chapter['council_groups'] if not g.get('always')}
    assert conditional['creatures'] <= 6
    assert conditional['absent'] <= 20
    assert conditional['foreign'] <= 12




def test_ending_thresholds_use_the_implemented_metric_scales():
    endings = {e['id']: e for e in load('data/world/main_campaign_endings.json')['endings']}
    assert endings['stable_coexistence']['requirements']['creature_relations_min'] <= 8
    assert endings['seek_absent']['requirements']['absent_contact_min'] <= 25
    assert endings['restore_concord']['requirements']['foreign_alliances_min'] <= 12
    assert endings['transform_concord']['requirements']['foreign_alliances_min'] <= 15
    assert endings['transform_concord']['requirements']['city_min'] <= 70






def test_all_six_success_endings_and_three_failure_states_change_sanctuary():
    layers = load('data/levels/sanctuary_state_layers.json')['layers']
    ids = {layer['id'] for layer in layers}
    expected = {
        'ending_radical_closure','ending_stable_coexistence','ending_preserve_crossings',
        'ending_seek_absent','ending_restore_concord','ending_transform_concord',
        'ending_fractured_survival','ending_authoritarian_order','ending_veil_dissolution'
    }
    assert expected <= ids
    for layer in layers:
        if layer['id'] in expected:
            assert layer['priority'] >= 110
            assert layer['visual'] and layer['audio'] and layer['population']


def test_final_revelation_keeps_light_in_the_dark_core_motto():
    chapter = load('data/levels/chapter_10_final_choice.json')
    assert 'La lumière ne supprime pas' in chapter['end_revelation']
    assert 'qui paie le prix' in chapter['end_revelation']
