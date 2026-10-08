from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[2]
RUNNER = ROOT / "tools" / "ci" / "run_godot_checked.sh"


class GodotCheckedRunnerTests(unittest.TestCase):
    def run_runner(self, *args: str) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            ["bash", str(RUNNER), *args],
            cwd=ROOT,
            text=True,
            capture_output=True,
            check=False,
        )

    def test_success_marker_is_required_when_requested(self):
        with tempfile.TemporaryDirectory() as tmp:
            log = Path(tmp) / "ok.log"
            result = self.run_runner(
                "--log",
                str(log),
                "--expect",
                "SMOKE_OK",
                "--",
                "bash",
                "-lc",
                "printf 'SMOKE_OK\\n'",
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn("SMOKE_OK", log.read_text(encoding="utf-8"))

    def test_missing_success_marker_fails(self):
        with tempfile.TemporaryDirectory() as tmp:
            result = self.run_runner(
                "--log",
                str(Path(tmp) / "missing.log"),
                "--expect",
                "SMOKE_OK",
                "--",
                "bash",
                "-lc",
                "printf 'done\\n'",
            )
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("GODOT_CHECKED_EXPECT_MISSING", result.stderr)

    def test_reject_marker_fails(self):
        with tempfile.TemporaryDirectory() as tmp:
            result = self.run_runner(
                "--log",
                str(Path(tmp) / "reject.log"),
                "--reject",
                "SMOKE_FAILED",
                "--",
                "bash",
                "-lc",
                "printf 'SMOKE_FAILED\\n'",
            )
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("GODOT_CHECKED_REJECT", result.stderr)

    def test_canonical_godot_fatal_pattern_fails(self):
        with tempfile.TemporaryDirectory() as tmp:
            result = self.run_runner(
                "--log",
                str(Path(tmp) / "fatal.log"),
                "--",
                "bash",
                "-lc",
                "printf 'SCRIPT ERROR: parse failed\\n'",
            )
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("GODOT_CHECKED_FATAL_PATTERN", result.stderr)

    def test_nonzero_command_is_preserved(self):
        with tempfile.TemporaryDirectory() as tmp:
            result = self.run_runner(
                "--log",
                str(Path(tmp) / "exit.log"),
                "--",
                "bash",
                "-lc",
                "exit 7",
            )
            self.assertEqual(result.returncode, 7)


if __name__ == "__main__":
    unittest.main()
