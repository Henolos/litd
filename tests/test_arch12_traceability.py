from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "docs" / "qa"))

import validate_arch12_traceability as checker


TRACE = (ROOT / "docs/qa/ARCH12_TRACEABILITY_AND_SCENARIOS_2026-11-26.md").read_text(encoding="utf-8")
MASTER = (ROOT / "docs/conception/LITD1_DOCUMENT_MAITRE.md").read_text(encoding="utf-8")


def test_current_arch12_matrix_is_consistent():
    assert checker.validate_texts(TRACE, MASTER) == []


def test_missing_rule_row_is_rejected():
    mutated = "\n".join(line for line in TRACE.splitlines() if not line.startswith("| ARCH-12.5 20 |"))
    errors = checker.validate_texts(mutated, MASTER)
    assert any("ARCH-12.5" in error and "attendu 20 lignes" in error for error in errors)


def test_dangling_rule_reference_is_rejected():
    mutated = TRACE.replace("ARCH-12.4 R1/R3/R5/R8–10", "ARCH-12.4 R1/R3/R5/R8–99", 1)
    errors = checker.validate_texts(mutated, MASTER)
    assert any("R99" in error for error in errors)


def test_missing_section_locator_is_rejected():
    mutated = TRACE.replace("§ Statistiques et progression", "§ Section inexistante", 1)
    errors = checker.validate_texts(mutated, MASTER)
    assert any("Section inexistante" in error for error in errors)


def test_duplicate_scenario_identifier_is_rejected():
    mutated = TRACE.replace("| S02 |", "| S01 |", 1)
    errors = checker.validate_texts(mutated, MASTER)
    assert any("70 identifiants distincts" in error for error in errors)
