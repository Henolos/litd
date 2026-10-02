from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TARGET_RESOLVER = (ROOT / "scripts" / "core" / "combat" / "veilleurs_target_resolver.gd").read_text(encoding="utf-8")
AI_V3 = (ROOT / "scripts" / "core" / "veilleurs_enemy_ai_v3.gd").read_text(encoding="utf-8")
ENEMY_DIRECTOR = (ROOT / "scripts" / "core" / "enemy_combat_director.gd").read_text(encoding="utf-8")
MAIN_V32 = (ROOT / "scripts" / "ui" / "main_v32.gd").read_text(encoding="utf-8")


def test_ui_routes_targeting_through_canonical_resolver():
    assert 'preload("res://scripts/core/combat/veilleurs_target_resolver.gd")' in MAIN_V32
    assert 'preload("res://scripts/core/combat_targeting_rules.gd")' in TARGET_RESOLVER
    assert "static func targetable_indices" in TARGET_RESOLVER
    assert "return RULES.targetable_indices(hero, skill, enemies)" in TARGET_RESOLVER
    assert "static func can_target" in TARGET_RESOLVER


def test_enemy_candidates_use_same_target_resolver():
    assert "static func enemy_targetable_indices" in TARGET_RESOLVER
    assert 'str(action.get("target", "random")) in ["none", "self"]' in TARGET_RESOLVER
    assert "TARGET_RESOLVER.enemy_targetable_indices" in AI_V3


def test_active_enemy_director_delegates_target_selection_to_v3():
    assert 'preload("res://scripts/core/veilleurs_enemy_ai_v3.gd")' in ENEMY_DIRECTOR
    assert "enemy_ai_v3.choose_rank_target_index" in ENEMY_DIRECTOR
    assert "func choose_rank_target_index" in AI_V3
    assert "func _rank_target_score" in AI_V3


def test_v3_rank_scoring_keeps_role_memory_and_position_inputs():
    assert "PREDATOR_ROLES.has(role)" in AI_V3
    assert 'adaptations.has("avoid_guard")' in AI_V3
    assert 'adaptations.has("pressure_wounded")' in AI_V3
    assert "func _rank_distance" in AI_V3
    assert 'enemy.get("combat_position", 0)' in AI_V3
    assert 'hero.get("combat_position", 0)' in AI_V3


def test_v3_controls_enemy_action_family():
    assert "func decide_rank_action" in AI_V3
    for action in ['"flee"', '"support"', '"move"', '"hold"', '"attack"']:
        assert action in AI_V3
    assert "enemy_ai_v3.decide_rank_action" in ENEMY_DIRECTOR
    assert "position_runtime.enemy_move_action" in ENEMY_DIRECTOR
    assert "func _support_action" in ENEMY_DIRECTOR
