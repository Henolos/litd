import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FORMATION = (ROOT / "scripts" / "ui" / "main_v47.gd").read_text(encoding="utf-8")
POSITION_RULES = (ROOT / "scripts" / "core" / "combat_position_rules.gd").read_text(encoding="utf-8")
POSITION_RUNTIME = (ROOT / "scripts" / "core" / "combat_position_runtime.gd").read_text(encoding="utf-8")
MAIN_COMBAT = (ROOT / "scripts" / "ui" / "main.gd").read_text(encoding="utf-8")
ROSTER = json.loads((ROOT / "data" / "veilleurs" / "canonical_roster.json").read_text(encoding="utf-8"))


def test_canonical_quartet_roles_match_front_and_back_contract():
    heroes = {hero["id"]: hero for hero in ROSTER["heroes"]}
    assert heroes["mathilde"]["class_id"] == "duelist"
    assert heroes["marec"]["class_id"] == "breaker"
    assert heroes["anouk"]["class_id"] == "mystic"
    assert heroes["aurelien"]["class_id"] == "surgeon"
    assert '"breaker", "watcher", "inquisitor", "duelist"' in POSITION_RULES
    assert '"vestal", "mystic", "ranger", "surgeon", "scout", "occultist"' in POSITION_RULES


def test_initial_formation_scores_canonical_front_and_back_classes():
    assert '"duelist", "breaker"' in FORMATION
    assert '"mystic", "surgeon"' in FORMATION


def test_equal_role_scores_are_stable_by_canonical_roster_order():
    assert 'left.get("starting_quartet_order", 999)' in FORMATION
    assert 'right.get("starting_quartet_order", 999)' in FORMATION


def test_visual_rank_order_keeps_r1_at_enemy_contact():
    assert "var visual_order := [4, 3, 2, 1]" in FORMATION
    assert "R4   R3   R2   R1" in FORMATION


def test_dead_enemy_compacts_survivors_toward_r1():
    assert "func compact_after_death" in POSITION_RUNTIME
    assert "func compact_living_formation" in POSITION_RUNTIME
    assert '"source": "death_compaction"' in POSITION_RUNTIME
    assert "character[\"combat_position\"] = destination" in POSITION_RUNTIME


def test_combat_flow_invokes_compaction_when_enemy_dies():
    assert "func _compact_enemy_formation_after_death" in MAIN_COMBAT
    assert 'compact_after_death(GameState.battle_enemies, "enemy")' in MAIN_COMBAT
    assert MAIN_COMBAT.count("_compact_enemy_formation_after_death()") >= 4
