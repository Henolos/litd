"""Integrity and data-contract tests for the weapon-master recruitable hero set."""
import hashlib
import json
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[2]
MANIFEST = ROOT / "docs/art/weapon_master_heroes_manifest_20261123.json"
RECRUITMENT = ROOT / "data/recruitment/weapon_master_hero_unlocks.json"
EXPECTED = {"ysra_nahal", "effrie", "lya", "zeje", "aurelien"}


def load_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


class WeaponMasterUnlockablesTest(unittest.TestCase):
    def test_manifest_contains_exact_five_unique_sources_and_targets(self):
        manifest = load_json(MANIFEST)
        assets = manifest["assets"]
        self.assertEqual({a["hero_id"] for a in assets}, EXPECTED)
        self.assertEqual(len(assets), 5)
        self.assertEqual(len({a["target_path"] for a in assets}), 5)
        self.assertEqual(len({a["sha256"] for a in assets}), 5)
        for asset in assets:
            path = ROOT / asset["target_path"]
            raw = path.read_bytes()
            self.assertEqual(len(raw), asset["bytes"], asset["hero_id"])
            self.assertEqual(hashlib.sha256(raw).hexdigest(), asset["sha256"], asset["hero_id"])
            self.assertTrue(raw.startswith(b"\xff\xd8"), asset["hero_id"])

    def test_existing_approved_references_are_reused_not_copied(self):
        manifest = load_json(MANIFEST)
        by_id = {asset["hero_id"]: asset for asset in manifest["assets"]}
        for hero_id in ("effrie", "aurelien"):
            asset = by_id[hero_id]
            self.assertEqual(asset["action"], "reuse_existing_exact_sha256")
            self.assertTrue(asset["existing_manifest"])
        lya = by_id["lya"]
        self.assertEqual(lya["action"], "new_supplemental_design_sheet")
        existing_lya = ROOT / lya["existing_runtime_reference"]["path"]
        self.assertEqual(hashlib.sha256(existing_lya.read_bytes()).hexdigest(), lya["existing_runtime_reference"]["sha256"])
        self.assertNotEqual(hashlib.sha256(existing_lya.read_bytes()).hexdigest(), lya["sha256"])

    def test_recruitment_contract_is_prepared_without_duplicate_or_new_meter(self):
        config = load_json(RECRUITMENT)
        self.assertEqual({h["hero_id"] for h in config["heroes"]}, EXPECTED)
        self.assertEqual(config["unlock"]["method"], "affinity_with_recruiter")
        self.assertIsNone(config["unlock"]["affinity_threshold"])
        self.assertIn("do_not_create_a_separate_trust_meter", config["unlock"]["relationship_meter"])
        self.assertEqual(config["recruitment_progression"]["level_at_recruitment"], "protagonist_current_level")
        self.assertEqual(config["recruitment_progression"]["skill_tree_choices_at_recruitment"], [])
        self.assertEqual(config["recruitment_progression"]["evolutionary_skill_choices_at_recruitment"], [])
        self.assertEqual(config["recruitment_progression"]["skill_points"]["status"], "not_verified_in_active_litd1_code")

    def test_aurelien_reuses_one_identity_without_starting_quartet_block(self):
        heroes = load_json(ROOT / "data/heroes.json")
        self.assertEqual(sum(hero["id"] == "aurelien" for hero in heroes), 1)
        recruitment = load_json(RECRUITMENT)
        aurelien = next(hero for hero in recruitment["heroes"] if hero["hero_id"] == "aurelien")
        self.assertNotIn("roster_conflict", aurelien)
        self.assertIn("not part of the current starting quartet", aurelien["roster_note"])

    def test_only_one_zeje_variant_is_registered(self):
        manifest = load_json(MANIFEST)
        zeje_assets = [a for a in manifest["assets"] if a["hero_id"] == "zeje"]
        self.assertEqual(len(zeje_assets), 1)
        self.assertIs(zeje_assets[0]["rejected_variant_included"], False)
        self.assertEqual(zeje_assets[0]["source_archive_member"], "assets_valides/zeje_planche_validee.jpeg")


if __name__ == "__main__":
    unittest.main()
