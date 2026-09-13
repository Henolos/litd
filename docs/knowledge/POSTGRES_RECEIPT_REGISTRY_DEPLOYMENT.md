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

