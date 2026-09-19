# Specialized Learning — Phase 0

Status: ACTIVE FOUNDATION / NON-AUTONOMOUS

## Purpose

Build an evidence-driven learning loop that improves engineering work without pretending to retrain the underlying model. Phase 0 is deliberately lightweight and must not introduce a new runtime service, autonomous mutation loop, or critical dependency.

## Core loop

1. Define the engineering task and expected behavior.
2. Inspect the real repository state and existing evidence.
3. Research authoritative documentation, standards, and relevant precedents.
4. Establish a reproducible baseline before changing code.
5. Implement the smallest justified change or exercise.
6. Compile/run and execute relevant automated tests.
7. Analyze failures and contradictory evidence; correct within mandate.
8. Compare the result with the baseline and acceptance criteria.
9. Record an evidence-backed lesson only when supported by reproducible results.
10. Revalidate lessons when their assumptions, engine/tool versions, or context change.

## Tracks

### LITD game engineering — priority 1

Initial competencies:
- Godot and GDScript correctness
- game architecture and separation of concerns
- deterministic turn-based combat logic
- procedural generation and seeded reproducibility
- game AI
- persistence/save systems
- UI architecture and input
- performance/profiling
- automated tests and regression prevention
- debugging and GitHub CI

The real LITD codebase is the principal evaluation environment. A lesson cannot be promoted merely because it is conventional advice: it must be compatible with the project and supported by appropriate tests/evidence.

### Henolos software/automation engineering — priority 1, separate evidence domain

Initial competencies:
- backend/API architecture
- Python/TypeScript where justified
- PostgreSQL/Supabase
- workflows, integrations and webhooks
- authentication/authorization
- multi-tenant isolation
- encryption and secrets handling
- observability, audit and logs
- queues/retries/idempotency/recovery
- testing and CI/CD
- infrastructure/deployment
- privacy-by-design, GDPR and application security

Henolos evidence must remain separate from LITD evidence. A game-development practice is never promoted into a business/security context merely because it worked in LITD.

## Evidence states

Every lesson uses one state:

- `candidate`: plausible but not demonstrated.
- `experimenting`: currently under reproducible evaluation.
- `proven`: supported by sufficient evidence for the explicitly recorded context.
- `rejected`: tested and not supported, or superseded.

`proven` never means universally true. Scope, assumptions, versions, limitations and counter-evidence remain part of the record.

## Promotion gate

A lesson may become `proven` only when the record contains:
- a precise claim;
- applicability scope and assumptions;
- source/standard references where relevant;
- reproducible experiment or real implementation evidence;
- baseline and post-change results;
- relevant tests/checks passing;
- known limitations and counter-evidence;
- date/version and affected project/domain.

No lesson can automatically change production code, governance policy, security controls, or LITD design. Promotion is knowledge curation, not deployment authorization.

## Phase 0 benchmark

The benchmark is not a vanity score. Each evaluated coding task records:
- task ID and immutable repository revision;
- expected behavior/acceptance criteria;
- relevant tests before work;
- failure/error category;
- implementation/correction attempts;
- relevant tests after work;
- regressions detected;
- maintainability/simplicity observations;
- resulting lesson candidates.

For LITD, deterministic and seeded tests are preferred whenever randomness is involved. For Henolos, security/privacy/isolation checks are mandatory whenever the task touches client or tenant data.

## Relationship to future systems

Phase 0 intentionally does not create a new daemon, agent, database or autonomous learning service. After the current LITD/governance stabilization, evidence from this foundation can justify or reject a V1 integration with the Veilleur, project libraries, Knowledge Guardian and governance Core.

Future integrations must pass the continuous-simplification question first: can the required capability be obtained by reusing or merging existing mechanisms rather than adding another layer?
