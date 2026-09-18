from __future__ import annotations

import pytest

from tools.quality.guardian_authority_contract import (
    CANONICAL_AUTHORITY,
    REQUIRED_GUARANTEES,
    assert_authority_equivalent,
    assert_guarantees_equivalent,
)


def test_canonical_authority_is_fail_closed() -> None:
    assert CANONICAL_AUTHORITY == {
        "core_write_allowed": False,
        "automatic_code_write_allowed": False,
        "automatic_merge_allowed": False,
        "automatic_application_allowed": False,
        "automatic_rollback_allowed": False,
        "automatic_target_change_allowed": False,
    }


def test_required_guarantees_are_fail_closed() -> None:
    assert REQUIRED_GUARANTEES == {
        "tests_must_pass_before_application": True,
        "rollback_evidence_required": True,
    }


def test_equivalence_accepts_explicit_legacy_values() -> None:
    payload = dict(CANONICAL_AUTHORITY)
    payload.update(REQUIRED_GUARANTEES)
    assert_authority_equivalent(payload, require=tuple(CANONICAL_AUTHORITY))
    assert_guarantees_equivalent(payload, require=tuple(REQUIRED_GUARANTEES))


@pytest.mark.parametrize("key", tuple(CANONICAL_AUTHORITY))
def test_authority_equivalence_fails_closed_on_missing_or_weakened_value(key: str) -> None:
    payload = dict(CANONICAL_AUTHORITY)
    payload.pop(key)
    with pytest.raises(ValueError):
        assert_authority_equivalent(payload, require=(key,))
    payload[key] = True
    with pytest.raises(ValueError):
        assert_authority_equivalent(payload, require=(key,))


@pytest.mark.parametrize("key", tuple(REQUIRED_GUARANTEES))
def test_guarantee_equivalence_fails_closed_on_missing_or_weakened_value(key: str) -> None:
    payload = dict(REQUIRED_GUARANTEES)
    payload.pop(key)
    with pytest.raises(ValueError):
        assert_guarantees_equivalent(payload, require=(key,))
    payload[key] = False
    with pytest.raises(ValueError):
        assert_guarantees_equivalent(payload, require=(key,))
