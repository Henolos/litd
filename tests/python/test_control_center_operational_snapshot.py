from tools.quality.control_center_operational_snapshot import compose


def test_composes_real_sources_without_fake_completion():
    pr = {"number": 1, "state": "closed", "merged": True, "head_sha": "a"*40, "updated_at": "now"}
    snap = compose(pr, [], [], project="LITD", change_record="CC-001")
    assert snap["status"] == "RUNNING"
    assert snap["evidence"] == {"verified_receipts": 0, "complete": False}
    assert snap["schema_version"] == 1


def test_verified_memory_closes_merged_change():
    pr = {"number": 1, "state": "closed", "merged": True, "head_sha": "a"*40, "updated_at": "now"}
    receipts = [{"kind": "LITD_APPLICATION_CLOSURE_RECEIPT",
                 "status": "APPLIED_MEASURED_PROVENANCE_VERIFIED",
                 "closure_hash": "b"*64, "blockers": []}]
    snap = compose(pr, [], receipts, project="LITD")
    assert snap["status"] == "COMPLETED"
    assert snap["last_evidence"] == "closure:" + "b"*64


def test_pending_ci_remains_visible():
    pr = {"number": 2, "state": "open", "merged": False, "head_sha": "c"*40, "updated_at": "now"}
    runs = [{"id": 9, "name": "CI", "status": "in_progress", "conclusion": None}]
    snap = compose(pr, runs, [], project="HENOLOS_GLOBAL_GOVERNANCE")
    assert snap["status"] == "WAITING_CI"
    assert snap["checks"] == {"passed": 0, "total": 1}
