import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def load(path):
    normalized = str(path).removeprefix('res://')
    return json.loads((ROOT / normalized).read_text())


def test_all_seven_deep_vestiges_are_playable_and_data_driven():
    index = load('data/world/deep_vestiges.json')
    vestiges = index['vestiges']
    expected = {
        'vestige_ashai_seven_resonances',
        'vestige_or_silex_black_glass',
        'vestige_saan_last_seal',
        'vestige_vaor_khal_thousand_orders',
        'vestige_lyr_mar_reversed_tides',
        'vestige_sahm_ir_sealed_voices',
        'vestige_ydris_impossible_causes',
    }
    assert len(vestiges) == 7
    assert {v['id'] for v in vestiges} == expected
    assert {v['status'] for v in vestiges} == {'playable'}
    for entry in vestiges:
        assert entry['data_path'].startswith('res://data/levels/')
        data = load(entry['data_path'])
        assert data['vestige_id'] == entry['id']
        assert len(data.get('zones', [])) >= 6
