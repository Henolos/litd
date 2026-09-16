# Les Veilleurs combat core

This directory contains small deterministic combat resolvers extracted from the sandbox runtime.

Rules:
- resolvers receive explicit inputs and return explicit results;
- pure calculation is preferred here; orchestration and state mutation remain outside until separately migrated;
- presentation must not be imported by these resolvers;
- deterministic contracts require regression coverage;
- hero/enemy-specific content should migrate toward data definitions rather than accumulating in generic resolvers.

Current extraction:
- `veilleurs_hit_resolver.gd`: accuracy and deterministic hit roll;
- `veilleurs_damage_resolver.gd`: power, protected-zone armor factor, damage and severity.
