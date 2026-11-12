import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CATALOG = ROOT / "data" / "roguelike" / "first_veil_rooms.json"
PLAN = ROOT / "data" / "roguelike" / "first_veil_proxy_plan.json"
PLAN_RUNTIME = ROOT / "scripts" / "core" / "first_veil_proxy_plan_runtime.gd"
ROOM_RUNTIME = ROOT / "scripts" / "world" / "dungeon_proxy_room.gd"
UI = ROOT / "scripts" / "ui" / "main_v28.gd"


def _data(path):
    return json.loads(path.read_text(encoding="utf-8"))


def test_every_first_veil_room_has_an_exact_proxy_plan():
    catalog = _data(CATALOG)
    plan = _data(PLAN)
    room_ids = {room["id"] for room in catalog["rooms"]}
    planned = {room["id"] for room in plan["rooms"]}
    assert room_ids == planned
    assert len(planned) == 37
    for room in plan["rooms"]:
        width, length, height = room["dimensions"]
        assert width >= 8
        assert length >= 6
        assert height >= 4
        assert len(room["port_sides"]) == 4
        assert set(room["port_sides"]) == {"north", "east", "south", "west"}
        assert room["module"].startswith("FV_")
        assert 1 <= room["phase"] <= 4


def test_proxy_plan_defines_stable_blender_handoff_and_four_connector_families():
    plan = _data(PLAN)
    assert plan["design_contract"]["one_node_one_room"] is True
    assert plan["design_contract"]["physical_passages"] is True
    assert plan["design_contract"]["secrets_hidden_until_discovered"] is True
    assert plan["design_contract"]["stable_gameplay_anchors_for_blender_swap"] is True
    assert set(plan["connectors"]) == {
        "standard_corridor",
        "stairwell",
        "secret_passage",
        "boss_gate",
    }
    assert plan["geometry"]["palier_drop"] == 7.5
    assert len(plan["anchor_profile"]) >= 8


def test_production_order_covers_all_rooms_before_blender_polish():
    plan = _data(PLAN)
    catalog = _data(CATALOG)
    all_ids = {room["id"] for room in catalog["rooms"]}
    scheduled = set()
    for phase in plan["production_order"]:
        if phase["rooms"] == ["ALL"]:
            continue
        scheduled.update(phase["rooms"])
    assert scheduled == all_ids
    assert plan["production_order"][-1]["name"] == "Blender et polish"
