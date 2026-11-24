"""Run against an imported isolated project and a Godot console executable."""
import os
import queue
import subprocess
import sys
import tempfile
import threading
from pathlib import Path

def main():
    exe = str(Path(sys.argv[1]).resolve())
    project = Path(__file__).resolve().parent / "project"
    with tempfile.TemporaryDirectory(prefix="litd-godot-lock-") as tmp:
        root = Path(tmp)
        env = dict(os.environ, APPDATA=tmp, LOCALAPPDATA=tmp, XDG_DATA_HOME=tmp)
        base = [exe, "--headless", "--path", str(project)]
        subprocess.run(base + ["--import", "--quit"], env=env, check=True, timeout=120)
        def command(mode):
            return base + ["--script", "res://probe.gd", "--", str(root / "campaign.lock"), mode]
        for forced in (False, True):
            owner = subprocess.Popen(command("hold"), env=env, stdout=subprocess.PIPE,
                                     stderr=subprocess.STDOUT, text=True)
            lines = queue.Queue()
            def reader():
                for line in owner.stdout:
                    lines.put(line)
                lines.put(None)
            threading.Thread(target=reader, daemon=True).start()
            try:
                while True:
                    line = lines.get(timeout=30)
                    if line is None:
                        raise RuntimeError("Owner exited before acquiring lock")
                    print(line, end="")
                    if line.strip() == "GODOT_LOCK_ACQUIRED":
                        break
                probe = subprocess.run(command("probe"), env=env, capture_output=True,
                                       text=True, timeout=30)
                assert probe.returncode == 23, (probe.returncode, probe.stdout, probe.stderr)
                if forced:
                    owner.kill()
                else:
                    # Graceful owner exit is requested via a sentinel in the isolated directory.
                    (root / "release.request").touch()
                owner.wait(timeout=30)
                if not forced:
                    assert owner.returncode == 0, owner.returncode
                (root / "release.request").unlink(missing_ok=True)
                probe = subprocess.run(command("probe"), env=env, capture_output=True,
                                       text=True, timeout=30)
                assert probe.returncode == 0 and "GODOT_LOCK_ACQUIRED" in probe.stdout, probe
            finally:
                if owner.poll() is None:
                    owner.kill()
                owner.wait(timeout=10)
        print("GODOT_INTERPROCESS_LOCK_PASS")

if __name__ == "__main__":
    main()
