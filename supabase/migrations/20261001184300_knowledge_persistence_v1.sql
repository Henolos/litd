-- Knowledge persistence v1
-- Canonical persistence model for Henolos/LITD knowledge spaces.
-- Designed to be private-by-default, RLS-enforced, and compatible with Supabase Auth / custom OIDC.

create schema if not exists knowledge;

revoke all on schema knowledge from public, anon;
grant usage on schema knowledge to authenticated, service_role;

create table knowledge.knowledge_spaces (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  space_type text not null check (space_type in ('internal','project','client')),
  tenant_id uuid,
  created_at timestamptz not null default now(),
  check (
    (space_type = 'client' and tenant_id is not null)
    or
    (space_type in ('internal','project') and tenant_id is null)
  )
);

create table knowledge.space_memberships (
  space_id uuid not null references knowledge.knowledge_spaces(id) on delete cascade,
  principal_id uuid not null,
  role text not null check (role in ('reader','editor','admin')),
  active boolean not null default true,
  created_at timestamptz not null default now(),
  primary key (space_id, principal_id)
);

create index knowledge_memberships_principal_idx
  on knowledge.space_memberships(principal_id, space_id, role)
  where active;

create table knowledge.sources (
  id uuid primary key default gen_random_uuid(),
  space_id uuid not null references knowledge.knowledge_spaces(id) on delete cascade,
  source_uri text not null,
  title text,
  author text,
  publisher text,
  published_at timestamptz,
  retrieved_at timestamptz not null default now(),
  language text,
  rights text,
  license text,
  content_hash text,
  unique (space_id, source_uri),
  unique (space_id, id)
);

create index knowledge_sources_space_idx on knowledge.sources(space_id);

create table knowledge.evidence_registry (
  id uuid primary key default gen_random_uuid(),
  space_id uuid not null,
  evidence_id text not null,
  canonical_hash text not null,
  source_id uuid not null,
  first_seen_at timestamptz not null default now(),
  unique (space_id, evidence_id),
  unique (space_id, canonical_hash),
  unique (space_id, id),
  foreign key (space_id) references knowledge.knowledge_spaces(id) on delete cascade,
  foreign key (space_id, source_id) references knowledge.sources(space_id, id) on delete restrict
);

create index knowledge_evidence_space_idx on knowledge.evidence_registry(space_id);

create table knowledge.evidence_decisions (
  id uuid primary key default gen_random_uuid(),
  space_id uuid not null references knowledge.knowledge_spaces(id) on delete cascade,
  evidence_id text not null,
  ingest_status text not null check (ingest_status in ('accepted','rejected','quarantined','duplicate')),
  reason text not null,
  previous_hash text not null,
  entry_hash text not null,
  recorded_at timestamptz not null default now(),
  unique (space_id, entry_hash)
);

create index knowledge_evidence_decisions_space_time_idx
  on knowledge.evidence_decisions(space_id, recorded_at);

create table knowledge.concepts (
  id uuid primary key default gen_random_uuid(),
  space_id uuid not null references knowledge.knowledge_spaces(id) on delete cascade,
  concept_key text not null,
  pref_label text not null,
  definition text,
  lifecycle_state text not null default 'active'
    check (lifecycle_state in ('active','experimental','revalidate','superseded','obsolete','rejected','archived')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (space_id, concept_key),
  unique (space_id, id)
);

create index knowledge_concepts_space_idx on knowledge.concepts(space_id);

create table knowledge.concept_relations (
  space_id uuid not null,
  subject_concept_id uuid not null,
  relation_type text not null check (relation_type in ('broader','narrower','related')),
  object_concept_id uuid not null,
  created_at timestamptz not null default now(),
  primary key (space_id, subject_concept_id, relation_type, object_concept_id),
  foreign key (space_id) references knowledge.knowledge_spaces(id) on delete cascade,
  foreign key (space_id, subject_concept_id) references knowledge.concepts(space_id, id) on delete cascade,
  foreign key (space_id, object_concept_id) references knowledge.concepts(space_id, id) on delete cascade,
  check (subject_concept_id <> object_concept_id)
);

create table knowledge.knowledge_items (
  id uuid primary key default gen_random_uuid(),
  space_id uuid not null references knowledge.knowledge_spaces(id) on delete cascade,
  item_key text not null,
  title text not null,
  body text not null,
  validation_state text not null default 'candidate'
    check (validation_state in ('candidate','experimenting','proven','rejected')),
  lifecycle_state text not null default 'experimental'
    check (lifecycle_state in ('active','experimental','revalidate','superseded','obsolete','rejected','archived')),
  confidence text not null default 'low'
    check (confidence in ('low','medium','high','very_high')),
  superseded_by_id uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (space_id, item_key),
  unique (space_id, id),
  foreign key (space_id, superseded_by_id)
    references knowledge.knowledge_items(space_id, id) on delete restrict,
  check (superseded_by_id is null or superseded_by_id <> id)
);

create index knowledge_items_space_state_idx
  on knowledge.knowledge_items(space_id, lifecycle_state, validation_state);

create table knowledge.knowledge_item_concepts (
  space_id uuid not null,
  knowledge_item_id uuid not null,
  concept_id uuid not null,
  primary key (space_id, knowledge_item_id, concept_id),
  foreign key (space_id) references knowledge.knowledge_spaces(id) on delete cascade,
  foreign key (space_id, knowledge_item_id)
    references knowledge.knowledge_items(space_id, id) on delete cascade,
  foreign key (space_id, concept_id)
    references knowledge.concepts(space_id, id) on delete cascade
);

create table knowledge.knowledge_relations (
  space_id uuid not null,
  subject_item_id uuid not null,
  relation_type text not null check (
    relation_type in (
      'depends_on','influences','contradicts','supersedes','validated_by',
      'tested_by','measured_by','risk_for','source_for','player_impact',
      'derived_from','inspired_by','applies_to','requires','invalidates','example_of'
    )
  ),
  object_item_id uuid not null,
  created_at timestamptz not null default now(),
  primary key (space_id, subject_item_id, relation_type, object_item_id),
  foreign key (space_id) references knowledge.knowledge_spaces(id) on delete cascade,
  foreign key (space_id, subject_item_id)
    references knowledge.knowledge_items(space_id, id) on delete cascade,
  foreign key (space_id, object_item_id)
    references knowledge.knowledge_items(space_id, id) on delete cascade,
  check (subject_item_id <> object_item_id)
);

create table knowledge.knowledge_versions (
  id uuid primary key default gen_random_uuid(),
  space_id uuid not null,
  knowledge_item_id uuid not null,
  version integer not null check (version > 0),
  snapshot jsonb not null,
  recorded_at timestamptz not null default now(),
  unique (space_id, knowledge_item_id, version),
  foreign key (space_id) references knowledge.knowledge_spaces(id) on delete cascade,
  foreign key (space_id, knowledge_item_id)
    references knowledge.knowledge_items(space_id, id) on delete cascade
);

create index knowledge_versions_item_idx
  on knowledge.knowledge_versions(space_id, knowledge_item_id, version desc);

create table knowledge.provenance_nodes (
  space_id uuid not null,
  node_id text not null,
  stage text not null check (
    stage in ('SOURCE','DOCUMENT','DISCOVERY','ROUTING_DECISION','CORE_DECISION','COMMIT','TEST','MEASUREMENT')
  ),
  parent_node_id text,
  evidence_id text,
  external_ref text,
  payload jsonb not null default '{}'::jsonb,
  payload_hash text not null,
  recorded_at timestamptz not null default now(),
  primary key (space_id, node_id),
  foreign key (space_id) references knowledge.knowledge_spaces(id) on delete cascade,
  foreign key (space_id, parent_node_id)
    references knowledge.provenance_nodes(space_id, node_id) on delete restrict,
  foreign key (space_id, evidence_id)
    references knowledge.evidence_registry(space_id, evidence_id) on delete restrict
);

create unique index knowledge_provenance_external_ref_uq
  on knowledge.provenance_nodes(space_id, stage, external_ref)
  where external_ref is not null;

create index knowledge_provenance_evidence_idx
  on knowledge.provenance_nodes(space_id, evidence_id, stage);

create or replace function knowledge.current_principal_id()
returns uuid
language sql
stable
security invoker
set search_path = ''
as $$
  select auth.uid();
$$;

revoke all on function knowledge.current_principal_id() from public, anon;
grant execute on function knowledge.current_principal_id() to authenticated, service_role;

create or replace function knowledge.can_access_space(target_space_id uuid, allowed_roles text[])
returns boolean
language sql
stable
security invoker
set search_path = ''
as $$
  select exists (
    select 1
    from knowledge.space_memberships m
    where m.space_id = target_space_id
      and m.principal_id = (select knowledge.current_principal_id())
      and m.active
      and m.role = any(allowed_roles)
  );
$$;

revoke all on function knowledge.can_access_space(uuid, text[]) from public, anon;
grant execute on function knowledge.can_access_space(uuid, text[]) to authenticated, service_role;

create or replace function knowledge.block_immutable_change()
returns trigger
language plpgsql
security invoker
set search_path = pg_catalog
as $$
begin
  raise exception 'immutable_history';
end;
$$;

revoke all on function knowledge.block_immutable_change() from public, anon, authenticated;

create trigger evidence_registry_immutable
before update or delete on knowledge.evidence_registry
for each row execute function knowledge.block_immutable_change();

create trigger evidence_decisions_immutable
before update or delete on knowledge.evidence_decisions
for each row execute function knowledge.block_immutable_change();

create trigger knowledge_versions_immutable
before update or delete on knowledge.knowledge_versions
for each row execute function knowledge.block_immutable_change();

create trigger provenance_nodes_immutable
before update or delete on knowledge.provenance_nodes
for each row execute function knowledge.block_immutable_change();

create or replace function knowledge.enforce_provenance_parent()
returns trigger
language plpgsql
security invoker
set search_path = pg_catalog
as $$
declare
  parent_stage text;
  parent_evidence text;
  expected_parent text;
begin
  if new.stage = 'SOURCE' then
    if new.parent_node_id is not null then
      raise exception 'source_must_be_root';
    end if;
    return new;
  end if;

  if new.parent_node_id is null then
    raise exception 'missing_parent';
  end if;

  select p.stage, p.evidence_id
    into parent_stage, parent_evidence
  from knowledge.provenance_nodes p
  where p.space_id = new.space_id
    and p.node_id = new.parent_node_id;

  if parent_stage is null then
    raise exception 'missing_parent';
  end if;

  expected_parent := case new.stage
    when 'DOCUMENT' then 'SOURCE'
    when 'DISCOVERY' then 'DOCUMENT'
    when 'ROUTING_DECISION' then 'DISCOVERY'
    when 'CORE_DECISION' then 'ROUTING_DECISION'
    when 'COMMIT' then 'CORE_DECISION'
    when 'TEST' then 'COMMIT'
    when 'MEASUREMENT' then 'TEST'
    else null
  end;

  if parent_stage <> expected_parent then
    raise exception 'invalid_parent_stage:%:expected:%:got:%',
      new.stage, expected_parent, parent_stage;
  end if;

  if parent_evidence is not null then
    if new.evidence_id is null then
      new.evidence_id := parent_evidence;
    elsif new.evidence_id <> parent_evidence then
      raise exception 'evidence_id_mismatch';
    end if;
  end if;

  return new;
end;
$$;

revoke all on function knowledge.enforce_provenance_parent() from public, anon, authenticated;

create trigger provenance_parent_guard
before insert on knowledge.provenance_nodes
for each row execute function knowledge.enforce_provenance_parent();

alter table knowledge.knowledge_spaces enable row level security;
alter table knowledge.space_memberships enable row level security;
alter table knowledge.sources enable row level security;
alter table knowledge.evidence_registry enable row level security;
alter table knowledge.evidence_decisions enable row level security;
alter table knowledge.concepts enable row level security;
alter table knowledge.concept_relations enable row level security;
alter table knowledge.knowledge_items enable row level security;
alter table knowledge.knowledge_item_concepts enable row level security;
alter table knowledge.knowledge_relations enable row level security;
alter table knowledge.knowledge_versions enable row level security;
alter table knowledge.provenance_nodes enable row level security;

alter table knowledge.knowledge_spaces force row level security;
alter table knowledge.space_memberships force row level security;
alter table knowledge.sources force row level security;
alter table knowledge.evidence_registry force row level security;
alter table knowledge.evidence_decisions force row level security;
alter table knowledge.concepts force row level security;
alter table knowledge.concept_relations force row level security;
alter table knowledge.knowledge_items force row level security;
alter table knowledge.knowledge_item_concepts force row level security;
alter table knowledge.knowledge_relations force row level security;
alter table knowledge.knowledge_versions force row level security;
alter table knowledge.provenance_nodes force row level security;

create policy knowledge_spaces_read
on knowledge.knowledge_spaces for select to authenticated
using (knowledge.can_access_space(id, array['reader','editor','admin']::text[]));

create policy memberships_read_self
on knowledge.space_memberships for select to authenticated
using (principal_id = (select knowledge.current_principal_id()) and active);

create policy sources_read
on knowledge.sources for select to authenticated
using (knowledge.can_access_space(space_id, array['reader','editor','admin']::text[]));
create policy sources_insert
on knowledge.sources for insert to authenticated
with check (knowledge.can_access_space(space_id, array['editor','admin']::text[]));
create policy sources_update
on knowledge.sources for update to authenticated
using (knowledge.can_access_space(space_id, array['editor','admin']::text[]))
with check (knowledge.can_access_space(space_id, array['editor','admin']::text[]));
create policy sources_delete
on knowledge.sources for delete to authenticated
using (knowledge.can_access_space(space_id, array['admin']::text[]));

create policy evidence_registry_read
on knowledge.evidence_registry for select to authenticated
using (knowledge.can_access_space(space_id, array['reader','editor','admin']::text[]));
create policy evidence_registry_insert
on knowledge.evidence_registry for insert to authenticated
with check (knowledge.can_access_space(space_id, array['editor','admin']::text[]));

create policy evidence_decisions_read
on knowledge.evidence_decisions for select to authenticated
using (knowledge.can_access_space(space_id, array['reader','editor','admin']::text[]));
create policy evidence_decisions_insert
on knowledge.evidence_decisions for insert to authenticated
with check (knowledge.can_access_space(space_id, array['editor','admin']::text[]));

create policy concepts_read
on knowledge.concepts for select to authenticated
using (knowledge.can_access_space(space_id, array['reader','editor','admin']::text[]));
create policy concepts_insert
on knowledge.concepts for insert to authenticated
with check (knowledge.can_access_space(space_id, array['editor','admin']::text[]));
create policy concepts_update
on knowledge.concepts for update to authenticated
using (knowledge.can_access_space(space_id, array['editor','admin']::text[]))
with check (knowledge.can_access_space(space_id, array['editor','admin']::text[]));
create policy concepts_delete
on knowledge.concepts for delete to authenticated
using (knowledge.can_access_space(space_id, array['admin']::text[]));

create policy concept_relations_read
on knowledge.concept_relations for select to authenticated
using (knowledge.can_access_space(space_id, array['reader','editor','admin']::text[]));
create policy concept_relations_insert
on knowledge.concept_relations for insert to authenticated
with check (knowledge.can_access_space(space_id, array['editor','admin']::text[]));
create policy concept_relations_delete
on knowledge.concept_relations for delete to authenticated
using (knowledge.can_access_space(space_id, array['editor','admin']::text[]));

create policy knowledge_items_read
on knowledge.knowledge_items for select to authenticated
using (knowledge.can_access_space(space_id, array['reader','editor','admin']::text[]));
create policy knowledge_items_insert
on knowledge.knowledge_items for insert to authenticated
with check (knowledge.can_access_space(space_id, array['editor','admin']::text[]));
create policy knowledge_items_update
on knowledge.knowledge_items for update to authenticated
using (knowledge.can_access_space(space_id, array['editor','admin']::text[]))
with check (knowledge.can_access_space(space_id, array['editor','admin']::text[]));
create policy knowledge_items_delete
on knowledge.knowledge_items for delete to authenticated
using (knowledge.can_access_space(space_id, array['admin']::text[]));

create policy knowledge_item_concepts_read
on knowledge.knowledge_item_concepts for select to authenticated
using (knowledge.can_access_space(space_id, array['reader','editor','admin']::text[]));
create policy knowledge_item_concepts_insert
on knowledge.knowledge_item_concepts for insert to authenticated
with check (knowledge.can_access_space(space_id, array['editor','admin']::text[]));
create policy knowledge_item_concepts_delete
on knowledge.knowledge_item_concepts for delete to authenticated
using (knowledge.can_access_space(space_id, array['editor','admin']::text[]));

create policy knowledge_relations_read
on knowledge.knowledge_relations for select to authenticated
using (knowledge.can_access_space(space_id, array['reader','editor','admin']::text[]));
create policy knowledge_relations_insert
on knowledge.knowledge_relations for insert to authenticated
with check (knowledge.can_access_space(space_id, array['editor','admin']::text[]));
create policy knowledge_relations_delete
on knowledge.knowledge_relations for delete to authenticated
using (knowledge.can_access_space(space_id, array['editor','admin']::text[]));

create policy knowledge_versions_read
on knowledge.knowledge_versions for select to authenticated
using (knowledge.can_access_space(space_id, array['reader','editor','admin']::text[]));
create policy knowledge_versions_insert
on knowledge.knowledge_versions for insert to authenticated
with check (knowledge.can_access_space(space_id, array['editor','admin']::text[]));

create policy provenance_nodes_read
on knowledge.provenance_nodes for select to authenticated
using (knowledge.can_access_space(space_id, array['reader','editor','admin']::text[]));
create policy provenance_nodes_insert
on knowledge.provenance_nodes for insert to authenticated
with check (knowledge.can_access_space(space_id, array['editor','admin']::text[]));

revoke all on all tables in schema knowledge from public, anon;
grant select on knowledge.knowledge_spaces, knowledge.space_memberships to authenticated;
grant select, insert, update, delete on
  knowledge.sources,
  knowledge.concepts,
  knowledge.concept_relations,
  knowledge.knowledge_items,
  knowledge.knowledge_item_concepts,
  knowledge.knowledge_relations
to authenticated;
grant select, insert on
  knowledge.evidence_registry,
  knowledge.evidence_decisions,
  knowledge.knowledge_versions,
  knowledge.provenance_nodes
to authenticated;

grant all privileges on all tables in schema knowledge to service_role;

insert into knowledge.knowledge_spaces (slug, space_type)
values ('henolos','internal'), ('litd','project')
on conflict (slug) do nothing;
