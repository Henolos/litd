import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
POLICY = ROOT / "data" / "roguelike" / "hybrid_dungeon_generation.json"
CATALOG = ROOT / "data" / "roguelike" / "first_veil_rooms.json"
GENERATOR = ROOT / "scripts" / "core" / "hybrid_dungeon_generator.gd"
RUNTIME = ROOT / "scripts" / "core" / "roguelike_runtime.gd"


def test_generation_never_replaces_authored_campaign_geometry():
    policy = json.loads(POLICY.read_text(encoding="utf-8"))
    boundaries = policy["generation_boundaries"]
    assert "first_map_tutorial" in boundaries["always_authored"]
    assert "boss_rooms" in boundaries["always_authored"]
    assert "unique_hero_missions" in boundaries["always_authored"]
    assert "procedural_room_geometry" in boundaries["forbidden"]
    assert "ordinary_room_order" in boundaries["variable_only"]


def test_hybrid_recipe_only_requests_existing_handcrafted_room_types():
    policy = json.loads(POLICY.read_text(encoding="utf-8"))
    catalog = json.loads(CATALOG.read_text(encoding="utf-8"))
    available = {room["type"] for room in catalog["rooms"]}
    recipe = policy["dungeons"]["first_veil_crypts"]["recipe"]
    for node in recipe["nodes"]:
        assert set(node["types"]) & available, node["key"]
    assert policy["dungeons"]["first_veil_crypts"]["campaign_first_visit"] == "authored_fixed_layout"
    assert policy["dungeons"]["first_veil_crypts"]["campaign_revisit"] == "hybrid_graph"


def test_recipe_has_branch_convergence_retreat_secret_and_boss_path():
    policy = json.loads(POLICY.read_text(encoding="utf-8"))
    recipe = policy["dungeons"]["first_veil_crypts"]["recipe"]
    nodes = {node["key"] for node in recipe["nodes"]}
    edges = {tuple(edge) for edge in recipe["edges"]}
    assert {"entry", "choice_left", "choice_right", "convergence", "respite", "risk", "reward", "preboss", "boss", "secret"} <= nodes
    assert ("approach", "choice_left") in edges
    assert ("approach", "choice_right") in edges
    assert ("choice_left", "convergence") in edges
    assert ("choice_right", "convergence") in edges
    assert ("respite", "entry") in edges
    assert ("preboss", "boss") in edges
