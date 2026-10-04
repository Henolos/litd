-- Synthetic transactional contract for Orchestrator V2.1 checkpoint persistence.
-- Run only after the checkpoint-registry migration is installed.

begin;

insert into governance_private.authorized_project_routes(project_id, target_route)
values ('__orchestrator_v21_test_project', '__orchestrator_v21_test_route')
on conflict do nothing;

do $$
declare
    v_first record;
    v_replay record;
    v_stale record;
    v_second record;
    v_read record;
    v_chain record;
begin
    select * into v_first
      from governance_private.write_orchestrator_checkpoint(
        '__mandate_v21',
        '__branch_v21',
        'LITD',
        '__orchestrator_v21_test_project',
        '__orchestrator_v21_test_route',
        'RUNNING',
        0,
        '2b3f06621096e222b6e04e21ecf0bb86177e861b',
        'pr:534',
        '__idem_001',
        '{"goal":"synthetic","remaining":["verify"]}'::jsonb,
        'orchestrator-test'
      );
    if not v_first.accepted or v_first.reason <> 'checkpoint_written'
       or v_first.checkpoint_version <> 1 then
        raise exception 'initial checkpoint failed: %', row_to_json(v_first);
    end if;

    select * into v_replay
      from governance_private.write_orchestrator_checkpoint(
        '__mandate_v21',
        '__branch_v21',
        'LITD',
        '__orchestrator_v21_test_project',
        '__orchestrator_v21_test_route',
        'RUNNING',
        1,
        '2b3f06621096e222b6e04e21ecf0bb86177e861b',
        'pr:534',
        '__idem_001',
        '{"goal":"synthetic","remaining":["verify"]}'::jsonb,
        'orchestrator-test'
      );
    if not v_replay.accepted or v_replay.reason <> 'idempotent_replay'
       or v_replay.checkpoint_version <> 1 then
        raise exception 'idempotent replay failed: %', row_to_json(v_replay);
    end if;

    select * into v_stale
      from governance_private.write_orchestrator_checkpoint(
        '__mandate_v21',
        '__branch_v21',
        'LITD',
        '__orchestrator_v21_test_project',
        '__orchestrator_v21_test_route',
        'VERIFYING',
        0,
        '2b3f06621096e222b6e04e21ecf0bb86177e861b',
        'pr:534',
        '__idem_stale',
        '{"goal":"synthetic","remaining":[]}'::jsonb,
        'orchestrator-test'
      );
    if v_stale.accepted or v_stale.reason <> 'stale_checkpoint_version'
       or v_stale.checkpoint_version <> 1 then
        raise exception 'stale write was not rejected: %', row_to_json(v_stale);
    end if;

    select * into v_second
      from governance_private.write_orchestrator_checkpoint(
        '__mandate_v21',
        '__branch_v21',
        'LITD',
        '__orchestrator_v21_test_project',
        '__orchestrator_v21_test_route',
        'VERIFYING',
        1,
        '2b3f06621096e222b6e04e21ecf0bb86177e861b',
        'pr:534',
        '__idem_002',
        '{"goal":"synthetic","remaining":[]}'::jsonb,
        'orchestrator-test'
      );
    if not v_second.accepted or v_second.reason <> 'checkpoint_written'
       or v_second.checkpoint_version <> 2 then
        raise exception 'versioned update failed: %', row_to_json(v_second);
    end if;

    select * into v_read
      from governance_private.read_orchestrator_checkpoint('__mandate_v21','__branch_v21');
    if v_read.checkpoint_version <> 2 or v_read.state <> 'VERIFYING'
       or v_read.external_id <> 'pr:534' then
        raise exception 'checkpoint read mismatch: %', row_to_json(v_read);
    end if;

    select * into v_chain
      from governance_private.verify_orchestrator_checkpoint_audit_chain();
    if not v_chain.valid or v_chain.entry_count < 2 then
        raise exception 'audit chain invalid: %', row_to_json(v_chain);
    end if;
end
$$;

rollback;
