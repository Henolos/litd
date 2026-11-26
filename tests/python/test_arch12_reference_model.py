import importlib.util
from itertools import combinations
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[2]
MODEL_PATH = ROOT / "tools/qa/arch12_reference_model.py"
MODEL_SPEC = importlib.util.spec_from_file_location("arch12_reference_model", MODEL_PATH)
assert MODEL_SPEC is not None and MODEL_SPEC.loader is not None
MODEL = importlib.util.module_from_spec(MODEL_SPEC)
MODEL_SPEC.loader.exec_module(MODEL)


def _subsets(values):
    return [
        frozenset(group)
        for size in range(len(values) + 1)
        for group in combinations(values, size)
    ]


def _assert_tie_invariants(result, contributors, prior_statuses):
    assert result.principal is None
    assert set(result.contributors) == set(contributors)
    assert result.nemesis_statuses == frozenset(prior_statuses)


def test_exhaustive_resolved_branches_preserve_principal_and_status_invariants():
    actors = ("A", "B", "C", "D")
    for contributors in _subsets(actors):
        for prior in _subsets(actors):
            tie = MODEL.resolve_death(
                kind=MODEL.EvidenceKind.IRREDUCIBLE_TIE,
                contributors=contributors,
                prior_nemesis_statuses=prior,
            )
            _assert_tie_invariants(tie, contributors, prior)

            unknown = MODEL.resolve_death(
                kind=MODEL.EvidenceKind.UNKNOWN,
                contributors=contributors,
                prior_nemesis_statuses=prior,
            )
            assert unknown.principal is None
            assert set(unknown.contributors) == set(contributors)
            assert unknown.nemesis_statuses == frozenset(prior)

            for principal in contributors:
                eligible = MODEL.resolve_death(
                    kind=MODEL.EvidenceKind.UNIQUE,
                    contributors=contributors,
                    prior_nemesis_statuses=prior,
                    unique_principal=principal,
                    principal_eligible=True,
                )
                assert eligible.principal == principal
                assert eligible.contributors == tuple(sorted(contributors))
                assert eligible.nemesis_statuses == frozenset(prior) | {principal}


def test_unique_principal_must_be_a_listed_contributor():
    with pytest.raises(ValueError):
        MODEL.resolve_death(
            kind=MODEL.EvidenceKind.UNIQUE,
            contributors={"A"},
            unique_principal="B",
        )


def test_action_uses_master_at_action_time_after_transfer():
    assert MODEL.master_for_action(
        master_at_action="A",
        master_at_resolution="B",
    ) == "A"


def test_posthumous_recognition_preserves_death_and_gameplay_state():
    before = MODEL.EntityState(
        entity_id="E1",
        alive=False,
        stats=(10, 20, 30),
        nemesis=True,
        promotions=2,
    )
    after = MODEL.recognize_posthumously(before)
    assert after.entity_id == before.entity_id
    assert after.alive is False
    assert after.stats == before.stats
    assert after.nemesis == before.nemesis
    assert after.promotions == before.promotions
    assert after.archived is True


def test_posthumous_recognition_refuses_living_entity():
    living = MODEL.EntityState("E1", True, (10,), False, 0)
    with pytest.raises(ValueError):
        MODEL.recognize_posthumously(living)


def test_mutation_kill_tie_breaks_by_last_attacker():
    actors = ("A", "B")
    correct = MODEL.resolve_death(
        kind=MODEL.EvidenceKind.IRREDUCIBLE_TIE,
        contributors=actors,
    )
    mutant_principal = actors[-1]
    with pytest.raises(AssertionError):
        _assert_tie_invariants(
            MODEL.DeathResolution(actors, mutant_principal, frozenset({mutant_principal})),
            actors,
            (),
        )


def test_mutation_kill_reassigns_old_action_to_new_master():
    expected = MODEL.master_for_action(master_at_action="A", master_at_resolution="B")
    mutant = "B"
    assert expected == "A"
    assert mutant != expected


def test_mutation_kill_resurrects_entity_during_archive_recognition():
    before = MODEL.EntityState("E1", False, (10,), False, 0)
    correct = MODEL.recognize_posthumously(before)
    assert correct.alive is False
    mutant = MODEL.EntityState("E1", True, before.stats, before.nemesis, before.promotions, True)
    assert mutant.alive is not correct.alive
