from tools.ci.godot_progress_bridge import state_for


def test_intermediate_progress_stays_pending() -> None:
    assert state_for("START", 3) == "pending"
    assert state_for("DONE", 86) == "pending"


def test_only_terminal_progress_is_success() -> None:
    assert state_for("DONE", 100) == "success"


def test_error_is_failure() -> None:
    assert state_for("ERROR", 24) == "failure"
