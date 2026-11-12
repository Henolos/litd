import json
from pathlib import Path

from tools.qa.psychology_combat_audit import run

ROOT = Path(__file__).resolve().parents[2]








def test_psychology_terms_keep_veil_folie_separate_from_real_mental_illness():
    data = json.loads((ROOT / "data/psychology_events.json").read_text(encoding="utf-8"))
    terminology = data["terminology"]
    assert "surnaturel" in terminology["veil_folie"].lower()
    assert "diagnostic" in terminology["veil_folie"].lower()
    forbidden = set(terminology["forbidden_equivalences"])
    assert {
        "mental_illness_equals_violence",
        "mental_illness_equals_evil",
        "mental_illness_equals_supernatural_perception",
        "trauma_always_breaks_or_strengthens",
        "fear_equals_cowardice",
    } <= forbidden
    assert all(rule.get("non_diagnostic") is True for rule in data["trait_definitions"].values())
