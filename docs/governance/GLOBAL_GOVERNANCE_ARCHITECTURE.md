# Global Governance Architecture — Consolidation Phase 1

Status: CRITICAL governance change / non-destructive migration.

## Purpose

This document defines the canonical logical architecture for global governance without removing or weakening any existing control. Existing workflows and contracts remain authoritative during Phase 1.

## Universal change protocol

Every significant change follows this sequence:

1. REAL STATE — establish the current verified state.
2. RESEARCH — gather external or uncertain information only when it can materially affect the decision.
3. COMPARISON — compare current state, target state, alternatives and evidence.
4. RISK — identify regressions, security, compliance, data and rollback risks.
5. DECISION — record the bounded decision and its authority.
6. EXECUTION — apply only the authorized bounded change.
7. VERIFICATION — test and measure the resulting real state.
8. MEMORY — preserve evidence, provenance, decision history and rollback information.

Research is conditional, not ceremonial: deterministic changes whose relevant facts are already verified do not require artificial external research.

## Six canonical responsibilities

### KNOWLEDGE
Owns libraries, Veilleurs, ingestion, sorting/quarantine, source quality and knowledge provenance. Knowledge may propose evidence and candidates; it does not directly write the Core or production targets.

### CORE
Owns comparison, contradiction, risk analysis, target interpretation and bounded decision formation. It consumes evidence from Knowledge and produces an explicit decision; it does not silently execute it.

### GUARDIAN
Owns authority boundaries, security/compliance gates, human-approval requirements and fail-closed policy. Authority rules must progressively converge here rather than being independently redefined by downstream components.

### EXECUTION
Owns bounded implementation in GitHub, Godot, infrastructure and other targets. Execution applies an authorized decision and must not enlarge its own scope or authority.

### VERIFICATION
Owns CI, tests, measurements, regression analysis and closure conditions. Verification determines whether the resulting state satisfies the decision and required controls; it does not rewrite the target to make a failure disappear.

### MEMORY
Owns receipts, evidence ledger, provenance checkpoints, transparency records, Remanence and durable change history. Memory records what actually happened, including failures and rollback.

## Risk classes

### NORMAL
Reversible, low-impact change with no sensitive data, security boundary, production authority or governance modification. Targeted tests are sufficient when the affected surface is bounded and verified.

### SENSITIVE
Architecture, dependency, persistent-data, cross-domain or material behavior change. Requires explicit comparison and risk analysis, Guardian validation appropriate to the affected boundary, and expanded verification.

### CRITICAL
Security, secrets, production, destructive operations, identity/authorization, governance itself, or any change capable of weakening the controls that authorize other changes. Requires fail-closed behavior, explicit evidence, rollback preparation, full applicable verification and human approval where an existing authority boundary requires it.

Governance changes are CRITICAL by default.

## Canonical Change Record

Every significant governed change must be traceable through one logical record containing, directly or by immutable references:

- change_id
- project/domain
- risk_class
- initial_real_state
- objective
- research_or_reason_not_required
- sources_and_provenance
- alternatives_and_comparison
- identified_risks
- Core decision
- Guardian authorization state
- bounded execution scope
- applied change / commit references
- verification and measurements
- result
- evidence / receipts
- rollback plan and, if used, rollback evidence
- final_real_state
- closure state

A Change Record is a traceability envelope, not a new independent authority layer.

## Current-component ownership map

Phase 1 changes ownership semantics only; it does not delete existing controls.

- Knowledge Governance, Library Trieur, Veilleurs, ingestion and source-quality mechanisms → KNOWLEDGE (with verification tasks delegated conceptually to VERIFICATION).
- Comparison, target evaluation, design-decision candidates and goalpost analysis → CORE.
- Guardian Change Gate and authority/security/compliance invariants → GUARDIAN.
- Bounded Implementation and target-specific application mechanisms → EXECUTION.
- CI, Developer Autotest, Developer Regression Analysis, measurement and Application Closure → VERIFICATION.
- Evidence Ledger, provenance checkpoints, transparency records, measurement history and Remanence → MEMORY.
- Application Decision Gate currently spans GUARDIAN and EXECUTION and is a future consolidation candidate; it remains active in Phase 1.

## Migration invariants

1. No existing gate is removed or disabled in Phase 1.
2. No existing authority boundary is weakened.
3. `automatic_merge_allowed`, automatic target changes and automatic code/application authority remain governed by existing fail-closed contracts until an equivalent centralized Guardian rule is implemented and proven.
4. A legacy protection may be removed only after its replacement exists, has an equivalence test, passes applicable CI, and preserves rollback/evidence requirements.
5. Global governance and domain governance remain separated: universal authority/security/evidence rules are global; LITD gameplay/Godot/lore/UX rules remain LITD-domain concerns; business/client/RGPD/billing rules remain business-domain concerns.
6. Projects may share the governance engine but must not share project secrets, client data or domain-specific authority merely because they share that engine.
7. Governance governs itself: changes to this architecture pass the same protocol and are CRITICAL by default.
8. A new governance layer may be introduced only when it removes more risk or complexity than it creates.

## Phase sequence

Phase 1: document canonical responsibilities, risk classes and Change Record; preserve all existing controls.

Phase 2: centralize duplicated authority invariants into Guardian with explicit equivalence tests while legacy checks remain active.

Phase 3: switch consumers to the centralized authority contract and verify real CI behavior.

Phase 4: retire only proven-redundant legacy authority definitions, one bounded change at a time.

Phase 5: apply the consolidated global governance engine to additional projects/infrastructure while keeping their domain data and rules isolated.
