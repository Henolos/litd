-- Catalog proof for the environment-specific knowledge sync runtime role.
-- This proof is intentionally executable before secret activation.

do $$
declare
  can_login boolean;
  is_super boolean;
  can_create_db boolean;
  can_create_role boolean;
  can_replicate boolean;
  can_bypass_rls boolean;
  inherits boolean;
  conn_limit integer;
  is_member boolean;
  role_config text[];
begin
  select
    rolcanlogin,
    rolsuper,
    rolcreatedb,
    rolcreaterole,
    rolreplication,
    rolbypassrls,
    rolinherit,
    rolconnlimit,
    rolconfig
  into
    can_login,
    is_super,
    can_create_db,
    can_create_role,
    can_replicate,
    can_bypass_rls,
    inherits,
    conn_limit,
    role_config
  from pg_roles
  where rolname = 'knowledge_sync_runtime';

  if can_login is null then
    raise exception 'knowledge_sync_runtime role missing';
  end if;
  if can_login then
    raise exception 'knowledge_sync_runtime must remain NOLOGIN until secret activation';
  end if;
  if is_super or can_create_db or can_create_role or can_replicate or can_bypass_rls then
    raise exception 'knowledge_sync_runtime has excessive privileges';
  end if;
  if not inherits then
    raise exception 'knowledge_sync_runtime must inherit granted role privileges';
  end if;
  if conn_limit <> 3 then
    raise exception 'knowledge_sync_runtime connection limit must be 3';
  end if;

  select pg_has_role('knowledge_sync_runtime', 'knowledge_sync', 'member')
    into is_member;
  if not is_member then
    raise exception 'knowledge_sync_runtime must inherit knowledge_sync';
  end if;

  if not ('statement_timeout=60s' = any(coalesce(role_config, array[]::text[]))) then
    raise exception 'knowledge_sync_runtime statement_timeout drifted';
  end if;
  if not ('idle_in_transaction_session_timeout=60s' = any(coalesce(role_config, array[]::text[]))) then
    raise exception 'knowledge_sync_runtime idle transaction timeout drifted';
  end if;
  if not ('search_path=pg_catalog,knowledge' = any(coalesce(role_config, array[]::text[]))) then
    raise exception 'knowledge_sync_runtime search_path drifted';
  end if;
end
$$;
