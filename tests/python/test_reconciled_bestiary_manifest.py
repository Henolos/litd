"""Documentary contracts; these tests do not certify unavailable image bytes."""
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]


def catalogue():
    return json.loads((ROOT / "docs/art/reconciled_bestiary_manifest_20261111.json").read_text(encoding="utf-8"))


def test_reference_identities_and_canonical_numbers_do_not_collide():
    data = catalogue()
    assets = data["assets"]
    assert len(assets) == data["scope"]["documented_official_plates"] == 21
    assert len({a["asset_id"] for a in assets}) == 21
    assert len({a["subject_id"] for a in assets}) == 21
    assert len({a["expected_sha256"] for a in assets}) == 21
    assert {a["canonical_plate_number"] for a in assets} == {4, 5, 6, 7, 9, 10, 11, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26}
    assert data["production_plan"]["total_creatures"] == 40
    assert len(assets) != data["production_plan"]["total_creatures"]


def test_expected_fingerprints_are_not_reported_as_verified_archives():
    data = catalogue()
    archived = 0
    for asset in data["assets"]:
        assert re.fullmatch(r"[0-9a-f]{64}", asset["expected_sha256"])
        assert re.fullmatch(r"[0-9a-f]{40}", asset["source_evidence"]["commit"])
        target = Path(asset["planned_target_path"])
        assert target.as_posix().startswith("art/library/bestiary/")
        assert ".." not in target.parts
        assert target.suffix == Path(asset["source_filename"]).suffix.lower()
        if asset["binary_status"] == "pending_retrieval":
            assert asset["measured_sha256"] is None
            assert asset["archived_path"] is None
        else:
            assert asset["binary_status"] == "verified_in_github"
            assert asset["archived_path"] == asset["planned_target_path"]
            digest = hashlib.sha256((ROOT / asset["archived_path"]).read_bytes()).hexdigest()
            assert digest == asset["measured_sha256"] == asset["expected_sha256"]
            archived += 1
    assert archived == data["scope"]["binary_imported_in_this_lot"]


def test_historical_candidates_cannot_silently_replace_current_references():
    assets = {a["subject_id"]: a for a in catalogue()["assets"]}
    assert assets["kitsune"]["canonical_plate_number"] == 26
    assert assets["draugr"]["canonical_plate_number"] == 21
    assert assets["spectral_valkyrie"]["expected_sha256"] == "30a1f79497759885753ae0de383d0fb1c5086bf1646653131531defaa81aaa37"
    assert assets["emaciated_wolf"]["expected_sha256"] == "e24caea7562a701cf61099416f62c62c8f4edb5d1f17df552bffd03e01e1110c"
    assert assets["runic_stone_golem"]["art_status"] == "validated_by_owner"


def test_documentary_reconciliation_does_not_activate_gameplay_mappings():
    data = catalogue()
    assert data["scope"]["runtime_migration"] is False
    assert all(a["runtime_enemy_id"] is None for a in data["assets"])


def test_complete_collection_claim_requires_every_registered_original():
    data = catalogue()
    pending = sum(a["binary_status"] == "pending_retrieval" for a in data["assets"])
    assert pending == data["scope"]["binary_still_pending"]
    if data["retrieval_status"] == "complete_for_documented_plates":
        assert pending == 0
        assert data["scope"]["binary_imported_in_this_lot"] == len(data["assets"])
        expected = {a["archived_path"] for a in data["assets"]}
        actual = {p.relative_to(ROOT).as_posix() for p in (ROOT / "art/library/bestiary").glob("*/reference.*")}
        assert actual == expected
