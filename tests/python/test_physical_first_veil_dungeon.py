import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CATALOG = ROOT / "data" / "roguelike" / "first_veil_rooms.json"
RUNTIME = ROOT / "scripts" / "core" / "first_veil_dungeon_runtime.gd"
UI = ROOT / "scripts" / "ui" / "main_v27.gd"




def test_first_veil_is_four_palier_vertical_descent_with_real_rooms():
    data = json.loads(CATALOG.read_text(encoding="utf-8"))
    assert data["dungeon_id"] == "first_veil_crypts"
    assert data["orientation"] == "vertical_descending"
    assert data["palier_count"] == 4
    assert data["design_rules"]["one_node_one_explorable_space"] is True
    assert data["design_rules"]["one_connection_one_physical_passage"] is True
    assert len(data["rooms"]) >= 30
    assert {room.get("palier", 0) for room in data["rooms"] if room.get("palier", 0) > 0} == {1, 2, 3, 4}
    assert any(room.get("room_role") == "entry" for room in data["rooms"])
    assert any(room.get("room_role") == "boss" for room in data["rooms"])
    for room in data["rooms"]:
        assert room["id"]
        assert room["name"]
        assert room["connections"]
        assert room["space_kind"]
        assert room["description"]
        assert room["interactions"]
        assert room["variant_pool"]
