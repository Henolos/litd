from __future__ import annotations

import json
from pathlib import Path

from tools.qa.systemic_cross_runtime_audit import audit_systemic_cross_runtime


ROOT = Path(__file__).resolve().parents[2]


def load(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))




def test_every_canonical_cross_event_and_cascade_has_runtime_presentation() -> None:
    canon = load(ROOT / "universe/lore/contextual_quest_cross_ramifications.json")
    runtime = load(ROOT / "data/narrative/systemic_cross_runtime.json")
    event_ids = {item["id"] for item in canon["cross_events"]}
    cascade_ids = {item["id"] for item in canon["compound_cascades"]}
    assert set(runtime["events"]) == event_ids
    assert set(runtime["cascades"]) == cascade_ids




def test_runtime_preserves_source_reliability_and_conditional_speakers() -> None:
    presentation = load(ROOT / "data/narrative/systemic_cross_runtime.json")
    allowed = {
        "hero.aurelien", "hero.effrie", "hero.lya", "hero.mathilde",
        "hero.marec", "hero.zeje", "hero.anouk",
    }
    reliabilities: set[str] = set()
    speakers: set[str] = set()
    for section in ["events", "cascades"]:
        for item in presentation[section].values():
            for rumor in item["rumors"]:
                reliabilities.add(rumor["reliability"])
            for line in item["dialogue"]:
                speakers.add(line["speaker_id"])
                assert line["speaker_id"] in allowed
                assert line["text"]
    assert {"confirmed", "direct", "reported", "variable", "unreliable"} <= reliabilities
    assert speakers <= allowed
