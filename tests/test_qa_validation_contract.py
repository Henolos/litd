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


def test_report_bytes_integrity():
    import hashlib
    from tools.qa.validate_contract import report_integrity_matches
    report = b'actual report'
    e = dict(tested_commit='a'*40, canonical_digest='b'*64, kind='runtime', status='PASS', report_sha256=hashlib.sha256(report).hexdigest())
    assert report_integrity_matches(e,'a'*40,'b'*64,report)
    assert not report_integrity_matches(e,'a'*40,'b'*64,report+b'!')
    assert not report_integrity_matches(e,'a'*40,'b'*64,None)
    assert not report_integrity_matches(e,'c'*40,'b'*64,report)


def test_canonical_source_must_be_declared():
    c,s = inputs()
    c["references"].remove("docs/conception/LITD1_DOCUMENT_MAITRE.md")
    with pytest.raises(ValueError, match="Canonical source is not declared"):
        validate(c,s,ROOT)


def test_every_rule_has_a_review_channel_and_open_reconciliation_statuses():
    contract, schema = inputs()
    validate(contract, schema, ROOT)
    assert all(rule["review_channel"] in {"human", "visual", "F8", "measurement_and_human", "physical_windows"} for rule in contract["rules"])
    assert all(rule["source_status"] in {"MISSING", "LINKED_UNVERIFIED", "SUPPORTING_SOURCE_UNVERIFIED", "CANONICAL_AND_SUPPORTING_UNVERIFIED"} for rule in contract["rules"])
    assert sum(rule["acceptance_criteria_status"] == "PARTIAL" for rule in contract["rules"]) == 23
    assert sum(rule["acceptance_criteria_status"] == "NOT_DEFINED" for rule in contract["rules"]) == 106
    assert all(rule.get("acceptance_criteria") for rule in contract["rules"] if rule["acceptance_criteria_status"] == "PARTIAL")
    assert all(not rule.get("acceptance_criteria") for rule in contract["rules"] if rule["acceptance_criteria_status"] == "NOT_DEFINED")


def test_supporting_sources_must_be_declared():
    c, s = inputs()
    c["references"].remove("docs/COMBAT_ANATOMIE_AVANCEE.md")
    with pytest.raises(ValueError, match="Supporting source is not declared"):
        validate(c, s, ROOT)


def test_partial_criteria_must_be_present():
    c, s = inputs()
    rule = next(r for r in c["rules"] if r["id"] == "COM-15")
    rule["acceptance_criteria"] = []
    with pytest.raises(ValueError, match="Partial criteria missing"):
        validate(c, s, ROOT)
