-- P0 #333: authorize exact project/route pairs in the shared governance registry.
-- The mapping is private and immutable at runtime. Adding/removing a route must
-- happen through a separately reviewed database migration.

create table if not exists governance_private.authorized_project_routes (
    project_id text not null check (length(btrim(project_id)) > 0),
    target_route text not null check (length(btrim(target_route)) > 0),
    registered_at timestamptz not null default clock_timestamp(),
    primary key (project_id, target_route)
);

insert into governance_private.authorized_project_routes(project_id, target_route)
values
    ('LITD', 'LITD_LIBRARY'),
    ('COMPANY', 'COMPANY_LIBRARY')
on conflict (project_id, target_route) do nothing;

alter table governance_private.authorized_project_routes enable row level security;
revoke all on governance_private.authorized_project_routes from public, anon, authenticated, service_role;

drop trigger if exists authorized_project_routes_append_only on governance_private.authorized_project_routes;
create trigger authorized_project_routes_append_only
before update or delete on governance_private.authorized_project_routes
for each row execute function governance_private.reject_append_only_mutation();

create or replace function governance_private.enforce_authorized_project_route()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
    if not exists (
        select 1
          from governance_private.authorized_project_routes
         where project_id = new.project_id
           and target_route = new.target_route
    ) then
        raise exception 'unauthorized_project_route:%:%', new.project_id, new.target_route
            using errcode = '42501';
    end if;
    return new;
end;
$$;

drop trigger if exists registered_receipts_authorized_scope on governance_private.registered_receipts;
create trigger registered_receipts_authorized_scope
before insert on governance_private.registered_receipts
for each row execute function governance_private.enforce_authorized_project_route();

create or replace function governance_private.is_project_route_authorized(
    p_project_id text,
    p_target_route text
) returns boolean
language sql
stable
security definer
set search_path = ''
as $$
    select exists (
        select 1
          from governance_private.authorized_project_routes
         where project_id = btrim(p_project_id)
           and target_route = btrim(p_target_route)
    );
$$;

revoke execute on function governance_private.enforce_authorized_project_route() from public, anon, authenticated, service_role;
revoke execute on function governance_private.is_project_route_authorized(text,text) from public, anon, authenticated;
grant execute on function governance_private.is_project_route_authorized(text,text) to service_role;
