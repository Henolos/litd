#!/usr/bin/env python3
"""Final governed application decision for bounded LITD implementations."""
from __future__ import annotations

import argparse
import json
from datetime import datetime
from hashlib import sha256
from pathlib import Path
from typing import Any

from tools.quality.guardian_authority_contract import CANONICAL_AUTHORITY, assert_authority_equivalent
from tools.quality.veilleur_v2_ingest import PROJECT_ID, TARGET_ROUTE

ALLOWED_DECISIONS = {"APPLY_CHANGE", "REJECT_IMPLEMENTATION", "REQUEST_MORE_EVIDENCE"}
ALLOWED_MEASUREMENT_ASSESSMENTS = {"NO_BLOCKING_REGRESSION", "BLOCKING_REGRESSION", "INCONCLUSIVE"}
AUTHORITY_KEYS = ("core_write_allowed", "automatic_merge_allowed", "automatic_application_allowed", "automatic_target_change_allowed")


def _hash(payload: dict[str, Any]) -> str:
    raw = json.dumps(payload, sort_keys=True, separators=(",", ":"), ensure_ascii=False)
    return sha256(raw.encode("utf-8")).hexdigest()


def _verify_embedded_hash(payload: dict[str, Any], field: str) -> None:
    claimed = payload.get(field)
    if not isinstance(claimed, str) or len(claimed) != 64 or any(ch not in "0123456789abcdef" for ch in claimed): raise ValueError(f"invalid {field}")
    if claimed != _hash({key: value for key, value in payload.items() if key != field}): raise ValueError(f"{field} integrity mismatch")


def _aware_iso(value: Any) -> bool:
    if not isinstance(value, str) or not value.strip(): return False
    try: dt = datetime.fromisoformat(value.replace("Z", "+00:00"))
    except ValueError: return False
    return dt.tzinfo is not None and dt.utcoffset() is not None


def _nonempty_strings(value: Any) -> bool: return isinstance(value, list) and bool(value) and all(isinstance(x, str) and x.strip() for x in value)
def _lower_hex(value: Any, length: int) -> bool: return isinstance(value, str) and len(value) == length and all(c in "0123456789abcdef" for c in value)


def evaluate(evaluation: dict[str, Any], decision: dict[str, Any]) -> dict[str, Any]:
    _verify_embedded_hash(evaluation, "evaluation_hash")
    if evaluation.get("kind") != "LITD_BOUNDED_IMPLEMENTATION_EVALUATION": raise ValueError("invalid bounded implementation evaluation kind")
    if evaluation.get("project_id") != PROJECT_ID: raise ValueError("implementation evaluation project scope mismatch")
    if evaluation.get("target_route") != TARGET_ROUTE: raise ValueError("implementation evaluation route scope mismatch")
    if evaluation.get("status") != "READY_FOR_APPLICATION_REVIEW": raise ValueError("implementation is not ready for application review")
    if evaluation.get("blockers") != []: raise ValueError("application review requires zero blockers")
    if evaluation.get("measurements_comparable") is not True: raise ValueError("application review requires comparable measurements")
    assert_authority_equivalent(evaluation, require=AUTHORITY_KEYS)
    if evaluation.get("application_requires_separate_decision") is not True: raise ValueError("separate application decision invariant missing")
    if evaluation.get("rollback_verification_required_before_application") is not True: raise ValueError("rollback verification invariant missing")
    for key in ("source_gate_receipt_hash", "source_candidate_hash", "pre_measurement_hash", "post_measurement_hash"):
        if not _lower_hex(evaluation.get(key), 64): raise ValueError(f"{key} must be 64 lowercase hex")
    if not _lower_hex(evaluation.get("implementation_commit_sha"), 40): raise ValueError("implementation_commit_sha must be 40 lowercase hex")
    if not _nonempty_strings(evaluation.get("rollback_evidence_refs")): raise ValueError("rollback evidence refs required")

    required = {"evaluation_hash", "decision", "decided_by", "decided_at", "rationale", "implementation_commit_sha", "pre_measurement_hash", "post_measurement_hash", "measurement_assessment", "rollback_verified", "evidence_refs"}
    missing = sorted(required - set(decision))
    if missing: raise ValueError("missing application decision fields:" + ",".join(missing))
    for key in ("evaluation_hash", "implementation_commit_sha", "pre_measurement_hash", "post_measurement_hash"):
        expected_key = "evaluation_hash" if key == "evaluation_hash" else key
        if decision[key] != evaluation[expected_key]: raise ValueError(f"{key} mismatch")
    choice = decision["decision"]
    if choice not in ALLOWED_DECISIONS: raise ValueError("unsupported application decision")
    if not isinstance(decision.get("decided_by"), str) or not decision["decided_by"].strip(): raise ValueError("decided_by required")
    if not _aware_iso(decision.get("decided_at")): raise ValueError("decided_at must be timezone-aware ISO-8601")
    if not isinstance(decision.get("rationale"), str) or len(decision["rationale"].strip()) < 20: raise ValueError("decision rationale too short")
    if not _nonempty_strings(decision.get("evidence_refs")): raise ValueError("evidence_refs required")
    assessment = decision["measurement_assessment"]
    if assessment not in ALLOWED_MEASUREMENT_ASSESSMENTS: raise ValueError("unsupported measurement assessment")
    rollback_verified = decision["rollback_verified"]
    if not isinstance(rollback_verified, bool): raise ValueError("rollback_verified must be boolean")
    if choice == "APPLY_CHANGE" and (assessment != "NO_BLOCKING_REGRESSION" or rollback_verified is not True): raise ValueError("APPLY_CHANGE requires no blocking regression and verified rollback")
    outcome = {"APPLY_CHANGE":"APPLICATION_AUTHORIZED_PENDING_SEPARATE_MERGE", "REJECT_IMPLEMENTATION":"IMPLEMENTATION_REJECTED", "REQUEST_MORE_EVIDENCE":"MORE_EVIDENCE_REQUIRED"}[choice]
    receipt = {
        "kind":"LITD_APPLICATION_DECISION_RECEIPT", "project_id":PROJECT_ID, "target_route":TARGET_ROUTE,
        "source_evaluation_hash":evaluation["evaluation_hash"], "source_gate_receipt_hash":evaluation["source_gate_receipt_hash"], "source_candidate_hash":evaluation["source_candidate_hash"],
        "implementation_commit_sha":evaluation["implementation_commit_sha"], "pre_measurement_hash":evaluation["pre_measurement_hash"], "post_measurement_hash":evaluation["post_measurement_hash"],
        "measurement_assessment":assessment, "rollback_verified":rollback_verified, "rollback_evidence_refs":list(evaluation["rollback_evidence_refs"]),
        "decision":choice, "outcome":outcome, "decided_by":decision["decided_by"].strip(), "decided_at":decision["decided_at"], "rationale":decision["rationale"].strip(), "evidence_refs":list(decision["evidence_refs"]),
        "merge_authorized":choice == "APPLY_CHANGE", "merge_must_be_separate_action":True, "post_merge_measurement_required":choice == "APPLY_CHANGE", "provenance_checkpoint_required":choice == "APPLY_CHANGE",
        "core_write_allowed":CANONICAL_AUTHORITY["core_write_allowed"], "automatic_merge_allowed":CANONICAL_AUTHORITY["automatic_merge_allowed"], "automatic_application_allowed":CANONICAL_AUTHORITY["automatic_application_allowed"], "automatic_target_change_allowed":CANONICAL_AUTHORITY["automatic_target_change_allowed"],
        "authority":"application_authorization_receipt_only_separate_merge_and_post_merge_verification_required",
    }
    receipt["application_decision_hash"] = _hash(receipt); return receipt


def main() -> int:
    parser=argparse.ArgumentParser(); parser.add_argument("--evaluation",required=True); parser.add_argument("--decision",required=True); parser.add_argument("--output",default="reports/application-decision.json"); args=parser.parse_args()
    result=evaluate(json.loads(Path(args.evaluation).read_text(encoding="utf-8")),json.loads(Path(args.decision).read_text(encoding="utf-8"))); out=Path(args.output); out.parent.mkdir(parents=True,exist_ok=True); out.write_text(json.dumps(result,ensure_ascii=False,indent=2,sort_keys=True)+"\n",encoding="utf-8"); print(json.dumps({"decision":result["decision"],"outcome":result["outcome"]},sort_keys=True)); return 0


if __name__ == "__main__": raise SystemExit(main())
