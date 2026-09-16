# Combat Resolvers 01 — Migration Plan

## Phase A — landed in this branch

- Introduce pure `VeilleursHitResolver` with the sandbox deterministic-roll contract.
- Introduce pure `VeilleursDamageResolver` with current power/posture/Porte-Cendre armor behavior.
- Add focused headless smoke coverage.
- Record the LITD ↔ HENOLOS evidence boundary.

These additions are intentionally not wired into `VeilleursCombatSandboxRuntime` yet. This makes the first checkpoint additive and reversible.

## Phase B — next commit after validation

Replace only the hit/damage calculation block inside `_resolve_enemy_action()` with resolver calls while preserving mutation, anatomy, knowledge and result payloads in the runtime.

Required parity:
- identical deterministic roll for identical inputs;
- identical accuracy modifiers and clamp;
- identical Porte-Cendre armor factor;
- identical damage rounding and severity thresholds;
- no change to anatomy/status/knowledge behavior.

## Phase C — later PRs

Extract anatomy/status/reaction/event emission, then introduce Utility AI as a behavior change with separate evidence. Do not combine Utility AI with this parity migration.
