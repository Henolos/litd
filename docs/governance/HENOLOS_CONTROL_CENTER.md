# HENOLOS Control Center

## Purpose

The HENOLOS Control Center is a read-only operational view over the consolidated governance engine.

It observes real execution, verification, and evidence state without becoming an authority layer.

## Phase 1 — read-only foundation

The first implementation MUST:

- read real GitHub / CI state rather than manually maintained decorative status;
- expose Change Record progress and the evidence that supports it;
- remain read-only;
- never merge pull requests;
- never write to Core;
- never widen Guardian authority;
- never change execution targets;
- never provision or mutate external infrastructure;
- preserve domain isolation between LITD, HENOLOS BUSINESS, and HENOLOS INFRASTRUCTURE.

## Canonical pipeline

```
KNOWLEDGE -> CORE -> GUARDIAN -> EXECUTION -> VERIFICATION -> MEMORY
                                      |
                                      v
                           HENOLOS CONTROL CENTER
                              (observation only)
```

The Control Center consumes state from the pipeline. It is not inserted into the authority chain.

## Minimum operational model

Each tracked change should expose, when available:

| Field | Meaning |
| --- | --- |
| Project | Governed project/domain |
| Change Record | Canonical change identifier |
| Phase | Current governance phase |
| Current action | Concrete action being executed or awaited |
| Status | Derived operational state |
| PR | Pull request reference |
| Head SHA | Exact revision being verified |
| Checks | Passed/total checks and relevant failures |
| Last evidence | Latest retained proof/reference |
| Blocker | Concrete blocker, if any |
| Needs human? | Whether a genuine decision is required |
| Updated at | Timestamp of latest source state |

## Derived statuses

The UI uses these operational states:

- `RUNNING` — execution is actively progressing.
- `WAITING_CI` — execution is waiting for required verification.
- `BLOCKED_DECISION` — a genuine human decision is required.
- `COMPLETED` — the governed objective is closed with required evidence.
- `FAILED_RETRYING` — a recoverable technical failure is being handled within the existing mandate.

These statuses must be derived from authoritative source state wherever possible. They must not be manually edited to make work appear active or complete.

## Security and authority boundary

This surface is deliberately observational.

Any future write/action capability requires a separate governed change, explicit Guardian authorization, risk classification, tests, rollback evidence, and preservation of existing human-approval boundaries.

No secret values, credentials, raw client payloads, or unnecessary personal data may be displayed or persisted by the Control Center.

## Operational evidence views

The Control Center may expose bounded workflow evidence for domain and overlay views when the source is real GitHub Actions metadata.

These indicators MUST describe the latest observed workflow evidence, not claim overall domain health. Allowed evidence states are:

- `PASS` — latest matching run completed successfully;
- `FAIL` — latest matching run completed without success;
- `RUNNING` — latest matching run has not completed;
- `NO_EVIDENCE` — no matching run was found in the bounded query window.

The indicator layer remains observation-only. It MUST NOT ingest workflow secrets, raw artifacts, client payloads or personal data merely to improve status detail. Workflow name, run identifier, event, branch/SHA and timestamps are sufficient for this tranche.

The five views remain isolated:

- `LITD`: game/playtest/maturity execution evidence;
- `HENOLOS_BUSINESS`: business-governance validation evidence only, not production/client health;
- `HENOLOS_INFRASTRUCTURE`: infrastructure-governance validation evidence only, not external service health;
- `SECURITY_COMPLIANCE`: Guardian/repository-governance evidence;
- `VEILLEURS_KNOWLEDGE`: Veilleur discovery workflow evidence, under LITD authority.

External business or infrastructure health requires separately authorized read-only adapters to the relevant services and must not be inferred from repository CI.


## External service observation contract

External service state is a separate evidence class from repository workflow evidence. It MUST NOT be inferred from CI success.

Allowed external states are `ACTIVE_HEALTHY`, `ADVISORY`, `DEGRADED`, `UNHEALTHY`, `VISIBILITY_UNAVAILABLE`, and `NOT_CONFIGURED`.

`VISIBILITY_UNAVAILABLE` is fail-closed evidence: it means the configured observer cannot currently prove service state. It MUST NOT be promoted to success.

External observations are restricted to non-secret operational metadata such as service identifier, region, project reference, advisory counts, observation time and platform-reported state. They MUST NOT contain credentials, secret values, raw logs, client payloads, or unnecessary personal data.

The normalization/rendering contract grants no collection authority. Persistent Supabase, Hetzner, backup, identity, or secrets-manager collection requires a separately configured least-privilege read-only identity and source adapter.
