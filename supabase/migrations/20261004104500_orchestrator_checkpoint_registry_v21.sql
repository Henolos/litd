-- Orchestrator V2.1 durable checkpoint registry.
-- Extends the existing private governance substrate; no parallel authority surface.

create table if not exists governance_private.orchestrator_checkpoints (
    mandate_id text not null check (length(btrim(mandate_id)) > 0),
    branch_id text not null check (length(btrim(branch_id)) > 0),
    domain text not null check (domain in ('HENOLOS','LITD')),
    project_id text not null check (length(btrim(project_id)) > 0),
    target_route text not null check (length(btrim(target_route)) > 0),
    state text not null check (state in (
        'APPROVED','RUNNING','WAITING_EXTERNAL','HUMAN_DECISION','VERIFYING','COMPLETED'
    )),
    checkpoint_version bigint not null check (checkpoint_version > 0),
    source_sha text check (source_sha is null or source_sha ~ '^[0-9a-f]{40}$'),
    external_id text,
    idempotency_key text not null check (length(btrim(idempotency_key)) > 0),
    state_hash text not null check (state_hash ~ '^[0-9a-f]{64}$'),
    checkpoint jsonb not null check (jsonb_typeof(checkpoint) = 'object'),
    updated_at timestamptz not null default clock_timestamp(),
    primary key (mandate_id, branch_id),
    unique (mandate_id, branch_id, idempotency_key)
);

create table if not exists governance_private.orchestrator_checkpoint_audit (
    sequence bigint generated always as identity primary key,
    mandate_id text not null,
    branch_id text not null,
    domain text not null,
    project_id text not null,
    target_route text not null,
    event_type text not null,
    checkpoint_version bigint not null,
    idempotency_key text not null,
    state_hash text not null check (state_hash ~ '^[0-9a-f]{64}$'),
    actor text not null,
    recorded_at timestamptz not null,
    previous_hash text not null,
    entry_hash text not null unique check (entry_hash ~ '^[0-9a-f]{64}$')
);

create index if not exists orchestrator_checkpoints_state_idx
    on governance_private.orchestrator_checkpoints(domain, state, updated_at);
create index if not exists orchestrator_checkpoint_audit_branch_idx
    on governance_private.orchestrator_checkpoint_audit(mandate_id, branch_id, sequence);

alter table governance_private.orchestrator_checkpoints enable row level security;
alter table governance_private.orchestrator_checkpoint_audit enable row level security;

revoke all on governance_private.orchestrator_checkpoints from public, anon, authenticated, service_role;
revoke all on governance_private.orchestrator_checkpoint_audit from public, anon, authenticated, service_role;
revoke all on sequence governance_private.orchestrator_checkpoint_audit_sequence_seq
    from public, anon, authenticated, service_role;

drop trigger if exists orchestrator_checkpoint_audit_append_only
    on governance_private.orchestrator_checkpoint_audit;
create trigger orchestrator_checkpoint_audit_append_only
before update or delete on governance_private.orchestrator_checkpoint_audit
for each row execute function governance_private.reject_append_only_mutation();

create or replace function governance_private.append_orchestrator_checkpoint_audit(
    p_mandate_id text,
    p_branch_id text,
    p_domain text,
    p_project_id text,
    p_target_route text,
    p_event_type text,
    p_checkpoint_version bigint,
    p_idempotency_key text,
    p_state_hash text,
    p_actor text
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
    perform pg_catalog.pg_advisory_xact_lock(42120261004);

    select entry_hash into v_previous
      from governance_private.orchestrator_checkpoint_audit
     order by sequence desc
     limit 1;
    v_previous := coalesce(v_previous, 'GENESIS');

    v_entry := encode(
        extensions.digest(
            pg_catalog.convert_to(
                pg_catalog.jsonb_build_object(
                    'mandate_id', btrim(p_mandate_id),
                    'branch_id', btrim(p_branch_id),
                    'domain', p_domain,
                    'project_id', btrim(p_project_id),
                    'target_route', btrim(p_target_route),
                    'event_type', p_event_type,
                    'checkpoint_version', p_checkpoint_version,
                    'idempotency_key', btrim(p_idempotency_key),
                    'state_hash', p_state_hash,
                    'actor', btrim(p_actor),
                    'recorded_at', v_recorded_at,
                    'previous_hash', v_previous
                )::text,
                'UTF8'
            ),
            'sha256'
        ),
        'hex'
    );

    insert into governance_private.orchestrator_checkpoint_audit(
        mandate_id, branch_id, domain, project_id, target_route, event_type,
        checkpoint_version, idempotency_key, state_hash, actor,
        recorded_at, previous_hash, entry_hash
    ) values (
        btrim(p_mandate_id), btrim(p_branch_id), p_domain, btrim(p_project_id),
        btrim(p_target_route), p_event_type, p_checkpoint_version,
        btrim(p_idempotency_key), p_state_hash, btrim(p_actor),
        v_recorded_at, v_previous, v_entry
    );

    return v_entry;
end;
$$;

create or replace function governance_private.write_orchestrator_checkpoint(
    p_mandate_id text,
    p_branch_id text,
    p_domain text,
    p_project_id text,
    p_target_route text,
    p_state text,
    p_expected_version bigint,
    p_source_sha text,
    p_external_id text,
    p_idempotency_key text,
    p_checkpoint jsonb,
    p_actor text
) returns table(
    accepted boolean,
    reason text,
    checkpoint_version bigint,
    state_hash text,
    audit_entry_hash text
)
language plpgsql
security definer
set search_path = ''
as $$
declare
    v_current governance_private.orchestrator_checkpoints%rowtype;
    v_next_version bigint;
    v_state_hash text;
    v_audit_hash text;
begin
    if p_domain not in ('HENOLOS','LITD') then
        raise exception 'invalid_domain' using errcode = '22023';
    end if;
    if p_state not in (
        'APPROVED','RUNNING','WAITING_EXTERNAL','HUMAN_DECISION','VERIFYING','COMPLETED'
    ) then
        raise exception 'invalid_orchestrator_state' using errcode = '22023';
    end if;
    if p_expected_version < 0 then
        raise exception 'invalid_expected_version' using errcode = '22023';
    end if;
    if p_source_sha is not null and p_source_sha !~ '^[0-9a-f]{40}$' then
        raise exception 'invalid_source_sha' using errcode = '22023';
    end if;
    if jsonb_typeof(p_checkpoint) <> 'object' then
        raise exception 'checkpoint_must_be_object' using errcode = '22023';
    end if;
    if length(btrim(p_mandate_id)) = 0 or length(btrim(p_branch_id)) = 0
       or length(btrim(p_project_id)) = 0 or length(btrim(p_target_route)) = 0
       or length(btrim(p_idempotency_key)) = 0 or length(btrim(p_actor)) = 0 then
        raise exception 'checkpoint_identity_scope_and_actor_required' using errcode = '22023';
    end if;

    if not exists (
        select 1
          from governance_private.authorized_project_routes
         where project_id = btrim(p_project_id)
           and target_route = btrim(p_target_route)
    ) then
        raise exception 'unauthorized_project_route:%:%', p_project_id, p_target_route
            using errcode = '42501';
    end if;

    v_state_hash := encode(
        extensions.digest(
            pg_catalog.convert_to(p_checkpoint::text, 'UTF8'),
            'sha256'
        ),
        'hex'
    );

    perform pg_catalog.pg_advisory_xact_lock(
        pg_catalog.hashtext(btrim(p_mandate_id) || ':' || btrim(p_branch_id))
    );

    select * into v_current
      from governance_private.orchestrator_checkpoints
     where mandate_id = btrim(p_mandate_id)
       and branch_id = btrim(p_branch_id)
     for update;

    if found then
        if v_current.project_id <> btrim(p_project_id)
           or v_current.target_route <> btrim(p_target_route)
           or v_current.domain <> p_domain then
            return query select false, 'scope_mismatch', v_current.checkpoint_version,
                                v_current.state_hash, null::text;
            return;
        end if;

        if v_current.idempotency_key = btrim(p_idempotency_key) then
            if v_current.state_hash = v_state_hash
               and v_current.state = p_state
               and v_current.source_sha is not distinct from p_source_sha
               and v_current.external_id is not distinct from p_external_id then
                return query select true, 'idempotent_replay', v_current.checkpoint_version,
                                    v_current.state_hash, null::text;
            end if;
            return query select false, 'idempotency_conflict', v_current.checkpoint_version,
                                v_current.state_hash, null::text;
            return;
        end if;

        if p_expected_version <> v_current.checkpoint_version then
            return query select false, 'stale_checkpoint_version', v_current.checkpoint_version,
                                v_current.state_hash, null::text;
            return;
        end if;

        v_next_version := v_current.checkpoint_version + 1;
        update governance_private.orchestrator_checkpoints
           set state = p_state,
               checkpoint_version = v_next_version,
               source_sha = p_source_sha,
               external_id = p_external_id,
               idempotency_key = btrim(p_idempotency_key),
               state_hash = v_state_hash,
               checkpoint = p_checkpoint,
               updated_at = clock_timestamp()
         where mandate_id = btrim(p_mandate_id)
           and branch_id = btrim(p_branch_id);
    else
        if p_expected_version <> 0 then
            return query select false, 'checkpoint_missing', 0::bigint, null::text, null::text;
            return;
        end if;

        v_next_version := 1;
        insert into governance_private.orchestrator_checkpoints(
            mandate_id, branch_id, domain, project_id, target_route, state,
            checkpoint_version, source_sha, external_id, idempotency_key,
            state_hash, checkpoint
        ) values (
            btrim(p_mandate_id), btrim(p_branch_id), p_domain, btrim(p_project_id),
            btrim(p_target_route), p_state, v_next_version, p_source_sha,
            p_external_id, btrim(p_idempotency_key), v_state_hash, p_checkpoint
        );
    end if;

    v_audit_hash := governance_private.append_orchestrator_checkpoint_audit(
        btrim(p_mandate_id), btrim(p_branch_id), p_domain, btrim(p_project_id),
        btrim(p_target_route), 'CHECKPOINT_WRITTEN', v_next_version,
        btrim(p_idempotency_key), v_state_hash, btrim(p_actor)
    );

    return query select true, 'checkpoint_written', v_next_version, v_state_hash, v_audit_hash;
end;
$$;

create or replace function governance_private.read_orchestrator_checkpoint(
    p_mandate_id text,
    p_branch_id text
) returns table(
    mandate_id text,
    branch_id text,
    domain text,
    project_id text,
    target_route text,
    state text,
    checkpoint_version bigint,
    source_sha text,
    external_id text,
    idempotency_key text,
    state_hash text,
    checkpoint jsonb,
    updated_at timestamptz
)
language sql
stable
security definer
set search_path = ''
as $$
    select c.mandate_id, c.branch_id, c.domain, c.project_id, c.target_route,
           c.state, c.checkpoint_version, c.source_sha, c.external_id,
           c.idempotency_key, c.state_hash, c.checkpoint, c.updated_at
      from governance_private.orchestrator_checkpoints c
     where c.mandate_id = btrim(p_mandate_id)
       and c.branch_id = btrim(p_branch_id);
$$;

create or replace function governance_private.verify_orchestrator_checkpoint_audit_chain()
returns table(valid boolean, entry_count bigint, tip_hash text, reason text)
language plpgsql
security definer
set search_path = ''
as $$
declare
    v_row governance_private.orchestrator_checkpoint_audit%rowtype;
    v_previous text := 'GENESIS';
    v_expected text;
    v_count bigint := 0;
begin
    perform pg_catalog.pg_advisory_xact_lock(42120261004);

    for v_row in
        select * from governance_private.orchestrator_checkpoint_audit order by sequence
    loop
        v_count := v_count + 1;
        if v_row.previous_hash <> v_previous then
            return query select false, v_count, v_previous, 'previous_hash_mismatch';
            return;
        end if;

        v_expected := encode(
            extensions.digest(
                pg_catalog.convert_to(
                    pg_catalog.jsonb_build_object(
                        'mandate_id', v_row.mandate_id,
                        'branch_id', v_row.branch_id,
                        'domain', v_row.domain,
                        'project_id', v_row.project_id,
                        'target_route', v_row.target_route,
                        'event_type', v_row.event_type,
                        'checkpoint_version', v_row.checkpoint_version,
                        'idempotency_key', v_row.idempotency_key,
                        'state_hash', v_row.state_hash,
                        'actor', v_row.actor,
                        'recorded_at', v_row.recorded_at,
                        'previous_hash', v_row.previous_hash
                    )::text,
                    'UTF8'
                ),
                'sha256'
            ),
            'hex'
        );

        if v_expected <> v_row.entry_hash then
            return query select false, v_count, v_previous, 'entry_hash_mismatch';
            return;
        end if;

        v_previous := v_row.entry_hash;
    end loop;

    return query select true, v_count, v_previous, 'chain_valid';
end;
$$;

revoke execute on function governance_private.append_orchestrator_checkpoint_audit(
    text,text,text,text,text,text,bigint,text,text,text
) from public, anon, authenticated, service_role;

revoke execute on function governance_private.write_orchestrator_checkpoint(
    text,text,text,text,text,text,bigint,text,text,text,jsonb,text
) from public, anon, authenticated;
revoke execute on function governance_private.read_orchestrator_checkpoint(text,text)
    from public, anon, authenticated;
revoke execute on function governance_private.verify_orchestrator_checkpoint_audit_chain()
    from public, anon, authenticated;

grant execute on function governance_private.write_orchestrator_checkpoint(
    text,text,text,text,text,text,bigint,text,text,text,jsonb,text
) to service_role;
grant execute on function governance_private.read_orchestrator_checkpoint(text,text)
    to service_role;
grant execute on function governance_private.verify_orchestrator_checkpoint_audit_chain()
    to service_role;
