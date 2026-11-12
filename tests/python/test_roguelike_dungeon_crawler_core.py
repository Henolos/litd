import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RULES = ROOT / "data" / "roguelike" / "roguelike_rules.json"
RUNTIME = ROOT / "scripts" / "core" / "roguelike_runtime.gd"
EXPEDITION = ROOT / "scripts" / "core" / "expedition_manager.gd"


def load_rules():
    return json.loads(RULES.read_text(encoding="utf-8"))


def test_roguelike_rules_define_core_identity():
    rules = load_rules()
    assert rules["principles"]["permadeath"] is True
    assert rules["principles"]["guild_persists"] is True
    assert rules["principles"]["knowledge_persists_on_failed_run"] is True
    assert rules["principles"]["horizontal_meta_progression"] is True
    assert rules["principles"]["player_can_dim_light"] is True
    assert rules["principles"]["extraction_is_a_player_choice"] is True
    assert rules["inventory_capacity"] == 20
    assert rules["capture_limit_per_zone"] == 2
    assert rules["capture_hp_ratio"] == 0.25


def test_dungeon_has_all_required_room_families_and_modules():
    rules = load_rules()
    required = {
        "combat", "elite", "ambush", "treasure", "trap", "shrine", "camp",
        "merchant", "survivor", "creature", "ruins", "puzzle", "altar",
        "secret", "anomaly", "corpse"
    }
    assert required <= set(rules["room_weights"])
    assert required | {"start", "boss"} <= set(rules["module_keys"])
    assert rules["module_keys"]["boss"] == "ASH_BOSS_ANGEL"


def test_light_is_risk_reward_not_only_a_timer():
    light = load_rules()["light"]
    assert light["dark_danger_bonus"] > 0
    assert light["dark_loot_bonus"] > 0
    assert light["dark_essence_bonus"] > 0
    assert light["pressure_per_dark_room"] > 0


def test_loot_and_hazards_are_systemic():
    rules = load_rules()
    assert set(rules["loot_rarity_weights"]) == {"common", "uncommon", "rare", "epic", "legendary"}
    assert rules["affix_counts"]["legendary"] == 3
    assert rules["cursed_item_chance"] > 0
    assert rules["unidentified_relic_chance"] > 0
    assert {"fire", "poison_gas", "pit", "light_source", "darkness"} <= set(rules["hazards"])
