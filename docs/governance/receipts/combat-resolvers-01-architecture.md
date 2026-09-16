# Combat Resolvers 01 — Architecture

Current migration target:

```text
UI
 -> VeilleursCombatSandboxRuntime (orchestration/state)
    -> HitResolver (pure)
    -> DamageResolver (pure)
    -> future AnatomyResolver
    -> future StatusResolver
    -> future ReactionResolver
 -> future CombatEvent stream
 -> UI / animation / audio / Remanence / telemetry
```

This PR begins only the pure hit/damage boundary. The runtime remains authoritative for sandbox combat state during the migration.
