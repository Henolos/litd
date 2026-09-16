# Combat Resolvers 01 — Additive Checkpoint

Checkpoint SHA is the branch head containing this receipt.

State:
- branch created from `main`;
- hit resolver added;
- damage resolver added;
- deterministic/parity smoke tests added;
- LITD ↔ HENOLOS governance contract proposed;
- existing combat runtime not modified at this checkpoint;
- therefore no production/sandbox behavior is intentionally changed yet.

Next gate:
Run the repository CI/Godot/governance chain on the pull request. Only after this additive checkpoint is validated should Phase B wire the resolvers into `_resolve_enemy_action()`.
