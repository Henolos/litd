"""Check that a PR declares its evidence status; never mistake declarations for proof."""
import argparse
import json
import re
from pathlib import Path

REQUIRED = (
    "## Changement et question",
    "## Preuves et recherche",
    "## Vérifications réellement exécutées",
    "## Scénarios d'échec et risques résiduels",
    "## Conclusion",
)
PLACEHOLDERS = {"", "todo", "tbd", "à compléter", "n/a"}


def validate(body: str) -> list[str]:
    errors = []
    for title in REQUIRED:
        match = re.search(r"^" + re.escape(title) + r".*$", body, re.MULTILINE)
        if not match:
            errors.append(f"Section manquante : {title}")
            continue
        start = match.end()
        next_heading = re.search(r"^## ", body[start:], re.MULTILINE)
        section = body[start:start + next_heading.start()] if next_heading else body[start:]
        cleaned = re.sub(r"(?m)^\s*[-*]\s*(?:\[[ xX]\])?\s*[^:\n]+:\s*$", "", section).strip()
        if cleaned.lower() in PLACEHOLDERS:
            errors.append(f"Section vide : {title}")
    if not re.search(r"(?im)^\s*(?:[-*]\s*)?Statut\s*:\s*(VALIDÉ|PARTIEL|BLOQUÉ)\b", body):
        errors.append("Statut explicite requis : VALIDÉ, PARTIEL ou BLOQUÉ")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--event", type=Path, required=True)
    args = parser.parse_args()
    event = json.loads(args.event.read_text(encoding="utf-8"))
    body = (event.get("pull_request") or {}).get("body") or ""
    errors = validate(body)
    for error in errors:
        print(f"::error::{error}")
    print("Contrôle déclaratif uniquement : les preuves et les tests nécessitent une revue.")
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
