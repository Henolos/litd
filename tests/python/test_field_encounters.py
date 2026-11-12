from pathlib import Path

from tools.qa.field_encounter_audit import run

ROOT = Path(__file__).resolve().parents[2]






def test_previous_choices_create_different_later_world_states():
    data = (ROOT / "data/field_encounters.json").read_text(encoding="utf-8")
    for token in [
        "c01_village_survivors",
        "c03_survivor_outpost",
        "c03_survivors_without_aid",
        "c03_spared_witness_return",
        "source_outcomes",
        "requires_boss_outcome",
    ]:
        assert token in data
