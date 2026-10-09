from pathlib import Path
import unittest

from tools.ci.select_export_targets import ALL, select


ROOT = Path(__file__).resolve().parents[2]
WORKFLOW = ROOT / ".github" / "workflows" / "build.yml"


class TargetedExportCIContractTests(unittest.TestCase):
    def test_expensive_exports_are_gated_but_main_and_tags_remain_supported(self):
        workflow = WORKFLOW.read_text(encoding="utf-8")
        self.assertIn("branches: [main]", workflow)
        self.assertIn("tags: ['v*']", workflow)
        self.assertIn("workflow_dispatch:", workflow)
        self.assertIn("name: Select export platforms", workflow)
        self.assertIn('if [[ "$EVENT" == "pull_request" ]]', workflow)
        self.assertIn("select_export_targets.py --all", workflow)
        self.assertIn("needs.select-exports.outputs.build_any == 'true'", workflow)
        self.assertEqual(select(["scripts/core/combat_targeting_rules.gd"]), [])

    def test_all_platforms_retained(self):
        workflow = WORKFLOW.read_text(encoding="utf-8")
        self.assertEqual([p["preset"] for p in ALL], ["Web", "Windows Desktop", "Linux/X11"])
        self.assertIn("fromJSON(needs.select-exports.outputs.matrix)", workflow)
        self.assertIn("needs: [canon-freshness, select-exports]", workflow)

    def test_export_config_changes_are_not_skipped(self):
        workflow = WORKFLOW.read_text(encoding="utf-8")
        self.assertIn("project.godot", workflow)
        self.assertIn("export_presets.cfg", workflow)
        self.assertIn(".github/workflows/build.yml", workflow)
        self.assertIn("git diff --name-only", workflow)
        self.assertIn("git cat-file -e", workflow)
        for path in ("project.godot", "export_presets.cfg", ".github/workflows/build.yml"):
            self.assertEqual(select([path]), list(ALL))

    def test_merge_queue_checks_not_changed(self):
        workflow = WORKFLOW.read_text(encoding="utf-8")
        self.assertIn("name: Canon Freshness Gate", workflow)
        self.assertIn("run: python tools/ci/canon_freshness_gate.py", workflow)
        self.assertNotIn("merge_group:", workflow)


if __name__ == "__main__":
    unittest.main()
