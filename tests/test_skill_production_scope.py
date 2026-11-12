import json
from pathlib import Path

ROOT = Path(__file__).parents[1]


def load(path: str):
    return json.loads((ROOT / path).read_text(encoding="utf-8"))


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")






def test_enemy_production_uses_small_pool_and_contextual_variation():
    scope = load("data/skill_production_scope.json")
    enemies = scope["enemies"]
    profiles = load("data/enemy_combat_profiles.json")
    assert enemies["currently_targeted_runtime_subset"] == [4, 8]
    assert enemies["canonical_branches"] == 3
    assert enemies["canonical_nodes_per_branch"] == 15
    assert enemies["runtime_subset_status"] == "temporary implementation gap"
    assert len(profiles["skills"]) <= 8
    assert {"ai_orientation", "fear_posture", "injury_state", "combat_rank", "environment", "family_identity"} <= set(enemies["diversity_sources"])


def test_no_new_major_system_before_pc_loop_validation():
    scope = load("data/skill_production_scope.json")
    assert scope["rules"]["no_new_major_system_before_pc_loop_validation"] is True
    assert scope["rules"]["do_not_delete_canonical_nodes"] is True
    assert scope["rules"]["do_not_present_incomplete_runtime_subset_as_final_design"] is True
    assert scope["rules"]["reserve_or_unimplemented_nodes_hidden_until_ready"] is True
