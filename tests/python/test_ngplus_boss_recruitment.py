import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def load(path):
    return json.loads((ROOT / path).read_text())


def test_ngplus_roster_covers_chapter_and_deep_vestige_bosses_and_minibosses():
    data = load('data/world/ngplus_boss_recruits.json')
    recruits = data['recruits']
    ids = {r['encounter_id'] for r in recruits}
    assert data['unlock_cycle_min'] == 1
    assert data['level_sync'] == 'party_average'
    assert len(recruits) >= 34
    assert {'c01_miniboss_warden','c10_unpaid_cost','c01_boss_ash_witness','c10_boss_final'} <= ids
    assert {
        'vestige_ashai_boss_seventh_voice','vestige_silex_boss_last_strategist',
        'vestige_saan_boss_last_watch','vestige_vaor_boss_command_without_body',
        'vestige_lyrmar_boss_absent_cartographer','vestige_sahmir_boss_single_interpreter',
        'vestige_ydris_boss_living_theorem'
    } <= ids
    assert all(r['signature'].strip() and r['archetype'].strip() for r in recruits)


def test_rank_specific_recruitment_is_harder_for_major_bosses():
    rules = load('data/world/ngplus_boss_recruits.json')['capture_rules']
    assert rules['boss']['max_hp_ratio'] < rules['miniboss']['max_hp_ratio']
    assert rules['deep_boss']['max_hp_ratio'] <= rules['boss']['max_hp_ratio']
    assert rules['boss']['essence_cost'] > rules['miniboss']['essence_cost']
    assert rules['deep_boss']['essence_cost'] >= rules['boss']['essence_cost']
