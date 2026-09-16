-- P0 #407: bounded live rollback/recovery/containment proof surface.
-- This schema is synthetic-proof-only. It cannot write a project Core, merge code,
-- or authorize cross-project propagation. Emergency recovery RPCs remain unavailable
-- to service_role; only the normal bounded mutation-attempt RPC is granted there.

create table if not exists governance_private.recovery_drill_state (
    drill_id text primary key check (length(btrim(drill_id)) > 0),
    project_id text not null check (length(btrim(project_id)) > 0),
    target_route text not null check (length(btrim(target_route)) > 0),
    baseline_hash text not null check (baseline_hash ~ '^[0-9a-f]{64}$'),
    active_hash text not null check (active_hash ~ '^[0-9a-f]{64}$'),
    phase text not null check (phase in ('ACTIVE','CONTAINED','RECOVERING','CLOSED')),
    capability_generation bigint not null check (capability_generation > 0),
    started_at timestamptz not null default clock_timestamp(),
    updated_at timestamptz not null default clock_timestamp()
);

create table if not exists governance_private.recovery_audit (
    sequence bigint generated always as identity primary key,
    drill_id text not null,
    event_type text not null,
    project_id text not null,
    target_route text not null,
    actor text not null,
    capability_generation bigint not null,
    state_hash text not null check (state_hash ~ '^[0-9a-f]{64}$'),
    recorded_at timestamptz not null,
    previous_hash text not null,
    entry_hash text not null unique
);

alter table governance_private.recovery_drill_state enable row level security;
alter table governance_private.recovery_audit enable row level security;
revoke all on governance_private.recovery_drill_state from public, anon, authenticated, service_role;
revoke all on governance_private.recovery_audit from public, anon, authenticated, service_role;

drop trigger if exists recovery_audit_append_only on governance_private.recovery_audit;
create trigger recovery_audit_append_only
before update or delete on governance_private.recovery_audit
for each row execute function governance_private.reject_append_only_mutation();

create or replace function governance_private.append_recovery_audit(
    p_drill_id text,
    p_event_type text,
    p_project_id text,
    p_target_route text,
    p_actor text,
    p_capability_generation bigint,
    p_state_hash text
) returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
    v_recorded_at timestamptz := clock_timestamp();
    v_previous text;
    v_entry text;
begin
    perform pg_catalog.pg_advisory_xact_lock(40720260916);
    select entry_hash into v_previous
      from governance_private.recovery_audit
     order by sequence desc limit 1;
    v_previous := coalesce(v_previous, 'GENESIS');
    v_entry := encode(
        extensions.digest(
            pg_catalog.convert_to(
                pg_catalog.jsonb_build_object(
                    'drill_id', p_drill_id,
                    'event_type', p_event_type,
                    'project_id', p_project_id,
                    'target_route', p_target_route,
                    'actor', p_actor,
                    'capability_generation', p_capability_generation,
                    'state_hash', p_state_hash,
                    'recorded_at', v_recorded_at,
                    'previous_hash', v_previous
                )::text,
                'UTF8'
            ),
            'sha256'
        ),
        'hex'
    );
    insert into governance_private.recovery_audit(
        drill_id,event_type,project_id,target_route,actor,capability_generation,
        state_hash,recorded_at,previous_hash,entry_hash
    ) values (
        p_drill_id,p_event_type,p_project_id,p_target_route,p_actor,p_capability_generation,
        p_state_hash,v_recorded_at,v_previous,v_entry
    );
    return v_entry;
end;
$$;

create or replace function governance_private.begin_recovery_drill(
    p_drill_id text,
    p_project_id text,
    p_target_route text,
    p_baseline_hash text,
    p_actor text
) returns bigint
language plpgsql
security definer
set search_path = ''
as $$
declare
    v_generation bigint := 1;
begin
    if p_baseline_hash !~ '^[0-9a-f]{64}$' then
        raise exception 'invalid_baseline_hash' using errcode = '22023';
    end if;
    if not exists (
        select 1 from governance_private.authorized_project_routes
         where project_id = btrim(p_project_id)
           and target_route = btrim(p_target_route)
    ) then
        raise exception 'unauthorized_project_route:%:%', p_project_id, p_target_route
            using errcode = '42501';
    end if;
    insert into governance_private.recovery_drill_state(
        drill_id,project_id,target_route,baseline_hash,active_hash,phase,capability_generation
    ) values (
        btrim(p_drill_id),btrim(p_project_id),btrim(p_target_route),p_baseline_hash,p_baseline_hash,'ACTIVE',v_generation
    );
    perform governance_private.append_recovery_audit(
        btrim(p_drill_id),'DRILL_BEGUN',btrim(p_project_id),btrim(p_target_route),btrim(p_actor),v_generation,p_baseline_hash
    );
    return v_generation;
end;
$$;

create or replace function governance_private.attempt_recovery_drill_mutation(
    p_drill_id text,
    p_project_id text,
    p_target_route text,
    p_capability_generation bigint,
    p_candidate_hash text,
    p_actor text
) returns table(accepted boolean, reason text, active_hash text, capability_generation bigint, phase text)
language plpgsql
security definer
set search_path = ''
as $$
declare
    v_row governance_private.recovery_drill_state%rowtype;
    v_reason text;
begin
    if p_candidate_hash !~ '^[0-9a-f]{64}$' then
        raise exception 'invalid_candidate_hash' using errcode = '22023';
    end if;
    select * into v_row from governance_private.recovery_drill_state
     where drill_id = btrim(p_drill_id) for update;
    if not found then
        raise exception 'unknown_recovery_drill' using errcode = 'P0002';
    end if;

    if btrim(p_project_id) <> v_row.project_id then
        v_reason := 'project_scope_mismatch';
    elsif btrim(p_target_route) <> v_row.target_route then
        v_reason := 'target_route_mismatch';
    elsif v_row.phase <> 'ACTIVE' then
        v_reason := 'global_containment_active';
    elsif p_capability_generation <> v_row.capability_generation then
        v_reason := 'stale_capability_generation';
    elsif not exists (
        select 1 from governance_private.authorized_project_routes
         where project_id = v_row.project_id and target_route = v_row.target_route
    ) then
        v_reason := 'project_route_not_authorized';
    end if;

    if v_reason is not null then
        perform governance_private.append_recovery_audit(
            v_row.drill_id,'MUTATION_REJECTED_' || upper(v_reason),v_row.project_id,v_row.target_route,
            btrim(p_actor),v_row.capability_generation,v_row.active_hash
        );
        return query select false,v_reason,v_row.active_hash,v_row.capability_generation,v_row.phase;
        return;
    end if;

    update governance_private.recovery_drill_state
       set active_hash = p_candidate_hash, updated_at = clock_timestamp()
     where drill_id = v_row.drill_id;
    perform governance_private.append_recovery_audit(
        v_row.drill_id,'CHANGE_APPLIED',v_row.project_id,v_row.target_route,btrim(p_actor),
        v_row.capability_generation,p_candidate_hash
    );
    return query select true,'change_applied',p_candidate_hash,v_row.capability_generation,'ACTIVE'::text;
end;
$$;

create or replace function governance_private.contain_recovery_drill(
    p_drill_id text,
    p_actor text
) returns bigint
language plpgsql
security definer
set search_path = ''
as $$
declare
    v_row governance_private.recovery_drill_state%rowtype;
    v_generation bigint;
begin
    select * into v_row from governance_private.recovery_drill_state
     where drill_id = btrim(p_drill_id) for update;
    if not found or v_row.phase <> 'ACTIVE' then
        raise exception 'recovery_drill_not_active' using errcode = '55000';
    end if;
    v_generation := v_row.capability_generation + 1;
    update governance_private.recovery_drill_state
       set phase='CONTAINED', capability_generation=v_generation, updated_at=clock_timestamp()
     where drill_id=v_row.drill_id;
    perform governance_private.append_recovery_audit(
        v_row.drill_id,'CONTAINMENT_STARTED',v_row.project_id,v_row.target_route,btrim(p_actor),v_generation,v_row.active_hash
    );
    return v_generation;
end;
$$;

create or replace function governance_private.rollback_recovery_drill(
    p_drill_id text,
    p_expected_changed_hash text,
    p_actor text
) returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
    v_row governance_private.recovery_drill_state%rowtype;
begin
    select * into v_row from governance_private.recovery_drill_state
     where drill_id=btrim(p_drill_id) for update;
    if not found or v_row.phase <> 'CONTAINED' then
        raise exception 'recovery_drill_not_contained' using errcode = '55000';
    end if;
    if v_row.active_hash <> p_expected_changed_hash then
        raise exception 'rollback_source_hash_mismatch' using errcode = '55000';
    end if;
    update governance_private.recovery_drill_state
       set active_hash=v_row.baseline_hash, phase='RECOVERING', updated_at=clock_timestamp()
     where drill_id=v_row.drill_id;
    perform governance_private.append_recovery_audit(
        v_row.drill_id,'ROLLBACK_APPLIED',v_row.project_id,v_row.target_route,btrim(p_actor),
        v_row.capability_generation,v_row.baseline_hash
    );
    return v_row.baseline_hash;
end;
$$;

create or replace function governance_private.resume_recovery_drill(
    p_drill_id text,
    p_expected_baseline_hash text,
    p_actor text
) returns bigint
language plpgsql
security definer
set search_path = ''
as $$
declare
    v_row governance_private.recovery_drill_state%rowtype;
    v_generation bigint;
begin
    select * into v_row from governance_private.recovery_drill_state
     where drill_id=btrim(p_drill_id) for update;
    if not found or v_row.phase <> 'RECOVERING' then
        raise exception 'recovery_drill_not_recovering' using errcode = '55000';
    end if;
    if v_row.active_hash <> v_row.baseline_hash or v_row.baseline_hash <> p_expected_baseline_hash then
        raise exception 'recovery_baseline_not_verified' using errcode = '55000';
    end if;
    v_generation := v_row.capability_generation + 1;
    update governance_private.recovery_drill_state
       set phase='ACTIVE', capability_generation=v_generation, updated_at=clock_timestamp()
     where drill_id=v_row.drill_id;
    perform governance_private.append_recovery_audit(
        v_row.drill_id,'RECOVERY_RESUMED',v_row.project_id,v_row.target_route,btrim(p_actor),
        v_generation,v_row.active_hash
    );
    return v_generation;
end;
$$;

create or replace function governance_private.close_recovery_drill(
    p_drill_id text,
    p_actor text
) returns bigint
language plpgsql
security definer
set search_path = ''
as $$
declare
    v_row governance_private.recovery_drill_state%rowtype;
    v_generation bigint;
begin
    select * into v_row from governance_private.recovery_drill_state
     where drill_id=btrim(p_drill_id) for update;
    if not found or v_row.phase <> 'ACTIVE' or v_row.active_hash <> v_row.baseline_hash then
        raise exception 'recovery_drill_not_safe_to_close' using errcode = '55000';
    end if;
    v_generation := v_row.capability_generation + 1;
    update governance_private.recovery_drill_state
       set phase='CLOSED', capability_generation=v_generation, updated_at=clock_timestamp()
     where drill_id=v_row.drill_id;
    perform governance_private.append_recovery_audit(
        v_row.drill_id,'DRILL_CLOSED',v_row.project_id,v_row.target_route,btrim(p_actor),
        v_generation,v_row.active_hash
    );
    return v_generation;
end;
$$;

create or replace function governance_private.verify_recovery_drill(p_drill_id text)
returns table(
    project_id text,
    target_route text,
    baseline_hash text,
    active_hash text,
    phase text,
    capability_generation bigint,
    baseline_restored boolean
)
language sql
stable
security definer
set search_path = ''
as $$
    select project_id,target_route,baseline_hash,active_hash,phase,capability_generation,
           active_hash = baseline_hash
      from governance_private.recovery_drill_state
     where drill_id = btrim(p_drill_id);
$$;

create or replace function governance_private.verify_recovery_audit_chain()
returns table(valid boolean, entry_count bigint, tip_hash text, reason text)
language plpgsql
security definer
set search_path = ''
as $$
declare
    v_row governance_private.recovery_audit%rowtype;
    v_previous text := 'GENESIS';
    v_expected text;
    v_count bigint := 0;
begin
    perform pg_catalog.pg_advisory_xact_lock(40720260916);
    for v_row in select * from governance_private.recovery_audit order by sequence loop
        v_count := v_count + 1;
        if v_row.previous_hash <> v_previous then
            return query select false,v_count,v_previous,'previous_hash_mismatch';
            return;
        end if;
        v_expected := encode(
            extensions.digest(
                pg_catalog.convert_to(
                    pg_catalog.jsonb_build_object(
                        'drill_id',v_row.drill_id,
                        'event_type',v_row.event_type,
                        'project_id',v_row.project_id,
                        'target_route',v_row.target_route,
                        'actor',v_row.actor,
                        'capability_generation',v_row.capability_generation,
                        'state_hash',v_row.state_hash,
                        'recorded_at',v_row.recorded_at,
                        'previous_hash',v_row.previous_hash
                    )::text,
                    'UTF8'
                ),
                'sha256'
            ),
            'hex'
        );
        if v_expected <> v_row.entry_hash then
            return query select false,v_count,v_previous,'entry_hash_mismatch';
            return;
        end if;
        v_previous := v_row.entry_hash;
    end loop;
    return query select true,v_count,v_previous,'chain_valid';
end;
$$;

revoke execute on function governance_private.append_recovery_audit(text,text,text,text,text,bigint,text) from public, anon, authenticated, service_role;
revoke execute on function governance_private.begin_recovery_drill(text,text,text,text,text) from public, anon, authenticated, service_role;
revoke execute on function governance_private.contain_recovery_drill(text,text) from public, anon, authenticated, service_role;
revoke execute on function governance_private.rollback_recovery_drill(text,text,text) from public, anon, authenticated, service_role;
revoke execute on function governance_private.resume_recovery_drill(text,text,text) from public, anon, authenticated, service_role;
revoke execute on function governance_private.close_recovery_drill(text,text) from public, anon, authenticated, service_role;

revoke execute on function governance_private.attempt_recovery_drill_mutation(text,text,text,bigint,text,text) from public, anon, authenticated;
revoke execute on function governance_private.verify_recovery_drill(text) from public, anon, authenticated;
revoke execute on function governance_private.verify_recovery_audit_chain() from public, anon, authenticated;
grant execute on function governance_private.attempt_recovery_drill_mutation(text,text,text,bigint,text,text) to service_role;
grant execute on function governance_private.verify_recovery_drill(text) to service_role;
grant execute on function governance_private.verify_recovery_audit_chain() to service_role;
