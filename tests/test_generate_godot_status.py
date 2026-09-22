from tools.ci.generate_godot_status import parse, render


def test_parse_godot_export_snapshot() -> None:
    log = """
[  12% ] scan | Storing File: res://scenes/intro.tscn
[  98% ] savepack | Storing File: res://scripts/world/final.gd.remap
ERROR: Unable to load fontconfig, system font support is disabled.
Orphan StringName: Node (static: 7, total: 8)
Godot exit code: 0
"""
    diagnostics = """
3:ERROR: Unable to load fontconfig, system font support is disabled.
4:Orphan StringName: Node (static: 7, total: 8)
"""
    refs = """
res://.godot/exported/cache.scn
res://scenes/intro.tscn
res://scripts/world/final.gd.remap
"""

    data = parse(log, diagnostics, refs)

    assert data["progress"] == 100
    assert data["status"] == "success"
    assert data["exit_code"] == 0
    assert data["current_file"] == "res://scripts/world/final.gd.remap"
    assert data["project_files_count"] == 2
    assert len(data["errors"]) == 1
    assert len(data["warnings"]) == 0
    assert len(data["notices"]) == 1


def test_render_reuses_existing_godot_progress_status() -> None:
    data = {
        "progress": 100,
        "current_file": "res://scripts/world/final.gd.remap",
        "exit_code": 0,
        "status": "success",
        "errors": [],
        "warnings": [],
        "notices": [],
        "referenced_files_count": 1,
        "project_files_count": 1,
        "sample_files": ["res://scripts/world/final.gd.remap"],
    }

    page = render(data, "hodaesu/litd", "web-playtest-pages.yml", "189", "123", "abcdef1234567890")

    assert "LITD · Godot Control Console" in page
    assert "api.github.com/repos/${REPO}/actions/workflows/" in page
    assert "api.github.com/repos/${REPO}/commits/${run.head_sha}/status" in page
    assert "godot-progress" in page
    assert "/actions/jobs/${build.id}/logs" not in page
    assert "setInterval(refresh,15000)" in page
    assert "res://scripts/world/final.gd.remap" in page
