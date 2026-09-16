# LITD Governance Contract

Status: PROPOSED — refactor/combat-resolvers-01

## Purpose

This contract defines the boundary between LITD implementation and the global HENOLOS governance layer. HENOLOS governs observable contracts and evidence; it does not depend on LITD-specific implementation classes.

## Invariants

1. `main` is not the workspace for experimental refactors; changes arrive through governed branches and pull requests.
2. Deterministic gameplay contracts must remain reproducible for identical explicit inputs and seeds.
3. Refactors that claim behavior parity must provide regression evidence before behavior changes are introduced.
4. UI, animation and audio must not become the authoritative source of combat state.
5. Project-specific resolvers may evolve without requiring changes to HENOLOS, provided the evidence contract remains satisfied.
6. Governance failures must remain visible and must not be bypassed or converted into false success.

## Evidence contract

A governed LITD change should expose, when applicable:

- change identifier and immutable commit SHA;
- declared intent: parity refactor, feature, balance, content, fix, or governance change;
- affected subsystem(s);
- deterministic or smoke-test evidence appropriate to the change;
- CI / Godot smoke result;
- governance-gate result;
- regression-analysis result;
- closure decision and retained receipt.

## Combat refactor rule

Combat extraction proceeds incrementally:

`UI -> CombatRuntime -> Resolvers -> Combat Events -> Presentation/Telemetry`

The first extraction must preserve the validated sandbox behavior. Utility AI and new gameplay behavior are separate changes and must not be hidden inside a parity refactor.

## HENOLOS boundary

HENOLOS may reason about contracts such as determinism, test coverage, approvals, evidence completeness, security and closure. It must not require knowledge of implementation details such as `VeilleursHitResolver`, `VeilleursDamageResolver`, hero-specific skill names, or enemy-specific tactical code.
