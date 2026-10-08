from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[2]
WORKFLOW = ROOT / ".github" / "workflows" / "build.yml"


class TargetedExportCIContractTests(unittest.TestCase):
    def test_expensive_exports_are_gated_but_main_and_tags_remain_supported(self):
        workflow = WORKFLOW.read_text(encoding="utf-8")
        self.assertIn("branches: [main]", workflow)
        self.assertIn("tags: ['v*']", workflow)
        self.assertIn("workflow_dispatch:", workflow)
        self.assertIn("name: Select export scope", workflow)
        self.assertIn('if [[ "$EVENT_NAME" != "pull_request" ]]', workflow)
        self.assertIn("build_all=true", workflow)
        self.assertIn("build_all=false", workflow)
        self.assertIn("needs.select-exports.outputs.build_all == 'true'", workflow)

    def test_all_platforms_retained(self):
        workflow = WORKFLOW.read_text(encoding="utf-8")
        for preset in ("Web", "Windows Desktop", "Linux/X11"):
            self.assertIn(f"- preset: {preset}", workflow)
        self.assertIn("needs: [canon-freshness, select-exports]", workflow)

    def test_export_config_changes_are_not_skipped(self):
        workflow = WORKFLOW.read_text(encoding="utf-8")
        self.assertIn("project\\.godot", workflow)
        self.assertIn("export_presets\\.cfg", workflow)
        self.assertIn("workflows/build\\.yml", workflow)
        self.assertIn("git diff --name-only", workflow)
        self.assertIn("git cat-file -e", workflow)

    def test_merge_queue_checks_not_changed(self):
        workflow = WORKFLOW.read_text(encoding="utf-8")
        self.assertIn("name: Canon Freshness Gate", workflow)
        self.assertIn("run: python tools/ci/canon_freshness_gate.py", workflow)
        self.assertNotIn("merge_group:", workflow)


if __name__ == "__main__":
    unittest.main()
