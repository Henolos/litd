# Support request — draft, NOT SENT

Subject: Actions runs #7 and #8 stuck queued with zero jobs in Henolos/litd

Repository: https://github.com/Henolos/litd
Workflow: .github/workflows/tactical-hit-parity.yml

Two manually dispatched runs on main remain Queued with zero jobs:
- https://github.com/Henolos/litd/actions/runs/43095219494
- https://github.com/Henolos/litd/actions/runs/43095233129

Both were created around November 11, 2026 20:18 UTC. On November 12 the jobs API still returns empty arrays. Normal UI cancellation of #8 reports “Failed to cancel workflow”. Force cancellation has not been attempted because it is not exposed in the available integration/UI.

The workflow uses GitHub-hosted ubuntu-latest with no concurrency group or environment approval. A new dispatch on main at the same commit (14f214278b26628e8e9b6d8bdc5b79227d169d02) succeeded: https://github.com/Henolos/litd/actions/runs/43211774629. All steps completed and TACTICAL_HIT_PARITY_OK cases=625 is present. No repository protections were changed.

Please investigate and clear the abnormal queued states of #7 and #8, preserving successful runs and protections. The internal cause is unknown; no runner capacity or concurrency issue has been established.

Submission blocked: the available support form has no Actions category; the Repositories form requires an unrelated feature type. No ticket submitted, no public community post made.
