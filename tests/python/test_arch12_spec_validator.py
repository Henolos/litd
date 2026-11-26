import importlib.util
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MODULE_PATH = ROOT / "tools/qa/arch12_spec_validator.py"
MODULE_SPEC = importlib.util.spec_from_file_location("arch12_spec_validator", MODULE_PATH)
assert MODULE_SPEC is not None and MODULE_SPEC.loader is not None
VALIDATOR = importlib.util.module_from_spec(MODULE_SPEC)
MODULE_SPEC.loader.exec_module(VALIDATOR)
EXPECTED_IDS = VALIDATOR.EXPECTED_IDS
validate_documents = VALIDATOR.validate_documents
SPEC = ROOT / "docs/qa/ARCH12_FUNCTIONAL_TEST_SPEC_2026-11-26.md"
TRACEABILITY = ROOT / "docs/qa/ARCH12_TRACEABILITY_AND_SCENARIOS_2026-11-26.md"


def _table_rows(ids=EXPECTED_IDS, *, bad_label=None, duplicate=False):
    rows = ["| ID | Règles | Fixture | Oracle | État |", "|---|---|---|---|---|"]
    for index, scenario_id in enumerate(ids, start=1):
        oracle = "O" if index <= 39 else "P"
        if scenario_id == bad_label:
            oracle = "X"
        rows.append(f"| {scenario_id} | règle | fixture | attendu | {oracle} — contrôle |")
    if duplicate and ids:
        rows.append(rows[-1])
    return "\n".join(rows)


def _trace_rows(ids=EXPECTED_IDS):
    rows = ["| ID | Scénario | Règle | État |", "|---|---|---|---|"]
    rows.extend(f"| {scenario_id} | cas | règle | non exécuté |" for scenario_id in ids)
    return "\n".join(rows)


def test_current_arch12_documents_have_frozen_inventory():
    result = validate_documents(
        SPEC.read_text(encoding="utf-8"),
        TRACEABILITY.read_text(encoding="utf-8"),
    )
    assert result["status"] == "PASS", result["issues"]
    assert result["scenario_rows"] == 70
    assert result["traceability_rows"] == 70
    assert result["oracle_counts"] == {"O": 39, "P": 31, "D": 0}


def test_synthetic_complete_inventory_passes():
    result = validate_documents(_table_rows(), _trace_rows())
    assert result["status"] == "PASS"


def test_missing_scenario_fails_closed():
    ids = EXPECTED_IDS[:-1]
    result = validate_documents(_table_rows(ids), _trace_rows(ids))
    assert result["status"] == "FAIL"
    assert any("inventaire" in issue for issue in result["issues"])


def test_duplicate_scenario_fails_closed():
    result = validate_documents(_table_rows(duplicate=True), _trace_rows())
    assert result["status"] == "FAIL"
    assert any("dupliqués" in issue for issue in result["issues"])


def test_unknown_oracle_label_fails_closed():
    result = validate_documents(_table_rows(bad_label="S01"), _trace_rows())
    assert result["status"] == "FAIL"
    assert any("étiquette O/P/D absente" in issue for issue in result["issues"])


def test_spec_and_traceability_must_match():
    result = validate_documents(_table_rows(), _trace_rows(EXPECTED_IDS[:-1]))
    assert result["status"] == "FAIL"
    assert any("divergent" in issue or "inventaire de traçabilité" in issue for issue in result["issues"])


def test_oracle_inventory_change_requires_explicit_update():
    rows = _table_rows().replace("| S01 | règle | fixture | attendu | O — contrôle |", "| S01 | règle | fixture | attendu | P — contrôle |")
    result = validate_documents(rows, _trace_rows())
    assert result["status"] == "FAIL"
    assert any("répartition O/P/D modifiée" in issue for issue in result["issues"])
