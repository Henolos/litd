"""Integrity and identity contracts for the owner's six original JPEG plates."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
QUARTET = {"mathilde", "marec", "anouk", "aurelien"}


def test_official_catalogue_matches_original_bytes():
    manifest = json.loads((ROOT / "docs/art/validated_heroes_manifest_20261111.json").read_text(encoding="utf-8"))
    assets = manifest["assets"]
    assert {a["hero"] for a in assets} == QUARTET | {"effrie", "lya"}
    assert len(assets) == len({a["id"] for a in assets}) == len({a["sha256"] for a in assets}) == 6
    for asset in assets:
        assert asset["target_path"] == f"art/library/heroes/{asset['hero']}/reference.jpg"
        raw = (ROOT / asset["target_path"]).read_bytes()
        assert raw.startswith(b"\xff\xd8")
        assert len(raw) == asset["size_bytes"]
        assert hashlib.sha256(raw).hexdigest() == asset["sha256"]


def test_art_catalogue_does_not_expand_playable_quartet_or_replace_generic_class_art():
    heroes = json.loads((ROOT / "data/heroes.json").read_text(encoding="utf-8"))
    assert {h["id"] for h in heroes} == QUARTET
    assert len(heroes) == 4
    classes = json.loads((ROOT / "data/classes.json").read_text(encoding="utf-8"))
    for clazz in classes:
        assert (ROOT / "assets/heroes" / clazz["art"]).is_file()
    jobs = json.loads((ROOT / "data/blender/character_jobs.json").read_text(encoding="utf-8"))
    hero_jobs = [j for j in jobs["jobs"] if j["category"] == "hero"]
    assert {j["character_id"] for j in hero_jobs} == QUARTET
    for job in hero_jobs:
        assert job["reference_art"] == f"art/library/heroes/{job['character_id']}/reference.jpg"
        assert (ROOT / job["reference_art"]).is_file()


def test_dynamic_art_slot_points_to_official_catalogue():
    registry = json.loads((ROOT / "data/canonical_art_v41.json").read_text(encoding="utf-8"))
    assert registry["asset_slots"]["portrait.active_hero"]["primary_path"] == "res://art/library/heroes/{entity_id}/reference.jpg"
