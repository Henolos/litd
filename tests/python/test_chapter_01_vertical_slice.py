import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def _data():
    return json.loads((ROOT / "data/levels/chapter_01_vertical_slice.json").read_text())


def test_chapter_one_vertical_slice_has_complete_eight_stage_loop():
    data = _data(); stages = data["stages"]
    assert data["chapter_id"] == "chapter_01_ashlands"
    assert data["start_zone"] == "zone_01_faubourg_cendreux"
    assert len(stages) == 8
    assert [stage["type"] for stage in stages] == ["exploration", "rescue", "campfire", "creature", "miniboss", "investigation", "boss", "return"]




def test_ash_witness_contract():
    data = _data(); boss = data["boss"]
    assert boss["name"] == "Le Témoin des Cendres"
    assert len(boss["phases"]) == 3
    assert boss["signature"] == "Dernier Souvenir du Jour"
