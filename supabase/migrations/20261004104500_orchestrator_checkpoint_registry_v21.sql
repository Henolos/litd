-- Orchestrator V2.1 durable checkpoints.
-- IMPORTANT: extend the existing henolos_execution core; do not create a parallel registry.

alter table henolos_execution.checkpoints
    add column if not exists branch_id text not null default 'root',
    add column if not exists idempotency_key text;

do $$
begin
    if not exists (
        select 1
        from pg_catalog.pg_constraint
        where conname = 'checkpoints_branch_id_nonempty'
          and conrelid = 'henolos_execution.checkpoints'::regclass
    ) then
        alter table henolos_execution.checkpoints
            add constraint checkpoints_branch_id_nonempty
            check (length(btrim(branch_id)) > 0);
    end if;

    if not exists (
        select 1
        from pg_catalog.pg_constraint
        where conname = 'checkpoints_idempotency_key_nonempty'
          and conrelid = 'henolos_execution.checkpoints'::regclass
    ) then
        alter table henolos_execution.checkpoints
            add constraint checkpoints_idempotency_key_nonempty
            check (idempotency_key is null or length(btrim(idempotency_key)) > 0);
    end if;
end
$$;

create unique index if not exists checkpoints_branch_idempotency_uq
    on henolos_execution.checkpoints(mandate_id, branch_id, idempotency_key)
    where idempotency_key is not null;

create index if not exists checkpoints_mandate_branch_created_idx
    on henolos_execution.checkpoints(mandate_id, branch_id, created_at desc);

create or replace function henolos_execution.append_orchestrator_checkpoint_v21(
    p_mandate_id uuid,
    p_branch_id text,
    p_idempotency_key text,
    p_expected_mandate_version bigint,
    p_state text,
    p_observed_state jsonb,
    p_last_successful_action jsonb,
    p_remaining_work jsonb,
    p_blockers jsonb,
    p_next_safe_action jsonb,
    p_evidence_summary jsonb,
    p_actor text,
    p_lease_token uuid,
    p_operation_id uuid
) returns table(
    accepted boolean,
    reason text,
    sequence_no bigint,
    mandate_version bigint,
    checkpoint_id bigint
)
language plpgsql
security definer
set search_path = ''
as $$
declare
    v_mandate henolos_execution.mandates%rowtype;
    v_existing henolos_execution.checkpoints%rowtype;
    v_sequence bigint;
    v_checkpoint_id bigint;
    v_new_version bigint;
begin
    if length(btrim(coalesce(p_branch_id, ''))) = 0
       or length(btrim(coalesce(p_idempotency_key, ''))) = 0
       or length(btrim(coalesce(p_actor, ''))) = 0 then
        raise exception 'branch_id, idempotency_key and actor are required'
            using errcode = '22023';
    end if;

    if p_expected_mandate_version < 1 then
        raise exception 'expected mandate version must be positive'
            using errcode = '22023';
    end if;

    if p_state not in (
        'APPROVED','RUNNING','WAITING_EXTERNAL',
        'HUMAN_DECISION','VERIFYING','COMPLETED'
    ) then
        raise exception 'invalid orchestrator state'
            using errcode = '22023';
    end if;

    if jsonb_typeof(coalesce(p_observed_state, '{}'::jsonb)) <> 'object'
       or jsonb_typeof(coalesce(p_remaining_work, '[]'::jsonb)) <> 'array'
       or jsonb_typeof(coalesce(p_blockers, '[]'::jsonb)) <> 'array'
       or jsonb_typeof(coalesce(p_evidence_summary, '[]'::jsonb)) <> 'array' then
        raise exception 'invalid checkpoint json shape'
            using errcode = '22023';
    end if;

    if p_state = 'COMPLETED' then
        if coalesce(p_observed_state ->> 'closure_verified', 'false') <> 'true'
           or jsonb_array_length(coalesce(p_remaining_work, '[]'::jsonb)) <> 0
           or jsonb_array_length(coalesce(p_blockers, '[]'::jsonb)) <> 0
           or jsonb_array_length(coalesce(p_evidence_summary, '[]'::jsonb)) = 0 then
            return query
                select false, 'closure_not_verified', null::bigint, null::bigint, null::bigint;
            return;
        end if;
    end if;

    perform pg_catalog.pg_advisory_xact_lock(
        pg_catalog.hashtextextended(
            'henolos_execution.checkpoint:' || p_mandate_id::text,
            0
        )
    );

    select *
      into v_mandate
      from henolos_execution.mandates
     where id = p_mandate_id
     for update;

    if not found then
        return query
            select false, 'unknown_mandate', null::bigint, null::bigint, null::bigint;
        return;
    end if;

    if not exists (
        select 1
          from henolos_execution.leases
         where mandate_id = p_mandate_id
           and lease_token = p_lease_token
           and expires_at > pg_catalog.clock_timestamp()
    ) then
        return query
            select false, 'valid_lease_required', null::bigint, v_mandate.version, null::bigint;
        return;
    end if;

    if p_operation_id is not null and not exists (
        select 1
          from henolos_execution.operations
         where id = p_operation_id
           and mandate_id = p_mandate_id
    ) then
        return query
            select false, 'operation_scope_mismatch', null::bigint, v_mandate.version, null::bigint;
        return;
    end if;

    select *
      into v_existing
      from henolos_execution.checkpoints
     where mandate_id = p_mandate_id
       and branch_id = btrim(p_branch_id)
       and idempotency_key = btrim(p_idempotency_key)
     limit 1;

    if found then
        if v_existing.state = p_state
           and v_existing.observed_state = coalesce(p_observed_state, '{}'::jsonb)
           and v_existing.last_successful_action is not distinct from p_last_successful_action
           and v_existing.remaining_work = coalesce(p_remaining_work, '[]'::jsonb)
           and v_existing.blockers = coalesce(p_blockers, '[]'::jsonb)
           and v_existing.next_safe_action is not distinct from p_next_safe_action
           and v_existing.evidence_summary = coalesce(p_evidence_summary, '[]'::jsonb) then
            return query
                select true, 'idempotent_replay', v_existing.sequence_no,
                       v_mandate.version, v_existing.id;
            return;
        end if;

        return query
            select false, 'idempotency_conflict', v_existing.sequence_no,
                   v_mandate.version, v_existing.id;
        return;
    end if;

    if v_mandate.version <> p_expected_mandate_version then
        return query
            select false, 'stale_mandate_version', null::bigint,
                   v_mandate.version, null::bigint;
        return;
    end if;

    select coalesce(max(sequence_no), 0) + 1
      into v_sequence
      from henolos_execution.checkpoints
     where mandate_id = p_mandate_id;

    insert into henolos_execution.checkpoints(
        mandate_id,
        sequence_no,
        state,
        observed_state,
        last_successful_action,
        remaining_work,
        blockers,
        next_safe_action,
        evidence_summary,
        branch_id,
        idempotency_key
    ) values (
        p_mandate_id,
        v_sequence,
        p_state,
        coalesce(p_observed_state, '{}'::jsonb),
        p_last_successful_action,
        coalesce(p_remaining_work, '[]'::jsonb),
        coalesce(p_blockers, '[]'::jsonb),
        p_next_safe_action,
        coalesce(p_evidence_summary, '[]'::jsonb),
        btrim(p_branch_id),
        btrim(p_idempotency_key)
    )
    returning id into v_checkpoint_id;

    v_new_version := v_mandate.version + 1;

    update henolos_execution.mandates
       set state = p_state,
           version = v_new_version,
           updated_at = pg_catalog.clock_timestamp()
     where id = p_mandate_id
       and version = p_expected_mandate_version;

    if not found then
        raise exception 'mandate version changed during checkpoint write'
            using errcode = '40001';
    end if;

    insert into henolos_execution.provenance_events(
        mandate_id,
        operation_id,
        event_type,
        actor,
        correlation_id,
        causation_id,
        payload
    ) values (
        p_mandate_id,
        p_operation_id,
        'ORCHESTRATOR_CHECKPOINT_WRITTEN',
        btrim(p_actor),
        'checkpoint:' || p_mandate_id::text || ':' || btrim(p_branch_id),
        p_lease_token::text,
        pg_catalog.jsonb_build_object(
            'checkpoint_id', v_checkpoint_id,
            'sequence_no', v_sequence,
            'branch_id', btrim(p_branch_id),
            'idempotency_key', btrim(p_idempotency_key),
            'previous_mandate_version', p_expected_mandate_version,
            'mandate_version', v_new_version,
            'state', p_state
        )
    );

    return query
        select true, 'checkpoint_written', v_sequence, v_new_version, v_checkpoint_id;
end;
$$;

revoke execute on function henolos_execution.append_orchestrator_checkpoint_v21(
    uuid,text,text,bigint,text,jsonb,jsonb,jsonb,jsonb,jsonb,jsonb,text,uuid,uuid
) from public, anon, authenticated;

grant usage on schema henolos_execution to service_role;

grant execute on function henolos_execution.append_orchestrator_checkpoint_v21(
    uuid,text,text,bigint,text,jsonb,jsonb,jsonb,jsonb,jsonb,jsonb,text,uuid,uuid
) to service_role;
