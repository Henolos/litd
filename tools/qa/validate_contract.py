"""Draft inventory validation; never promotes historical evidence."""
import hashlib
import hmac
import json
import re
from pathlib import Path

def evidence_current(evidence, commit, canonical_digest):
    """Metadata eligibility only; does not authenticate or validate execution."""
    return (
        isinstance(evidence, dict)
        and isinstance(commit, str)
        and re.fullmatch(r"[0-9a-f]{40}", commit) is not None
        and isinstance(canonical_digest, str)
        and re.fullmatch(r"[0-9a-f]{64}", canonical_digest) is not None
        and evidence.get("tested_commit") == commit
        and evidence.get("canonical_digest") == canonical_digest
        and evidence.get("status") == "PASS"
        and evidence.get("kind") == "runtime"
        and isinstance(evidence.get("report_sha256"), str)
        and re.fullmatch(r"[0-9a-f]{64}", evidence["report_sha256"]) is not None
    )

def report_integrity_matches(evidence, commit, canonical_digest, report_bytes):
    """Check actual bytes, not provenance or gameplay correctness."""
    return (evidence_current(evidence, commit, canonical_digest)
            and isinstance(report_bytes, bytes)
            and hmac.compare_digest(hashlib.sha256(report_bytes).hexdigest(), evidence['report_sha256']))

def validate(contract, schema, root):
    from jsonschema import Draft202012Validator
    Draft202012Validator.check_schema(schema)
    Draft202012Validator(schema).validate(contract)
    ids = [r["id"] for r in contract["rules"]]
    if len(ids) != len(set(ids)):
        raise ValueError("Duplicate rule ID")
    expected = {f"{g}-{i:02d}" for g,n in {"COM":20,"EXP":17,"SAV":20,"PRO":14,"REF":10,"ANA":10,"PSY":8,"UI":10,"INT":20}.items() for i in range(1,n+1)}
    if set(ids) != expected:
        raise ValueError("Inventory IDs differ")
    for ref in contract["references"]:
        p = (root / ref).resolve()
        if not p.is_relative_to(root.resolve()) or not p.is_file():
            raise ValueError(f"Invalid reference: {ref}")
    reference_set = set(contract["references"])
    for rule in contract["rules"]:
        source = rule.get("canonical_source")
        if source is not None and source["document"] not in reference_set:
            raise ValueError(f"Canonical source is not declared in references: {rule['id']}")
        for support in rule.get("supporting_sources", []):
            if support["document"] not in reference_set:
                raise ValueError(f"Supporting source is not declared in references: {rule['id']}")
        criteria = rule.get("acceptance_criteria", [])
        criteria_status = rule["acceptance_criteria_status"]
        if criteria_status == "NOT_DEFINED" and criteria:
            raise ValueError(f"Criteria supplied while status is NOT_DEFINED: {rule['id']}")
        if criteria_status == "PARTIAL" and not criteria:
            raise ValueError(f"Partial criteria missing: {rule['id']}")

if __name__ == "__main__":
    root = Path(__file__).resolve().parents[2]
    validate(json.loads((root / "data/qa/validation_contract.json").read_text()), json.loads((root / "schemas/qa/validation_contract.schema.json").read_text()), root)
    print("QA_DRAFT_INVENTORY_OK")
