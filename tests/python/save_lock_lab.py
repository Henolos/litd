"""Laboratory only: native exclusive lock, never unlink the lock file."""
import os
from contextlib import contextmanager
from pathlib import Path

@contextmanager
def campaign_lock(path: Path):
    # All cooperating processes must use the same stable path/inode.
    with open(path, "a+b") as handle:
        handle.seek(0)
        if os.name == "nt":
            import msvcrt
            # Windows byte-range locks may extend beyond EOF.
            msvcrt.locking(handle.fileno(), msvcrt.LK_NBLCK, 1)
        else:
            import fcntl
            fcntl.flock(handle.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)
        try:
            yield
        finally:
            handle.seek(0)
            if os.name == "nt":
                msvcrt.locking(handle.fileno(), msvcrt.LK_UNLCK, 1)
            else:
                fcntl.flock(handle.fileno(), fcntl.LOCK_UN)
