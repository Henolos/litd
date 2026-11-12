import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def load(path):
    return json.loads((ROOT / path).read_text())




def test_seven_ancient_civilizations_are_compared_without_making_vestiges_mandatory():
    chapter = load('data/levels/chapter_09_veil_nature.json')
    lenses = chapter['ancient_lenses']
    assert len(lenses) == 7
    assert {l['civilization'] for l in lenses} == {
        'Ashaï de Nhal', "Royaumes d'Or-Silex", 'Veilleurs de Saan',
        'Cités de Vaor-Khal', 'Navigateurs de Lyr-Mar', 'Cités de Sahm-Ir', "Ateliers d'Ydris"
    }
    rule = chapter['model_rules']['rule']
    assert 'facultatifs' in rule
    assert chapter['model_rules']['ancient_lenses_required'] == 7
    assert chapter['model_rules']['deep_truths_for_high_confidence'] >= 3


def test_models_keep_observation_interpretation_and_unknowns_separate():
    chapter = load('data/levels/chapter_09_veil_nature.json')
    world = load('data/levels/chapter_09_world.json')
    assert len(chapter['models']) == 5
    assert len(world['observations']) >= 19
    assert len({o['source_family'] for o in world['observations']}) >= 10
    assert all(m['required_support'] >= 3 and m['required_families'] >= 3 for m in chapter['models'])
    revelation = chapter['end_revelation'].lower()
    assert any(marker in revelation for marker in ('inconnue', 'ne savons toujours pas', 'ne savons pas'))
    assert 'volonté' in revelation










def test_chapter_nine_unlocks_model_chamber_and_preserves_uncertainty():
    chapter = load('data/levels/chapter_09_veil_nature.json')
    sanctuary = load('data/levels/sanctuary_state_layers.json')
    by_id = {layer['id']: layer for layer in sanctuary['layers']}
    assert chapter['unique_rewards']['service']['name'] == 'Chambre des Modèles'
    assert 'model_chamber' in by_id
    assert 'sanctuary_model_chamber_unlocked' in by_id['model_chamber']['when']['campaign_any_flag']
    assert any('Ce que nous ne savons pas' in cue for cue in by_id['model_chamber']['visual'])
