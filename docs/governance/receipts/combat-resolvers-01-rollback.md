# Combat Resolvers 01 — Rollback Boundary

The additive checkpoint is reversible by dropping the branch/PR because active combat runtime behavior is not yet routed through the new resolver files.

After Phase B, rollback must restore the original `_resolve_enemy_action()` hit/damage calculation block and remove resolver preloads/calls while preserving unrelated branch changes.

Never force-update `main` as a rollback mechanism.
