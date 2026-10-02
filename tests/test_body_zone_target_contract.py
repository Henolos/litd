from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TARGET_RESOLVER = (ROOT / "scripts" / "core" / "combat" / "veilleurs_target_resolver.gd").read_text(encoding="utf-8")


def test_body_zone_is_canonical_target_dimension():
    assert "static func body_zones_for_action" in TARGET_RESOLVER
    assert "static func requires_body_zone" in TARGET_RESOLVER
    assert "static func can_target_body_zone" in TARGET_RESOLVER
    assert "static func validate_target_contract" in TARGET_RESOLVER


def test_body_zone_contract_keeps_all_six_playable_zones():
    for zone in ["head", "torso", "left_arm", "right_arm", "left_leg", "right_leg"]:
        assert f'"{zone}"' in TARGET_RESOLVER


def test_zone_required_actions_fail_without_explicit_zone():
    assert '"body_zone_required"' in TARGET_RESOLVER
    assert '"body_zone_not_targetable"' in TARGET_RESOLVER
