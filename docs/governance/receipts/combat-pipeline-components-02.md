# Combat Pipeline Components 02 — Consolidated Receipt

Status: ADDITIVE_CHECKPOINT_AWAITING_VALIDATION
Intent: introduce deterministic, non-authoritative component contracts before runtime migration.

## Added contracts
TargetResolver -> HitResolver -> DamageResolver -> AnatomyResolver -> StatusResolver -> ReactionResolver -> CombatEvent, with CombatCommand as the input intent contract.

## Safety boundary
These new components are additive at this checkpoint. The existing combat runtime remains authoritative. Utility AI is not introduced here. No balance, UI, save schema, skill content or enemy behavior is changed.

## Migration rule
After the exact checkpoint SHA is green, runtime authority may be migrated component by component while preserving payloads, mutation order and deterministic outcomes. Each migrated checkpoint must be validated before the next behavior-bearing extraction.

## Evidence
Focused contracts:
- scripts/tests/veilleurs_anatomy_resolver_contract_test.gd
- scripts/tests/veilleurs_combat_pipeline_contract_test.gd
- existing hit/damage resolver smoke and parity tests.
