# Les Veilleurs — Combat Pipeline

Authoritative target architecture:

`CombatCommand -> TargetResolver -> HitResolver -> DamageResolver -> AnatomyResolver -> StatusResolver -> ReactionResolver -> CombatEvent`

Decision architecture remains separate:

`Perception -> EnemyMemory -> UtilityAI -> CombatCommand`

## Authority rules
- Utility AI may choose intent only. It never computes authoritative hit, damage, anatomy, status or reaction outcomes.
- Combat resolvers are deterministic for the same inputs and do not own presentation.
- CombatEvent is an immutable-style snapshot payload used to decouple authoritative resolution from UI, telemetry, audio/animation and Rémanence consumers.
- The combat runtime remains the migration orchestrator until all behavior-parity wiring checkpoints are complete.
- HENOLOS governs invariants, evidence, authorization and closure, not LITD-specific formulas.

## Migration order
1. Target/Hit/Damage contracts.
2. Anatomy and status contracts.
3. Reaction contract.
4. Command/Event boundary.
5. Runtime wiring with parity tests.
6. Only after the engine boundary is stable: Perception/EnemyMemory/UtilityAI as a separate behavior change.
