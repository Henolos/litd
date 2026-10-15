import unittest

from tools.ci.select_godot_domains import ALL_DOMAINS, select_domains


class GodotDomainSelectorTests(unittest.TestCase):
    def test_unknown_change_falls_back_to_all_domains(self):
        self.assertEqual(select_domains(["unexpected/new/runtime.file"]), list(ALL_DOMAINS))

    def test_global_project_change_runs_all_domains(self):
        self.assertEqual(select_domains(["project.godot"]), list(ALL_DOMAINS))

    def test_ui_change_avoids_unrelated_world_and_audio_domains(self):
        self.assertEqual(
            select_domains(["scripts/ui/main_v49.gd"]),
            ["runtime", "veilleurs", "ui-qa"],
        )

    def test_audio_change_targets_audio_and_runtime(self):
        self.assertEqual(
            select_domains(["scripts/core/audio_director.gd"]),
            ["audiovisual", "runtime"],
        )

    def test_veilleurs_data_change_targets_runtime_and_veilleurs(self):
        self.assertEqual(
            select_domains(["data/veilleurs/v08/enemy_doctrines_24.json"]),
            ["runtime", "veilleurs"],
        )

    def test_combat_core_change_is_conservative(self):
        self.assertEqual(
            select_domains(["scripts/core/combat_targeting_rules.gd"]),
            ["core-world", "runtime", "veilleurs"],
        )

    def test_test_only_change_uses_test_name(self):
        self.assertEqual(
            select_domains(["scenes/tests/mobile_touch_smoke.tscn"]),
            ["runtime", "ui-qa"],
        )


if __name__ == "__main__":
    unittest.main()
