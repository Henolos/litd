import copy
import json
from pathlib import Path
import pytest
from tools.qa.validate_contract import validate, evidence_current

ROOT = Path(__file__).resolve().parents[1]
def inputs():
    return (json.loads((ROOT / "data/qa/validation_contract.json").read_text()), json.loads((ROOT / "schemas/qa/validation_contract.schema.json").read_text()))

def test_inventory():
    validate(*inputs(), ROOT)

def test_duplicate():
    c,s = inputs()
    c["rules"][1]["id"] = c["rules"][0]["id"]
    with pytest.raises(ValueError):
        validate(c,s,ROOT)

@pytest.mark.parametrize("field,value", [("tested_commit","b"*40),("canonical_digest","b"*64),("kind","simulation"),("status","NOT_RUN"),("report_sha256",None)])
def test_reject_stale_or_incomplete(field,value):
    e = dict(tested_commit="a"*40,canonical_digest="a"*64,kind="runtime",status="PASS",report_sha256="c"*64)
    assert evidence_current(e,"a"*40,"a"*64)
    e[field]=value
    assert not evidence_current(e,"a"*40,"a"*64)

def test_missing_evidence():
    assert not evidence_current({},None,None)
