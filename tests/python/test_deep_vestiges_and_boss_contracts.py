import json
from pathlib import Path
ROOT = Path(__file__).resolve().parents[2]


def test_all_known_campaign_bosses_have_mechanical_contracts():
    contracts = json.loads((ROOT/'data/boss_design_contracts.json').read_text())
    campaign = json.loads((ROOT/'data/world/main_campaign.json').read_text())
    contract_ids = {b['id'] for b in contracts['bosses']}
    known = {chapter['bosses'][0]['id'] for chapter in campaign['chapters']}
    historical_aliases = {'c02_marker_warden':'c02_boss_archive_keeper'}
    normalized = contract_ids | {historical_aliases.get(i, i) for i in contract_ids}
    assert known.issubset(normalized)
    assert 'c10_boss_final' in contract_ids
    for boss in contracts['bosses']:
        assert boss['core_puzzle'].strip()
        assert boss['mechanics']
        assert boss['counterplay'].strip()
        assert boss['signature'].strip()


def test_deep_vestige_rule_covers_each_known_ancient_civilization():
    data = json.loads((ROOT/'data/world/deep_vestiges.json').read_text())
    civs = {v['civilization'] for v in data['vestiges']}
    assert {
        'Ashaï de Nhal', "Royaumes d'Or-Silex", 'Veilleurs de Saan',
        'Cités de Vaor-Khal', 'Navigateurs de Lyr-Mar', 'Cités de Sahm-Ir', "Ateliers d'Ydris"
    }.issubset(civs)
    assert len(data['vestiges']) >= 7
    assert all(v.get('data_path') for v in data['vestiges'])
    assert data['difficulty']['recommended_offset_levels'] >= 4
    assert data['difficulty']['resource_abundance_multiplier'] < 1
