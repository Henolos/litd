import json
from pathlib import Path

ROOT = Path(__file__).parents[1]


def test_first_map_production_contract_is_complete():
    data = json.loads((ROOT / "data/levels/ashlands_first_map_production.json").read_text(encoding="utf-8"))
    assert data["units"] == "meters"
    assert len(data["zones"]) == 5
    assert len(data["routes"]["main"]) == len(data["zones"])
    assert len(data["routes"]["shortcuts"]) >= 2
    assert len(data["routes"]["blocked"]) >= 2
    assert len(data["routes"]["expedition_variants"]) >= 3
    assert len(data["assets"]) >= 5
    assert len(data["enemy_profiles"]) >= 4
    assert len(data["audio_events"]) >= 15
    for zone in data["zones"]:
        assert all(value > 0 for value in zone["size"])
        assert zone["traversal_seconds"] > 0
        assert "giver" in zone and "quests" in zone
    for asset in data["assets"]:
        assert asset["variants"] > 0
        assert asset["lods"] >= 2
        assert asset["poly_budget"] > 0
        assert asset["collision"]
        assert asset["export"].endswith(".glb")
    for enemy in data["enemy_profiles"]:
        assert enemy["rig"]
        if enemy["family"] == "first_veil_boss":
            assert {"idle", "stagger", "phase_change", "death"}.issubset(enemy["animations"])
        else:
            assert {"idle", "fear", "panic", "hit", "death"}.issubset(enemy["animations"])
