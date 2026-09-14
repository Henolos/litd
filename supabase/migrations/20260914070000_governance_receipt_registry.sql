-- Durable governance receipt registry for P0 #331 / #333.
-- This schema grants no Core, merge, application, or target authority.
-- It only records immutable receipts, invalidations, single-use consumption,
-- and an append-only hash-chained audit trail.

create extension if not exists pgcrypto;
create schema if not exists governance;

revoke all on schema governance from public;

create table if not exists governance.registered_receipts (
    project_id text not null,
    target_route text not null,
    receipt_hash text not null check (receipt_hash ~ '^[0-9a-f]{64}$'),
    receipt_id text not null,
    receipt_kind text not null,
    source_hash text not null check (source_hash ~ '^[0-9a-f]{64}$'),
    context_hash text not null check (context_hash ~ '^[0-9a-f]{64}$'),
    expected_consumer text not null,
    registered_at timestamptz not null default now(),
    primary key (project_id, target_route, receipt_hash),
    unique (project_id, target_route, receipt_id),
    check (btrim(project_id) <> ''),
    check (btrim(target_route) <> ''),
    check (btrim(receipt_id) <> ''),
    check (btrim(receipt_kind) <> ''),
    check (btrim(expected_consumer) <> '')
);

create table if not exists governance.receipt_consumptions (
    project_id text not null,
    target_route text not null,
    receipt_hash text not null,
    consumer text not null,
    actor text not null,
    consumed_at timestamptz not null default now(),
    current_context_hash text not null check (current_context_hash ~ '^[0-9a-f]{64}$'),
    primary key (project_id, target_route, receipt_hash),
    foreign key (project_id, target_route, receipt_hash)
        references governance.registered_receipts(project_id, target_route, receipt_hash),
    check (btrim(consumer) <> ''),
    check (btrim(actor) <> '')
);

create table if not exists governance.receipt_invalidations (
    project_id text not null,
    target_route text not null,
    receipt_hash text not null,
    invalidation_kind text not null check (invalidation_kind in ('REVOKED', 'SUPERSEDED')),
    reason text not null,
    replacement_receipt_hash text check (replacement_receipt_hash is null or replacement_receipt_hash ~ '^[0-9a-f]{64}$'),
    actor text not null,
    invalidated_at timestamptz not null default now(),
    primary key (project_id, target_route, receipt_hash),
    foreign key (project_id, target_route, receipt_hash)
        references governance.registered_receipts(project_id, target_route, receipt_hash),
    check (btrim(reason) <> ''),
    check (btrim(actor) <> ''),
    check (invalidation_kind <> 'SUPERSEDED' or replacement_receipt_hash is not null)
);

create table if not exists governance.consumption_audit (
    sequence bigint generated always as identity primary key,
    project_id text not null,
    target_route text not null,
    receipt_hash text not null check (receipt_hash ~ '^[0-9a-f]{64}$'),
    consumer text not null,
    actor text not null,
    current_context_hash text not null check (current_context_hash ~ '^[0-9a-f]{64}$'),
    outcome text not null check (outcome in ('ACCEPTED', 'REJECTED')),
    reason text not null,
    recorded_at timestamptz not null default now(),
    previous_hash text not null,
    entry_hash text not null unique check (entry_hash ~ '^[0-9a-f]{64}$'),
    check (btrim(project_id) <> ''),
    check (btrim(target_route) <> ''),
    check (btrim(consumer) <> ''),
    check (btrim(actor) <> ''),
    check (btrim(reason) <> '')
);

create index if not exists consumption_audit_scope_sequence_idx
    on governance.consumption_audit(project_id, target_route, sequence desc);

create or replace function governance.reject_mutation()
returns trigger
language plpgsql
as $$
begin
    raise exception '% is append-only', tg_table_name;
end;
$$;

create trigger registered_receipts_no_update
before update or delete on governance.registered_receipts
for each row execute function governance.reject_mutation();

create trigger receipt_consumptions_no_update
before update or delete on governance.receipt_consumptions
for each row execute function governance.reject_mutation();

create trigger receipt_invalidations_no_update
before update or delete on governance.receipt_invalidations
for each row execute function governance.reject_mutation();

create trigger consumption_audit_no_update
before update or delete on governance.consumption_audit
for each row execute function governance.reject_mutation();

create or replace function governance.consume_receipt_once(
    p_project_id text,
    p_target_route text,
    p_receipt_hash text,
    p_consumer text,
    p_actor text,
    p_current_context_hash text
)
returns table (
    accepted boolean,
    status text,
    reason text,
    receipt_hash text,
    audit_entry_hash text
)
language plpgsql
security invoker
set search_path = governance, pg_catalog
as $$
declare
    r governance.registered_receipts%rowtype;
    invalidation_kind text;
    prior_consumption text;
    v_outcome text := 'REJECTED';
    v_reason text := 'unknown_receipt';
    v_previous_hash text := 'GENESIS';
    v_recorded_at timestamptz := clock_timestamp();
    v_entry_hash text;
begin
    if p_project_id is null or btrim(p_project_id) = '' then
        raise exception 'project_id required';
    end if;
    if p_target_route is null or btrim(p_target_route) = '' then
        raise exception 'target_route required';
    end if;
    if p_receipt_hash !~ '^[0-9a-f]{64}$' then
        raise exception 'receipt_hash must be 64 lowercase hex';
    end if;
    if p_current_context_hash !~ '^[0-9a-f]{64}$' then
        raise exception 'current_context_hash must be 64 lowercase hex';
    end if;
    if p_consumer is null or btrim(p_consumer) = '' or p_actor is null or btrim(p_actor) = '' then
        raise exception 'consumer and actor required';
    end if;

    -- Serialize one audit chain per project/route while allowing unrelated projects
    -- to proceed independently. This also makes the read/check/insert atomic.
    perform pg_advisory_xact_lock(hashtextextended(p_project_id || E'\x1f' || p_target_route, 0));

    select * into r
    from governance.registered_receipts
    where project_id = p_project_id
      and target_route = p_target_route
      and receipt_hash = p_receipt_hash
    for share;

    if found then
        if r.expected_consumer <> p_consumer then
            v_reason := 'unexpected_consumer';
        elsif r.context_hash <> p_current_context_hash then
            v_reason := 'stale_context';
        else
            select i.invalidation_kind into invalidation_kind
            from governance.receipt_invalidations i
            where i.project_id = p_project_id
              and i.target_route = p_target_route
              and i.receipt_hash = p_receipt_hash;

            if invalidation_kind is not null then
                v_reason := 'receipt_' || lower(invalidation_kind);
            else
                select c.consumer into prior_consumption
                from governance.receipt_consumptions c
                where c.project_id = p_project_id
                  and c.target_route = p_target_route
                  and c.receipt_hash = p_receipt_hash;

                if prior_consumption is not null then
                    v_reason := 'replay_detected';
                else
                    insert into governance.receipt_consumptions(
                        project_id, target_route, receipt_hash, consumer, actor,
                        current_context_hash
                    ) values (
                        p_project_id, p_target_route, p_receipt_hash, btrim(p_consumer),
                        btrim(p_actor), p_current_context_hash
                    );
                    v_outcome := 'ACCEPTED';
                    v_reason := 'consumed_once';
                end if;
            end if;
        end if;
    end if;

    select a.entry_hash into v_previous_hash
    from governance.consumption_audit a
    where a.project_id = p_project_id
      and a.target_route = p_target_route
    order by a.sequence desc
    limit 1;
    v_previous_hash := coalesce(v_previous_hash, 'GENESIS');

    v_entry_hash := encode(
        digest(
            convert_to(
                jsonb_build_object(
                    'receipt_hash', p_receipt_hash,
                    'project_id', p_project_id,
                    'target_route', p_target_route,
                    'consumer', btrim(p_consumer),
                    'actor', btrim(p_actor),
                    'current_context_hash', p_current_context_hash,
                    'outcome', v_outcome,
                    'reason', v_reason,
                    'recorded_at', v_recorded_at,
                    'previous_hash', v_previous_hash
                )::text,
                'UTF8'
            ),
            'sha256'
        ),
        'hex'
    );

    insert into governance.consumption_audit(
        project_id, target_route, receipt_hash, consumer, actor,
        current_context_hash, outcome, reason, recorded_at, previous_hash, entry_hash
    ) values (
        p_project_id, p_target_route, p_receipt_hash, btrim(p_consumer), btrim(p_actor),
        p_current_context_hash, v_outcome, v_reason, v_recorded_at, v_previous_hash, v_entry_hash
    );

    return query select
        v_outcome = 'ACCEPTED', v_outcome, v_reason, p_receipt_hash, v_entry_hash;
end;
$$;

alter table governance.registered_receipts enable row level security;
alter table governance.receipt_consumptions enable row level security;
alter table governance.receipt_invalidations enable row level security;
alter table governance.consumption_audit enable row level security;

-- No client role gets direct access. The governance worker must use a dedicated
-- database role granted only the exact statements/functions required by deployment.
revoke all on all tables in schema governance from public, anon, authenticated;
revoke all on all sequences in schema governance from public, anon, authenticated;
revoke execute on all functions in schema governance from public, anon, authenticated;
