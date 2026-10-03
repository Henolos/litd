-- Environment bootstrap for the SQLite -> Supabase knowledge shadow-sync runtime.
-- Intentionally creates the runtime role as NOLOGIN.
-- Credential activation is a separate secret-management step and must not be committed.

do $$
begin
  if not exists (select 1 from pg_roles where rolname = 'knowledge_sync_runtime') then
    create role knowledge_sync_runtime
      nologin
      inherit
      nosuperuser
      nocreatedb
      nocreaterole
      noreplication
      nobypassrls
      connection limit 3;
  end if;
end
$$;

grant knowledge_sync to knowledge_sync_runtime;

alter role knowledge_sync_runtime
  set statement_timeout = '60s';

alter role knowledge_sync_runtime
  set idle_in_transaction_session_timeout = '60s';

alter role knowledge_sync_runtime
  set search_path = 'pg_catalog,knowledge';
