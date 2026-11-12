import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def load(path: str):
    return json.loads(read(path))






def test_first_map_has_authored_living_content():
    content = load("data/levels/ashlands_living_exploration.json")
    manifest = load("data/levels/terre_des_cendres_blockout_manifest.json")
    # The optional dungeon has its own authored map and room-level hazards.
    dungeon = load("data/dungeons/first_map_hall_of_first_accord.json")
    dungeon_zone = next(zone for zone in manifest["zones"] if zone["id"] == dungeon["zone_id"])
    assert dungeon_zone["dungeon"] is True
    assert dungeon_zone["optional"] is True
    authored_map = load(dungeon["authored_map"]["path"].removeprefix("res://"))
    assert authored_map["zone_id"] == dungeon["zone_id"]
    assert all(floor["rooms"] for floor in authored_map["floors"])
    assert all(floor["hazards"] and floor["retreat_exit"] for floor in dungeon["floors"])
    zone_ids = {zone["id"] for zone in manifest["zones"]}
    assert set(content["zones"]) | {dungeon["zone_id"]} == zone_ids
    assert all("landmark" in zone for zone in content["zones"].values())
    assert sum(len(zone.get("traps", [])) for zone in content["zones"].values()) >= 14
    assert sum(len(zone.get("patrols", [])) for zone in content["zones"].values()) >= 6


def test_traps_are_readable_and_offer_multiple_responses():
    rules = load("data/exploration_systems.json")
    assert len(rules["traps"]) >= 8
    for trap in rules["traps"].values():
        assert len(trap["cues"]) >= 2
        assert len(trap["actions"]) >= 3
        assert "failure" in trap












def test_no_forbidden_survival_micromanagement_was_added():
    rules = read("data/exploration_systems.json").lower()
    for forbidden in ['"hunger"', '"thirst"', '"individual_weight"', '"equipment_durability"']:
        assert forbidden not in rules
