-- P0 #331/#333 live proof helpers for the durable governance receipt registry.
-- These SECURITY DEFINER RPCs expose only aggregate verification results and
-- safe trigger probes. They do not expose private rows or grant table access.

create or replace function governance_private.verify_consumption_audit_chain()
returns table(valid boolean, entry_count bigint, tip_hash text, reason text)
language plpgsql
security definer
set search_path = ''
as $$
declare
    v_row governance_private.consumption_audit%rowtype;
    v_previous text := 'GENESIS';
    v_expected text;
    v_count bigint := 0;
begin
    perform pg_catalog.pg_advisory_xact_lock(33120260912);

    for v_row in
        select * from governance_private.consumption_audit order by sequence
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
                        'receipt_hash', v_row.receipt_hash,
                        'project_id', v_row.project_id,
                        'target_route', v_row.target_route,
                        'consumer', v_row.consumer,
                        'actor', v_row.actor,
                        'current_context_hash', v_row.current_context_hash,
                        'outcome', v_row.outcome,
                        'reason', v_row.reason,
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

create or replace function governance_private.probe_append_only_guards(
    p_consumed_receipt_hash text,
    p_invalidated_receipt_hash text,
    p_project_id text,
    p_target_route text
) returns table(
    registered_receipts_guard boolean,
    receipt_consumptions_guard boolean,
    receipt_invalidations_guard boolean,
    consumption_audit_guard boolean
)
language plpgsql
security definer
set search_path = ''
as $$
declare
    v_registered boolean := false;
    v_consumed boolean := false;
    v_invalidated boolean := false;
    v_audit boolean := false;
begin
    if not exists (
        select 1 from governance_private.registered_receipts
        where receipt_hash = p_consumed_receipt_hash
          and project_id = p_project_id and target_route = p_target_route
    ) or not exists (
        select 1 from governance_private.registered_receipts
        where receipt_hash = p_invalidated_receipt_hash
          and project_id = p_project_id and target_route = p_target_route
    ) then
        raise exception 'unknown or cross-scope proof receipt';
    end if;
    if not exists (select 1 from governance_private.receipt_consumptions where receipt_hash = p_consumed_receipt_hash)
       or not exists (select 1 from governance_private.receipt_invalidations where receipt_hash = p_invalidated_receipt_hash) then
        raise exception 'proof receipts are not in required states';
    end if;

    begin
        update governance_private.registered_receipts
           set receipt_id = receipt_id
         where receipt_hash = p_consumed_receipt_hash;
    exception when sqlstate '55000' then
        v_registered := true;
    end;

    begin
        update governance_private.receipt_consumptions
           set actor = actor
         where receipt_hash = p_consumed_receipt_hash;
    exception when sqlstate '55000' then
        v_consumed := true;
    end;

    begin
        update governance_private.receipt_invalidations
           set reason = reason
         where receipt_hash = p_invalidated_receipt_hash;
    exception when sqlstate '55000' then
        v_invalidated := true;
    end;

    begin
        update governance_private.consumption_audit
           set reason = reason
         where receipt_hash in (p_consumed_receipt_hash, p_invalidated_receipt_hash);
    exception when sqlstate '55000' then
        v_audit := true;
    end;

    return query select v_registered, v_consumed, v_invalidated, v_audit;
end;
$$;

revoke execute on function governance_private.verify_consumption_audit_chain() from public, anon, authenticated;
revoke execute on function governance_private.probe_append_only_guards(text,text,text,text) from public, anon, authenticated;
grant execute on function governance_private.verify_consumption_audit_chain() to service_role;
grant execute on function governance_private.probe_append_only_guards(text,text,text,text) to service_role;
