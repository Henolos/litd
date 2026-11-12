import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def _load(path: str) -> dict:
    return json.loads((ROOT / path).read_text(encoding="utf-8"))


def test_ngplus_keeps_intentional_replay_privileges():
    rules = _load("data/world/new_game_plus.json")
    assert rules["skill_tree_rules"]["multitree_from_cycle"] == 1
    assert rules["boss_recruitment"]["enabled_from_cycle"] == 1
    assert set(rules["boss_recruitment"]["includes"]) >= {"miniboss", "boss"}


def test_ngplus_cycle_profiles_cover_four_replay_layers():
    data = _load("data/world/ngplus_cycle_variants.json")
    boundary = data["canon_boundary"]
    assert boundary["initial_cycle_is_reference_history"] is True
    assert boundary["ngplus_is_replay_gameplay_layer"] is True
    assert boundary["does_not_create_literal_time_loop"] is True
    assert boundary["does_not_rewrite_established_history"] is True
    assert boundary["boss_recruitment_is_replay_privilege"] is True
    assert boundary["multitree_is_replay_privilege"] is True

    profiles = data["profiles"]
    assert [p["cycle_min"] for p in profiles[:4]] == [1, 2, 3, 4]
    assert profiles[-1]["cycle_max"] >= 999
    for profile in profiles:
        assert profile["world_variants"]
        assert profile["dungeon"]["extra_hazard_pool"]
        assert profile["enemy_mutators"]
        assert profile["narrative_echoes"]




def test_ngplus_wow_contract_requires_early_visible_change():
    data = _load("data/world/ngplus_cycle_variants.json")
    wow = data["wow_guarantee"]
    assert wow["visible_difference_within_minutes"] <= 15
    assert set(wow["required_layers_per_cycle"]) == {"world", "dungeon", "enemy", "narrative"}
