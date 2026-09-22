# HENOLOS Infrastructure — Global Governance Binding

Status: Phase 5 bounded rollout contract. Risk class: CRITICAL governance change, non-production binding only.

## Purpose
Bind HENOLOS_INFRASTRUCTURE to the consolidated governance engine without importing credentials, secret values, client payloads or production authority into governance.

KNOWLEDGE -> CORE -> GUARDIAN -> EXECUTION -> VERIFICATION -> MEMORY

This adapter is not a new authority layer.

## Boundaries
- Global Guardian prohibitions remain authoritative.
- Infrastructure credentials remain scoped to their service/domain and least privilege.
- Governance stores references and verification evidence, never plaintext credentials.
- Repository readiness does not prove an external resource exists or is healthy.
- Real production, identity/auth, secret-management, backup/restore, destructive, network/security-boundary and global-governance changes are CRITICAL.
- Cross-domain execution remains subject to the global domain-isolation contract.
- Client/personal data crossing an infrastructure boundary remains CRITICAL and may not be copied into LITD.

## Real-state closure
READY or CI-green configuration is configuration evidence only. An external infrastructure resource may be marked CLOSED only after the declared real resource has been provisioned or changed, verified against intended state, evidence retained, and rollback readiness established.

## Production foundation
Existing planned HENOLOS infrastructure remains at its actual readiness state. This binding does not provision, configure or certify any external service.

## Rollback
Rollback of this binding is a repository revert. No external infrastructure resource is mutated by this contract.
