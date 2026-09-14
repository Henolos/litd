# PostgreSQL receipt registry adapter

## Purpose

This adapter connects the existing single-use governance transition wrappers to the durable Supabase/PostgreSQL registry contract already defined in `supabase/migrations/20260912162000_governance_receipt_registry.sql`.

## Authority boundary

The adapter has no authority to:

- write a project Core;
- merge a pull request;
- apply a governed change;
- mutate Guardian rules or routing targets;
- read or manage secrets;
- bypass local project vetoes.

It only invokes the three existing private governance RPCs:

- `governance_private.register_receipt`;
- `governance_private.invalidate_receipt`;
- `governance_private.consume_receipt`.

## Deployment status

Repository integration is not production proof. P0 #331 remains open until the migration is applied to the real Supabase/PostgreSQL governance registry and replay/concurrency/stale/cross-project behavior is measured there with retained evidence.

P0 #333 also remains open until the shared registry is exercised with at least two distinct project scopes (LITD and COMPANY) and negative cross-project tests prove that a valid receipt cannot be consumed outside its authorized project and route.
