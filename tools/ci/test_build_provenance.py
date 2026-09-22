from __future__ import annotations

import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "tools" / "ci" / "generate_build_provenance.py"


class BuildProvenanceTests(unittest.TestCase):
    def test_generates_exact_sha_and_canon_version(self) -> None:
        sha = "0123456789abcdef0123456789abcdef01234567"
        with tempfile.TemporaryDirectory(dir=ROOT) as tmp:
            output = Path(tmp) / "provenance.json"
            rel = output.relative_to(ROOT)
            result = subprocess.run(
                [sys.executable, str(SCRIPT), "--output", str(rel), "--sha", sha, "--branch", "main", "--run-id", "42"],
                cwd=ROOT,
                text=True,
                capture_output=True,
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            payload = json.loads(output.read_text(encoding="utf-8"))
            self.assertEqual(payload["git_sha"], sha)
            self.assertEqual(payload["git_short_sha"], sha[:12])
            self.assertEqual(payload["source_branch"], "main")
            self.assertEqual(payload["workflow_run_id"], "42")
            self.assertIsInstance(payload["canon_version"], int)
            self.assertTrue(payload["build_timestamp_utc"].endswith("Z"))

    def test_rejects_missing_sha(self) -> None:
        with tempfile.TemporaryDirectory(dir=ROOT) as tmp:
            output = Path(tmp) / "provenance.json"
            rel = output.relative_to(ROOT)
            result = subprocess.run(
                [sys.executable, str(SCRIPT), "--output", str(rel), "--sha", ""],
                cwd=ROOT,
                text=True,
                capture_output=True,
            )
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("missing/invalid git SHA", result.stderr + result.stdout)


if __name__ == "__main__":
    unittest.main()
