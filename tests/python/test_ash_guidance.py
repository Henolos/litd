import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def test_ash_guidance_color_contract():
    config = json.loads((ROOT / "data" / "ash_guidance.json").read_text(encoding="utf-8"))
    assert config["version"] >= 3
    assert config["objective_modes"]["boss"]["far_color"] == "#85888D"
    assert config["objective_modes"]["boss"]["near_color"] == "#FF3B1F"
    assert config["objective_modes"]["quest"]["far_color"] == "#85888D"
    assert config["objective_modes"]["quest"]["near_color"] == "#45A8FF"
    assert config["accessibility"]["color_is_not_only_signal"] is True










def test_emotional_guidance_contract_has_fear_danger_and_safety():
    config = json.loads((ROOT / "data" / "ash_guidance.json").read_text(encoding="utf-8"))
    emotion = config["emotion"]
    assert emotion["fear"]["enter"] > emotion["fear"]["exit"]
    assert emotion["major_danger"]["enter"] > emotion["major_danger"]["exit"]
    assert emotion["safe"]["enter"] > emotion["safe"]["exit"]
    assert emotion["direction_fidelity_min"] >= 0.75
    assert config["accessibility"]["emotion_never_reverses_direction"] is True
    assert config["accessibility"]["fear_changes_motion_not_destination"] is True










def test_dungeon_environment_maps_major_danger_and_safe_rooms():
    config = json.loads((ROOT / "data" / "ash_guidance.json").read_text(encoding="utf-8"))
    danger = config["environment_context"]["danger_floor_by_role"]
    safety = config["environment_context"]["safety_by_room_type"]
    assert danger["boss"] == 1.0
    assert danger["preboss"] >= 0.85
    assert danger["elite"] >= 0.70
    assert safety["camp"] == 1.0
    assert safety["sanctuary"] >= 0.90
