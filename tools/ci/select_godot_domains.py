#!/usr/bin/env python3
"""Select the smallest safe Godot CI domain set for a pull request.

The selector is deliberately fail-closed: any unknown or globally sensitive path
returns every domain. Merge-group and manual validations should use --all.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

ALL_DOMAINS = ("core-world", "audiovisual", "runtime", "veilleurs", "ui-qa")
_ORDER = {name: index for index, name in enumerate(ALL_DOMAINS)}


def _tests_for(path: str) -> set[str] | None:
    low = path.lower()
    selected: set[str] = set()

    if any(token in low for token in (
        "audio", "music", "sfx", "voice", "dialogue", "narrative",
        "cinematic", "animation", "body_visual", "canonical_art", "movement",
    )):
        selected.add("audiovisual")
    if any(token in low for token in (
        "veilleurs", "affliction", "enemy_", "combat_", "first_accord",
        "dungeon_", "hybrid_", "hemocorde", "anatomie", "entaille",
    )):
        selected.add("veilleurs")
    if any(token in low for token in (
        "ui_", "hud_", "mobile_", "qa_validation", "canonical_ui", "canonical_ux",
    )):
        selected.update(("runtime", "ui-qa"))
    if any(token in low for token in (
        "campaign_", "runtime_", "physical_", "first_descent", "ash_guidance",
        "visual_vertical_slice", "visual_slice_runtime",
    )):
        selected.add("runtime")
    if any(token in low for token in (
        "psychology", "relationship", "decision_memory", "field_memory",
        "field_encounter", "community_network", "systemic_cross",
        "legendary_seven", "descendants_hall", "sanctuary_buildings", "core_smoke",
    )):
        selected.add("core-world")

    return selected or None


def domains_for_path(raw_path: str) -> set[str] | None:
    path = raw_path.strip().replace("\\", "/")
    low = path.lower()
    if not path:
        return set()

    if (
        low == "project.godot"
        or low.startswith("addons/")
        or low == "tools/build/run_godot_ci_domain.sh"
        or low == ".github/workflows/ci-godot-domains.yml"
        or low == "tools/ci/select_godot_domains.py"
    ):
        return set(ALL_DOMAINS)

    if low.startswith(("scripts/tests/", "scenes/tests/")):
        return _tests_for(low)

    if low.startswith("scripts/ui/"):
        return {"runtime", "veilleurs", "ui-qa"}

    if low.startswith("scripts/world/"):
        return {"core-world", "runtime", "veilleurs"}

    if low.startswith("scripts/qa/"):
        return {"veilleurs", "ui-qa"}

    if low.startswith("scripts/core/"):
        if any(token in low for token in (
            "audio", "music", "voice", "dialogue", "narrative", "cinematic",
            "animation", "movement", "body_state", "visual",
        )):
            return {"audiovisual", "runtime"}
        if any(token in low for token in (
            "combat", "enemy", "affliction", "target", "position", "veilleurs",
            "dungeon", "roguelike", "expedition", "remanence", "capture",
        )):
            return {"core-world", "runtime", "veilleurs"}
        return set(ALL_DOMAINS)

    if low.startswith("data/veilleurs/"):
        return {"runtime", "veilleurs"}

    if low.startswith("data/"):
        if any(token in low for token in (
            "audio", "music", "sfx", "voice", "dialogue", "narrative",
            "cinematic", "animation", "art",
        )):
            return {"audiovisual"}
        if any(token in low for token in (
            "skill", "enemy", "combat", "dungeon", "expedition", "roguelike",
        )):
            return {"core-world", "runtime", "veilleurs"}
        return {"core-world", "runtime"}

    if low.startswith("scenes/veilleurs/"):
        return {"runtime", "veilleurs", "ui-qa"}

    if low.startswith(("scenes/ui/", "scenes/hud/")):
        return {"runtime", "ui-qa"}

    if low.startswith("assets/"):
        if any(token in low for token in (
            "audio", "music", "sfx", "voice", "animation", "cinematic", "art",
        )):
            return {"audiovisual", "runtime"}
        return {"audiovisual", "runtime", "ui-qa"}

    # Any monitored path we do not understand must get full coverage.
    return None


def select_domains(files: list[str]) -> list[str]:
    if not files:
        return list(ALL_DOMAINS)

    selected: set[str] = set()
    for path in files:
        domains = domains_for_path(path)
        if domains is None:
            return list(ALL_DOMAINS)
        selected.update(domains)
        if len(selected) == len(ALL_DOMAINS):
            return list(ALL_DOMAINS)

    return sorted(selected, key=_ORDER.__getitem__) or list(ALL_DOMAINS)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--all", action="store_true", help="Select every domain.")
    parser.add_argument("--files-from", type=Path, help="Newline-delimited changed files.")
    parser.add_argument(
        "--github-output",
        type=Path,
        help="Append GitHub Actions outputs instead of only printing JSON.",
    )
    args = parser.parse_args()

    if args.all:
        files: list[str] = []
        domains = list(ALL_DOMAINS)
        mode = "full"
    else:
        if args.files_from is None:
            parser.error("--files-from is required unless --all is used")
        files = [
            line.strip()
            for line in args.files_from.read_text(encoding="utf-8").splitlines()
            if line.strip()
        ]
        domains = select_domains(files)
        mode = "impact"

    payload = json.dumps(domains, separators=(",", ":"))
    if args.github_output:
        with args.github_output.open("a", encoding="utf-8") as handle:
            handle.write(f"domains={payload}\n")
            handle.write(f"mode={mode}\n")
            handle.write(f"changed_count={len(files)}\n")
    print(payload)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
