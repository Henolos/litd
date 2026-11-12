import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def _load(name):
    return json.loads((ROOT / "data" / name).read_text())


def test_only_regular_first_level_creatures_are_capturable():
    definitions = _load("capturable_creatures.json")
    enemies = {enemy["id"]: enemy for enemy in _load("enemies.json")}
    assert {definition["enemy_id"] for definition in definitions} == {1, 8, 10}
    assert all(not enemies[definition["enemy_id"]].get("boss", False) for definition in definitions)
