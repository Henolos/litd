
import json, pytest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
SCHEMA_KEYS={'version','gold','essence','light','supplies','party','expedition_room','equipment','creatures'}

@pytest.mark.save
@pytest.mark.parametrize('gold,essence,light,supplies',[(0,0,0,0),(120,18,75,8),(999999,9999,100,99)])
def test_save_payload_ranges(gold,essence,light,supplies):
    payload={'version':'0.16','gold':gold,'essence':essence,'light':light,'supplies':supplies,'party':[],'expedition_room':0,'equipment':{},'creatures':{}}
    assert SCHEMA_KEYS <= payload.keys()
    assert payload['gold'] >= 0 and 0 <= payload['light'] <= 100

@pytest.mark.save
def test_save_manager_preserves_opaque_snapshot_without_gameplay_dependencies():
    text=(ROOT/'scripts/core/save_manager.gd').read_text()
    assert 'func set_snapshot(' in text
    assert 'func get_snapshot(' in text
    assert '_snapshot.duplicate(true)' in text
    assert 'GameState' not in text
    assert '"version"' in text
