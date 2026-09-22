# HENOLOS Business — Global Governance Binding

Status: Phase 5 bounded rollout contract.
Risk class: CRITICAL governance change, non-production binding only.

## Purpose

Bind the HENOLOS BUSINESS domain to the consolidated global governance engine without moving client data, secrets, credentials, production state, or domain-specific authority into the governance repository.

The binding uses the existing flow:

KNOWLEDGE -> CORE -> GUARDIAN -> EXECUTION -> VERIFICATION -> MEMORY

It does not create a new authority layer.

## Domain identity

- `primary_domain`: `HENOLOS_BUSINESS`
- Business policy, client-facing automation design, RGPD/privacy requirements, service definitions, subscription rules and business-specific operating decisions remain domain-owned.
- Global Guardian prohibitions remain authoritative and may only be made stricter by the business domain.
- `library_write_allowed` remains domain-specific and is not promoted into global authority by this binding.

## Change Record binding

Every HENOLOS Business execution entering the consolidated engine MUST identify:

1. `primary_domain = HENOLOS_BUSINESS`;
2. the risk class;
3. affected domains;
4. objective and initial state;
5. research/evidence references when materially relevant;
6. Core decision;
7. Guardian authorization;
8. execution target references;
9. verification evidence;
10. rollback evidence/impact;
11. final state and closure.

Cross-domain changes additionally comply with `GLOBAL_GOVERNANCE_DOMAIN_ISOLATION.md` and its machine-verifiable validator.

## Data and secret boundary

Governance records MUST contain metadata and references, not raw client payloads or secret values.

Client data:
- MUST use an authenticated encrypted transport channel from entry (TLS/HTTPS or equivalent appropriate protection);
- MUST remain encrypted at rest whenever retained, including databases, files, queues, backups, exports and temporary storage;
- MUST NOT be copied into LITD knowledge, fixtures, receipts, logs or evidence;
- SHOULD be replaced by synthetic data for staging and governance verification whenever real client data is unnecessary.

Secrets and credentials:
- MUST remain in the domain/service secret-management boundary;
- governance may retain a non-secret reference, scope, owner domain and verification evidence;
- plaintext secret or credential values MUST NOT be written to Change Records, receipts, logs, tests or repository fixtures.

## Execution boundary

This binding does not authorize production execution.

A configuration, policy or plan marked READY is not CLOSED merely because its repository representation passes CI. Real hosting, database, identity, secret-management, production, backup or client-data changes require separate real-state execution and verification evidence.

Changes affecting production, identity/authentication, secrets, personal/client data, destructive operations, or global governance are CRITICAL.

## Current production-foundation mapping

Existing HENOLOS production-foundation work may be represented in the global engine, but its current readiness state MUST be preserved rather than upgraded by this binding alone.

In particular, configuration-ready staging/security work remains configuration-ready until the corresponding real resources are provisioned and tested. Repository CI is evidence for the governance/configuration layer, not proof that an external resource exists or is correctly operating.

## Closure rule

A HENOLOS Business Change Record may close only when its declared execution scope has actually occurred and the required verification/evidence exists. If scope is documentation/configuration only, closure applies only to that bounded scope and MUST NOT imply external production closure.

## Rollback

Rollback of this binding is a repository revert. No external business system, client data, credential or production resource is mutated by introducing this contract.
