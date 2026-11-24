import os
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
with tempfile.TemporaryDirectory() as directory:
    root = Path(directory)
    lock = root / "campaign.lock"
    def rejected(path):
        result = subprocess.run([exe, str(path), "probe"], capture_output=True, timeout=15)
        assert result.returncode == 23, result
    lock.mkdir()
    rejected(lock)
    lock.rmdir()
    target = root / "target"
    target.write_bytes(b"preserve original")
    os.link(target, lock)
    rejected(lock)
    assert target.read_bytes() == b"preserve original"
    lock.unlink()
    try:
        lock.symlink_to(target)
    except OSError as exc:
        if os.name != "nt" or getattr(exc, "winerror", None) != 1314:
            raise
        print("NATIVE_LOCK_SYMLINK_SKIPPED_WINDOWS_PRIVILEGE")
    else:
        rejected(lock)
        assert lock.is_symlink() and target.read_bytes() == b"preserve original"
        lock.unlink()
        print("NATIVE_LOCK_SYMLINK_PASS")
    if os.name != "nt":
        os.mkfifo(lock)
        rejected(lock)
        lock.unlink()
        print("NATIVE_LOCK_FIFO_PASS")
    result = subprocess.run([exe, str(lock), "probe"], capture_output=True, timeout=15)
    assert result.returncode == 0 and result.stdout.strip() == b"ACQUIRED", result
    print("NATIVE_LOCK_FILE_PROTECTIONS_PASS")
print("NATIVE_SAVE_LOCK_PASS")
