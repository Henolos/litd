import unittest
from pathlib import Path

from tools.ci.select_godot_domains import ALL_DOMAINS, domain_test_owners, select_domains


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

    def test_test_only_change_uses_runner_owner(self):
        self.assertEqual(
            select_domains(["scenes/tests/mobile_touch_smoke.tscn"]),
            ["ui-qa"],
        )

    def test_dungeon_and_playthrough_changes_run_core_world(self):
        for path in (
            "scenes/tests/dungeon_playable_pipeline_smoke.tscn",
            "scenes/tests/first_accord_playthrough_smoke.tscn",
        ):
            with self.subTest(path=path):
                self.assertEqual(select_domains([path]), ["core-world"])

    def test_script_targets_are_indexed_too(self):
        self.assertEqual(
            select_domains(["scripts/tests/first_accord_extraction_route_smoke.gd"]),
            ["veilleurs"],
        )

    def test_unowned_test_falls_back_to_all_domains(self):
        self.assertEqual(select_domains(["scenes/tests/new_smoke.tscn"]), list(ALL_DOMAINS))

    def test_runner_index_covers_all_domains_and_existing_targets(self):
        owners = domain_test_owners()
        self.assertEqual(set.union(*owners.values()), set(ALL_DOMAINS))
        for path, domains in owners.items():
            with self.subTest(path=path):
                self.assertTrue(domains)
                self.assertTrue(Path(path).is_file())
                self.assertEqual(set(select_domains([path])), domains)


if __name__ == "__main__":
    unittest.main()
