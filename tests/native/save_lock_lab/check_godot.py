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
        root = Path(tmp).resolve()
        env = dict(os.environ, APPDATA=tmp, LOCALAPPDATA=tmp, XDG_DATA_HOME=tmp)
        base = [exe, "--headless", "--path", str(project)]
        # Establish whether the editor crashes even without the extension.
        import shutil
        baseline = root / "baseline"
        baseline.mkdir()
        shutil.copyfile(project / "project.godot", baseline / "project.godot")
        print("GODOT_BASELINE_IMPORT_START", flush=True)
        subprocess.run([exe, "--headless", "--path", str(baseline), "--import", "--quit"],
                       env=env, check=True, timeout=120)
        print("GODOT_BASELINE_IMPORT_PASS", flush=True)
        # Use a separate project/cache so the init-only case cannot mask full import.
        minimal = root / "init_only"
        shutil.copytree(project, minimal, ignore=shutil.ignore_patterns(".godot"))
        minimal_env = dict(env, LITD_LOCK_INIT_ONLY="1")
        print("GODOT_INIT_ONLY_IMPORT_START", flush=True)
        diagnostic = subprocess.run([exe, "--headless", "--path", str(minimal),
                                     "--import", "--quit", "--verbose"],
                                    env=minimal_env, timeout=120)
        print(f"GODOT_INIT_ONLY_IMPORT_EXIT={diagnostic.returncode}", flush=True)
        empty_class = root / "empty_class"
        shutil.copytree(project, empty_class, ignore=shutil.ignore_patterns(".godot"))
        empty_env = dict(env, LITD_LOCK_EMPTY_CLASS="1")
        print("GODOT_EMPTY_CLASS_IMPORT_START", flush=True)
        diagnostic = subprocess.run([exe, "--headless", "--path", str(empty_class),
                                     "--import", "--quit", "--verbose"],
                                    env=empty_env, timeout=120)
        print(f"GODOT_EMPTY_CLASS_IMPORT_EXIT={diagnostic.returncode}", flush=True)
        class_only = root / "class_only"
        shutil.copytree(project, class_only, ignore=shutil.ignore_patterns(".godot"))
        class_env = dict(env, LITD_LOCK_CLASS_ONLY="1")
        print("GODOT_CLASS_ONLY_IMPORT_START", flush=True)
        diagnostic = subprocess.run([exe, "--headless", "--path", str(class_only),
                                     "--import", "--quit", "--verbose"],
                                    env=class_env, timeout=120)
        print(f"GODOT_CLASS_ONLY_IMPORT_EXIT={diagnostic.returncode}", flush=True)
        # Always run the full case, even if the minimal case fails.
        print("GODOT_EXTENSION_IMPORT_START", flush=True)
        # Godot upstream #111048: cold headless import may race documentation shutdown.
        # Keep the immediate-exit diagnostic cases above; delay only the full import.
        print("GODOT_DELAYED_IMPORT_START", flush=True)
        subprocess.run(base + ["--import", "--quit", "--frame-delay", "1000", "--verbose"],
                       env=env, check=True, timeout=180)
        print("GODOT_DELAYED_IMPORT_PASS", flush=True)
        print("GODOT_EXTENSION_IMPORT_PASS", flush=True)
        def command(mode):
            return base + ["--script", "res://probe.gd", "--", str(root / "campaign.lock"), mode]
        def reject_path(path):
            result = subprocess.run(base + ["--script", "res://probe.gd", "--", str(path), "probe"],
                                    env=env, capture_output=True, text=True, timeout=30)
            assert result.returncode == 23, result
        child = root / "child"
        child.mkdir()
        reject_path(str(child) + "/../campaign.lock")
        reject_path(root / "missing" / "campaign.lock")
        alias = root / "alias"
        try:
            alias.symlink_to(child, target_is_directory=True)
        except OSError as exc:
            if os.name != "nt" or getattr(exc, "winerror", None) != 1314:
                raise
            print("GODOT_PARENT_SYMLINK_SKIPPED_WINDOWS_PRIVILEGE")
        else:
            reject_path(alias / "campaign.lock")
            assert not (child / "campaign.lock").exists()
            print("GODOT_PARENT_SYMLINK_PASS")
        print("GODOT_PARENT_PREFLIGHT_PASS")
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
