"""Static regression checks for high-risk save/load contracts before playtesting.

These tests protect save-manager contracts. No user save data is accessed.
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
    assert "DirAccess.remove_absolute(absolute_path)" not in body, (
        "Do not remove the live save before replacement."
    )


def test_failed_slot_zero_legacy_write_is_not_reported_as_full_success():
    body = section("save_game", "save_qa_snapshot")
    assert 'success = _atomic_write(SAVE_PATH, body)' not in body, (
        "A successful canonical slot write is reported as failed when the "
        "secondary legacy mirror fails; test and define the desired contract."
    )


def test_staged_save_is_validated_before_replacement():
    body = section("_atomic_write", "_read_payload")
    assert "_read_payload(temp).is_empty()" in body
    assert "FileAccess.get_file_as_string(temp) != text" in body


def test_invalid_primary_does_not_overwrite_good_backup():
    body = section("_atomic_write", "_read_payload")
    assert "and not _read_payload(path).is_empty()" in body


def test_load_checks_backup_before_legacy_mirror():
    body = section("load_game", "slot_metadata")
    assert "candidates: Array[String] = [_path(slot), _backup_path(slot)]" in body
    assert "candidates.append(SAVE_PATH)" in body
    assert "var migrated := _migrate(candidate_payload)" in body


def test_save_backup_is_not_deleted_before_replacement():
    body = section("_atomic_write", "_read_payload")
    assert "DirAccess.remove_absolute(absolute_path)" not in body
    assert "DirAccess.rename_absolute(absolute_temp, absolute_path)" in body
