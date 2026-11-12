import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def test_first_veil_declares_first_descent_reward():
    rules = json.loads((ROOT / "data/roguelike/roguelike_rules.json").read_text())
    challenge = rules["dungeons"]["first_veil_crypts"]["first_descent"]
    assert challenge["enabled"] is True
    assert challenge["title"] == "Celui qui n'a pas remonté"
    assert challenge["relic_name"] == "Éclat du Premier Voile"
    assert challenge["chronicle_title"] == "LA PREMIÈRE DESCENTE"
    assert challenge["reward_policy"] == "commemorative_only_no_required_power"
