-- Synthetic transactional contract for Orchestrator V2.1 checkpoint persistence.
-- Reuses henolos_execution; no parallel checkpoint registry is created.

begin;

do $$
declare
    v_mandate_id uuid := '42100000-0000-4000-8000-000000000001'::uuid;
    v_lease uuid;
    v_first record;
    v_replay record;
    v_conflict record;
    v_stale record;
    v_second record;
    v_bad_close record;
    v_close record;
    v_saved record;
begin
    insert into henolos_execution.mandates(
        id, mandate_key, title, objective, scope, state,
        approval_source, approved_at, version, domain, priority,
        dependencies, closure_criteria
    ) values (
        v_mandate_id,
        '__orchestrator_v21_sql_test',
        'Synthetic Orchestrator V2.1 test',
        'Verify checkpoint durability contract',
        '{"synthetic":true}'::jsonb,
        'APPROVED',
        'sql-test',
        pg_catalog.clock_timestamp(),
        1,
        'LITD',
        50,
        '[]'::jsonb,
        '["checkpoint persisted","closure verified"]'::jsonb
    );

    v_lease := henolos_execution.acquire_lease(
        v_mandate_id,
        'orchestrator-v21-test',
        120
    );

    if v_lease is null then
        raise exception 'failed to acquire synthetic lease';
    end if;

    select * into v_first
      from henolos_execution.append_orchestrator_checkpoint_v21(
        v_mandate_id,
        'pr-535',
        'checkpoint:run-001',
        1,
        'RUNNING',
        '{"head_sha":"012e5a2","closure_verified":false}'::jsonb,
        '{"action":"inspect"}'::jsonb,
        '["verify"]'::jsonb,
        '[]'::jsonb,
        '{"action":"verify"}'::jsonb,
        '[{"type":"sql-test"}]'::jsonb,
        'orchestrator-v21-test',
        v_lease,
        null
      );

    if not v_first.accepted or v_first.reason <> 'checkpoint_written'
       or v_first.sequence_no <> 1 or v_first.mandate_version <> 2 then
        raise exception 'initial checkpoint failed: %', row_to_json(v_first);
    end if;

    select * into v_replay
      from henolos_execution.append_orchestrator_checkpoint_v21(
        v_mandate_id,
        'pr-535',
        'checkpoint:run-001',
        1,
        'RUNNING',
        '{"head_sha":"012e5a2","closure_verified":false}'::jsonb,
        '{"action":"inspect"}'::jsonb,
        '["verify"]'::jsonb,
        '[]'::jsonb,
        '{"action":"verify"}'::jsonb,
        '[{"type":"sql-test"}]'::jsonb,
        'orchestrator-v21-test',
        v_lease,
        null
      );

    if not v_replay.accepted or v_replay.reason <> 'idempotent_replay'
       or v_replay.sequence_no <> 1 or v_replay.mandate_version <> 2 then
        raise exception 'idempotent replay failed: %', row_to_json(v_replay);
    end if;

    select * into v_conflict
      from henolos_execution.append_orchestrator_checkpoint_v21(
        v_mandate_id,
        'pr-535',
        'checkpoint:run-001',
        2,
        'VERIFYING',
        '{"head_sha":"different","closure_verified":false}'::jsonb,
        null,
        '[]'::jsonb,
        '[]'::jsonb,
        null,
        '[{"type":"sql-test"}]'::jsonb,
        'orchestrator-v21-test',
        v_lease,
        null
      );

    if v_conflict.accepted or v_conflict.reason <> 'idempotency_conflict' then
        raise exception 'idempotency conflict was not rejected: %', row_to_json(v_conflict);
    end if;

    select * into v_stale
      from henolos_execution.append_orchestrator_checkpoint_v21(
        v_mandate_id,
        'pr-535',
        'checkpoint:run-002-stale',
        1,
        'VERIFYING',
        '{"head_sha":"012e5a2","closure_verified":false}'::jsonb,
        null,
        '[]'::jsonb,
        '[]'::jsonb,
        null,
        '[{"type":"sql-test"}]'::jsonb,
        'orchestrator-v21-test',
        v_lease,
        null
      );

    if v_stale.accepted or v_stale.reason <> 'stale_mandate_version'
       or v_stale.mandate_version <> 2 then
        raise exception 'stale version was not rejected: %', row_to_json(v_stale);
    end if;

    select * into v_second
      from henolos_execution.append_orchestrator_checkpoint_v21(
        v_mandate_id,
        'pr-535',
        'checkpoint:run-002',
        2,
        'VERIFYING',
        '{"head_sha":"012e5a2","closure_verified":false}'::jsonb,
        '{"action":"ci-green"}'::jsonb,
        '[]'::jsonb,
        '[]'::jsonb,
        '{"action":"closure-check"}'::jsonb,
        '[{"type":"ci","status":"green"}]'::jsonb,
        'orchestrator-v21-test',
        v_lease,
        null
      );

    if not v_second.accepted or v_second.reason <> 'checkpoint_written'
       or v_second.sequence_no <> 2 or v_second.mandate_version <> 3 then
        raise exception 'second checkpoint failed: %', row_to_json(v_second);
    end if;

    select * into v_bad_close
      from henolos_execution.append_orchestrator_checkpoint_v21(
        v_mandate_id,
        'pr-535',
        'checkpoint:run-003-bad-close',
        3,
        'COMPLETED',
        '{"closure_verified":false}'::jsonb,
        null,
        '[]'::jsonb,
        '[]'::jsonb,
        null,
        '[{"type":"ci","status":"green"}]'::jsonb,
        'orchestrator-v21-test',
        v_lease,
        null
      );

    if v_bad_close.accepted or v_bad_close.reason <> 'closure_not_verified' then
        raise exception 'unsafe closure was not rejected: %', row_to_json(v_bad_close);
    end if;

    select * into v_close
      from henolos_execution.append_orchestrator_checkpoint_v21(
        v_mandate_id,
        'pr-535',
        'checkpoint:run-003',
        3,
        'COMPLETED',
        '{"closure_verified":true}'::jsonb,
        '{"action":"verified"}'::jsonb,
        '[]'::jsonb,
        '[]'::jsonb,
        null,
        '[{"type":"ci","status":"green"},{"type":"sql-contract","status":"green"}]'::jsonb,
        'orchestrator-v21-test',
        v_lease,
        null
      );

    if not v_close.accepted or v_close.reason <> 'checkpoint_written'
       or v_close.sequence_no <> 3 or v_close.mandate_version <> 4 then
        raise exception 'verified closure failed: %', row_to_json(v_close);
    end if;

    select c.branch_id, c.idempotency_key, c.state
      into v_saved
      from henolos_execution.checkpoints c
     where c.mandate_id = v_mandate_id
       and c.sequence_no = 3;

    if v_saved.branch_id <> 'pr-535'
       or v_saved.idempotency_key <> 'checkpoint:run-003'
       or v_saved.state <> 'COMPLETED' then
        raise exception 'saved checkpoint mismatch: %', row_to_json(v_saved);
    end if;

    if not exists (
        select 1
          from henolos_execution.provenance_events
         where mandate_id = v_mandate_id
           and event_type = 'ORCHESTRATOR_CHECKPOINT_WRITTEN'
    ) then
        raise exception 'checkpoint provenance was not recorded';
    end if;

    if (select state from henolos_execution.mandates where id = v_mandate_id) <> 'COMPLETED' then
        raise exception 'mandate state did not advance with verified checkpoint';
    end if;
end
$$;

rollback;
