import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def test_political_data_has_three_playable_first_level_decisions():
    data = json.loads((ROOT / "data/levels/ashlands_politics.json").read_text())
    quests = {quest["id"]: quest for quest in data["quests"]}
    assert set(quests) == {"ashlands_refugee_gate", "ashlands_first_blood", "ashlands_conscious_creature"}
