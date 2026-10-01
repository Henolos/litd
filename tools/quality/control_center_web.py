#!/usr/bin/env python3
"""Render a self-contained read-only Control Center HTML surface."""
from __future__ import annotations

import argparse
import html
import json
from pathlib import Path
from typing import Any


def _text(value: Any) -> str:
    return html.escape("—" if value is None else str(value))


def render(snapshot: dict[str, Any]) -> str:
    if snapshot.get("authority") != "read_only_control_center_snapshot":
        raise ValueError("refusing to render an untrusted snapshot")
    checks = snapshot.get("checks") if isinstance(snapshot.get("checks"), dict) else {}
    sources = snapshot.get("sources") if isinstance(snapshot.get("sources"), dict) else {}
    rows = [
        ("Project", snapshot.get("project")),
        ("Change Record", snapshot.get("change_record")),
        ("Phase", snapshot.get("phase")),
        ("Status", snapshot.get("status")),
        ("PR", snapshot.get("pr")),
        ("Head SHA", snapshot.get("head_sha")),
        ("Checks", f'{checks.get("passed", 0)}/{checks.get("total", 0)}'),
        ("Last evidence", snapshot.get("last_evidence")),
        ("Blocker", snapshot.get("blocker")),
        ("Needs human?", snapshot.get("needs_human")),
        ("Updated at", snapshot.get("updated_at")),
    ]
    body = "".join(
        f"<tr><th>{html.escape(label)}</th><td>{_text(value)}</td></tr>"
        for label, value in rows
    )
    source_items = "".join(
        f"<li><strong>{html.escape(str(key))}</strong>: {_text(value)}</li>"
        for key, value in sorted(sources.items())
    )

    catalog = snapshot.get("domain_catalog") if isinstance(snapshot.get("domain_catalog"), dict) else {}
    views = catalog.get("views") if isinstance(catalog.get("views"), list) else []
    view_rows = "".join(
        "<tr>"
        f"<td>{_text(view.get('id'))}</td>"
        f"<td>{_text(view.get('kind'))}</td>"
        f"<td>{_text(view.get('authority_scope'))}</td>"
        f"<td>{_text(view.get('status'))}</td>"
        "</tr>"
        for view in views
        if isinstance(view, dict)
    )
    if not view_rows:
        view_rows = '<tr><td colspan="4">—</td></tr>'

    operational = snapshot.get("operational_indicators") if isinstance(snapshot.get("operational_indicators"), dict) else {}
    indicators = operational.get("indicators") if isinstance(operational.get("indicators"), list) else []
    indicator_rows = "".join(
        "<tr>"
        f"<td>{_text(row.get('view_id'))}</td>"
        f"<td>{_text(row.get('signal'))}</td>"
        f"<td>{_text(row.get('evidence_state'))}</td>"
        f"<td>{_text(row.get('run_id'))}</td>"
        f"<td>{_text(row.get('event'))}</td>"
        f"<td>{_text(row.get('head_sha'))}</td>"
        f"<td>{_text(row.get('updated_at'))}</td>"
        "</tr>"
        for row in indicators
        if isinstance(row, dict)
    )
    if not indicator_rows:
        indicator_rows = '<tr><td colspan="7">—</td></tr>'
    semantics = operational.get("semantics")

    status = html.escape(str(snapshot.get("status", "UNKNOWN")))
    return f"""<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>HENOLOS Control Center</title>
<style>
:root {{ color-scheme: dark; font-family: system-ui, sans-serif; }}
body {{ max-width: 1200px; margin: 0 auto; padding: 2rem 1rem; background:#0b0d10; color:#f3f5f7; }}
header,section {{ border:1px solid #30363d; border-radius:14px; padding:1rem 1.2rem; margin-bottom:1rem; background:#11151a; }}
h1 {{ margin:.2rem 0; }} .status {{ font-weight:700; }}
table {{ width:100%; border-collapse:collapse; }} th,td {{ padding:.65rem; border-bottom:1px solid #30363d; text-align:left; overflow-wrap:anywhere; }}
th {{ color:#aab3bd; }} ul {{ padding-left:1.25rem; }}
small {{ color:#8b949e; }}
.note {{ color:#aab3bd; }}
</style>
</head>
<body>
<header><small>READ-ONLY OPERATIONAL VIEW</small><h1>HENOLOS Control Center</h1><p class="status">{status}</p></header>
<section><h2>Current snapshot</h2><table>{body}</table></section>
<section><h2>Domains &amp; views</h2><table><thead><tr><th>ID</th><th>Type</th><th>Authority scope</th><th>Status</th></tr></thead><tbody>{view_rows}</tbody></table></section>
<section><h2>Operational evidence</h2><p class="note">{_text(semantics)}</p><table><thead><tr><th>View</th><th>Signal</th><th>Evidence</th><th>Run</th><th>Event</th><th>Head SHA</th><th>Updated</th></tr></thead><tbody>{indicator_rows}</tbody></table></section>
<section><h2>External services</h2><p class="note">{_text(external_semantics)}</p><table><thead><tr><th>View</th><th>Service</th><th>State</th><th>Visibility</th><th>Region</th><th>Security advisories</th><th>Performance advisories</th><th>Observed</th></tr></thead><tbody>{external_rows}</tbody></table></section>\n<section><h2>Sources</h2><ul>{source_items}</ul></section>
</body>
</html>
"""


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--snapshot", default="reports/control-center-snapshot.json")
    parser.add_argument("--output", default="reports/control-center/index.html")
    args = parser.parse_args()
    snapshot = json.loads(Path(args.snapshot).read_text(encoding="utf-8"))
    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(render(snapshot), encoding="utf-8")
    print(json.dumps({"output": str(output), "mode": "read_only"}))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
