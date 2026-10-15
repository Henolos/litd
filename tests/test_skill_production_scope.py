import json
from pathlib import Path

ROOT = Path(__file__).parents[1]


def load(path: str):
    return json.loads((ROOT / path).read_text(encoding="utf-8"))


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def test_hero_catalog_is_preserved_but_production_is_bounded():
    scope = load("data/skill_production_scope.json")
    heroes = scope["heroes"]
    assert heroes["catalog_nodes_per_branch"] == 15
    assert heroes["currently_targeted_runtime_nodes_per_branch"] == 10
    assert heroes["remaining_nodes_status"] == "authored_or_pending_production_not_removed_from_canon"
    assert scope["canonical_design"] == {
        "branches_per_character": 3,
        "nodes_per_branch": 15,
        "total_nodes_per_character": 45,
        "tree_choice_exclusive": True,
        "applies_to": ["heroes", "enemies", "captured_creatures"],
    }

    manager = read("scripts/core/hero_skill_manager.gd")
    assert "FULL_CATALOG_NODES_PER_BRANCH := 15" in manager
    assert "PRODUCTION_NODES_PER_BRANCH := 10" in manager
    assert "func production_skill_nodes" in manager
    assert "func reserve_skill_nodes" in manager
    assert "return VeilleursSkillCatalog.skill_nodes(hero, branch)" in manager
    assert '"production_state": "active" if index < PRODUCTION_NODES_PER_BRANCH else "reserve"' in manager
    assert 'not bool(node.get("available_in_current_release", false))' in manager


def test_current_ui_hides_reserve_without_deleting_it():
    focused_ui = read("scripts/ui/main_v33.gd")
    assert "HeroSkillManager.production_skill_nodes" in focused_ui
    assert "5 CONCEPTS CONSERVÉS EN RÉSERVE" in focused_ui


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
