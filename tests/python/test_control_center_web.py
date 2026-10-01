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
        "domain_states": {
            "LITD": {
                "source": "github_actions_litd_read_only",
                "domain": "LITD",
                "status": "HEALTHY_LAST_KNOWN",
                "authority": "observation_only",
                "mutation_authority": False,
                "signals": [
                    {
                        "name": "Veilleurs Playtest Readiness",
                        "path": ".github/workflows/veilleurs-playtest-readiness.yml",
                        "status": "completed",
                        "conclusion": "success",
                        "on_current_main": False,
                        "created_at": "2026-10-01T13:00:37Z",
                    }
                ],
            }
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
    assert "LITD operational state" in page
    assert "HEALTHY_LAST_KNOWN" in page
    assert "Veilleurs Playtest Readiness" in page
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


def test_escapes_litd_operational_signal_values():
    snapshot = _snapshot()
    snapshot["domain_states"]["LITD"]["signals"][0]["name"] = "<svg onload=alert(1)>"
    page = render(snapshot)
    assert "<svg onload=alert(1)>" not in page
    assert "&lt;svg onload=alert(1)&gt;" in page
