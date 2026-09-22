from tools.quality.control_center_governance_evidence import evaluate_evidence


def receipt(**overrides):
    value = {
        "kind": "LITD_APPLICATION_CLOSURE_RECEIPT",
        "status": "APPLIED_MEASURED_PROVENANCE_VERIFIED",
        "closure_hash": "a" * 64,
        "blockers": [],
    }
    value.update(overrides)
    return value


def test_verified_closure_is_complete():
    result = evaluate_evidence([receipt()])
    assert result["evidence_complete"] is True
    assert result["last_evidence"] == "closure:" + "a" * 64
    assert result["authority"] == "read_only_evidence_interpretation"


def test_blocked_closure_is_not_complete():
    result = evaluate_evidence([receipt(status="POST_MERGE_CLOSURE_BLOCKED", blockers=["x"])])
    assert result["evidence_complete"] is False


def test_invalid_hash_is_not_evidence():
    assert evaluate_evidence([receipt(closure_hash="not-a-hash")])["evidence_complete"] is False


def test_decorative_boolean_cannot_fake_completion():
    fake = {"evidence_complete": True, "kind": "decorative"}
    assert evaluate_evidence([fake])["evidence_complete"] is False
