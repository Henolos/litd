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

# Regression gate: namespace replacement must not allow a second owner.
for scenario in ("unlink", "rename_parent"):
    with tempfile.TemporaryDirectory() as directory:
        root = Path(directory)
        parent = root / "active"
        parent.mkdir()
        lock = parent / "campaign.lock"
        owner = subprocess.Popen([exe, str(lock), "hold"], stdin=subprocess.PIPE,
                                 stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        try:
            with ThreadPoolExecutor(max_workers=1) as pool:
                future = pool.submit(owner.stdout.readline)
                try:
                    assert future.result(timeout=15).strip() == "ACQUIRED"
                except BaseException:
                    owner.kill()
                    raise
            assert owner.poll() is None
            try:
                if scenario == "unlink":
                    lock.unlink()
                else:
                    parent.rename(root / "displaced")
                    parent.mkdir()
            except PermissionError:
                print(f"NATIVE_NAMESPACE_{scenario.upper()}_OS_DENIED", flush=True)
            else:
                probe = subprocess.run([exe, str(lock), "probe"], capture_output=True, timeout=15)
                assert owner.poll() is None
                assert probe.returncode in (0, 23), probe
                if probe.returncode == 0:
                    assert probe.stdout.strip() == b"ACQUIRED", probe
                    raise AssertionError(f"NATIVE_NAMESPACE_{scenario.upper()}_DOUBLE_ACQUIRE")
                else:
                    print(f"NATIVE_NAMESPACE_{scenario.upper()}_SECOND_DENIED", flush=True)
        finally:
            if owner.poll() is None:
                owner.kill()
            owner.communicate(timeout=15)
        probe = subprocess.run([exe, str(lock), "probe"], capture_output=True, timeout=15)
        assert probe.returncode == 0 and probe.stdout.strip() == b"ACQUIRED", probe
        print(f"NATIVE_NAMESPACE_{scenario.upper()}_RECOVERY_PASS", flush=True)

# Residual-risk diagnostics: no production data or transaction engine involved.
if os.name != "nt":
    with tempfile.TemporaryDirectory() as directory:
        root = Path(directory)
        parent = root / "active"
        parent.mkdir()
        lock = parent / "campaign.lock"
        alias = root / "alias"
        alias.symlink_to(parent, target_is_directory=True)
        owner = subprocess.Popen([exe, str(lock), "hold"], stdin=subprocess.PIPE,
                                 stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        try:
            with ThreadPoolExecutor(max_workers=1) as pool:
                future = pool.submit(owner.stdout.readline)
                try:
                    assert future.result(timeout=15).strip() == "ACQUIRED"
                except BaseException:
                    owner.kill()
                    raise
            for phase in ("same_inode", "recreated_inode"):
                if phase == "recreated_inode":
                    lock.unlink()
                probe = subprocess.run([exe, str(alias / "campaign.lock"), "probe"],
                                       capture_output=True, timeout=15)
                assert owner.poll() is None
                assert probe.returncode in (0, 23), probe
                marker = "DOUBLE_ACQUIRE" if probe.returncode == 0 else "SECOND_DENIED"
                print(f"NATIVE_ALIAS_{phase.upper()}_{marker}", flush=True)
            # Model a path-based publication after parent replacement.
            # This is a filesystem experiment, not a SaveManager runtime test.
            original = parent / "slot.json"
            original.write_bytes(b"original")
            staged = parent / "slot.tmp"
            staged.write_bytes(b"staged")
            displaced = root / "displaced"
            parent.rename(displaced)
            parent.mkdir()
            (parent / "slot.json").write_bytes(b"replacement")
            (parent / "slot.tmp").write_bytes(b"foreign")
            os.replace(parent / "slot.tmp", parent / "slot.json")
            assert (displaced / "slot.json").read_bytes() == b"original"
            assert (displaced / "slot.tmp").read_bytes() == b"staged"
            assert (parent / "slot.json").read_bytes() == b"foreign"
            print("NATIVE_PATH_PUBLICATION_REDIRECT_REPRODUCED", flush=True)
        finally:
            if owner.poll() is None:
                owner.kill()
            owner.communicate(timeout=15)

print("NATIVE_SAVE_LOCK_PASS")
