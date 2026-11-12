import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def _load(path):
    return json.loads((ROOT / path).read_text())


def test_all_six_political_npcs_have_multi_step_conversations():
    politics = _load("data/levels/ashlands_politics.json")
    social = _load("data/levels/ashlands_social_politics.json")
    npc_ids = {npc["id"] for npc in politics["npcs"]}
    assert len(npc_ids) == 6
    assert set(social["conversations"]) == npc_ids
    for entries in social["conversations"].values():
        assert entries
        assert any(len(entry["lines"]) >= 3 for entry in entries)


def test_dynamic_events_cover_requested_sanctuary_conflicts():
    social = _load("data/levels/ashlands_social_politics.json")
    ids = {event["id"] for event in social["dynamic_events"]}
    assert {
        "grain_argument",
        "xenophobic_whisper",
        "refugee_refusal",
        "lynching_attempt",
        "creature_debate",
        "scarcity_council",
        "emergency_power_request",
    } <= ids
    assert all(event["conditions"] for event in social["dynamic_events"])
    assert all(event["rumor"].strip() for event in social["dynamic_events"])


def test_social_consequences_are_visible_not_only_numeric():
    social = _load("data/levels/ashlands_social_politics.json")
    for consequence in social["visible_consequences"].values():
        assert "population_tags" in consequence
        assert "inscriptions" in consequence
        assert "rumors" in consequence
        assert "guard_delta" in consequence


def test_relationships_and_non_political_factions_are_present():
    social = _load("data/levels/ashlands_social_politics.json")
    assert len(social["relationships"]) >= 5
    assert len(social["social_factions"]) >= 7
    types = {faction["type"] for faction in social["social_factions"]}
    assert {"marchands", "guérisseurs", "familles", "sécurité", "artisans", "philosophique", "protection_du_vivant"} <= types


def test_world_memory_has_hooks_for_future_cities():
    social = _load("data/levels/ashlands_social_politics.json")
    hooks = _load("data/world/political_memory_hooks.json")
    memory_tags = {tag for value in social["world_memory"].values() for tag in value["tags"]}
    hook_tags = {hook["tag"] for hook in hooks["hooks"]}
    assert memory_tags <= hook_tags
    target_cities = {target["city"] for hook in hooks["hooks"] for target in hook["targets"]}
    assert {"orun_sai", "jian_lu", "dhor_khal", "sorye", "tessen", "lhaor"} <= target_cities
