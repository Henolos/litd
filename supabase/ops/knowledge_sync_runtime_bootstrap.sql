-- Environment bootstrap for the SQLite -> Supabase knowledge shadow-sync runtime.
-- The runtime role is deliberately kept NOLOGIN here.
-- Credential activation is a separate secret-management step and must never be committed.

do $$
begin
  if not exists (select 1 from pg_roles where rolname = 'knowledge_sync') then
    raise exception 'knowledge_sync parent role missing; apply the knowledge shadow-sync migration first';
  end if;

  if not exists (select 1 from pg_roles where rolname = 'knowledge_sync_runtime') then
    create role knowledge_sync_runtime nologin;
  end if;
end
$$;

-- Reassert the complete security posture on every run so bootstrap is drift-correcting,
-- not only safe on first creation.
alter role knowledge_sync_runtime
  nologin
  inherit
  nosuperuser
  nocreatedb
  nocreaterole
  noreplication
  nobypassrls
  connection limit 3;

grant knowledge_sync to knowledge_sync_runtime;

alter role knowledge_sync_runtime set statement_timeout = '60s';
alter role knowledge_sync_runtime set idle_in_transaction_session_timeout = '60s';
alter role knowledge_sync_runtime set search_path = pg_catalog, knowledge;
