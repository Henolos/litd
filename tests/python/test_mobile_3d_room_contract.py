from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def test_dungeon_proxy_explorer_scene_is_touch_ready_and_lit():
    scene = (ROOT / "scenes/dungeon/DungeonProxyExplorer.tscn").read_text(encoding="utf-8")
    assert "dungeon_proxy_explorer_v2.gd" in scene
    assert 'type="DirectionalLight3D"' in scene
    assert "position = Vector3(0, 5.0, 6.2)" in scene


def test_dungeon_proxy_explorer_v2_exposes_touch_navigation_and_interaction():
    script = (ROOT / "scripts/world/dungeon_proxy_explorer_v2.gd").read_text(encoding="utf-8")
    assert "DisplayServer.is_touchscreen_available()" in script
    assert 'button_down.connect' in script
    assert 'button_up.connect' in script
    assert 'interact.name = "TouchInteract"' in script
    assert 'interact.text = "INTERAGIR"' in script
    assert "interaction_requested.emit(focused_interaction_id, focused_interaction_label)" in script
    assert "super._movement_input()" in script


def test_isometric_proxy_room_does_not_render_ceiling_over_camera():
    script = (ROOT / "scripts/world/dungeon_proxy_room_v2.gd").read_text(encoding="utf-8")
    assert '_hide_proxy_ceiling_for_isometric_camera()' in script
    assert 'get_node_or_null("Ceiling/Mesh")' in script
    assert "ceiling_mesh.visible = false" in script
