# Combat Resolvers 01 — Intent Receipt

- Change: `refactor/combat-resolvers-01`
- Intent: behavior-parity architecture refactor
- Scope: deterministic hit calculation, damage calculation, regression smoke coverage, HENOLOS/LITD governance boundary
- Explicitly excluded: Utility AI, balance changes, skill redesign, UI redesign, save-schema changes
- Main safety rule: no direct experimental write to `main`
- Acceptance: resolver parity tests + existing CI/Godot/governance checks must pass before merge consideration
- Failure policy: failures remain failures; no masking or bypassing gates
