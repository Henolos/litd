"""Execute the workflow's actual publisher with HTTP isolated from GitHub."""
import contextlib
import io
import json
from pathlib import Path
import textwrap
import unittest
from unittest.mock import patch
from urllib.error import HTTPError

ROOT = Path(__file__).resolve().parents[2]


class LiveStatusRuntimeTests(unittest.TestCase):
    def publish(self, action, live_status, conclusion=None, head_sha="test-sha", read_error=False):
        workflow = (ROOT / ".github/workflows/godot-live-status.yml").read_text()
        source = textwrap.dedent(workflow.split("python3 - <<'PY'\n", 1)[1].split("\n          PY", 1)[0])
        writes = []
        run = {"id": 123, "status": live_status, "conclusion": conclusion, "head_sha": head_sha}

        class Response:
            status = 201

            def __enter__(self):
                return self

            def __exit__(self, *_args):
                return False

            def read(self):
                return json.dumps(run).encode()

        def urlopen(request, **_kwargs):
            if request.get_method() == "GET":
                self.assertEqual(request.full_url, "https://api.github.com/repos/Henolos/litd/actions/runs/123")
                if read_error:
                    raise HTTPError(request.full_url, 503, "unavailable", {}, None)
            else:
                self.assertEqual(request.get_method(), "POST")
                writes.append(json.loads(request.data))
            return Response()

        environment = {
            "GH_TOKEN": "test-token", "REPOSITORY": "Henolos/litd",
            "TARGET_SHA": "test-sha", "TARGET_URL": "https://github.com/Henolos/litd/actions/runs/123",
            "RUN_ID": "123", "RUN_ACTION": action,
            # Deliberately stale payload: the current canonical run is authoritative.
            "RUN_CONCLUSION": "failure" if action == "completed" else "",
        }
        with patch.dict("os.environ", environment), patch("urllib.request.urlopen", urlopen), contextlib.redirect_stdout(io.StringIO()):
            try:
                exec(compile(source, str(ROOT / ".github/workflows/godot-live-status.yml"), "exec"), {})
            except (SystemExit, HTTPError):
                self.assertEqual(writes, [], "identity/read errors must not publish a status")
                raise
        self.assertEqual(len(writes), 1)
        self.assertEqual(writes[0]["context"], "godot-progress")
        self.assertEqual(writes[0]["target_url"], environment["TARGET_URL"])
        return writes[0]["state"]

    def test_requested_run_is_pending(self):
        self.assertEqual(self.publish("requested", "queued"), "pending")

    def test_delayed_request_preserves_completed_success(self):
        self.assertEqual(self.publish("requested", "completed", "success"), "success")

    def test_old_completion_during_a_rerun_is_pending(self):
        self.assertEqual(self.publish("completed", "in_progress"), "pending")

    def test_terminal_results_follow_current_run(self):
        for conclusion, expected in [("success", "success"), ("failure", "failure"), ("timed_out", "failure"), ("cancelled", "error"), ("skipped", "error"), ("neutral", "error")]:
            with self.subTest(conclusion=conclusion):
                self.assertEqual(self.publish("completed", "completed", conclusion), expected)

    def test_different_commit_is_not_published(self):
        with self.assertRaises(SystemExit):
            self.publish("completed", "completed", "success", head_sha="different-sha")

    def test_read_failure_does_not_forge_a_status(self):
        with self.assertRaises(HTTPError):
            self.publish("requested", "queued", read_error=True)


if __name__ == "__main__":
    unittest.main()
