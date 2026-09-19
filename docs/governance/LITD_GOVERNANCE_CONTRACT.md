# LITD Governance Contract

## Purpose
This contract defines the boundary between LITD implementation and the global HENOLOS governance layer. HENOLOS governs observable contracts and evidence, not LITD-specific implementation classes.

## Invariants
1. Experimental refactors do not land directly on `main`.
2. Deterministic gameplay contracts remain reproducible for identical explicit inputs and seeds.
3. Behavior-parity refactors provide regression evidence before behavior changes are introduced.
4. UI, animation and audio are not authoritative sources of combat state.
5. Project internals may evolve without HENOLOS changes when the evidence contract remains satisfied.
6. Governance failures remain visible and are never converted into false success.

## Evidence contract
A governed change exposes, when applicable: immutable revision identity, declared intent and scope, affected subsystems, appropriate deterministic/smoke evidence, CI/Godot results, governance-gate results, regression analysis, decision and closure evidence.

## Combat migration rule
Combat extraction proceeds incrementally:
`UI -> Combat Runtime -> Resolvers -> Combat Events -> Presentation/Telemetry`.

Utility AI and other behavior changes are separate from parity refactors.

## HENOLOS boundary
HENOLOS may reason about determinism, tests, approvals, evidence completeness, security and closure. It must not require knowledge of implementation details such as resolver class names, hero-specific skills or enemy-specific tactical code.
