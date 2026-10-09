import unittest

from tools.ci.select_export_targets import ALL, select


class ExportSelectionTests(unittest.TestCase):
    def test_regular_game_change_avoids_redundant_exports(self):
        self.assertEqual(select(["scripts/core/combat_targeting_rules.gd"]), [])

    def test_assets_change_avoids_redundant_exports(self):
        self.assertEqual(select(["assets/art/hero.png"]), [])

    def test_export_configuration_change_builds_every_platform(self):
        self.assertEqual(select(["export_presets.cfg"]), list(ALL))

    def test_unknown_change_fails_closed_to_all(self):
        self.assertEqual(select(["tools/unknown/build_step.py"]), list(ALL))

    def test_empty_change_fails_closed_to_all(self):
        self.assertEqual(select([]), list(ALL))

    def test_mixed_change_including_config_builds_all(self):
        self.assertEqual(select(["scenes/tests/test.tscn", "project.godot"]), list(ALL))


if __name__ == "__main__":
    unittest.main()
