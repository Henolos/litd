# Combat Pipeline Migration Plan

Status: ACTIVE

The migration is intentionally split into governed checkpoints to avoid coupling behavior changes to architecture changes.

Checkpoint A: pure component contracts (this branch).
Checkpoint B: runtime wiring of Target/Anatomy/Status/Reaction while preserving exact current outcomes.
Checkpoint C: CombatCommand entry and CombatEvent emission, with existing UI compatibility adapter.
Checkpoint D: regression closure of the old inline rule paths.
Checkpoint E: separate AI branch introducing Perception -> EnemyMemory -> UtilityAI -> CombatCommand.

A checkpoint may proceed automatically when its exact head SHA is green and no new architecture/security/scope decision is discovered. Any discovery that changes gameplay semantics, save compatibility, governance guarantees or project scope requires explicit approval.
