"""Pure candidate projection, not a transaction commit or a SaveManager."""
import json
from pathlib import Path
from jsonschema import Draft202012Validator
from expedition_validator import PersistentState
from secure_validator import valid_id

_SCHEMA = json.loads(Path(__file__).with_name('transaction_candidate.schema.json').read_text())
Draft202012Validator.check_schema(_SCHEMA)
_VALIDATOR = Draft202012Validator(_SCHEMA)
_FIELDS = ('discoveries','narrative','world','rewards','closures')

def validate_candidate(candidate):
    if type(candidate) is not dict or not _VALIDATOR.is_valid(candidate):
        raise ValueError('invalid transaction schema')
    if not valid_id(candidate['campaign_id']) or not valid_id(candidate['transaction_id']) or type(candidate['base_revision']) is not int:
        raise ValueError('invalid transaction identity')
    state = candidate['persistent_state']
    if type(state) is not dict or type(state['resources']) is not dict or any(type(k) is not str or type(v) is not int for k,v in state['resources'].items()):
        raise ValueError('invalid resources')
    if any(type(state[k]) is not list or any(type(x) is not str for x in state[k]) for k in _FIELDS) or not all(map(valid_id,state['closures'])):
        raise ValueError('invalid persistent fields')
    return candidate

def project(state: PersistentState, *, base_revision: int, transaction_id: str):
    if not isinstance(state, PersistentState) or not valid_id(state.campaign_id):
        raise ValueError('campaign-bound state required')
    if type(state.resources) is not tuple or any(type(x) is not tuple or len(x)!=2 or type(x[0]) is not str or type(x[1]) is not int for x in state.resources):
        raise ValueError('invalid resources')
    if len(dict(state.resources)) != len(state.resources):
        raise ValueError('duplicate resources')
    if any(type(getattr(state,k)) is not frozenset or any(type(x) is not str for x in getattr(state,k)) for k in _FIELDS):
        raise ValueError('invalid persistent fields')
    return validate_candidate(dict(campaign_id=state.campaign_id, base_revision=base_revision,
                transaction_id=transaction_id, persistent_state=dict(resources=dict(state.resources),
                **{k:sorted(getattr(state,k)) for k in _FIELDS})))
