import json
from pathlib import Path

ROOT = Path(__file__).parents[1]


def load(path):
    return json.loads((ROOT / path).read_text(encoding="utf-8"))




def test_character_and_giver_blender_contracts_are_exhaustive():
    characters = load("data/production/character_blender_contract.json")
    givers = load("data/production/quest_giver_blender_contract.json")
    required = {"idle", "walk", "run", "tactical_step", "retreat", "limp_l", "limp_r", "stairs_up", "stairs_down", "narrow_passage", "vault", "climb_short"}
    assert required.issubset(characters["animation_contract"]["locomotion"])
    assert len(characters["posture_variation"]["axes"]) >= 7
    assert characters["posture_variation"]["minimum_presets_per_character"] >= 4
    assert characters["weapon_rules"]["two_handed_missing_arm"] == "forbidden regardless of Ambidextrous"
    assert len(givers["quest_givers"]) == 5
    for giver in givers["quest_givers"]:
        assert {"offered", "active", "completed", "failed"}.issubset(giver["postures"])
        assert len(giver["expressions"]) >= 4
    assert givers["interaction_rules"]["pause_game"] is False


def test_first_map_scenery_catalog_is_production_ready():
    catalog = load("data/production/ashlands_scenery_catalog.json")
    assert len(catalog["modules"]) >= 20
    assert len(catalog["materials"]) >= 6
    ids = {entry["id"] for entry in catalog["modules"]}
    assert {"stairs", "bridge", "quarry_lift", "buried_bell", "medical_cache", "memorial_wall"}.issubset(ids)
    for asset in catalog["modules"]:
        assert asset["variants"] >= 1
        assert len(asset["size"]) == 3
        assert asset["lods"] >= 2
        assert asset["poly_budget_lod0"] > 0
        assert asset["export"].endswith(".glb")
    assert catalog["placement"]["seed_saved"] is True


def test_narrative_covers_environment_camp_and_philosophy():
    narrative = load("data/narrative/chapter_01_extended_narrative.json")
    assert len(narrative["environmental_sequences"]) >= 5
    assert len(narrative["camp_conversations"]) >= 5
    themes = {doc["theme"] for doc in narrative["documents"]}
    assert {"body_mind_common_good", "politics_after_fall", "fear", "veil_folie", "hope"}.issubset(themes)
    assert {"trait", "injury", "fear", "veil_folie", "hope", "relationship", "quest_choice", "ally_death", "captured_creature"}.issubset(narrative["reaction_dimensions"])


def test_audio_contract_preserves_litd_identity_and_legal_sources():
    audio = load("data/audio/audio_music_production_contract.json")
    assert audio["legal"]["composition"] == "public domain only or original"
    assert "forbidden" in audio["legal"]["modern_recordings"]
    assert {language["id"] for language in audio["languages"]} == {"body", "spirit", "common_good"}
    assert len(audio["sfx_events"]) >= 14
    assert audio["deep_listening"]["cost"] == "time_and_alert_risk"
    assert "exact_stats" in audio["deep_listening"]["never_reveals"]
    assert audio["mix"]["sample_rate"] == 48000




def test_non_pc_boundary_is_explicit():
    pending = {
        "Blender models and final animation authoring",
        "visual animation and collision tuning",
        "audio recording listening and mix approval",
        "physical keyboard mouse controller and touch validation",
        "Windows performance profiling and build",
    }
    assert len(pending) == 5
