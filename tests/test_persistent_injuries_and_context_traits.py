import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RULES = json.loads((ROOT / "data" / "game_rules.json").read_text(encoding="utf-8"))
INJURIES = json.loads((ROOT / "data" / "persistent_injuries.json").read_text(encoding="utf-8"))
TRAITS = json.loads((ROOT / "data" / "character_traits.json").read_text(encoding="utf-8"))

def test_litd_has_one_non_selectable_difficulty():
    difficulty = RULES["difficulty"]
    assert difficulty["mode_count"] == 1
    assert difficulty["player_selectable"] is False
    assert difficulty["story_scales_to_company_level"] is True
    assert difficulty["farming_required_for_story"] is False

def test_injuries_persist_until_real_treatment():
    rules = RULES["persistent_injuries"]
    assert rules["persist_after_combat"] is True
    assert rules["persist_after_dungeon"] is True
    assert rules["persist_after_sleep"] is True
    assert rules["removed_only_by_treatment"] is True
    assert rules["can_worsen_when_untreated"] is True
    assert INJURIES["treatment"]["field_stabilization_removes_debuff"] is False


def test_no_permanent_blindness_system():
    assert RULES["vision"]["permanent_blindness"] is False
    assert RULES["vision"]["eye_injuries_are_temporary"] is True
    injury_ids = {entry["id"] for entry in INJURIES["definitions"]}
    assert "blindness" not in injury_ids
    assert "blind" not in injury_ids


def test_contextual_traits_keep_catalog_within_contract():
    positive_ids = {t["id"] for t in TRAITS["positives"]}
    assert {"ambidextrous", "alternate_support", "pain_endurance", "improviser", "ground_fighter"} <= positive_ids
    assert 20 <= len(TRAITS["positives"]) <= 30
    assert len(TRAITS["positives"]) == 25
