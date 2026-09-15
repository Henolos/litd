from pathlib import Path

ROOT = Path(__file__).parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def test_player_main_keeps_playtest_ux_layers_active():
    scene = read("scenes/Main.tscn")
    v52 = read("scripts/ui/main_v52.gd")
    v51 = read("scripts/ui/main_v51.gd")
    v50 = read("scripts/ui/main_v50.gd")

    assert 'path="res://scripts/ui/main_v52.gd"' in scene
    assert 'extends "res://scripts/ui/main_v51.gd"' in v52
    assert 'extends "res://scripts/ui/main_v50.gd"' in v51
    assert 'extends "res://scripts/ui/combat_sandbox_ui_v51.gd"' in v50


def test_hub_and_mission_departure_remain_guided():
    ui = read("scripts/ui/main_v51.gd")

    for token in (
        "PARTIR EN MISSION",
        "1 · ÉQUIPE",
        "2 · RÉSERVES",
        "3 · MISSION",
        "LANCER L'EXPÉDITION",
    ):
        assert token in ui


def test_room_navigation_is_direct_and_macro_map_is_optional():
    ui = read("scripts/ui/main_v51.gd")

    assert "SORTIES ACCESSIBLES" in ui
    assert "Touchez une destination pour avancer." in ui
    assert "VOIR LA MACRO-CARTE" in ui
    assert "facultative pour se déplacer" in ui
    assert "_room_is_reachable" in ui
    assert "_enter_roguelike_room" in ui
    assert "expedition_macro_map_open_v51" in ui


def test_combatant_inspection_remains_bound_to_heroes_and_enemies():
    combat = read("scripts/ui/main.gd")
    inspection = read("scripts/ui/combatant_inspection_ui.gd")

    assert combat.count("CombatantInspectionUI.bind_combatant") >= 2
    assert "func open_detail(combatant: Dictionary, enemy: bool)" in inspection
    assert "ÉTAT DU CORPS ET EFFETS" in inspection
    assert "COMPÉTENCES" in inspection
