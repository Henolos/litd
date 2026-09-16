# Combat Resolvers 01 — Risk Assessment

Risk at additive checkpoint: LOW.

Reason: new resolver and test files are introduced without replacing the active combat runtime yet.

Primary future Phase B risks:
1. deterministic roll parity;
2. integer/float rounding parity for armor;
3. severity-threshold parity;
4. accidental mutation-order changes;
5. result-payload drift affecting UI/tests.

Mitigation: wire only hit/damage calculations after green checkpoint, preserve state mutation in the runtime, compare old/new results, and keep Utility AI outside this PR.
