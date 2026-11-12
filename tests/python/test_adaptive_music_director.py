import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]




def test_narrative_music_priority_contract():
    training = json.loads((ROOT / "data/adaptive_music_training.json").read_text(encoding="utf-8"))
    narrative = json.loads((ROOT / "data/narrative_audio.json").read_text(encoding="utf-8"))
    audio = json.loads((ROOT / "data/audio_director.json").read_text(encoding="utf-8"))

    contract = training["narrative_contract"]
    beats = narrative["beats"]
    assert beats["revelation"]["music"] == contract["revelation"]
    assert beats["loss"]["music"] == contract["loss"]
    assert beats["reunion"]["music"] == contract["reunion"]
    assert audio["combat_resolution_music"]["victory"] == contract["victory"]
    assert audio["combat_resolution_music"]["defeat"] == contract["defeat"]
    assert contract["dialogue_has_priority"] is True
    assert contract["scripted_silence_has_priority"] is True
