import hashlib
import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


class StoryUnlockableHeroesTests(unittest.TestCase):
    def test_order_progression_and_asset_integrity(self):
        contract = json.loads((ROOT / "data/recruitment/story_unlockable_heroes.json").read_text())
        manifest = json.loads((ROOT / "docs/art/story_heroes_asset_manifest_20261123.json").read_text())
        heroes = contract["heroes"]
        self.assertEqual(contract["order"], ["anouk", "marec", "mathilde"])
        self.assertEqual([hero["id"] for hero in heroes], contract["order"])
        self.assertEqual([hero["order"] for hero in heroes], [1, 2, 3])
        self.assertTrue(all(hero["existing_character"] for hero in heroes))
        self.assertEqual(contract["rules"]["level_at_recruitment"], "protagonist_current_level")
        self.assertEqual(contract["rules"]["skill_tree_choices_at_recruitment"], [])
        self.assertEqual(contract["rules"]["evolutionary_skill_choices_at_recruitment"], [])
        self.assertEqual(contract["runtime_status"], "not_implemented")
        for hero in heroes:
            entry = manifest["heroes"][hero["id"]]
            self.assertEqual(hero["art"], entry["sheet"]["path"])
            self.assertEqual(hero["portrait"], entry["portrait"]["path"])
            self.assertTrue((ROOT / entry["sheet"]["path"]).is_file())
            self.assertTrue((ROOT / entry["portrait"]["path"]).is_file())
            for asset in (entry["sheet"], entry["portrait"]):
                digest = hashlib.sha256((ROOT / asset["path"]).read_bytes()).hexdigest()
                self.assertEqual(digest, asset["sha256"], asset["path"])
            self.assertEqual(entry["portrait"]["status"], "imported_provisional_requires_visual_approval")


if __name__ == "__main__":
    unittest.main()
