-- Reproducible isolation check for knowledge RLS.
-- Designed for staging/dry-run execution only.

begin;

delete from knowledge.knowledge_items where item_key like '__rls_test_%';
delete from knowledge.space_memberships where principal_id in (
  '11111111-1111-4111-8111-111111111111'::uuid,
  '22222222-2222-4222-8222-222222222222'::uuid
);

insert into knowledge.space_memberships(space_id, principal_id, role)
select id, '11111111-1111-4111-8111-111111111111'::uuid, 'editor'
from knowledge.knowledge_spaces where slug='litd';

insert into knowledge.space_memberships(space_id, principal_id, role)
select id, '22222222-2222-4222-8222-222222222222'::uuid, 'editor'
from knowledge.knowledge_spaces where slug='henolos';

insert into knowledge.knowledge_items(space_id,item_key,title,body)
select id,'__rls_test_litd','LITD RLS test','synthetic'
from knowledge.knowledge_spaces where slug='litd';

insert into knowledge.knowledge_items(space_id,item_key,title,body)
select id,'__rls_test_henolos','Henolos RLS test','synthetic'
from knowledge.knowledge_spaces where slug='henolos';

select set_config(
  'knowledge.test_henolos_space',
  (select id::text from knowledge.knowledge_spaces where slug='henolos'),
  true
);

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
  allowed_write_count integer;
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

  insert into knowledge.knowledge_items(space_id,item_key,title,body)
  values (
    litd_space,
    '__rls_test_allowed_write',
    'Allowed write',
    'synthetic'
  );

  select count(*) into allowed_write_count
  from knowledge.knowledge_items
  where item_key='__rls_test_allowed_write';

  if allowed_write_count <> 1 then
    raise exception 'expected LITD editor write to succeed';
  end if;

  henolos_space := current_setting('knowledge.test_henolos_space')::uuid;

  begin
    insert into knowledge.knowledge_items(space_id,item_key,title,body)
    values (
      henolos_space,
      '__rls_test_cross_space_denied',
      'Denied write',
      'synthetic'
    );
    raise exception 'cross-space write unexpectedly allowed';
  exception
    when insufficient_privilege then
      null;
  end;
end
$$;

rollback;
