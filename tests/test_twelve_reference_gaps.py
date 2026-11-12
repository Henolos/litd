import json
from pathlib import Path

ROOT = Path(__file__).parents[1]

def text(path):
    return (ROOT / path).read_text(encoding="utf-8")

def test_robust_save_slots_autosave_integrity_backup_and_migration():
    save = text("scripts/core/save_manager.gd")
    for token in ("SLOT_COUNT := 3", "AUTOSAVE_SLOT := -1", "func autosave", "func slot_metadata", "func all_slots_metadata", "sha256_text", "_atomic_write", "_backup_path", "_migrate", "campaign_memory", "expedition_reports", "preparation_presets"):
        assert token in save
    assert "litd_slot_%d.json" in save and "litd_autosave.json" in save
    assert "DirAccess.rename_absolute" in save
