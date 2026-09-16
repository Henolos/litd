# Combat Resolvers 01 — Behavior Baseline

Baseline copied from the active sandbox runtime before wiring:

- base accuracy defaults to 75;
- coordination bonus adds to accuracy;
- precision posture adds +6 accuracy;
- hit succeeds when deterministic roll is strictly lower than accuracy clamped to 5..97;
- force-cost posture adds +3 power;
- Porte-Cendre torso/arms use armor factor 0.55;
- other zones use factor 1.0;
- damage is rounded and clamped to at least 1;
- severity: 1 below 8 damage, 2 from 8 through 12, 3 from 13 upward.

This baseline is the parity target, not a balance recommendation.
