import json

from tools.quality.control_center_memory_collector import collect


def _write(path, payload):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload), encoding="utf-8")


def test_collects_real_registry_and_closure_receipt(tmp_path):
    _write(
        tmp_path / "docs/knowledge/governance/registry/evidence_registry.json",
        {
            "schema_version": 1,
            "entries": [
                {
                    "id": "EVD-1",
                    "type": "CI",
                    "result": "PASS",
                    "uri": "run:1",
                    "observed_at": "2026-09-24T00:00:00Z",
                    "change_id": "CHG-1",
                }
            ],
        },
    )
    closure = {
        "kind": "LITD_APPLICATION_CLOSURE_RECEIPT",
        "status": "APPLIED_MEASURED_PROVENANCE_VERIFIED",
        "closure_hash": "a" * 64,
        "blockers": [],
    }
    _write(tmp_path / "reports/application-closure.json", closure)

    result = collect(tmp_path)

    assert result["registry_evidence"][0]["id"] == "EVD-1"
    assert result["closure_receipts"] == [closure]
    assert result["counts"] == {"registry_evidence": 1, "closure_receipts": 1}
    assert result["authority"] == "read_only_memory_collection"


def test_does_not_promote_decorative_or_markdown_evidence(tmp_path):
    _write(
        tmp_path / "docs/knowledge/governance/registry/evidence_registry.json",
        {
            "entries": [
                {"id": "incomplete", "result": "PASS"},
                {
                    "id": "EVD-FAIL",
                    "type": "CI",
                    "result": "FAIL",
                    "uri": "run:2",
                    "observed_at": "2026-09-24T00:00:00Z",
                    "change_id": "CHG-2",
                },
            ]
        },
    )
    receipt_dir = tmp_path / "docs/governance/receipts"
    receipt_dir.mkdir(parents=True)
    (receipt_dir / "application-closure-note.md").write_text(
        "evidence_complete: true", encoding="utf-8"
    )
    _write(
        tmp_path / "reports/application-closure-fake.json",
        {"kind": "DECORATIVE", "evidence_complete": True},
    )

    result = collect(tmp_path)

    assert [item["id"] for item in result["registry_evidence"]] == ["EVD-FAIL"]
    assert result["closure_receipts"] == []
    assert "evidence_complete" not in result
