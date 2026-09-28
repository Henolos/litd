from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def test_runtime_reuses_status_resolver_and_does_not_duplicate_damage():
    text = (ROOT / "scripts/core/combat/veilleurs_affliction_synergy_runtime.gd").read_text(encoding="utf-8")
    assert "veilleurs_status_resolver.gd" in text
    assert "incoming_factor" not in text
    assert "outgoing_factor" not in text
    assert "PERIODIC_DAMAGE" not in text

def test_three_declared_cross_build_synergies_have_runtime_receipts():
    data = (ROOT / "data/veilleurs/skills/affliction_build_synergies.json").read_text(encoding="utf-8")
    runtime = (ROOT / "scripts/core/combat/veilleurs_affliction_synergy_runtime.gd").read_text(encoding="utf-8")
    for synergy_id in ["open_wound_team", "breaker_execution_window", "control_window"]:
        assert synergy_id in data
        assert synergy_id in runtime
