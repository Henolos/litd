import subprocess
import sys
from pathlib import Path

import pytest

LAB = Path(__file__).with_name("save_lock_lab.py")
CODE = """
import runpy, sys
from pathlib import Path
lock = runpy.run_path(sys.argv[1])['campaign_lock']
try:
    with lock(Path(sys.argv[2])):
        print('ACQUIRED', flush=True)
        if sys.argv[3] == 'hold':
            sys.stdin.read()
except OSError:
    sys.exit(23)
"""

def launch(path, mode):
    return subprocess.Popen(
        [sys.executable, "-c", CODE, str(LAB), str(path), mode],
        stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        text=True,
    )

@pytest.mark.parametrize("forced", [False, True])
def test_native_lock_contention_and_release(tmp_path, forced):
    path = tmp_path / "campaign.lock"
    owner = launch(path, "hold")
    try:
        # A separate probe cannot acquire while the owner is alive.
        # Bound the readiness wait via a thread, including on Windows.
        from concurrent.futures import ThreadPoolExecutor
        with ThreadPoolExecutor(max_workers=1) as pool:
            future = pool.submit(owner.stdout.readline)
            try:
                assert future.result(timeout=15).strip() == "ACQUIRED"
            except BaseException:
                owner.kill()
                raise
        contender = launch(path, "probe")
        out, err = contender.communicate(timeout=15)
        assert contender.returncode == 23, (out, err)
        if forced:
            owner.kill()
        owner.communicate(timeout=15)
        if not forced:
            assert owner.returncode == 0
        assert path.exists()
        successor = launch(path, "probe")
        out, err = successor.communicate(timeout=15)
        assert successor.returncode == 0, err
        assert out.strip() == "ACQUIRED"
    finally:
        if owner.poll() is None:
            owner.kill()
            owner.communicate(timeout=15)
