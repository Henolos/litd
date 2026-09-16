# Combat Anatomy Resolver 02 — Receipt

Status: ADDITIVE_CHECKPOINT_AWAITING_VALIDATION
Intent: behavior-parity extraction of anatomy mutation calculation.

## Scope
- add a pure anatomy resolver;
- preserve injury state/function/armor thresholds and injury payload;
- preserve caller-owned mutation authority until runtime wiring;
- add a focused contract test.

## Invariants
- severity >= 2 produces impaired function, otherwise functional;
- armor factor < 0.8 maps to strong armor, otherwise weak;
- injury evidence preserves severity, impact and action source;
- resolver does not mutate its input dictionary;
- no AI, balance, status, reaction, UI or save-schema behavior changes.

## Validation gate
The additive checkpoint must be green on its exact PR head SHA before runtime wiring. Failures remain visible and are not bypassed.
