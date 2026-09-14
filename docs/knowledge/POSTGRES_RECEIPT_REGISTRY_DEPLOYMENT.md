# PostgreSQL receipt registry deployment

The production governance path uses `PostgresReceiptConsumptionRegistry` through
`open_governance_registry()`. It fails closed when
`LITD_GOVERNANCE_DATABASE_URL` is absent and never falls back to SQLite.

## Deployment gate

1. Apply both timestamped migrations to the dedicated Supabase PostgreSQL project.
2. Store the direct PostgreSQL connection string in the approved secret manager;
   never commit it or expose it to client-side code.
3. Require TLS (`sslmode=require`, `verify-ca`, or `verify-full`) for every remote
   connection.
4. Run the PostgreSQL Registry workflow contract, then execute the same integration
   tests against staging Supabase with synthetic receipt hashes.
5. Preserve the workflow run, migration identifiers, database region, test output,
   and audit-chain verdict as deployment evidence.

The GitHub service-container run proves PostgreSQL semantics and concurrent atomicity.
It is not evidence that the Supabase staging resource has been provisioned. PR #366
must remain draft until the real staging execution succeeds and its evidence is retained.

## Staging evidence — 2026-09-14

A real Supabase staging project was provisioned with synthetic data only:

- project ref: `bddnsfyxubupxwzadmyt`
- region: Frankfurt, `eu-central-1`
- PostgreSQL: standard
- plan: Free
- Data API: disabled
- automatic RLS: enabled
- migrations applied:
  - `20260912162000_governance_receipt_registry.sql` (blob `9eee0fe005bd81e29fc89205376ffca7b46182f9`)
  - `20260913093000_governance_receipt_registry_runtime.sql` (blob `a159f33b963f613c14aafc562047a658af104d02`)

Functional staging proof:

- valid first consumption: accepted
- replay: rejected with `replay_detected`
- wrong consumer: rejected with `unexpected_consumer`
- correct consumer after the wrong-consumer attempt: accepted
- revoked receipt: rejected with `receipt_revoked`
- accepted consumptions: 2
- audit entries: 5
- audit chain: valid

Database protections were also verified:

- four append-only protection triggers are installed
- `anon` and `authenticated` cannot execute the registry functions
- `service_role` can execute them
- RLS is enabled on all four registry tables
- SSL enforcement is enabled for incoming database connections

The atomic concurrency proof scheduled eight distinct consumers against one synthetic
receipt. The first wave produced exactly 8 calls: 1 accepted, 7 rejected with
`replay_detected`, 8 distinct actors, and a valid audit chain. The scheduler emitted a
second wave before cleanup; the aggregate remained 1 acceptance and 15 replay
rejections. All temporary cron jobs were removed (`remaining_cron_jobs = 0`).

The database password is retained in the Infisical EU Staging environment under the
current key `litd`; no secret value is recorded here. The final connection-string key
and runtime wiring still need to be standardized before deployment.

This staging proof validates PostgreSQL behavior but does not close the production
deployment gate. The Free staging plan does not provide production-grade backup/PITR
evidence. Network restrictions remain open until the fixed outbound IP of the Hetzner
worker is provisioned; restricting access earlier would block the required runtime.
