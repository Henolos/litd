#!/usr/bin/env python3
"""Live bounded rollback/recovery/containment certification for P0 #407.

The drill uses synthetic hashes in the authorized governance PostgreSQL database.
It never writes a project Core, merges code, or restores credentials automatically.
Emergency recovery RPCs are expected to be unavailable to service_role.
"""
from __future__ import annotations

import json
import os
import secrets
from hashlib import sha256
from pathlib import Path

import psycopg

OUTPUT = Path("artifacts/governance/postgres-recovery-live-certification.json")
PROJECT_ID = "COMPANY"
TARGET_ROUTE = "COMPANY_LIBRARY"


def h(value: str) -> str:
    return sha256(value.encode("utf-8")).hexdigest()


def one(cursor, query: str, params: tuple = ()):
    cursor.execute(query, params)
    row = cursor.fetchone()
    if row is None:
        raise RuntimeError("expected one row")
    return row


def run() -> dict:
    database_url = os.environ.get("GOVERNANCE_DATABASE_URL", "").strip()
    git_sha = os.environ.get("GITHUB_SHA", "").strip()
    if not database_url:
        raise RuntimeError("GOVERNANCE_DATABASE_URL is required")
    if len(git_sha) != 40 or any(ch not in "0123456789abcdef" for ch in git_sha):
        raise RuntimeError("GITHUB_SHA must be 40 lowercase hex")

    run_id = secrets.token_hex(8)
    drill_id = f"RECOVERY-LIVE-{run_id}"
    baseline = h(f"baseline:{run_id}")
    changed = h(f"changed:{run_id}")
    attack = h(f"attack:{run_id}")
    actor = f"recovery-cert:{run_id}"

    evidence: dict = {
        "kind": "GOVERNANCE_POSTGRES_RECOVERY_LIVE_CERTIFICATION",
        "git_sha": git_sha,
        "run_id": run_id,
        "drill_id": drill_id,
        "project_id": PROJECT_ID,
        "target_route": TARGET_ROUTE,
        "baseline_hash": baseline,
        "changed_hash": changed,
        "scenarios": {},
        "authority": {
            "core_write_allowed": False,
            "automatic_merge_allowed": False,
            "automatic_application_allowed": False,
            "automatic_resume_allowed": False,
        },
    }

    mutation_sql = (
        "select accepted,reason,active_hash,capability_generation,phase "
        "from governance_private.attempt_recovery_drill_mutation(%s,%s,%s,%s,%s,%s,%s,%s)"
    )

    with psycopg.connect(database_url) as connection:
        with connection.cursor() as cursor:
            current_user = one(cursor, "select current_user")[0]
            evidence["database_user"] = str(current_user)

            generation_1 = int(one(
                cursor,
                "select governance_private.begin_recovery_drill(%s,%s,%s,%s,%s,%s)",
                (drill_id, PROJECT_ID, TARGET_ROUTE, git_sha, baseline, actor),
            )[0])
            connection.commit()

            stale_sha = one(
                cursor,
                mutation_sql,
                (drill_id, PROJECT_ID, TARGET_ROUTE, "0" * 40, generation_1, baseline, attack, actor),
            )
            if stale_sha[0] or stale_sha[1] != "stale_source_sha" or stale_sha[2] != baseline:
                raise RuntimeError(f"stale SHA did not fail closed: {stale_sha!r}")
            evidence["scenarios"]["stale_source_sha"] = {
                "accepted": False,
                "reason": str(stale_sha[1]),
                "state_hash": str(stale_sha[2]),
            }
            connection.commit()

            substituted_hash = one(
                cursor,
                mutation_sql,
                (drill_id, PROJECT_ID, TARGET_ROUTE, git_sha, generation_1, attack, attack, actor),
            )
            if substituted_hash[0] or substituted_hash[1] != "active_hash_mismatch" or substituted_hash[2] != baseline:
                raise RuntimeError(f"active-hash substitution did not fail closed: {substituted_hash!r}")
            evidence["scenarios"]["hash_substitution"] = {
                "accepted": False,
                "reason": str(substituted_hash[1]),
                "state_hash": str(substituted_hash[2]),
            }
            connection.commit()

            accepted, reason, active_hash, generation, phase = one(
                cursor,
                mutation_sql,
                (drill_id, PROJECT_ID, TARGET_ROUTE, git_sha, generation_1, baseline, changed, actor),
            )
            if not accepted or reason != "change_applied" or active_hash != changed or phase != "ACTIVE":
                raise RuntimeError("representative governed change did not apply")
            evidence["scenarios"]["representative_change"] = {
                "accepted": True,
                "before": baseline,
                "after": changed,
                "generation": int(generation),
            }
            connection.commit()

            generation_2 = int(one(
                cursor,
                "select governance_private.contain_recovery_drill(%s,%s)",
                (drill_id, actor),
            )[0])
            if generation_2 <= generation_1:
                raise RuntimeError("containment did not rotate capability generation")
            evidence["scenarios"]["containment_capability_rotation"] = {
                "before_generation": generation_1,
                "after_generation": generation_2,
            }
            connection.commit()

            def rejected(
                name: str,
                project: str,
                route: str,
                generation_value: int,
                expected_reason: str,
                expected_hash: str = changed,
            ) -> None:
                row = one(
                    cursor,
                    mutation_sql,
                    (drill_id, project, route, git_sha, generation_value, expected_hash, attack, actor),
                )
                accepted_value, reason_value, state_hash, gen_value, phase_value = row
                if accepted_value or reason_value != expected_reason or state_hash != changed:
                    raise RuntimeError(f"{name} did not fail closed: {row!r}")
                evidence["scenarios"][name] = {
                    "accepted": False,
                    "reason": str(reason_value),
                    "phase": str(phase_value),
                    "generation": int(gen_value),
                }
                connection.commit()

            rejected("contained_stale_capability", PROJECT_ID, TARGET_ROUTE, generation_1, "global_containment_active")
            rejected("contained_target_project_change", "LITD", TARGET_ROUTE, generation_2, "project_scope_mismatch")
            rejected("contained_wrong_route", PROJECT_ID, "LITD_LIBRARY", generation_2, "target_route_mismatch")

            try:
                cursor.execute(
                    "update governance_private.recovery_audit set event_type=event_type where drill_id=%s",
                    (drill_id,),
                )
                connection.commit()
                raise RuntimeError("recovery audit tamper unexpectedly succeeded")
            except psycopg.Error as exc:
                connection.rollback()
                if exc.sqlstate != "55000":
                    raise
                evidence["scenarios"]["ledger_tamper"] = {
                    "accepted": False,
                    "reason": "append_only_trigger_rejected",
                    "sqlstate": exc.sqlstate,
                }

            try:
                one(
                    cursor,
                    "select governance_private.rollback_recovery_drill(%s,%s,%s)",
                    (drill_id, attack, actor),
                )
                connection.commit()
                raise RuntimeError("rollback hash substitution unexpectedly succeeded")
            except psycopg.Error as exc:
                connection.rollback()
                if exc.sqlstate != "55000" or "rollback_source_hash_mismatch" not in str(exc):
                    raise
                evidence["scenarios"]["rollback_hash_substitution"] = {
                    "accepted": False,
                    "reason": "rollback_source_hash_mismatch",
                    "sqlstate": exc.sqlstate,
                }

            restored_hash = str(one(
                cursor,
                "select governance_private.rollback_recovery_drill(%s,%s,%s)",
                (drill_id, changed, actor),
            )[0])
            if restored_hash != baseline:
                raise RuntimeError("rollback did not restore baseline")
            evidence["scenarios"]["rollback_restored_baseline"] = {
                "before": changed,
                "after": restored_hash,
            }
            connection.commit()

            recovering = one(
                cursor,
                mutation_sql,
                (drill_id, PROJECT_ID, TARGET_ROUTE, git_sha, generation_2, baseline, attack, actor),
            )
            if recovering[0] or recovering[1] != "global_containment_active" or recovering[2] != baseline or recovering[4] != "RECOVERING":
                raise RuntimeError("mutation was not blocked during recovery")
            evidence["scenarios"]["mutation_during_recovery"] = {
                "accepted": False,
                "reason": str(recovering[1]),
                "phase": str(recovering[4]),
            }
            connection.commit()

            generation_3 = int(one(
                cursor,
                "select governance_private.resume_recovery_drill(%s,%s,%s)",
                (drill_id, baseline, actor),
            )[0])
            if generation_3 <= generation_2:
                raise RuntimeError("resume did not rotate capability generation")
            connection.commit()

            stale_after_resume = one(
                cursor,
                mutation_sql,
                (drill_id, PROJECT_ID, TARGET_ROUTE, git_sha, generation_1, baseline, attack, actor),
            )
            if stale_after_resume[0] or stale_after_resume[1] != "stale_capability_generation" or stale_after_resume[2] != baseline:
                raise RuntimeError("pre-containment capability replay was not rejected after resume")
            evidence["scenarios"]["pre_containment_capability_replay"] = {
                "accepted": False,
                "reason": str(stale_after_resume[1]),
                "generation": int(stale_after_resume[3]),
            }
            connection.commit()

            safe_noop = one(
                cursor,
                mutation_sql,
                (drill_id, PROJECT_ID, TARGET_ROUTE, git_sha, generation_3, baseline, baseline, actor),
            )
            if not safe_noop[0] or safe_noop[1] != "change_applied" or safe_noop[2] != baseline:
                raise RuntimeError("post-recovery capability was not usable in bounded path")
            evidence["scenarios"]["post_recovery_bounded_path"] = {
                "accepted": True,
                "generation": int(safe_noop[3]),
                "state_hash": str(safe_noop[2]),
            }
            connection.commit()

            closed_generation = int(one(
                cursor,
                "select governance_private.close_recovery_drill(%s,%s)",
                (drill_id, actor),
            )[0])
            connection.commit()

            state = one(
                cursor,
                "select project_id,target_route,source_commit_sha,baseline_hash,active_hash,phase,capability_generation,baseline_restored "
                "from governance_private.verify_recovery_drill(%s)",
                (drill_id,),
            )
            if (
                state[0] != PROJECT_ID
                or state[1] != TARGET_ROUTE
                or state[2] != git_sha
                or state[3] != baseline
                or state[4] != baseline
                or state[5] != "CLOSED"
                or not state[7]
            ):
                raise RuntimeError("final recovery state is not closed on verified SHA-bound baseline")
            evidence["final_state"] = {
                "source_commit_sha": str(state[2]),
                "phase": str(state[5]),
                "capability_generation": int(state[6]),
                "closed_generation": closed_generation,
                "baseline_restored": bool(state[7]),
            }

            audit = one(
                cursor,
                "select valid,entry_count,tip_hash,reason from governance_private.verify_recovery_audit_chain()",
            )
            if not audit[0] or int(audit[1]) <= 0 or len(str(audit[2])) != 64 or audit[3] != "chain_valid":
                raise RuntimeError("recovery audit chain verification failed")
            evidence["audit_chain"] = {
                "valid": bool(audit[0]),
                "entry_count": int(audit[1]),
                "tip_hash": str(audit[2]),
                "reason": str(audit[3]),
            }

            privileges = one(
                cursor,
                "select "
                "has_function_privilege('service_role','governance_private.attempt_recovery_drill_mutation(text,text,text,text,bigint,text,text,text)','EXECUTE'),"
                "has_function_privilege('service_role','governance_private.begin_recovery_drill(text,text,text,text,text,text)','EXECUTE'),"
                "has_function_privilege('service_role','governance_private.contain_recovery_drill(text,text)','EXECUTE'),"
                "has_function_privilege('service_role','governance_private.rollback_recovery_drill(text,text,text)','EXECUTE'),"
                "has_function_privilege('service_role','governance_private.resume_recovery_drill(text,text,text)','EXECUTE'),"
                "has_function_privilege('service_role','governance_private.close_recovery_drill(text,text)','EXECUTE')",
            )
            expected = (True, False, False, False, False, False)
            if tuple(bool(x) for x in privileges) != expected:
                raise RuntimeError(f"recovery authority separation invalid: {privileges!r}")
            evidence["authority_separation"] = {
                "service_role_bounded_mutation": True,
                "service_role_begin": False,
                "service_role_contain": False,
                "service_role_rollback": False,
                "service_role_resume": False,
                "service_role_close": False,
            }
            evidence["scenarios"]["source_compromise_emergency_bypass"] = {
                "accepted": False,
                "reason": "normal_service_role_has_no_emergency_recovery_authority",
            }
            evidence["scenarios"]["bypass_attempt"] = {
                "accepted": False,
                "reason": "emergency_functions_not_executable_by_service_role",
            }

            direct = one(
                cursor,
                "select "
                "has_table_privilege('service_role','governance_private.recovery_drill_state','SELECT'),"
                "has_table_privilege('service_role','governance_private.recovery_drill_state','UPDATE'),"
                "has_table_privilege('service_role','governance_private.recovery_audit','SELECT'),"
                "has_table_privilege('service_role','governance_private.recovery_audit','UPDATE')",
            )
            if any(bool(x) for x in direct):
                raise RuntimeError(f"service_role has direct recovery table privileges: {direct!r}")
            evidence["direct_table_access_denied"] = True

    evidence["passed"] = True
    evidence["evidence_hash"] = h(json.dumps(evidence, sort_keys=True, separators=(",", ":")))
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_text(json.dumps(evidence, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return evidence


def main() -> int:
    result = run()
    print(json.dumps({"passed": result["passed"], "run_id": result["run_id"], "evidence_hash": result["evidence_hash"]}, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
