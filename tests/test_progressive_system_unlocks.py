import json
from pathlib import Path

ROOT = Path(__file__).parents[1]


def load(path: str):
    return json.loads((ROOT / path).read_text(encoding="utf-8"))


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def test_world_rules_are_active_from_new_game():
    scope = load("data/content_scope.json")
    world = scope["categories"]["world_rules"]
    assert world["activation"] == "new_game"
    assert world["never_locked"] is True
    required = {
        "persistent_injuries", "untreated_injury_aggravation", "infirmary",
        "field_healing", "all_healing_characters_can_treat", "mutilations",
        "fear_hope_postures", "supernatural_veil_folie", "positive_negative_traits",
        "permadeath", "physical_retreat", "ash_guidance_on_request",
        "enemy_senses", "enemy_reactions", "patrols", "reactive_rooms",
    }
    assert required.issubset(set(world["systems"]))


def test_only_player_capabilities_are_locked():
    scope = load("data/content_scope.json")
    unlocks = scope["categories"]["unlockable_capabilities"]
    assert {"capture", "bounties", "specialized_exploration_roles", "trap_weaponization", "player_markers"}.issubset(unlocks)
    capture = unlocks["capture"]
    assert capture["logic"] == "first_eligible_creature_encounter"
    assert capture["hidden_until_unlocked"] is False
    assert capture["campaign_chapter"] == 1
    assert capture["company_rank"] == 1
    for capability, definition in unlocks.items():
        if capability == "capture":
            continue
        assert definition["logic"] == "or"
        assert definition["hidden_until_unlocked"] is True
    assert unlocks["targeted_farming"]["required_for_story"] is False
