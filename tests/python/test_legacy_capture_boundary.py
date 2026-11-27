"""LEG-CAP: static documentary boundaries, not runtime gameplay validation."""
import json
from pathlib import Path
import re
import pytest

ROOT = Path(__file__).resolve().parents[2]
LEGACY = (
    "data/veilleurs/v07/recruitment_rules.json",
    "data/world/ngplus_boss_recruits.json",
    "data/capture_wound_rules.json",
)

def references(root):
    hits = []
    for folder in ("scripts", "scenes"):
        for path in (root / folder).rglob("*"):
            if path.is_file() and path.suffix in {".gd", ".tscn", ".tres", ".cs"}:
                for n, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
                    if any(Path(name).name in line for name in LEGACY):
                        hits.append((path.relative_to(root).as_posix(), n))
    return hits

def master():
    return (ROOT / "docs/conception/LITD1_DOCUMENT_MAITRE.md").read_text(encoding="utf-8")

def test_leg_cap_01_no_literal_runtime_legacy_reference():
    assert references(ROOT) == []

@pytest.mark.parametrize("rule,phrase", [
    ("CAP-G03", "ARCH-07"),
    ("CAP-J02", "Aucune saturation"),
    ("CAP-J11", "ne suspend pas"),
    ("CAP-K12", "sans duplication"),
])
def test_leg_cap_02_to_05_normative_anchors(rule, phrase):
    assert any(line.startswith(f"- {rule} :") and phrase in line for line in master().splitlines())

def test_leg_cap_06_guardian_preserved():
    text = (ROOT / "docs/knowledge/guardian-rules.yml").read_text(encoding="utf-8")
    assert "angel-not-capturable" in text
    assert "Le boss Ange n'est jamais capturable." in text

def test_leg_cap_07_scanner_detects_injected_dependency(tmp_path):
    folder = tmp_path / "scripts"
    folder.mkdir()
    (folder / "example.gd").write_text('var p = "res://data/world/ngplus_boss_recruits.json"\n', encoding="utf-8")
    assert references(tmp_path) == [("scripts/example.gd", 1)]

def test_leg_cap_08_precedence():
    assert "Index de lecture consolidé du bloc 12.4" in master()
    assert "appliquer CAP-HUB et CAP-J" in master()
