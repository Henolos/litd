import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MENU_V1 = ROOT / "scripts" / "ui" / "context_menu_ui.gd"
MENU_V2 = ROOT / "scripts" / "ui" / "context_menu_ui_v2.gd"
MENU_V3 = ROOT / "scripts" / "ui" / "context_menu_ui_v3.gd"








def test_dungeon_quest_data_is_explicitly_typed_and_trackable():
    quests = json.loads((ROOT / "data" / "quests.json").read_text(encoding="utf-8"))
    assert quests
    assert all(quest.get("quest_type") == "dungeon" for quest in quests)
    assert all(quest.get("dungeon_id") for quest in quests)
    assert all(isinstance(quest.get("condition"), dict) and quest["condition"].get("type") for quest in quests)
