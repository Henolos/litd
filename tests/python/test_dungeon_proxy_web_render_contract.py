from pathlib import Path

ROOM_V2 = Path("scripts/world/dungeon_proxy_room_v2.gd")
ROOM_SCENE = Path("scenes/dungeon/DungeonProxyRoom.tscn")
EXPLORER_SCENE = Path("scenes/dungeon/DungeonProxyExplorer.tscn")
PROJECT = Path("project.godot")










def test_project_uses_web_compatible_renderer():
    project = PROJECT.read_text(encoding="utf-8")
    assert 'renderer/rendering_method="gl_compatibility"' in project
    assert 'renderer/rendering_method.mobile="gl_compatibility"' in project
