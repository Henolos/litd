from __future__ import annotations
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_qa_room_concentrates_critical_player_flows() -> None:
    matrix = json.loads((ROOT / "data/qa/validation_room_matrix.json").read_text(encoding="utf-8"))
    assert matrix["campaign_state_isolation"] is True
    assert matrix["production_build_visibility"] == "debug_only"
    station_ids = {station["id"] for station in matrix["stations"]}
    assert station_ids == {"movement", "dialogue", "loot", "combat", "systems"}
    combat = next(station for station in matrix["stations"] if station["id"] == "combat")
    for required in ["four_enemies", "skill_slots", "healing_item", "grenade", "capture_indicator", "return_to_same_room"]:
        assert required in combat["tests"]






def test_qa_snapshot_never_uses_campaign_slots() -> None:
    save = (ROOT / "scripts/core/save_manager.gd").read_text(encoding="utf-8")
    assert 'QA_SNAPSHOT_PATH := "user://litd_qa_snapshot.json"' in save
    assert "save_qa_snapshot" in save
    assert "load_qa_snapshot" in save
    assert "delete_qa_snapshot" in save
