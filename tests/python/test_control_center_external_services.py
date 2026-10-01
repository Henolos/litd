import pytest

from tools.quality.control_center_external_services import build, normalize, unavailable


def test_normalizes_external_service_without_payload_or_authority():
    row = normalize(
        {
            "view_id": "HENOLOS_INFRASTRUCTURE",
            "service": "Supabase",
            "state": "ACTIVE_HEALTHY",
            "source": "supabase_project_metadata_read_only",
            "observed_at": "2026-10-01T15:13:50Z",
            "project_ref": "example-ref",
            "region": "eu-central-1",
            "security_advisory_count": 1,
            "performance_advisory_count": 9,
        }
    )
    assert row["state"] == "ACTIVE_HEALTHY"
    assert row["contains_payload_data"] is False
    assert row["contains_secret_values"] is False
    assert row["mutation_authority"] is False


def test_visibility_unavailable_is_not_success():
    row = unavailable(
        view_id="HENOLOS_INFRASTRUCTURE",
        service="Supabase staging",
        source="connector_visibility",
    )
    assert row["state"] == "VISIBILITY_UNAVAILABLE"
    assert row["visibility"] == "unavailable"


def test_rejects_unknown_state_and_view():
    with pytest.raises(ValueError):
        normalize({"view_id": "LITD", "service": "x", "state": "ACTIVE_HEALTHY", "source": "x"})
    with pytest.raises(ValueError):
        normalize({"view_id": "HENOLOS_BUSINESS", "service": "x", "state": "PASS", "source": "x"})


def test_build_preserves_observation_only_semantics():
    result = build([
        {
            "view_id": "HENOLOS_BUSINESS",
            "service": "Supabase",
            "state": "NOT_CONFIGURED",
            "source": "control_center_configuration",
        }
    ])
    assert result["authority"] == "observation_only"
    assert result["semantics"] == "external_service_evidence_not_governance_closure"
