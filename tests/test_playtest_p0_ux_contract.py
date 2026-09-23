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


def test_combatant_inspection_is_contextual_and_keeps_controls_available():
    inspection = read("scripts/ui/combatant_inspection_ui.gd")

    assert "const BASE_DETAIL_SIZE := Vector2(620, 260)" in inspection
    assert "detail_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE" in inspection
    assert "dim.mouse_filter = Control.MOUSE_FILTER_IGNORE" in inspection
    assert "detail_frame.mouse_filter = Control.MOUSE_FILTER_STOP" in inspection
    assert "minf(desired_detail.y, safe_size.y * 0.40)" in inspection


def test_enemy_inspection_uses_canonical_knowledge_before_revealing_details():
    adapter = read("scripts/ui/veilleurs_ui_state_adapter.gd")
    inspection = read("scripts/ui/combatant_inspection_ui.gd")

    assert "static func enemy_knowledge_view(combatant: Dictionary) -> Dictionary" in adapter
    assert "VeilleursRuntime.knowledge_summary(entry_id)" in adapter
    assert "KnowledgeDiscoveryUIContract.enemy_view(" in adapter
    assert "VeilleursUIStateAdapter.enemy_knowledge_view(combatant)" in inspection
    assert "KnowledgeDiscoveryUIContract.LEVEL_STUDIED" in inspection
    assert "KnowledgeDiscoveryUIContract.LEVEL_DOCUMENTED" in inspection
    assert 'combatant.get("skills", combatant.get("observed_skills"' in inspection
    assert "if not enemy or _knowledge_level(combatant) >= KnowledgeDiscoveryUIContract.LEVEL_DOCUMENTED:" in inspection
