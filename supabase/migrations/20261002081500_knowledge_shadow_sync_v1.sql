-- Shadow-sync support for SQLite -> Supabase knowledge replication.

alter table knowledge.evidence_registry
  add column if not exists project_id text,
  add column if not exists target_route text,
  add column if not exists origin_store text not null default 'native';

alter table knowledge.evidence_decisions
  add column if not exists decision text,
  add column if not exists decision_dimension text not null default 'ingest',
  add column if not exists project_id text,
  add column if not exists target_route text,
  add column if not exists origin_store text not null default 'native',
  add column if not exists origin_sequence bigint;

update knowledge.evidence_decisions
set decision = ingest_status
where decision is null;

alter table knowledge.evidence_decisions
  alter column decision set not null,
  alter column ingest_status drop not null;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'evidence_decisions_dimension_check'
      and conrelid = 'knowledge.evidence_decisions'::regclass
  ) then
    alter table knowledge.evidence_decisions
      add constraint evidence_decisions_dimension_check
      check (decision_dimension in ('ingest','routing','other'));
  end if;
end
$$;

create unique index if not exists evidence_decisions_sqlite_sequence_uq
  on knowledge.evidence_decisions(space_id, origin_store, origin_sequence)
  where origin_store = 'sqlite' and origin_sequence is not null;

alter table knowledge.provenance_nodes
  add column if not exists origin_store text not null default 'native';

do $$
begin
  if not exists (select 1 from pg_roles where rolname = 'knowledge_sync') then
    create role knowledge_sync nologin inherit nosuperuser nocreatedb nocreaterole noreplication nobypassrls;
  end if;
end
$$;

grant usage on schema knowledge to knowledge_sync;
grant select on knowledge.knowledge_spaces to knowledge_sync;
grant select, insert on
  knowledge.sources,
  knowledge.evidence_registry,
  knowledge.evidence_decisions,
  knowledge.provenance_nodes
to knowledge_sync;

drop policy if exists knowledge_sync_spaces_read on knowledge.knowledge_spaces;
create policy knowledge_sync_spaces_read
on knowledge.knowledge_spaces for select to knowledge_sync
using (slug = 'litd');

drop policy if exists knowledge_sync_sources_read on knowledge.sources;
create policy knowledge_sync_sources_read
on knowledge.sources for select to knowledge_sync
using (
  space_id in (
    select id from knowledge.knowledge_spaces where slug = 'litd'
  )
);

drop policy if exists knowledge_sync_sources_insert on knowledge.sources;
create policy knowledge_sync_sources_insert
on knowledge.sources for insert to knowledge_sync
with check (
  space_id in (
    select id from knowledge.knowledge_spaces where slug = 'litd'
  )
);

drop policy if exists knowledge_sync_evidence_read on knowledge.evidence_registry;
create policy knowledge_sync_evidence_read
on knowledge.evidence_registry for select to knowledge_sync
using (
  space_id in (
    select id from knowledge.knowledge_spaces where slug = 'litd'
  )
);

drop policy if exists knowledge_sync_evidence_insert on knowledge.evidence_registry;
create policy knowledge_sync_evidence_insert
on knowledge.evidence_registry for insert to knowledge_sync
with check (
  space_id in (
    select id from knowledge.knowledge_spaces where slug = 'litd'
  )
);

drop policy if exists knowledge_sync_decisions_read on knowledge.evidence_decisions;
create policy knowledge_sync_decisions_read
on knowledge.evidence_decisions for select to knowledge_sync
using (
  space_id in (
    select id from knowledge.knowledge_spaces where slug = 'litd'
  )
);

drop policy if exists knowledge_sync_decisions_insert on knowledge.evidence_decisions;
create policy knowledge_sync_decisions_insert
on knowledge.evidence_decisions for insert to knowledge_sync
with check (
  space_id in (
    select id from knowledge.knowledge_spaces where slug = 'litd'
  )
);

drop policy if exists knowledge_sync_provenance_read on knowledge.provenance_nodes;
create policy knowledge_sync_provenance_read
on knowledge.provenance_nodes for select to knowledge_sync
using (
  space_id in (
    select id from knowledge.knowledge_spaces where slug = 'litd'
  )
);

drop policy if exists knowledge_sync_provenance_insert on knowledge.provenance_nodes;
create policy knowledge_sync_provenance_insert
on knowledge.provenance_nodes for insert to knowledge_sync
with check (
  space_id in (
    select id from knowledge.knowledge_spaces where slug = 'litd'
  )
);

grant execute on function knowledge.enforce_provenance_parent() to knowledge_sync;
