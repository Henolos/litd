import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def test_sanctuary_has_modular_states_including_listening_hearing_delegations_models_and_endings():
    data = json.loads((ROOT / "data/levels/sanctuary_state_layers.json").read_text())
    ids = {layer["id"] for layer in data["layers"]}
    core = {
        "stable","welcoming","tense","militarized","impoverished","creature_coexistence",
        "civic_reconstruction","absent_listening","foreign_delegations","public_hearing",
        "model_chamber","fractured",
    }
    endings = {
        "ending_radical_closure","ending_stable_coexistence","ending_preserve_crossings",
        "ending_seek_absent","ending_restore_concord","ending_transform_concord",
        "ending_fractured_survival","ending_authoritarian_order","ending_veil_dissolution",
    }
    assert core <= ids
    assert endings <= ids
    assert data["base_state"] == "stable"
    assert data["composition"]["max_simultaneous_major_layers"] == 3


def test_every_state_explains_visual_audio_and_population_changes():
    data = json.loads((ROOT / "data/levels/sanctuary_state_layers.json").read_text())
    for layer in data["layers"]:
        assert layer["visual"]
        assert layer["audio"]
        assert layer["population"]






def test_states_cover_requested_player_consequences():
    data = json.loads((ROOT / "data/levels/sanctuary_state_layers.json").read_text())
    by_id = {layer["id"]: layer for layer in data["layers"]}
    assert "refugees_welcomed" in by_id["welcoming"]["when"]["any_flag"]
    assert by_id["tense"]["when"]["tension_min"] >= 50
    assert by_id["impoverished"]["when"]["supplies_max"] <= 4
    assert "creature_sanctuary_trial" in by_id["creature_coexistence"]["when"]["any_flag"]
    assert "city_min" in by_id["civic_reconstruction"]["when"]
    assert "sanctuary_listening_room_unlocked" in by_id["absent_listening"]["when"]["campaign_any_flag"]
    assert "sanctuary_foreign_house_unlocked" in by_id["foreign_delegations"]["when"]["campaign_any_flag"]
    assert "sanctuary_public_hearing_unlocked" in by_id["public_hearing"]["when"]["campaign_any_flag"]
    assert "sanctuary_model_chamber_unlocked" in by_id["model_chamber"]["when"]["campaign_any_flag"]
    assert "trust_max" in by_id["fractured"]["when"]


def test_each_final_orientation_has_a_distinct_postgame_layer():
    data = json.loads((ROOT / "data/levels/sanctuary_state_layers.json").read_text())
    ending_layers = [layer for layer in data["layers"] if layer["id"].startswith("ending_")]
    assert len(ending_layers) == 9
    for layer in ending_layers:
        assert layer["priority"] >= 110
        assert layer["gameplay"]["postgame"] is True
        flag = layer["when"]["campaign_any_flag"][0]
        assert flag == layer["id"]
