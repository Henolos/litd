"""Pure in-memory preview; not a durable journal or a SaveManager."""
import json
from dataclasses import dataclass
from secure_validator import valid_id
from canonical_candidate import validate_candidate

@dataclass(frozen=True)
class Preview:
    campaign_id: str
    revision: int = 0
    receipts: tuple = ()

    def apply(self, candidate):
        validate_candidate(candidate)
        if not valid_id(self.campaign_id) or type(self.revision) is not int or self.revision < 0:
            raise ValueError('invalid preview')
        if candidate['campaign_id'] != self.campaign_id:
            raise ValueError('campaign conflict')
        tid = candidate['transaction_id']
        rev = candidate['base_revision']
        if not valid_id(tid) or type(rev) is not int or rev < 0:
            raise ValueError('invalid identity')
        payload = json.dumps(candidate, sort_keys=True, separators=(',', ':'), allow_nan=False)
        previous = dict(self.receipts).get(tid)
        if previous is not None:
            if previous != payload:
                raise ValueError('transaction conflict')
            return self, 'duplicate'
        if rev != self.revision:
            raise ValueError('revision conflict')
        return Preview(self.campaign_id, self.revision + 1, self.receipts + ((tid, payload),)), 'candidate'
