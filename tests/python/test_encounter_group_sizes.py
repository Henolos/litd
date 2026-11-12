import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def test_canonical_enemy_group_sizes_are_declared():
    rules = json.loads((ROOT / "data/roguelike/roguelike_rules.json").read_text(encoding="utf-8"))
    balance = rules["combat_balance"]
    assert balance["encounter_group_sizes"] == {
        "normal": [4, 4],
        "elite": [2, 3],
        "miniboss": [1, 2],
        "boss": [1, 1],
    }
    assert balance["encounter_member_scaling"]["normal"] == {"hp": 0.46, "damage": 0.55}
