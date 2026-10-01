# Supabase persistence v1 — Knowledge

## Scope

This migration materializes the canonical knowledge contracts in PostgreSQL/Supabase without replacing the current SQLite ingress/provenance implementation yet.

It creates a private-by-default `knowledge` schema with:

- strict `knowledge_space` isolation;
- root spaces `henolos` and `litd`;
- future client spaces requiring a `tenant_id`;
- RLS membership roles `reader`, `editor`, `admin`;
- concepts and concept relations;
- knowledge items, typed relations, concepts and immutable versions;
- source/evidence registry plus append-only ingress decisions;
- provenance nodes linked to registered evidence within the same space;
- immutable audit/history tables;
- no anonymous access.

## Security model

The schema is not intended to be exposed automatically through the Data API. `anon` receives no schema/table access. `authenticated` access is always combined with RLS membership predicates. `service_role` remains reserved for trusted backend operations.

Identity is represented by `principal_id`. The current RLS helper derives it from `auth.uid()`, allowing later integration through a Supabase custom OIDC provider (for example authentik) without putting authorization data in user-editable metadata.

## State model

The database keeps the three state dimensions distinct:

- ingestion: `accepted | rejected | quarantined | duplicate`
- validation: `candidate | experimenting | proven | rejected`
- lifecycle: `active | experimental | revalidate | superseded | obsolete | rejected | archived`

## Validation evidence

The migration was applied on the `henolos-promotion-dry-run` Supabase project in Frankfurt before being committed.

Verified on the dry-run project:

- all knowledge tables have RLS enabled;
- Security Advisor reported no knowledge-schema RLS-without-policy finding;
- a synthetic LITD editor saw only the LITD space and LITD item;
- a write in the LITD space succeeded;
- a direct write into the Henolos space was blocked;
- all synthetic test rows were removed afterwards.

Production remains unchanged.
