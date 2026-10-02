alter table knowledge.evidence_registry
  drop constraint if exists evidence_registry_origin_store_check;
alter table knowledge.evidence_registry
  add constraint evidence_registry_origin_store_check
  check (origin_store in ('native','sqlite'));

alter table knowledge.evidence_decisions
  drop constraint if exists evidence_decisions_origin_store_check;
alter table knowledge.evidence_decisions
  add constraint evidence_decisions_origin_store_check
  check (origin_store in ('native','sqlite'));

alter table knowledge.provenance_nodes
  drop constraint if exists provenance_nodes_origin_store_check;
alter table knowledge.provenance_nodes
  add constraint provenance_nodes_origin_store_check
  check (origin_store in ('native','sqlite'));

drop policy if exists evidence_registry_insert on knowledge.evidence_registry;
create policy evidence_registry_insert
on knowledge.evidence_registry for insert to authenticated
with check (
  knowledge.can_access_space(space_id, array['editor','admin']::text[])
  and origin_store = 'native'
);

drop policy if exists evidence_decisions_insert on knowledge.evidence_decisions;
create policy evidence_decisions_insert
on knowledge.evidence_decisions for insert to authenticated
with check (
  knowledge.can_access_space(space_id, array['editor','admin']::text[])
  and origin_store = 'native'
);

drop policy if exists provenance_nodes_insert on knowledge.provenance_nodes;
create policy provenance_nodes_insert
on knowledge.provenance_nodes for insert to authenticated
with check (
  knowledge.can_access_space(space_id, array['editor','admin']::text[])
  and origin_store = 'native'
);
