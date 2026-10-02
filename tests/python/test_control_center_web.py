import pytest

from tools.quality.control_center_web import render


def _snapshot():
    return {
        "authority": "read_only_control_center_snapshot",
        "project": "HENOLOS_CONTROL_CENTER",
        "change_record": "PR-474",
        "phase": "verification",
        "status": "WAITING_CI",
        "pr": 474,
        "head_sha": "a" * 40,
        "checks": {"passed": 5, "total": 6},
        "last_evidence": "closure:" + "b" * 64,
        "blocker": None,
        "needs_human": False,
        "updated_at": "2026-09-28T02:04:26Z",
        "sources": {
            "github": "github_api_read_only",
            "memory": "repository_memory_read_only",
        },
        "domain_catalog": {
            "source": "repository_domain_catalog_read_only",
            "authority": "observation_only",
            "views": [
                {"id": "LITD", "kind": "domain", "authority_scope": "LITD", "status": "AVAILABLE"},
                {"id": "HENOLOS_BUSINESS", "kind": "domain", "authority_scope": "HENOLOS_BUSINESS", "status": "AVAILABLE"},
                {"id": "HENOLOS_INFRASTRUCTURE", "kind": "domain", "authority_scope": "HENOLOS_INFRASTRUCTURE", "status": "AVAILABLE"},
                {"id": "SECURITY_COMPLIANCE", "kind": "overlay", "authority_scope": "GLOBAL_GUARDIAN", "status": "AVAILABLE"},
                {"id": "VEILLEURS_KNOWLEDGE", "kind": "overlay", "authority_scope": "LITD", "status": "AVAILABLE"},
            ],
        },
        "external_services": {
            "source": "external_service_observations",
            "authority": "observation_only",
            "semantics": "external_service_evidence_not_governance_closure",
            "observations": [{"view_id":"HENOLOS_INFRASTRUCTURE","service":"Supabase","state":"VISIBILITY_UNAVAILABLE","source":"connector_visibility","observed_at":"2026-10-01T15:13:50Z","project_ref":None,"region":None,"security_advisory_count":0,"performance_advisory_count":0,"visibility":"unavailable","contains_payload_data":False,"contains_secret_values":False,"mutation_authority":False}],
        },
        "operational_indicators": {
            "source": "github_actions_latest_run_read_only",
            "semantics": "latest_workflow_evidence_not_domain_health",
            "authority": "observation_only",
            "indicators": [
                {
                    "view_id": "LITD",
                    "signal": "Veilleurs Playtest Readiness",
                    "evidence_state": "PASS",
                    "run_id": 123,
                    "event": "push",
                    "head_branch": "main",
                    "head_sha": "c" * 40,
                    "created_at": "2026-10-01T10:00:00Z",
                    "updated_at": "2026-10-01T10:01:00Z",
                    "conclusion": "success",
                },
                {
                    "view_id": "VEILLEURS_KNOWLEDGE",
                    "signal": "Veilleur Autonomous Discovery",
                    "evidence_state": "RUNNING",
                    "run_id": 124,
                    "event": "schedule",
                    "head_branch": "main",
                    "head_sha": "d" * 40,
                    "created_at": "2026-10-01T11:00:00Z",
                    "updated_at": "2026-10-01T11:00:30Z",
                    "conclusion": None,
                },
            ],
        },
    }


def test_renders_operational_fields_and_sources():
    page = render(_snapshot())
    assert "HENOLOS Control Center" in page
    assert "WAITING_CI" in page
    assert "5/6" in page
    assert "github_api_read_only" in page
    assert "repository_memory_read_only" in page
    assert "HENOLOS_BUSINESS" in page
    assert "HENOLOS_INFRASTRUCTURE" in page
    assert "SECURITY_COMPLIANCE" in page
    assert "VEILLEURS_KNOWLEDGE" in page
    assert "GLOBAL_GUARDIAN" in page
    assert "Operational evidence" in page
    assert "latest_workflow_evidence_not_domain_health" in page
    assert "Veilleurs Playtest Readiness" in page
    assert "Veilleur Autonomous Discovery" in page
    assert "PASS" in page
    assert "RUNNING" in page
    assert "<script" not in page.lower()


def test_escapes_untrusted_values():
    snapshot = _snapshot()
    snapshot["blocker"] = "<script>alert(1)</script>"
    page = render(snapshot)
    assert "<script>alert(1)</script>" not in page
    assert "&lt;script&gt;alert(1)&lt;/script&gt;" in page


def test_refuses_non_read_only_snapshot():
    snapshot = _snapshot()
    snapshot["authority"] = "write_capable"
    with pytest.raises(ValueError):
        render(snapshot)


def test_escapes_domain_catalog_values():
    snapshot = _snapshot()
    snapshot["domain_catalog"]["views"][0]["id"] = "<img src=x onerror=alert(1)>"
    page = render(snapshot)
    assert "<img src=x onerror=alert(1)>" not in page
    assert "&lt;img src=x onerror=alert(1)&gt;" in page


def test_escapes_operational_indicator_values():
    snapshot = _snapshot()
    snapshot["operational_indicators"]["indicators"][0]["signal"] = "<svg onload=alert(1)>"
    page = render(snapshot)
    assert "<svg onload=alert(1)>" not in page
    assert "&lt;svg onload=alert(1)&gt;" in page
\n

def test_escapes_external_service_values():
    snapshot = _snapshot()
    snapshot["external_services"]["observations"][0]["service"] = "<script>alert(1)</script>"
    page = render(snapshot)
    assert "<script>alert(1)</script>" not in page
    assert "&lt;script&gt;alert(1)&lt;/script&gt;" in page
