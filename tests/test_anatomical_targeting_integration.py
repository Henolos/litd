from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MAIN_SCENE = (ROOT / "scenes" / "Main.tscn").read_text(encoding="utf-8")
MAIN_V53 = (ROOT / "scripts" / "ui" / "main_v53.gd").read_text(encoding="utf-8")
SANDBOX_V2 = (ROOT / "scripts" / "core" / "veilleurs_combat_sandbox_runtime_v2.gd").read_text(encoding="utf-8")
TARGET_RESOLVER = (ROOT / "scripts" / "core" / "combat" / "veilleurs_target_resolver.gd").read_text(encoding="utf-8")


def test_main_scene_activates_v53():
    assert 'res://scripts/ui/main_v53.gd' in MAIN_SCENE


def test_v53_uses_canonical_body_zone_resolver():
    assert 'veilleurs_target_resolver.gd' in MAIN_V53
    assert "body_zones_for_action" in MAIN_V53
    assert "can_target_body_zone" in MAIN_V53
    assert "body_zone_label" in MAIN_V53


def test_sandbox_runtime_v2_validates_body_zone_before_resolution():
    assert 'veilleurs_combat_sandbox_runtime.gd' in SANDBOX_V2
    assert 'veilleurs_target_resolver.gd' in SANDBOX_V2
    assert "requires_body_zone" in SANDBOX_V2
    assert "can_target_body_zone" in SANDBOX_V2
    assert '"body_zone_not_targetable"' in SANDBOX_V2


def test_six_anatomical_zones_remain_canonical():
    for zone in ["head", "torso", "left_arm", "right_arm", "left_leg", "right_leg"]:
        assert f'"{zone}"' in TARGET_RESOLVER
