"""Campaign-bound entry point; historical oracle is for regression only."""
import re
from expedition_validator import analyze as _analyze, Result, PersistentState

def valid_id(value):
    return type(value) is str and re.fullmatch(r'[A-Za-z0-9][A-Za-z0-9_.:-]{0,127}', value) is not None

def analyze(g, schema, prior=None, max_states=10000, max_seconds=5, *, campaign_id):
    if not valid_id(campaign_id) or not isinstance(g, dict) or g.get('schema_version') != 5 or not valid_id(g.get('expedition_id')):
        return Result('invalid_schema', reason='invalid_identity')
    if prior is not None and (not isinstance(prior, PersistentState) or prior.campaign_id != campaign_id or type(prior.closures) is not frozenset or not all(map(valid_id, prior.closures))):
        return Result('invalid_schema', reason='invalid_prior_identity')
    return _analyze(g, schema, prior, max_states, max_seconds, campaign_id=campaign_id)
