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

## Next implementation slice

Build a machine-readable read-only snapshot generator that maps GitHub pull-request/check state and governance evidence into the minimum operational model above. Validate the mapping with deterministic tests before adding a web UI.
