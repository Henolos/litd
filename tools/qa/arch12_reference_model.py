"""Finite reference policies for resolved ARCH-12 decision branches.

This model receives causal evidence as input. It deliberately does not compute
causal weights or decide unresolved game-design parameters.
"""
from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
from typing import Iterable


class EvidenceKind(str, Enum):
    UNIQUE = "unique"
    IRREDUCIBLE_TIE = "irreducible_tie"
    UNKNOWN = "unknown"


@dataclass(frozen=True)
class DeathResolution:
    contributors: tuple[str, ...]
    principal: str | None
    nemesis_statuses: frozenset[str]


@dataclass(frozen=True)
class EntityState:
    entity_id: str
    alive: bool
    stats: tuple[int, ...]
    nemesis: bool
    promotions: int
    archived: bool = False


def resolve_death(
    *,
    kind: EvidenceKind,
    contributors: Iterable[str],
    prior_nemesis_statuses: Iterable[str] = (),
    unique_principal: str | None = None,
    principal_eligible: bool = False,
) -> DeathResolution:
    """Apply only the already-resolved policy branch; do not score causality."""
    contributor_set = tuple(sorted(set(contributors)))
    prior = frozenset(prior_nemesis_statuses)

    if kind is EvidenceKind.UNIQUE:
        if unique_principal is None or unique_principal not in contributor_set:
            raise ValueError("a unique principal must be an identified contributor")
        statuses = prior | {unique_principal} if principal_eligible else prior
        return DeathResolution(contributor_set, unique_principal, statuses)

    if unique_principal is not None:
        raise ValueError("tie/unknown evidence cannot carry a unique principal")

    # Tie and unknown branches cannot create or erase Nemesis statuses.
    return DeathResolution(contributor_set, None, prior)


def master_for_action(*, master_at_action: str | None, master_at_resolution: str | None) -> str | None:
    """Resolve provenance from the action-time master; later transfers are irrelevant."""
    del master_at_resolution
    return master_at_action


def recognize_posthumously(state: EntityState) -> EntityState:
    """Add archive recognition without changing gameplay state."""
    if state.alive:
        raise ValueError("posthumous recognition requires a deceased entity")
    return EntityState(
        entity_id=state.entity_id,
        alive=False,
        stats=state.stats,
        nemesis=state.nemesis,
        promotions=state.promotions,
        archived=True,
    )
