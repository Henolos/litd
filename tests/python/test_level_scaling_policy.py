import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def _section(text: str, function_name: str) -> str:
    marker = f"func {function_name}("
    start = text.index(marker)
    next_func = text.find("\nfunc ", start + len(marker))
    return text[start:] if next_func == -1 else text[start:next_func]




def test_dungeon_has_an_explicit_required_level_and_fixed_enemy_curve() -> None:
    rules = json.loads((ROOT / "data/roguelike/roguelike_rules.json").read_text(encoding="utf-8"))
    dungeon_id = rules["default_dungeon_id"]
    profile = rules["dungeons"][dungeon_id]

    assert profile["required_level"] == 3
    assert profile["enemy_base_level"] == 4
    assert profile["enemy_level_per_depth"] == 2
    assert profile["scaling_rule"] == "fixed_by_dungeon_and_depth_never_by_hero_level"
    assert rules["principles"]["campaign_scales_to_party"] is True
    assert rules["principles"]["dungeons_never_scale_to_party"] is True
    assert rules["principles"]["dungeons_have_required_levels"] is True
