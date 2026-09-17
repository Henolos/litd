from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def test_web_playtest_forces_new_worker_to_take_control() -> None:
    workflow = (ROOT / ".github/workflows/web-playtest-pages.yml").read_text(encoding="utf-8")

    assert "Enforce immediate playtest PWA refresh" in workflow
    assert "self.skipWaiting()" in workflow
    assert "self.clients.claim()" in workflow
    assert "client.navigate(client.url)" in workflow
    assert ".github/workflows/web-playtest-pages.yml" in workflow


def test_normal_combat_repairs_canonical_loadout_before_render() -> None:
    source = (ROOT / "scripts/ui/main_v52.gd").read_text(encoding="utf-8")

    show_combat = source.index("func show_combat() -> void:")
    guard_call = source.index("_enforce_canonical_combat_loadouts_v52()", show_combat)
    inherited_render = source.index("super.show_combat()", show_combat)

    assert guard_call < inherited_render
    assert '"basic_strike"' in source
    assert '"heavy_blow"' in source
    assert '"guard_stance"' in source
    assert '"field_aid"' in source
    assert 'hero["combat_loadout"] = HeroSkillManager.starter_loadout(hero)' in source


def test_backline_starters_cover_anouk_r3_and_aurelien_r4() -> None:
    manager = (ROOT / "scripts/core/hero_skill_manager_v2.gd").read_text(encoding="utf-8")

    anouk = manager[manager.index('"anouk": ['):manager.index('"aurelien": [')]
    aurelien = manager[manager.index('"aurelien": ['):manager.index("func _canonical_starter_id")]

    assert '"effect":"attack"' in anouk
    assert '"allowed_positions":[1,2,3]' in anouk or '"allowed_positions":[0,1,2,3]' in anouk
    assert '"effect":"attack"' in aurelien
    assert '"allowed_positions":[1,2,3]' in aurelien or '"allowed_positions":[0,1,2,3]' in aurelien
