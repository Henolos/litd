import json
import re
import subprocess
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).parents[1]
CONTRACT_PATH = ROOT / "data/veilleurs/legacy/vs001_dependency_contract.json"
BASELINE_PATH = ROOT / "data/veilleurs/legacy/vs001_reference_baseline.json"


def _contract() -> dict:
    return json.loads(CONTRACT_PATH.read_text(encoding="utf-8"))


def _tracked_files() -> list[str]:
    result = subprocess.run(
        ["git", "ls-files"],
        cwd=ROOT,
        check=True,
        capture_output=True,
        text=True,
    )
    return [line.strip() for line in result.stdout.splitlines() if line.strip()]


def _code_without_comments(text: str) -> str:
    # Keep quoted strings (including resource paths), remove line comments.
    return re.sub(
        r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|#[^\n]*|(?m:^[ \t]*;[^\n]*)',
        lambda match: "" if match.group().lstrip().startswith(("#", ";")) else match.group(),
        text,
    )


def _vs001_lines(text: str) -> list[str]:
    return [line.strip() for line in _code_without_comments(text).splitlines() if "vs001" in line.lower()]


def _operational_vs001_references() -> dict[str, list[str]]:
    suffixes = {".gd", ".tscn", ".tres", ".json", ".py", ".yml", ".yaml", ".godot", ".cfg", ".sh", ".ps1", ".cmd"}
    hits: dict[str, list[str]] = {}
    for relative in _tracked_files():
        path = ROOT / relative
        if path.suffix.lower() not in suffixes or not path.is_file():
            continue
        references = _vs001_lines(path.read_text(encoding="utf-8", errors="ignore"))
        if references:
            hits[relative] = references
    return hits


def _new_references(current: dict[str, list[str]], baseline: dict[str, list[str]]) -> dict[str, list[str]]:
    return {
        path: list(extra.elements())
        for path, lines in current.items()
        if (extra := Counter(lines) - Counter(baseline.get(path, [])))
    }


def _inside_legacy_namespace(path: str, prefixes: list[str]) -> bool:
    return any(path.startswith(prefix) for prefix in prefixes)






def test_boundary_distinguishes_comment_from_executable_reference():
    assert _vs001_lines('## No VS001 dependency.\nvar active = true # VS001 comment') == []
    assert _vs001_lines('preload("res://scripts/core/veilleurs_vs001_runtime.gd") # compatibility') == [
        'preload("res://scripts/core/veilleurs_vs001_runtime.gd")'
    ]


def test_boundary_rejects_new_file_and_new_reference_in_existing_file():
    baseline = {"scripts/ui/existing.gd": ["LegacyVS001.first()"]}
    assert _new_references({"scripts/ui/new.gd": ["LegacyVS001.first()"]}, baseline)
    assert _new_references({"scripts/ui/existing.gd": ["LegacyVS001.second()"]}, baseline)
    assert _new_references({"scripts/ui/existing.gd": ["LegacyVS001.first()"] * 2}, baseline)
    assert _new_references({}, baseline) == {}


def test_migration_has_explicit_removal_gates():
    contract = _contract()
    assert contract["status"] == "contained_active_compatibility"
    assert len(contract["migration_order"]) >= 5
    assert "zero VS001 autoloads in project.godot" in contract["removal_gates"]
    assert "old veilleurs_vs001 saves still load through explicit migration" in contract["removal_gates"]
