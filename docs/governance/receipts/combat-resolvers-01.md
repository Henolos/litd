# Combat Resolvers 01 — Consolidated Receipt

Status: AWAITING_PR_VALIDATION
Intent: behavior-parity architecture refactor.

## Scope
Extract deterministic hit and damage calculations into pure resolvers. Add focused regression coverage and define the LITD ↔ HENOLOS evidence boundary.

Excluded from this change: Utility AI, balance changes, new skills/statuses, UI changes, save-schema changes, and hero/content redesign.

## Behavior baseline
- base accuracy defaults to 75;
- coordination bonus adds to accuracy;
- precision posture adds +6 accuracy;
- hit succeeds when deterministic roll is lower than accuracy clamped to 5..97;
- force-cost posture adds +3 power;
- Porte-Cendre torso/arms use armor factor 0.55;
- other zones use factor 1.0;
- damage is rounded and clamped to at least 1;
- severity is 1 below 8, 2 from 8 through 12, and 3 from 13 upward.

## Architecture boundary
`UI -> Combat Runtime -> pure Resolvers -> future Combat Events -> presentation / telemetry / Rémanence`

The combat runtime remains authoritative during this migration. HENOLOS governs intent, invariants, evidence, approvals, regression results and closure; it does not depend on LITD-specific resolver classes or combat formulas.

## Risk and rollback
Current additive checkpoint risk is low because the active combat runtime is not wired to these resolvers yet. The branch can be abandoned without changing `main`. Phase B must preserve deterministic roll, rounding, severity, mutation order and result payloads.

## Validation
Focused tests:
- `scripts/tests/veilleurs_combat_resolvers_smoke.gd`
- `scripts/tests/veilleurs_combat_resolvers_contract_test.gd`

Required before Phase B or merge: current-head repository CI, Godot smoke, Knowledge Governance, Guardian Change Gate, Developer Regression Analysis, and applicable decision/closure gates. Failures must remain visible and must not be bypassed.

## Next decision
A green additive checkpoint authorizes only Phase B runtime wiring. Utility AI remains a separate governed behavior change.
