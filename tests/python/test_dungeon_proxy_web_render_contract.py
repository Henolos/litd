from pathlib import Path

ROOM_V2 = Path("scripts/world/dungeon_proxy_room_v2.gd")
ROOM_SCENE = Path("scenes/dungeon/DungeonProxyRoom.tscn")
EXPLORER_SCENE = Path("scenes/dungeon/DungeonProxyExplorer.tscn")
PROJECT = Path("project.godot")


def test_web_room_preserves_static_render_support():
    source = ROOM_V2.read_text(encoding="utf-8")
    assert "STATIC_RENDER_SUPPORT" in source
    assert '"WorldEnvironment"' in source
    assert '"KeyLight"' in source
    assert '"FillLight"' in source
    assert "remove_child(node)" in source
    assert "add_child(node)" in source
    assert "var static_support := _detach_static_render_support()" in source
    assert "_restore_static_render_support(static_support)" in source


def test_web_room_forces_a_current_camera_after_rebuild():
    source = ROOM_V2.read_text(encoding="utf-8")
    assert 'explorer.get_node_or_null("Camera3D")' in source
    assert "camera.current = true" in source
    assert "camera.make_current()" in source
    assert "render_support_ready" in source


def test_room_scene_declares_environment_and_lights():
    scene = ROOM_SCENE.read_text(encoding="utf-8")
    assert '[node name="WorldEnvironment" type="WorldEnvironment" parent="."]' in scene
    assert '[node name="KeyLight" type="DirectionalLight3D" parent="."]' in scene
    assert '[node name="FillLight" type="OmniLight3D" parent="."]' in scene


def test_explorer_scene_declares_current_camera():
    scene = EXPLORER_SCENE.read_text(encoding="utf-8")
    assert '[node name="Camera3D" type="Camera3D" parent="."]' in scene
    assert "current = true" in scene


def test_project_uses_web_compatible_renderer():
    project = PROJECT.read_text(encoding="utf-8")
    assert 'renderer/rendering_method="gl_compatibility"' in project
    assert 'renderer/rendering_method.mobile="gl_compatibility"' in project
