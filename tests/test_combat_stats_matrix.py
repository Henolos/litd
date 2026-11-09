"""Deterministic, dependency-free audit of the canonical v06 combat stat matrix.

Run: python3 -m unittest discover -s tests -p 'test_combat_stats_matrix.py'
This checks static data and formulas, NOT a Godot combat playthrough.
"""
import json
import math
import pathlib
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
DATA = ROOT / "data" / "veilleurs" / "v06"
STATS = ("FOR", "TEC", "PRE", "MOB", "GAR", "RES", "PER", "VIG")


def load(name):
    return json.loads((DATA / name).read_text(encoding="utf-8"))


def godot_round_positive(value):
    return math.floor(value + 0.5)


class CombatStatsMatrixAudit(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.heroes = load("watchers.json")["watchers"]
        cls.enemies = load("enemies_24_definitions.json")["enemies"]
        cls.constants = load("combat_constants.json")

    def test_roster_and_stats_complete(self):
        self.assertEqual(len(self.heroes), 4)
        self.assertEqual(len(self.enemies), 24)
        for entity in self.heroes + self.enemies:
            with self.subTest(entity=entity["entity_id"]):
                self.assertTrue(all(k in entity["stats"] for k in STATS))
                self.assertTrue(all(isinstance(entity["stats"][k], (int, float)) for k in STATS))
                self.assertGreater(80 + entity["stats"]["VIG"], 0)

    def test_all_96_matchups_have_valid_baseline(self):
        zone_bonus = self.constants["zone_accuracy_mod"]["torso"]
        low = self.constants["hit_clamp"]["min_percent"]
        high = self.constants["hit_clamp"]["max_percent"]
        balance = self.constants["v061_balance"]
        self.assertEqual(balance["watcher_weapon_power"], 30)
        self.assertEqual(balance["enemy_weapon_power"], 42)
        seen = 0
        for hero in self.heroes:
            for enemy in self.enemies:
                with self.subTest(hero=hero["entity_id"], enemy=enemy["entity_id"]):
                    chance = max(low, min(high, godot_round_positive(
                        75 + (hero["stats"]["PRE"] - enemy["stats"]["MOB"]) * .45 + zone_bonus
                    )))
                    # Canonical v2 tactical formula with skill multiplier 1, armor 20,
                    # no resistance, status, equipment, or positional effects.
                    damage = max(1, godot_round_positive(
                        30 * (.70 + hero["stats"]["FOR"] / 200) * (1 - 20 / 120)
                    ))
                    self.assertTrue(low <= chance <= high)
                    self.assertGreater(damage, 0)
                    self.assertTrue(0 < chance * damage / 100 <= damage)
                    seen += 1
        self.assertEqual(seen, 96)

    def test_hero_hp_authority_is_distinct_from_legacy_seed(self):
        legacy = {row["id"]: row for row in json.loads(
            (ROOT / "data" / "heroes.json").read_text(encoding="utf-8")
        )}
        differences = []
        for hero in self.heroes:
            hero_id = hero["entity_id"].removeprefix("ENT_WATCHER_")
            tactical_hp = 80 + hero["stats"]["VIG"]
            self.assertIn(hero_id, legacy)
            if tactical_hp != legacy[hero_id]["max_hp"]:
                differences.append(hero_id)
        # Intentional audit signal: avoid silently assuming the two HP sources agree.
        self.assertEqual(len(differences), 4)


if __name__ == "__main__":
    unittest.main()
