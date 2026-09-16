# Combat Resolvers 01 — Consolidated Receipt

Status: PHASE_B_WIRED_AWAITING_VALIDATION
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

## Phase B evidence
- the runtime now delegates deterministic hit resolution to `VeilleursHitResolver`;
- the runtime now delegates damage, severity and armor-factor calculation to `VeilleursDamageResolver`;
- the historical `_stable_roll()` compatibility method remains present while the contract test locks resolver parity against the legacy runtime;
- special effects (`expose`, `reveal_observation`, `trame_control`) remain outside the resolver path;
- anatomy, status, Knowledge observation, effort-cost mutations and successful-hit payload construction remain owned by the combat runtime and occur after resolver output;
- no Utility AI, balance, UI, save-schema or content behavior is introduced by Phase B.

## Risk and rollback
Phase B changes the call path but is intended to preserve behavior exactly. Merge remains fail-closed until the exact final PR head SHA passes the required repository, Godot and governance checks. The branch remains independently revertible before merge.

## Validation
Focused tests:
- `scripts/tests/veilleurs_combat_resolvers_smoke.gd`
- `scripts/tests/veilleurs_combat_resolvers_contract_test.gd`

Required before merge: exact-final-head repository CI, Godot smoke, Knowledge Governance, Guardian Change Gate, Developer Regression Analysis, and applicable decision/closure gates. Failures must remain visible and must not be bypassed.

## Next decision
If the exact final Phase B head is fully green and the PR remains mergeable, the authorized next action is merge. Utility AI remains a separate governed behavior change.
