from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def test_canonical_portraits_reuse_responsive_combat_slots():
    layer = (ROOT / "scripts/ui/main_v52.gd").read_text(encoding="utf-8")
    start = layer.index("func _replace_legacy_hero_cards_v52() -> void:")
    end = layer.index("func show_hero_skills() -> void:", start)
    body = layer[start:end]

    assert "legacy_portraits: Array[TextureRect]" in body
    assert "portrait_slot.texture = portrait_texture" in body
    assert "portrait_slot.visible = true" in body
    assert "PanelContainer.new()" not in body
    assert 'panel.name = "CanonicalCombatCard_' not in body


def test_rear_line_canonical_starters_keep_real_attacks():
    manager = (ROOT / "scripts/core/hero_skill_manager_v2.gd").read_text(encoding="utf-8")

    assert '"id":"anouk_point_tension"' in manager
    assert '"allowed_positions":[1,2,3]' in manager
    assert '"id":"anouk_couper_flux"' in manager
    assert '"allowed_positions":[0,1,2,3]' in manager

    assert '"id":"aurelien_examen_bref"' in manager
    assert '"description":"Diagnostic offensif à distance de travail ; garantit une action hostile en R4."' in manager
    assert '"allowed_positions":[1,2,3]' in manager


def test_skill_and_context_rows_remain_below_hero_area():
    base = (ROOT / "scripts/ui/main_v30.gd").read_text(encoding="utf-8")
    assert "loadout_row.position = Vector2(24, 510)" in base
    assert "extra_row.position = Vector2(24, 580)" in base
