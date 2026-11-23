import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
HEROES_PATH = ROOT / "data" / "heroes.json"
ROSTER_PATH = ROOT / "data" / "veilleurs" / "canonical_roster.json"
GAME_STATE_PATH = ROOT / "scripts" / "core" / "game_state.gd"

FORMER_STARTERS = {"mathilde", "marec", "anouk", "aurelien"}
STALE_NAMES = {
    "Sahen Varo", "Mira Sen", "Narem Osh", "Ysra Nahal",
    "Malvor", "Lysandra", "Darius",
}
STALE_IDS = {"malvor", "lysandra", "darius", "sahen_varo", "mira_sen", "narem_osh", "ysra_nahal"}


def _load_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def test_starting_quartet_is_unassigned_until_new_roster_is_defined():
    roster = _load_json(ROSTER_PATH)
    assert roster["status"] == "starting_roster_unassigned"
    assert roster["rules"]["starting_quartet_assigned"] is False
    assert roster["rules"]["canonical_names_are_player_facing"] is True
    assert roster["rules"]["gameplay_identity_is_defined_only_by_current_roster"] is True
    assert roster["heroes"] == []
    assert roster["design_status"] == "awaiting_user_defined_starting_roster"


def test_former_starters_remain_catalogued_without_starting_status():
    heroes = _load_json(HEROES_PATH)
    assert {h["id"] for h in heroes} == FORMER_STARTERS
    assert all(h["canon_status"] == "canonical_hero_not_in_starting_roster" for h in heroes)
    assert all("starting_quartet_order" not in h for h in heroes)
    assert all(h["canonical_id"] == h["id"] for h in heroes)
    assert all(h["legendary_hero"] is True for h in heroes)
    assert all(h["race_id"] == "human" for h in heroes)


def test_stale_starting_hero_identities_are_not_active():
    heroes = _load_json(HEROES_PATH)
    assert STALE_NAMES.isdisjoint({h["name"] for h in heroes})
    assert STALE_IDS.isdisjoint({h["id"] for h in heroes})
    assert STALE_IDS.isdisjoint({h["canonical_id"] for h in heroes})




def test_existing_designs_and_world_constraints_are_preserved():
    roster = _load_json(ROSTER_PATH)
    constraints = roster["design_constraints"]
    assert constraints["cosmopolitan_world"] is True
    assert constraints["strong_asian_cultural_foundation"] is True
    assert constraints["primarily_chinese_visual_influence"] is True
    assert constraints["human_ethnic_diversity_required"] is True
    assert constraints["redesign_existing_four"] is False
    assert roster["rules"]["reuse_existing_legendary_hero_sheets"] is True
