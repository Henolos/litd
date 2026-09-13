-- Runtime verification helper for the durable P0 #331 registry.

create or replace function governance_private.verify_consumption_audit_chain()
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
    v_row governance_private.consumption_audit%rowtype;
    v_previous_hash text := 'GENESIS';
    v_expected_hash text;
begin
    for v_row in select * from governance_private.consumption_audit order by sequence loop
        if v_row.previous_hash <> v_previous_hash then
            return false;
        end if;
        v_expected_hash := encode(
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
        if v_expected_hash <> v_row.entry_hash then
            return false;
        end if;
        v_previous_hash := v_row.entry_hash;
    end loop;
    return true;
end;
$$;

revoke execute on function governance_private.verify_consumption_audit_chain()
from public, anon, authenticated;
grant execute on function governance_private.verify_consumption_audit_chain()
to service_role;

