# Combat core components

Pure/deterministic contracts live here. They receive data and return resolution data; orchestration and authoritative mutation remain in the combat runtime during migration.

Pipeline target:
`CombatCommand -> TargetResolver -> HitResolver -> DamageResolver -> AnatomyResolver -> StatusResolver -> ReactionResolver -> CombatEvent`

AI decision target (separate layer):
`Perception -> EnemyMemory -> UtilityAI -> CombatCommand`

Do not let AI compute authoritative combat outcomes. Do not let presentation become authoritative state.
