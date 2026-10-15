"""Static regression checks for high-risk save/load contracts before playtesting.

These tests intentionally document existing risky behavior; they will fail until
the save manager is hardened. No user save data is accessed.
"""
from pathlib import Path
import re

SOURCE = Path(__file__).resolve().parents[1] / "scripts/core/save_manager.gd"
TEXT = SOURCE.read_text(encoding="utf-8")


def section(name: str, following: str) -> str:
    start = TEXT.index(f"func {name}(")
    end = TEXT.index(f"func {following}(", start)
    return TEXT[start:end]


def test_slot_zero_prefers_its_own_canonical_file():
    body = section("load_game", "slot_metadata")
    assert not re.search(r"_read_payload\(SAVE_PATH\) if slot == 0", body), (
        "Slot zero loads the legacy global save before its canonical slot file."
    )


def test_save_migration_does_not_silently_assume_current_version():
    body = section("_migrate", "_atomic_write")
    assert 'payload.get("version", "0.31")' not in body, (
        "Missing version is treated as the current version; require explicit "
        "legacy schema handling."
    )


def test_backup_copy_and_remove_results_are_checked():
    body = section("_atomic_write", "_read_payload")
    assert re.search(r"if\s+DirAccess\.copy_absolute\(", body) or re.search(
        r"var\s+\w+\s*:?=\s*DirAccess\.copy_absolute\(", body
    ), "Backup copy return value is ignored."
    assert re.search(r"if\s+DirAccess\.remove_absolute\(", body) or re.search(
        r"var\s+\w+\s*:?=\s*DirAccess\.remove_absolute\(", body
    ), "Removal return value is ignored."


def test_failed_slot_zero_legacy_write_is_not_reported_as_full_success():
    body = section("save_game", "save_qa_snapshot")
    assert 'success = _atomic_write(SAVE_PATH, body)' not in body, (
        "A successful canonical slot write is reported as failed when the "
        "secondary legacy mirror fails; test and define the desired contract."
    )
