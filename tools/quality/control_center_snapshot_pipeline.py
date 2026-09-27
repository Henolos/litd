#!/usr/bin/env python3
"""Connect read-only Control Center source payloads to the snapshot composer."""
from __future__ import annotations
import argparse, json
from pathlib import Path
from typing import Any
from tools.quality.control_center_operational_snapshot import compose

def build_snapshot(github_source: dict[str, Any], memory_source: dict[str, Any], *, project: str, change_record: str | None = None, phase: str = "verification", needs_human: bool = False, blocker: str | None = None) -> dict[str, Any]:
    """Build one snapshot without granting either source mutation authority."""
    if github_source.get("source") != "github_api_read_only": raise ValueError("untrusted GitHub source")
    if memory_source.get("source") != "repository_memory_read_only": raise ValueError("untrusted MEMORY source")
    pr=github_source.get("pr"); workflows=github_source.get("workflow_runs"); receipts=memory_source.get("closure_receipts")
    if not isinstance(pr,dict): raise ValueError("GitHub source must contain pr")
    if not isinstance(workflows,list): raise ValueError("GitHub source must contain workflow_runs")
    if not isinstance(receipts,list): raise ValueError("MEMORY source must contain closure_receipts")
    snapshot=compose(pr,workflows,receipts,project=project,change_record=change_record,phase=phase,needs_human=needs_human,blocker=blocker)
    snapshot["sources"]={"github":"github_api_read_only","memory":"repository_memory_read_only","registry_evidence_count":len(memory_source.get("registry_evidence",[]))}
    snapshot["authority"]="read_only_control_center_snapshot"
    return snapshot

def main()->int:
    p=argparse.ArgumentParser(); p.add_argument("--github",required=True); p.add_argument("--memory",required=True); p.add_argument("--project",required=True); p.add_argument("--change-record"); p.add_argument("--phase",default="verification"); p.add_argument("--output",default="reports/control-center-snapshot.json"); args=p.parse_args()
    load=lambda x: json.loads(Path(x).read_text(encoding="utf-8"))
    result=build_snapshot(load(args.github),load(args.memory),project=args.project,change_record=args.change_record,phase=args.phase)
    output=Path(args.output); output.parent.mkdir(parents=True,exist_ok=True); output.write_text(json.dumps(result,indent=2,sort_keys=True)+"\n",encoding="utf-8")
    print(json.dumps({"status":result["status"],"output":str(output)},sort_keys=True)); return 0
if __name__=="__main__": raise SystemExit(main())
