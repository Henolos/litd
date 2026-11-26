#!/usr/bin/env python3
"""Structural audit for the ARCH-12 scenario specification.

This tool checks document inventory and declared oracle labels only. It does not
execute gameplay scenarios or decide whether prose correctly interprets a rule.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import platform
import re
from collections import Counter
from pathlib import Path
from typing import Any

SCENARIO_ROW = re.compile(r"^\|\s*(S\d{2})\s*\|")
ORACLE_LABEL = re.compile(r"^\s*([OPD])(?:\s|—|-|$)")
EXPECTED_IDS = tuple(f"S{i:02d}" for i in range(1, 71))
# Frozen inventory for this specification revision. Change deliberately with
# the source document and its review; do not silently accept relabeling.
EXPECTED_ORACLE_COUNTS = {"O": 39, "P": 31, "D": 0}


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(65536), b""):
            digest.update(block)
    return digest.hexdigest()


def scenario_rows(markdown: str) -> tuple[list[dict[str, Any]], list[str]]:
    rows: list[dict[str, Any]] = []
    issues: list[str] = []
    for line_number, line in enumerate(markdown.splitlines(), start=1):
        match = SCENARIO_ROW.match(line)
        if not match:
            continue
        cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
        scenario_id = match.group(1)
        if len(cells) != 5:
            issues.append(
                f"{scenario_id} ligne {line_number}: attendu 5 colonnes, obtenu {len(cells)}"
            )
            continue
        label = ORACLE_LABEL.match(cells[4])
        if label is None:
            issues.append(f"{scenario_id} ligne {line_number}: étiquette O/P/D absente")
            oracle = None
        else:
            oracle = label.group(1)
        if any(not cell for cell in cells[1:]):
            issues.append(f"{scenario_id} ligne {line_number}: champ obligatoire vide")
        rows.append({"id": scenario_id, "oracle": oracle, "line": line_number})
    return rows, issues


def traceability_ids(markdown: str) -> tuple[list[str], list[str]]:
    ids: list[str] = []
    issues: list[str] = []
    for line_number, line in enumerate(markdown.splitlines(), start=1):
        match = SCENARIO_ROW.match(line)
        if not match:
            continue
        cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
        if len(cells) < 4:
            issues.append(f"ligne {line_number}: ligne de scénario mal formée dans la matrice")
            continue
        ids.append(match.group(1))
    return ids, issues


def validate_documents(spec: str, traceability: str) -> dict[str, Any]:
    rows, issues = scenario_rows(spec)
    matrix_ids, matrix_issues = traceability_ids(traceability)
    issues.extend(matrix_issues)

    ids = [row["id"] for row in rows]
    counts = Counter(row["oracle"] for row in rows if row["oracle"] is not None)
    if len(ids) != len(set(ids)):
        issues.append("identifiants de scénarios dupliqués")
    if tuple(sorted(ids)) != EXPECTED_IDS:
        missing = sorted(set(EXPECTED_IDS) - set(ids))
        extra = sorted(set(ids) - set(EXPECTED_IDS))
        issues.append(f"inventaire de spécification incorrect: manquants={missing}, inattendus={extra}")
    if len(matrix_ids) != len(set(matrix_ids)):
        issues.append("identifiants de scénarios dupliqués dans la matrice de traçabilité")
    if tuple(sorted(matrix_ids)) != EXPECTED_IDS:
        missing = sorted(set(EXPECTED_IDS) - set(matrix_ids))
        extra = sorted(set(matrix_ids) - set(EXPECTED_IDS))
        issues.append(f"inventaire de traçabilité incorrect: manquants={missing}, inattendus={extra}")
    if ids and set(ids) != set(matrix_ids):
        issues.append("les identifiants de la spécification et de la matrice divergent")
    actual_counts = {label: counts.get(label, 0) for label in ("O", "P", "D")}
    if actual_counts != EXPECTED_ORACLE_COUNTS:
        issues.append(
            f"répartition O/P/D modifiée: attendu={EXPECTED_ORACLE_COUNTS}, obtenu={actual_counts}; "
            "mettre à jour explicitement le référentiel après contrôle"
        )

    return {
        "status": "PASS" if not issues else "FAIL",
        "scope": "inventaire_documentaire_et_etiquettes_oracle_uniquement",
        "scenario_rows": len(rows),
        "traceability_rows": len(matrix_ids),
        "oracle_counts": actual_counts,
        "issues": issues,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[2])
    parser.add_argument("--output", type=Path, help="write the JSON report to this path")
    args = parser.parse_args()

    spec_path = args.root / "docs/qa/ARCH12_FUNCTIONAL_TEST_SPEC_2026-11-26.md"
    trace_path = args.root / "docs/qa/ARCH12_TRACEABILITY_AND_SCENARIOS_2026-11-26.md"
    missing = [str(path) for path in (spec_path, trace_path) if not path.is_file()]
    if missing:
        result = {"status": "FAIL", "scope": "input_presence", "issues": [f"fichier absent: {p}" for p in missing]}
    else:
        result = validate_documents(
            spec_path.read_text(encoding="utf-8"),
            trace_path.read_text(encoding="utf-8"),
        )
        result["inputs"] = {
            str(path.relative_to(args.root)): sha256(path)
            for path in (spec_path, trace_path)
        }
        result["python"] = platform.python_version()

    rendered = json.dumps(result, ensure_ascii=False, indent=2) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(rendered, encoding="utf-8")
    print(rendered, end="")
    return 0 if result["status"] == "PASS" else 1


if __name__ == "__main__":
    raise SystemExit(main())
