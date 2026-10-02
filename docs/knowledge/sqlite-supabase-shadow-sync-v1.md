# SQLite → Supabase shadow sync v1

## Goal

Move the existing LITD Evidence Ledger and Provenance Chain toward Supabase
without losing or rewriting the SQLite history that already exists.

This is deliberately **not** a big-bang migration.

## Authority model

During this phase:

1. SQLite remains the canonical write authority.
2. Every new SQLite evidence/provenance write creates a replication outbox
   event in the same SQLite transaction.
3. Supabase is a shadow copy.
4. A failed remote write leaves the outbox event pending.
5. Re-running synchronization is idempotent.
6. Cutover is forbidden while any event is pending or parity differs.

The outbox is not a second governance authority. It is only a durable delivery
mechanism.

## Existing history

Opening an older SQLite database creates the outbox table without touching its
historical rows.

The explicit backfill operation scans the existing:

- evidence registry;
- decision ledger;
- provenance nodes;

and creates idempotent outbox events. It does **not** update or delete those
canonical rows.

No historical SQLite database file is stored in the Git repository, so the
actual historical backfill must run where the live SQLite files reside.

## Remote connection

The sync process is designed for the persistent Henolos backend.

Preferred connection:

- Supabase direct PostgreSQL connection when the Hetzner host has compatible
  IPv6 connectivity;
- Supavisor session-mode connection if the host is IPv4-only.

The private knowledge schema does not need to be exposed through the Supabase
Data API for this worker.

The runtime connection string is read from the environment variable
HENOLOS_KNOWLEDGE_DB_URL. It must be delivered by the secrets system and must
never be committed to Git or printed by the sync CLI.

TLS is mandatory. HENOLOS_KNOWLEDGE_SSLMODE defaults to require and can be
raised to a certificate-verifying mode when the Supabase root certificate is
installed on the host.

## Least-privilege role

The migration creates a group role:

- knowledge_sync;
- NOLOGIN;
- no superuser privileges;
- no BYPASSRLS;
- SELECT/INSERT only on the LITD synchronization tables;
- RLS policies restricted to the litd knowledge space.

The deployment login and its password are intentionally not created in Git.
A dedicated LOGIN role will be provisioned separately, receive only membership
in knowledge_sync, and have its credential stored in Infisical.

## Synchronization order

The worker always drains the Evidence Ledger outbox before the Provenance
outbox. This guarantees that registered evidence is present remotely before a
provenance SOURCE node that references it is attempted.

A remote error stops that outbox at the failing event. Later events are not
silently skipped.

## Conflict behavior

Remote writes are idempotent.

If the same stable key already exists with the same canonical content, replay
succeeds.

If the same stable key exists with different canonical content, synchronization
fails closed with a conflict instead of overwriting history.

## Parity gate

After all outboxes are empty, the worker compares SQLite and Supabase using:

- evidence count + digest of evidence_id/canonical_hash;
- decision count + digest of sequence/entry_hash;
- provenance count + digest of node_id/payload_hash.

A cutover requires exact parity.

## CLI

Dry-run / prepare old history:

    python tools/quality/sync_sqlite_knowledge.py \
      --ledger-db <ledger.sqlite3> \
      --provenance-db <provenance.sqlite3> \
      --backfill \
      --dry-run

Real shadow sync:

    python tools/quality/sync_sqlite_knowledge.py \
      --ledger-db <ledger.sqlite3> \
      --provenance-db <provenance.sqlite3> \
      --backfill

The CLI returns non-zero if synchronization fails, the maximum batch count is
reached, or parity does not match.

## Cutover gate

Supabase must not become authoritative until all of the following are true:

- local Ledger chain verification passes;
- local Provenance integrity verification passes;
- both outboxes contain zero pending events;
- SQLite/Supabase parity matches;
- the dedicated knowledge-sync login has been tested from Hetzner over TLS;
- backup/restore evidence exists for the Supabase knowledge schema;
- rollback to the preserved SQLite snapshot has been rehearsed.

Until then the state is SHADOW, not CUTOVER.
