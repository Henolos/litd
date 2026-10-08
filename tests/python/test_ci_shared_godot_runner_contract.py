from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[2]
PRODUCTION = ROOT / ".github" / "workflows" / "veilleurs-production-automation.yml"
WINDOWS = ROOT / ".github" / "workflows" / "veilleurs-first-playtest-windows.yml"


class SharedGodotRunnerContractTests(unittest.TestCase):
    def test_production_workflow_uses_shared_checked_runner(self):
        text = PRODUCTION.read_text(encoding="utf-8")
        self.assertGreaterEqual(text.count("tools/ci/run_godot_checked.sh"), 8)
        self.assertNotIn("SCRIPT ERROR:", text)

    def test_windows_playtest_uses_shared_checked_runner(self):
        text = WINDOWS.read_text(encoding="utf-8")
        self.assertGreaterEqual(text.count("tools/ci/run_godot_checked.sh"), 7)
        self.assertNotIn("SCRIPT ERROR:", text)
        self.assertIn("barichello/godot-ci:4.7.2@sha256:", text)

    def test_shared_runner_changes_trigger_both_workflows(self):
        production = PRODUCTION.read_text(encoding="utf-8")
        windows = WINDOWS.read_text(encoding="utf-8")
        self.assertIn("'tools/ci/run_godot_checked.sh'", production)
        self.assertEqual(windows.count("'tools/ci/run_godot_checked.sh'"), 2)


if __name__ == "__main__":
    unittest.main()
