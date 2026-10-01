import pytest

from tools.quality.control_center_litd_state import LITD_SIGNAL_PATHS, collect, summarize


def _run(path: str, *, sha: str, conclusion: str = "success", status: str = "completed", name: str | None = None):
    return {
        "path": path,
        "name": name or path.rsplit("/", 1)[-1],
        "status": status,
        "conclusion": conclusion,
        "head_sha": sha,
        "event": "push",
        "created_at": "2026-10-01T14:02:10Z",
    }


def test_summarize_marks_all_current_success_as_healthy_current():
    sha = "a" * 40
    result = summarize([_run(path, sha=sha) for path in LITD_SIGNAL_PATHS], sha)

    assert result["status"] == "HEALTHY_CURRENT"
    assert result["current_signal_count"] == len(LITD_SIGNAL_PATHS)
    assert result["mutation_authority"] is False
    assert result["contains_secret_values"] is False
    assert result["contains_payload_data"] is False


def test_summarize_distinguishes_last_known_success_from_current_main():
    main_sha = "a" * 40
    old_sha = "b" * 40
    runs = [
        _run(path, sha=(main_sha if index < 2 else old_sha))
        for index, path in enumerate(LITD_SIGNAL_PATHS)
    ]

    result = summarize(runs, main_sha)

    assert result["status"] == "HEALTHY_LAST_KNOWN"
    assert result["current_signal_count"] == 2


def test_summarize_failure_degrades_even_if_other_signals_are_green():
    sha = "a" * 40
    runs = [_run(path, sha=sha) for path in LITD_SIGNAL_PATHS]
    runs[2]["conclusion"] = "failure"

    result = summarize(runs, sha)

    assert result["status"] == "DEGRADED"


def test_summarize_active_run_takes_precedence():
    sha = "a" * 40
    runs = [_run(path, sha=sha) for path in LITD_SIGNAL_PATHS]
    runs[0]["status"] = "in_progress"
    runs[0]["conclusion"] = None

    result = summarize(runs, sha)

    assert result["status"] == "RUNNING"


def test_summarize_missing_signal_is_incomplete_without_inventing_health():
    sha = "a" * 40
    result = summarize([_run(LITD_SIGNAL_PATHS[0], sha=sha)], sha)

    assert result["status"] == "INCOMPLETE"
    assert any(signal["status"] == "missing" for signal in result["signals"])


def test_collect_uses_only_read_only_github_endpoints():
    sha = "a" * 40
    seen: list[str] = []

    def getter(url: str, token: str):
        seen.append(url)
        assert token == "token"
        if url.endswith("/commits/main"):
            return {"sha": sha}
        assert "actions/runs?branch=main&per_page=100" in url
        return {"workflow_runs": [_run(path, sha=sha) for path in LITD_SIGNAL_PATHS]}

    result = collect("Henolos/litd", "token", getter=getter)

    assert result["status"] == "HEALTHY_CURRENT"
    assert len(seen) == 2
    assert all("/repos/Henolos/litd/" in url for url in seen)


def test_collect_rejects_invalid_main_sha():
    def getter(url: str, token: str):
        if url.endswith("/commits/main"):
            return {"sha": "short"}
        return {"workflow_runs": []}

    with pytest.raises(ValueError, match="invalid main SHA"):
        collect("Henolos/litd", "token", getter=getter)
