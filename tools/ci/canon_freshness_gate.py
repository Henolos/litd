#!/usr/bin/env python3
"""Fail CI when runtime-facing LITD data drifts from the canonical starting quartet.

This gate is intentionally dependency-free so it can run before any game export.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
HEROES_FILE = ROOT / "data" / "heroes.json"

EXPECTED_QUARTET = [
    (1, "mathilde", "Mathilde"),
    (2, "marec", "Marec"),
    (3, "anouk", "Anouk"),
    (4, "aurelien", "Aurélien"),
]

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


def validate_quartet(heroes: list[dict]) -> None:
    canonical = [
        hero
        for hero in heroes
        if isinstance(hero, dict)
        and hero.get("canon_status") == "canonical_starting_hero"
    ]
    if len(canonical) != 4:
        fail(
            "expected exactly 4 canonical_starting_hero entries, "
            f"found {len(canonical)}"
        )

    try:
        canonical.sort(key=lambda hero: int(hero["starting_quartet_order"]))
    except (KeyError, TypeError, ValueError) as exc:
        fail(f"invalid starting_quartet_order in canonical heroes: {exc}")

    actual = [
        (
            int(hero.get("starting_quartet_order")),
            str(hero.get("canonical_id", hero.get("id", ""))).lower(),
            str(hero.get("name", "")),
        )
        for hero in canonical
    ]

    if actual != EXPECTED_QUARTET:
        fail(
            "starting quartet drifted from canon. "
            f"expected={EXPECTED_QUARTET!r} actual={actual!r}"
        )

    ids = [str(hero.get("id", "")).lower() for hero in heroes if isinstance(hero, dict)]
    duplicate_ids = sorted({hero_id for hero_id in ids if hero_id and ids.count(hero_id) > 1})
    if duplicate_ids:
        fail(f"duplicate hero ids in data/heroes.json: {duplicate_ids}")


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
    validate_quartet(heroes)
    reject_legacy_runtime_references()
    print(
        "CANON_FRESHNESS_OK: starting quartet is Mathilde, Marec, Anouk, Aurélien "
        "and no legacy quartet references were found in runtime-facing text files."
    )


if __name__ == "__main__":
    main()
