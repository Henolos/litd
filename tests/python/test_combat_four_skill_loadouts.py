from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]








def test_healing_items_and_grenades_are_combat_supplies_not_skill_slots():
    rules = json.loads((ROOT / "data/levels/ashlands_survival_rules.json").read_text(encoding="utf-8"))
    assert rules["expedition_inventory"]["bandages"] >= 1
    assert rules["expedition_inventory"]["medicine"] >= 1
    assert rules["expedition_inventory"]["grenades"] >= 1
    assert rules["combat_items"]["bandages"]["effect"] == "heal"
    assert rules["combat_items"]["medicine"]["effect"] == "heal"
    assert rules["combat_items"]["grenades"]["effect"] == "damage_all"
    assert rules["principles"]["combat_items_are_separate_from_skill_loadout"] is True
    assert rules["principles"]["position_change_costs_turn"] is True
    assert rules["principles"]["passing_costs_turn"] is True
