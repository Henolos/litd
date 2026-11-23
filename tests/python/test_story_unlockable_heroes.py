import hashlib
import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


class StoryUnlockableHeroesTests(unittest.TestCase):
    def test_order_progression_and_asset_integrity(self):
        contract = json.loads((ROOT / "data/recruitment/story_unlockable_heroes.json").read_text())
        manifest = json.loads((ROOT / "docs/art/story_heroes_asset_manifest_20261123.json").read_text())
        canon = json.loads((ROOT / "universe/lore/legendary_seven_formation.json").read_text())
        canon_by_id = {event["id"]: event for event in canon["recruitments"]}
        heroes = contract["heroes"]
        self.assertEqual(contract["order"], ["anouk", "marec", "mathilde"])
        self.assertEqual([hero["id"] for hero in heroes], contract["order"])
        self.assertEqual([hero["order"] for hero in heroes], [1, 2, 3])
        self.assertTrue(all(hero["existing_character"] for hero in heroes))
        self.assertEqual(contract["rules"]["level_at_recruitment"], "protagonist_current_level")
        self.assertEqual(contract["rules"]["skill_tree_choices_at_recruitment"], [])
        self.assertEqual(contract["rules"]["evolutionary_skill_choices_at_recruitment"], [])
        self.assertEqual(contract["runtime_status"], "not_implemented")
        self.assertEqual([gate["hero_id"] for gate in contract["story_progression"]["gates"]], contract["order"])
        self.assertEqual([gate["canonical_event_id"] for gate in contract["story_progression"]["gates"]], ["formation.anouk_rank_2", "formation.marec_rank_3", "formation.mathilde_rank_4"])
        self.assertEqual(contract["story_progression"]["gates"][1]["prerequisite_unlocked_hero_ids"], ["anouk"])
        self.assertEqual(contract["story_progression"]["gates"][2]["prerequisite_unlocked_hero_ids"], ["anouk", "marec"])
        self.assertEqual(contract["story_progression"]["runtime_adapter"], "not_implemented_campaign_event_adapter_needed")
        self.assertEqual(contract["persistence"]["unlocked_hero_flags"], "permanent_across_game_over")
        self.assertEqual(contract["persistence"]["hero_death"], "permanent_for_the_individual_hero")
        self.assertEqual([canon["formation_order"].index("hero." + hero_id) for hero_id in contract["order"]], [1, 2, 3])
        for hero in heroes:
            entry = manifest["heroes"][hero["id"]]
            self.assertEqual(hero["art"], entry["sheet"]["path"])
            self.assertEqual(hero["portrait"], entry["portrait"]["path"])
            beat_id = hero["canonical_story_beat_ref"].rsplit("/", 1)[-1]
            self.assertEqual(canon_by_id[beat_id]["joining_hero"], "hero." + hero["id"])
            self.assertTrue((ROOT / entry["sheet"]["path"]).is_file())
            self.assertTrue((ROOT / entry["portrait"]["path"]).is_file())
            for asset in (entry["sheet"], entry["portrait"]):
                digest = hashlib.sha256((ROOT / asset["path"]).read_bytes()).hexdigest()
                self.assertEqual(digest, asset["sha256"], asset["path"])
            self.assertEqual(entry["portrait"]["status"], "provisional_not_approved_for_combat")


if __name__ == "__main__":
    unittest.main()
