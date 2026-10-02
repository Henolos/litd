-- Catalog-level validation for the least-privilege shadow-sync role.
-- Does not require SET ROLE and is safe to run from the Supabase SQL/MCP session.

do $$
declare
  can_login boolean;
  bypass_rls boolean;
  policy_count integer;
begin
  select rolcanlogin, rolbypassrls
    into can_login, bypass_rls
  from pg_roles
  where rolname = 'knowledge_sync';

  if can_login is null then
    raise exception 'knowledge_sync role missing';
  end if;
  if can_login then
    raise exception 'knowledge_sync must remain NOLOGIN';
  end if;
  if bypass_rls then
    raise exception 'knowledge_sync must not BYPASSRLS';
  end if;

  if not has_schema_privilege('knowledge_sync', 'knowledge', 'USAGE') then
    raise exception 'knowledge_sync missing schema USAGE';
  end if;

  if not has_table_privilege('knowledge_sync', 'knowledge.knowledge_spaces', 'SELECT') then
    raise exception 'knowledge_sync missing spaces SELECT';
  end if;

  if not has_table_privilege('knowledge_sync', 'knowledge.sources', 'SELECT,INSERT') then
    raise exception 'knowledge_sync missing sources SELECT/INSERT';
  end if;
  if has_table_privilege('knowledge_sync', 'knowledge.sources', 'UPDATE')
     or has_table_privilege('knowledge_sync', 'knowledge.sources', 'DELETE') then
    raise exception 'knowledge_sync has excessive sources privileges';
  end if;

  if not has_table_privilege('knowledge_sync', 'knowledge.evidence_registry', 'SELECT,INSERT') then
    raise exception 'knowledge_sync missing evidence SELECT/INSERT';
  end if;
  if not has_table_privilege('knowledge_sync', 'knowledge.evidence_decisions', 'SELECT,INSERT') then
    raise exception 'knowledge_sync missing decision SELECT/INSERT';
  end if;
  if not has_table_privilege('knowledge_sync', 'knowledge.provenance_nodes', 'SELECT,INSERT') then
    raise exception 'knowledge_sync missing provenance SELECT/INSERT';
  end if;

  select count(*)
    into policy_count
  from pg_policies
  where schemaname = 'knowledge'
    and policyname like 'knowledge_sync_%'
    and 'knowledge_sync' = any(roles);

  if policy_count <> 9 then
    raise exception 'expected 9 knowledge_sync policies, got %', policy_count;
  end if;
end
$$;
