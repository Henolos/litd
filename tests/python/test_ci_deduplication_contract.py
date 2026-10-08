from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[2]


class CIDeduplicationContractTests(unittest.TestCase):
    def test_canonical_ci_owns_automatic_full_godot_suite(self):
        ci = (ROOT / ".github/workflows/ci.yml").read_text(encoding="utf-8")
        self.assertIn("merge_group:", ci)
        self.assertIn("bash tools/build/run_godot_ci.sh", ci)

    def test_live_status_mirrors_ci_without_rerunning_godot(self):
        workflow = (ROOT / ".github/workflows/godot-live-status.yml").read_text(encoding="utf-8")
        self.assertIn('workflows: ["CI"]', workflow)
        self.assertIn("types: [requested, in_progress, completed]", workflow)
        self.assertIn('"context": "godot-progress"', workflow)
        self.assertNotIn("run_godot_ci.sh", workflow)
        self.assertNotIn("godot_progress_bridge.py", workflow)
        self.assertNotIn("barichello/godot-ci", workflow)

    def test_production_full_regression_is_manual_only(self):
        workflow = (ROOT / ".github/workflows/veilleurs-production-automation.yml").read_text(
            encoding="utf-8"
        )
        self.assertIn(
            "if: ${{ github.event_name == 'workflow_dispatch' && inputs.full_suite }}",
            workflow,
        )
        self.assertNotIn(
            "github.event_name == 'push' || (github.event_name == 'workflow_dispatch' && inputs.full_suite)",
            workflow,
        )


if __name__ == "__main__":
    unittest.main()
