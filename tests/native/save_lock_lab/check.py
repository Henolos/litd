import subprocess
import sys
import tempfile
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor

exe = str(Path(sys.argv[1]).resolve())
with tempfile.TemporaryDirectory() as directory:
    path = str(Path(directory) / "campaign.lock")
    for forced in (False, True):
        owner = subprocess.Popen([exe, path, "hold"], stdin=subprocess.PIPE,
                                 stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        try:
            with ThreadPoolExecutor(max_workers=1) as pool:
                future = pool.submit(owner.stdout.readline)
                try:
                    assert future.result(timeout=15).strip() == "ACQUIRED"
                except BaseException:
                    owner.kill()
                    raise
            probe = subprocess.run([exe, path, "probe"], capture_output=True, timeout=15)
            assert probe.returncode == 23, probe
            if forced:
                owner.kill()
            owner.communicate(timeout=15)
            if not forced:
                assert owner.returncode == 0
            assert Path(path).exists()
            probe = subprocess.run([exe, path, "probe"], capture_output=True, timeout=15)
            assert probe.returncode == 0 and probe.stdout.strip() == b"ACQUIRED", probe
        finally:
            if owner.poll() is None:
                owner.kill()
                owner.communicate(timeout=15)
print("NATIVE_SAVE_LOCK_PASS")
