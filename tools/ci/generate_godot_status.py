#!/usr/bin/env python3
"""Generate a human-readable Godot CI control dashboard from verbose export logs."""
from __future__ import annotations

import argparse
import html
import json
import re
from pathlib import Path

ANSI_RE = re.compile(r"\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])")
PROGRESS_RE = re.compile(r"\[\s*(\d{1,3})%\s*\]")
RES_RE = re.compile(r"res://[^\s\"'<>)]+'?")
EXIT_RE = re.compile(r"Godot exit code:\s*(-?\d+)")


def clean(value: str) -> str:
    return ANSI_RE.sub("", value).replace("\x00", "")


def parse(log_text: str, diag_text: str, refs_text: str) -> dict[str, object]:
    text = clean(log_text)
    lines = text.splitlines()
    progress = 0
    current_file = ""
    for line in lines:
        match = PROGRESS_RE.search(line)
        if match:
            progress = max(progress, min(100, int(match.group(1))))
        paths = RES_RE.findall(line)
        if paths:
            current_file = paths[-1].rstrip("'.,:;")

    exit_code = None
    for match in EXIT_RE.finditer(text):
        exit_code = int(match.group(1))

    refs = sorted({clean(item).strip().rstrip("'.,:;") for item in refs_text.splitlines() if item.strip()})
    project_refs = [item for item in refs if not item.startswith("res://.godot/")]
    diag_lines = [clean(item).strip() for item in diag_text.splitlines() if item.strip()]
    errors: list[str] = []
    warnings: list[str] = []
    notices: list[str] = []
    for line in diag_lines:
        upper = line.upper()
        if "WARNING" in upper:
            warnings.append(line)
        elif "ERROR" in upper or "PARSE ERROR" in upper or "SCRIPT ERROR" in upper:
            errors.append(line)
        else:
            notices.append(line)

    for line in lines:
        if "cannot connect to daemon at tcp:5037" in line.lower() and line.strip() not in notices:
            notices.append(line.strip())

    if exit_code == 0:
        progress = 100

    return {
        "progress": progress,
        "current_file": current_file,
        "exit_code": exit_code,
        "status": "success" if exit_code == 0 else ("failure" if exit_code is not None else "unknown"),
        "errors": errors,
        "warnings": warnings,
        "notices": notices,
        "referenced_files_count": len(refs),
        "project_files_count": len(project_refs),
        "sample_files": project_refs[-40:],
    }


def render(data: dict[str, object], repo: str, workflow: str, run_number: str, run_id: str, sha: str) -> str:
    errors = list(data["errors"])
    warnings = list(data["warnings"])
    notices = list(data["notices"])
    sample_files = list(data["sample_files"])
    embedded = json.dumps(data, ensure_ascii=False).replace("</", "<\\/")
    title = "LITD · Godot Control Console"
    diagnostics = "\n".join(errors + warnings + notices) or "Aucun diagnostic détecté."
    files = "\n".join(sample_files) or "—"
    current_file = str(data["current_file"] or "—")
    progress = int(data["progress"])
    status = str(data["status"])
    project_files_count = int(data["project_files_count"])
    return f'''<!doctype html>
<html lang="fr"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>{title}</title>
<style>
:root{{--bg:#0d1017;--panel:#161b22;--line:#30363d;--text:#e6edf3;--muted:#8b949e;--ok:#3fb950;--warn:#d29922;--bad:#f85149;--accent:#58a6ff}}
*{{box-sizing:border-box}} body{{margin:0;background:var(--bg);color:var(--text);font:15px/1.45 system-ui,-apple-system,Segoe UI,sans-serif}} main{{max-width:1100px;margin:auto;padding:24px}} h1{{font-size:25px;margin:0 0 5px}} .sub{{color:var(--muted);margin-bottom:22px}} .grid{{display:grid;grid-template-columns:repeat(auto-fit,minmax(210px,1fr));gap:12px}} .card{{background:var(--panel);border:1px solid var(--line);border-radius:10px;padding:16px}} .label{{color:var(--muted);font-size:12px;text-transform:uppercase;letter-spacing:.06em}} .value{{font-size:21px;font-weight:700;margin-top:4px;word-break:break-word}} .bar{{height:10px;background:#21262d;border-radius:999px;overflow:hidden;margin-top:10px}} .bar>i{{display:block;height:100%;width:0;background:var(--accent);transition:width .25s}} .ok{{color:var(--ok)}} .warn{{color:var(--warn)}} .bad{{color:var(--bad)}} code{{font-family:ui-monospace,SFMono-Regular,Menlo,monospace;font-size:12px}} pre{{white-space:pre-wrap;overflow-wrap:anywhere;max-height:280px;overflow:auto;background:#0d1117;padding:12px;border-radius:7px;border:1px solid var(--line)}} a{{color:var(--accent)}} .row{{display:flex;gap:10px;flex-wrap:wrap;align-items:center}} .pill{{border:1px solid var(--line);border-radius:999px;padding:4px 9px;color:var(--muted)}} .wide{{margin-top:12px}} footer{{color:var(--muted);margin-top:18px;font-size:12px}}
</style></head><body><main>
<h1>{title}</h1><div class="sub">Suivi du workflow <code>{html.escape(workflow)}</code> · dépôt <code>{html.escape(repo)}</code></div>
<div class="grid">
 <section class="card"><div class="label">Run GitHub</div><div class="value" id="run">#{html.escape(run_number)}</div><div class="row"><span class="pill" id="runStatus">chargement…</span><a id="runLink" href="https://github.com/{html.escape(repo)}/actions/runs/{html.escape(run_id)}">ouvrir Actions</a></div></section>
 <section class="card"><div class="label">Progression Godot</div><div class="value"><span id="progress">{progress}</span>%</div><div class="bar"><i id="bar" style="width:{progress}%"></i></div></section>
 <section class="card"><div class="label">Erreurs / warnings</div><div class="value"><span id="errCount">{len(errors)}</span> / <span id="warnCount">{len(warnings)}</span></div><div class="row"><span class="pill">erreurs</span><span class="pill">warnings</span></div></section>
 <section class="card"><div class="label">Fichiers projet vus</div><div class="value" id="fileCount">{project_files_count}</div><div class="pill">références uniques</div></section>
</div>
<section class="card wide"><div class="label">Fichier courant / dernier fichier observé</div><div class="value"><code id="currentFile">{html.escape(current_file)}</code></div><div class="sub" id="liveHint">Dernier export publié. Connexion à Godot Live Status…</div></section>
<section class="card wide"><div class="label">Étape courante du déploiement Web</div><div class="value" id="currentStep">—</div></section>
<section class="card wide"><div class="row"><strong>Diagnostics du dernier export</strong><span class="pill" id="finalStatus">{html.escape(status)}</span><span class="pill">SHA {html.escape(sha[:12])}</span></div><pre id="diagnostics">{html.escape(diagnostics)}</pre></section>
<section class="card wide"><strong>Derniers fichiers référencés</strong><pre id="files">{html.escape(files)}</pre></section>
<footer>Mise à jour automatique toutes les 15 s. Le temps réel provient du statut GitHub <code>godot-progress</code> publié par le workflow existant Godot Live Status ; le rapport détaillé reste celui du dernier export Web publié.</footer>
<script id="snapshot" type="application/json">{embedded}</script>
<script>
const REPO={json.dumps(repo)}, WF={json.dumps(workflow)};
const $=id=>document.getElementById(id);
function setRunState(run){{
 $('run').textContent='#'+run.run_number; $('runLink').href=run.html_url;
 const st=run.status==='completed'?(run.conclusion||'completed'):run.status; $('runStatus').textContent=st;
 $('runStatus').className='pill '+(st==='success'?'ok':(/failure|cancelled|timed_out/.test(st)?'bad':''));
 $('finalStatus').textContent=st;
}}
function applyGodotProgress(status){{
 const description=status.description||'';
 let match=description.match(/^(\d+)\/(\d+)\s+(\d+)%\s+([A-Z]+)\s+(.+)$/);
 if(match){{
   const [,step,total,percent,state,file]=match;
   $('progress').textContent=percent; $('bar').style.width=Math.min(100,+percent)+'%';
   if(file && file!=='Godot CI') $('currentFile').textContent=file;
   $('liveHint').textContent=`Godot Live Status · ${{step}}/${{total}} · ${{state}}`;
   return;
 }}
 match=description.match(/^(\d+)\/(\d+)\s+ERROR\s+(.+)$/);
 if(match){{
   const [,step,total,file]=match; const percent=total?Math.floor((+step/+total)*100):0;
   $('progress').textContent=percent; $('bar').style.width=Math.min(100,percent)+'%'; $('currentFile').textContent=file;
   $('liveHint').textContent=`Godot Live Status · ${{step}}/${{total}} · ERROR`;
   return;
 }}
 if(status.state==='success'){{ $('progress').textContent='100'; $('bar').style.width='100%'; }}
 $('liveHint').textContent='Godot Live Status · '+(description||status.state||'état inconnu');
}}
async function refresh(){{
 try{{
  const opts={{cache:'no-store',headers:{{Accept:'application/vnd.github+json'}}}};
  const rr=await fetch(`https://api.github.com/repos/${{REPO}}/actions/workflows/${{encodeURIComponent(WF)}}/runs?branch=main&per_page=1`,opts);
  if(!rr.ok) throw new Error('runs '+rr.status);
  const run=(await rr.json()).workflow_runs[0]; if(!run)return; setRunState(run);
  const jr=await fetch(`https://api.github.com/repos/${{REPO}}/actions/runs/${{run.id}}/jobs?per_page=100`,opts);
  if(jr.ok){{
    const jobs=(await jr.json()).jobs||[]; const build=jobs.find(j=>j.name==='Export Godot Web PWA')||jobs[0];
    if(build){{ const step=(build.steps||[]).find(s=>s.status==='in_progress') || [...(build.steps||[])].reverse().find(s=>s.status==='completed'); $('currentStep').textContent=step?`${{step.name}} · ${{step.status}}`:`${{build.name}} · ${{build.status}}`; }}
  }}
  const sr=await fetch(`https://api.github.com/repos/${{REPO}}/commits/${{run.head_sha}}/status`,opts);
  if(sr.ok){{ const combined=await sr.json(); const live=(combined.statuses||[]).find(s=>s.context==='godot-progress'); if(live) applyGodotProgress(live); else $('liveHint').textContent='Godot Live Status · aucun statut godot-progress pour ce SHA'; }}
  else $('liveHint').textContent='Statut du run actif ; Godot Live Status momentanément indisponible.';
 }}catch(e){{ $('runStatus').textContent='indisponible'; $('liveHint').textContent='Dernier export publié (API GitHub momentanément indisponible).'; }}
}}
refresh(); setInterval(refresh,15000);
</script></main></body></html>'''


def read_text(path: str) -> str:
    candidate = Path(path)
    if not candidate.exists():
        return ""
    return candidate.read_text(encoding="utf-8", errors="replace")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--log", required=True)
    parser.add_argument("--diagnostics", required=True)
    parser.add_argument("--refs", required=True)
    parser.add_argument("--output-html", required=True)
    parser.add_argument("--output-json", required=True)
    parser.add_argument("--repo", default="hodaesu/litd")
    parser.add_argument("--workflow", default="web-playtest-pages.yml")
    parser.add_argument("--run-number", default="0")
    parser.add_argument("--run-id", default="0")
    parser.add_argument("--sha", default="unknown")
    args = parser.parse_args()

    data = parse(read_text(args.log), read_text(args.diagnostics), read_text(args.refs))
    output_json = Path(args.output_json)
    output_html = Path(args.output_html)
    output_json.parent.mkdir(parents=True, exist_ok=True)
    output_html.parent.mkdir(parents=True, exist_ok=True)
    output_json.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    output_html.write_text(render(data, args.repo, args.workflow, args.run_number, args.run_id, args.sha), encoding="utf-8")
    print(
        "GODOT_STATUS_DASHBOARD_OK "
        f"status={data['status']} progress={data['progress']} files={data['project_files_count']} "
        f"errors={len(data['errors'])} warnings={len(data['warnings'])}"
    )


if __name__ == "__main__":
    main()
