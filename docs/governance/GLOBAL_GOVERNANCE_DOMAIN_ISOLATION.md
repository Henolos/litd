# Global Governance — Phase 5 Domain Isolation Contract

Status: CRITICAL governance change / non-destructive deployment preparation.

## Purpose

Phase 5 applies the consolidated governance engine beyond the LITD domain without allowing shared governance to become shared domain authority, shared secrets, or shared data.

The global engine provides the universal sequence KNOWLEDGE → CORE → GUARDIAN → EXECUTION → VERIFICATION → MEMORY and the canonical Change Record. Each governed domain remains an explicit isolation boundary.

## Initial governed domains

### LITD
Owns game-specific knowledge, Godot/gameplay/lore/UX targets, game build/test evidence and project-specific execution state.

### HENOLOS BUSINESS
Owns client/business automation, RGPD/privacy obligations, billing/business operations, customer data and business-specific execution state.

### HENOLOS INFRASTRUCTURE
Owns hosting, deployment, identity, secrets management, databases, backups, observability and infrastructure-specific execution state.

Infrastructure may serve another domain, but this does not transfer ownership of that domain's data or authority to infrastructure governance.

## Mandatory isolation invariants

1. Every Change Record MUST identify exactly one primary `project/domain` before execution.
2. A domain MUST NOT read or write another domain's secrets merely because both use the global governance engine.
3. Client data MUST NOT be copied into LITD knowledge, test fixtures, receipts, logs or evidence stores.
4. LITD assets, gameplay state and domain decisions MUST NOT become business or infrastructure authority inputs unless an explicit cross-domain Change Record authorizes a bounded reference.
5. Cross-domain changes are SENSITIVE at minimum. They become CRITICAL when they affect secrets, identity/authorization, production, personal/client data, destructive operations or global governance.
6. Cross-domain execution MUST enumerate each affected domain and the exact bounded interface between them; implicit transitive authority is prohibited.
7. Shared evidence MUST use references or appropriately minimized/redacted records where possible. Sharing governance evidence does not authorize sharing underlying secret or client payloads.
8. The Guardian canonical authority contract remains global. A domain may add stricter restrictions, but MUST NOT widen a global prohibition.
9. Execution credentials MUST be scoped to the target domain/service and least privilege. A credential valid for one domain MUST NOT be treated as globally valid.
10. Rollback MUST restore the affected domain without requiring unrelated-domain mutation unless that dependency was explicitly recorded before execution.
11. Verification MUST include isolation checks for SENSITIVE/CRITICAL cross-domain changes.
12. MEMORY MUST preserve which domain produced each receipt/evidence item and must not silently merge domain histories into an authority source.

## Business data protection boundary

For HENOLOS BUSINESS, client data in transit must use an authenticated encrypted channel such as TLS/HTTPS or an appropriate equivalent. If client data is persisted, it must remain encrypted at rest in applicable databases, files, queues, backups, exports and temporary storage. Plaintext client payloads must not be introduced into governance receipts or diagnostic artifacts unless strictly required by an explicitly authorized bounded operation and protected by the same or stronger controls.

## Infrastructure application boundary

Provisioning or modifying real hosting, databases, identity, secrets, production services or backups is CRITICAL when it changes security/production authority. Configuration readiness is not closure: a resource is only considered provisioned/verified after its real state has been tested and evidence retained.

Synthetic data should be used for staging and governance verification unless real data is explicitly required and authorized.

## Cross-domain Change Record extension

When more than one domain is affected, the canonical Change Record must additionally capture:

- primary_domain
- affected_domains
- cross_domain_interfaces
- data_classes_crossing_boundary
- credentials_or_authority_boundaries (references only; never secret values)
- isolation_verification
- domain-specific rollback impact

These fields extend traceability only; they create no new authority layer.

## Phase 5 rollout order

1. Establish this isolation contract and verify it does not widen authority.
2. Bind HENOLOS BUSINESS governance to the global engine at the policy/Change-Record boundary without moving client data or secrets.
3. Bind HENOLOS INFRASTRUCTURE governance at the same boundary, keeping credentials and real service state isolated.
4. Add machine-verifiable domain/isolation checks before any cross-domain automated execution is introduced.
5. Apply the engine to additional projects only after their domain boundary, data classes, credentials and rollback ownership are explicit.

## Rollback

This phase begins with documentation only. Revert this file/PR to remove the Phase 5 isolation specification. No production resource, credential, client data, workflow authority or domain target is modified by this first tranche.
