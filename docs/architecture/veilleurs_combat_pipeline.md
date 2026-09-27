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

## Afflictions in the sandbox

`VeilleursStatusResolver` is the single authority for timed afflictions on heroes and enemies. The `afflictions` dictionary stores remaining **actor turns** by identifier. Reapplication refreshes to the longer duration; distinct effects coexist. An effect is active for its final turn and expires at its end. Damage over time happens at the start of the affected actor's turn and cannot reduce HP below zero. Failed hits do not apply an effect or spend extra resources beyond the action's normal AP cost.

An actor may define `affliction_resistances` per ID with independent signed `damage` and `duration` percentages, for example `{"poison":{"damage":50,"duration":-50}}`. Positive values reduce the corresponding effect; negative values increase it. Both are clamped to −100…+100, so +100 duration prevents a new application and +100 damage suppresses its periodic damage, while −100 doubles the corresponding value. Duration is adjusted when applied, rounded to whole actor turns, then compared with the existing duration; resistance never cleanses an active effect. Periodic damage is adjusted separately for each effect at each turn start and rounded to whole damage. Missing values default to zero. This damage facet applies to poison, burn and bleed ticks, not direct weapon hits or the separate `vulnerability` combat modifier. The sandbox inspection shows the signed characteristics; the Charognard is sensitive to bleeding and Porte-Cendre resists burning.

| ID | Display name | Effect while active |
| --- | --- | --- |
| `poison` | Poison | 3 damage per turn |
| `burn` | Brûlure | 4 damage per turn |
| `bleed` | Saignement | 2 damage per turn; Stabiliser removes it |
| `freeze` | Gel | Movement blocked; accuracy −15 |
| `stun` | Étourdissement | Actions and movement blocked; enemy loses its turn |
| `blind` | Cécité | Accuracy −25 |
| `silence` | Silence | Trame actions blocked |
| `weakness` | Faiblesse | Outgoing damage ×0.75 |
| `vulnerability` | Vulnérabilité | Incoming damage ×1.25 |
| `snare` | Entrave | Movement blocked; enemy basic attack damage halved |

The sandbox bridge exposes one enemy-targeted action for each effect. All ten use the existing command, hit, status and turn pipeline. The original anatomical `bleeding_state` remains an injury/inspection field; the timed `bleed` is an additional combat effect. Enemy basic strikes have no trame tag, so Silence matters when a trame action is attempted by an afflicted hero; it is also ready for tagged enemy actions. Afflictions are visible through actor inspection.
