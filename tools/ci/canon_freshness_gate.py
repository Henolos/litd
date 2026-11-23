#!/usr/bin/env python3
"""Fail CI when hero source data reintroduces an unapproved starting roster.

This gate is intentionally dependency-free so it can run before any game export.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
HEROES_FILE = ROOT / "data" / "heroes.json"
ROSTER_FILE = ROOT / "data" / "veilleurs" / "canonical_roster.json"

# Former starting-quartet identities. They may remain in historical documentation,
# but must not be referenced by runtime-facing game data or scripts.
LEGACY_TOKENS = (
    "nayra",
    "tarek",
    "aïsha",
    "aisha",
    "idris",
)

RUNTIME_ROOTS = (
    ROOT / "data",
    ROOT / "scenes",
    ROOT / "scripts",
)
TEXT_EXTENSIONS = {
    ".json",
    ".gd",
    ".tscn",
    ".tres",
    ".cfg",
    ".ini",
    ".txt",
    ".csv",
    ".yaml",
    ".yml",
}


def fail(message: str) -> None:
    print(f"CANON_FRESHNESS_ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)


def load_heroes() -> list[dict]:
    if not HEROES_FILE.is_file():
        fail(f"missing canonical hero source: {HEROES_FILE.relative_to(ROOT)}")
    try:
        payload = json.loads(HEROES_FILE.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        fail(f"cannot read canonical hero source: {exc}")
    if not isinstance(payload, list):
        fail("data/heroes.json must contain a JSON list")
    return payload


def validate_heroes(heroes: list[dict]) -> None:
    designated_starters = [
        hero for hero in heroes
        if isinstance(hero, dict)
        and (hero.get("canon_status") == "canonical_starting_hero" or "starting_quartet_order" in hero)
    ]
    if designated_starters:
        fail("data/heroes.json still designates a starting quartet; the current roster is unassigned")
    ids = [str(hero.get("id", "")).lower() for hero in heroes if isinstance(hero, dict)]
    duplicate_ids = sorted({hero_id for hero_id in ids if hero_id and ids.count(hero_id) > 1})
    if duplicate_ids:
        fail(f"duplicate hero ids in data/heroes.json: {duplicate_ids}")


def validate_unassigned_roster() -> None:
    try:
        roster = json.loads(ROSTER_FILE.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        fail(f"cannot read canonical roster decision: {exc}")
    if (
        roster.get("status") != "starting_roster_unassigned"
        or roster.get("rules", {}).get("starting_quartet_assigned") is not False
        or roster.get("heroes") != []
    ):
        fail("the retired starting quartet must remain unassigned until a new roster is explicitly approved")


def iter_runtime_text_files():
    for root in RUNTIME_ROOTS:
        if not root.exists():
            continue
        for path in root.rglob("*"):
            if path.is_file() and path.suffix.lower() in TEXT_EXTENSIONS:
                yield path


def reject_legacy_runtime_references() -> None:
    violations: list[str] = []
    for path in iter_runtime_text_files():
        # The canonical source is checked structurally above; keep legacy detection
        # focused on other runtime-facing references.
        if path == HEROES_FILE:
            continue
        try:
            text = path.read_text(encoding="utf-8").lower()
        except UnicodeDecodeError:
            continue
        matches = sorted(token for token in LEGACY_TOKENS if token in text)
        if matches:
            rel = path.relative_to(ROOT)
            violations.append(f"{rel}: {', '.join(matches)}")

    if violations:
        fail(
            "legacy starting-hero references found in runtime-facing files:\n  - "
            + "\n  - ".join(violations)
        )


def main() -> None:
    heroes = load_heroes()
    validate_heroes(heroes)
    validate_unassigned_roster()
    reject_legacy_runtime_references()
    print(
        "CANON_FRESHNESS_OK: no starting roster is designated and no legacy quartet references were found in runtime-facing text files."
    )


if __name__ == "__main__":
    main()
