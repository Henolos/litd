# Durable governance receipt registry — PostgreSQL/Supabase

Status: P0 implementation step for #331. This document does **not** mark #331 closed.

## Purpose

The SQLite registry merged in #341 is the executable contract prototype. The durable target is PostgreSQL/Supabase with the same fail-closed semantics and with cross-process concurrency handled inside the database transaction.

## Durable invariants

- receipts are immutable and uniquely identified by lowercase SHA-256 hashes;
- project identity and target route are persisted with every registered receipt;
- expected consumer and critical-context hash are bound at registration time;
- receipt consumption is atomic and single-use;
- identical or concurrent replays are rejected;
- stale context, wrong consumer, wrong project, wrong route, revocation and supersession are rejected;
- accepted and rejected attempts are written to an append-only hash-chained audit log;
- audit-chain insertion is globally serialized to prevent forks under concurrent writes;
- tables are not exposed directly to `anon` or `authenticated` clients;
- mutations are performed only through restricted server-side database functions;
- privileged functions pin `search_path=''` and schema-qualify referenced objects;
- no Core write, merge, application, rollback or target-mutation authority is granted by this registry.

## Migration

Canonical migration:

`supabase/migrations/20260912162000_governance_receipt_registry.sql`

It creates the private schema `governance_private`, four append-only tables, restricted registration/invalidation/consumption functions, per-receipt transaction serialization, and serialized audit-chain insertion.

## Security boundary

The migration revokes direct table access from `public`, `anon`, `authenticated`, and `service_role`, then grants only schema usage plus explicit function execution to `service_role`. The service role must remain server-side. No browser/client key may invoke or mutate the registry.

The schema is intentionally outside the exposed `public` schema. Row-level security is enabled as defense in depth, but the primary interface is the restricted function surface rather than direct table CRUD.

## Real staging verification — 2026-09-24

Project: `litd-governance-staging` (Supabase, `eu-central-1`).

The four registry tables, restricted functions, append-only triggers and RLS are present in `governance_private`. `anon` and `authenticated` have no schema usage, direct table access or function execution. `service_role` has function execution without direct table access. Existing audit evidence shows rejections for stale context, revoked and superseded receipts, wrong project, wrong route and wrong consumer.

The overlapping-session concurrency test used receipt `codex-cron-race-1790230485827`. Four temporary `pg_cron` jobs (IDs 21–24) started between 06:18:00.063598 and 06:18:00.068121 UTC. Their execution windows overlapped for about two seconds. All four jobs succeeded, and the registry recorded **one `ACCEPTED / consumed_once` and three `REJECTED / replay_detected`** from four distinct actors, with exactly one consumption row. The four audit entries were recorded between 06:18:02.069992 and 06:18:02.072850 UTC. The audit verifier returned `valid=true`, `entry_count=105`, tip hash `1dd8703546cea15090bef3f50a14dcce7909ef4496ae8498428087f3a0ac5100`. All temporary jobs were unscheduled; the follow-up count was zero.

Jobs 17–20 from the first scheduling attempt failed before invoking the registry because of incorrectly quoted SQL and were removed. Earlier parallel connector calls yielded one acceptance and three replay rejections, but server timestamps showed that the connector serialized them. Only the four successful `pg_cron` jobs establish overlapping sessions.

The deployed objects exist, but canonical migration version `20260912162000` is absent from `supabase_migrations.schema_migrations`. Full schema equivalence must be checked before repairing migration history.

## What remains before #331 can close

1. Compare the complete deployed schema and privileges with the canonical migration, then repair the missing version in migration history using the official Supabase CLI workflow.
2. Propagate single-use consumption through every remaining authority-bearing transition after Guardian.
3. Bind the durable audit hash into downstream receipts and provenance evidence.
4. Preserve the staging evidence and verify recovery/backup behavior.
5. Verify equivalent project isolation for COMPANY and future projects in the shared registry.

The staging deployment and adversarial database tests establish the registry's behavior. They do not yet establish end-to-end enforcement or production readiness.
