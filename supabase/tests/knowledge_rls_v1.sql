-- Reproducible isolation check for knowledge RLS.
-- Designed for staging/dry-run execution only.

begin;

insert into knowledge.space_memberships(space_id, principal_id, role)
select id, '11111111-1111-4111-8111-111111111111'::uuid, 'editor'
from knowledge.knowledge_spaces where slug='litd'
on conflict (space_id, principal_id) do update set role='editor', active=true;

insert into knowledge.space_memberships(space_id, principal_id, role)
select id, '22222222-2222-4222-8222-222222222222'::uuid, 'editor'
from knowledge.knowledge_spaces where slug='henolos'
on conflict (space_id, principal_id) do update set role='editor', active=true;

insert into knowledge.knowledge_items(space_id,item_key,title,body)
select id,'__rls_test_litd','LITD RLS test','synthetic'
from knowledge.knowledge_spaces where slug='litd'
on conflict (space_id,item_key) do nothing;

insert into knowledge.knowledge_items(space_id,item_key,title,body)
select id,'__rls_test_henolos','Henolos RLS test','synthetic'
from knowledge.knowledge_spaces where slug='henolos'
on conflict (space_id,item_key) do nothing;

set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"11111111-1111-4111-8111-111111111111","role":"authenticated"}',
  true
);

do $$
declare
  visible_spaces integer;
  visible_items integer;
  litd_space uuid;
  henolos_space uuid;
begin
  select count(*) into visible_spaces from knowledge.knowledge_spaces;
  if visible_spaces <> 1 then
    raise exception 'expected exactly one visible space, got %', visible_spaces;
  end if;

  select count(*) into visible_items from knowledge.knowledge_items;
  if visible_items <> 1 then
    raise exception 'expected exactly one visible item, got %', visible_items;
  end if;

  select id into litd_space from knowledge.knowledge_spaces where slug='litd';
  if litd_space is null then
    raise exception 'litd space not visible';
  end if;

  begin
    insert into knowledge.knowledge_items(space_id,item_key,title,body)
    values (
      '00000000-0000-4000-8000-000000000001'::uuid,
      '__rls_test_cross_space_denied',
      'Denied write',
      'synthetic'
    );
    raise exception 'cross-space write unexpectedly allowed';
  exception
    when foreign_key_violation or insufficient_privilege then
      null;
  end;
end
$$;

rollback;
