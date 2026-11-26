#!/usr/bin/env python3
"""Reproducible technical assurance for archived V1.10 evidence; not formal IV&V."""
import argparse, hashlib, io, json, os, re, urllib.parse, urllib.request, zipfile

REPO = "Henolos/litd"
API = "https://api.github.com/repos/" + REPO
RAW = "https://raw.githubusercontent.com/" + REPO
RUN, ATTEMPT, JOB = "45410435324", 2, "139560963765"
HEAD = "42f9b16541dae2046a0824dc0d99629948b7ec6e"
MERGE_REF = "bc7ffcd406e3e67b211ba06a1b84379d27fe8b9e"
FINAL_MERGE = "547e8153a45ea87005829b8f220f2ace8852610e"
BASE = "7ac9bfffdcc2457b1b26262a1fee7b81c321ba78"
TREE = "c1895a2d004e427cae0736e34bbcf15c7c83070c"
MANIFEST = "tools/qa/litd_exploration_validator/v1_10/SHA256SUMS.txt"
MANIFEST_BLOB = "dda5c8839e4df653860bb514a47b544d463a8591"
WORKFLOW = ".github/workflows/litd-validator-v110.yml"


class SafeRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        new = super().redirect_request(req, fp, code, msg, headers, newurl)
        if new and urllib.parse.urlsplit(req.full_url).netloc != urllib.parse.urlsplit(newurl).netloc:
            new.remove_header("Authorization")
            new.remove_header("Cookie")
        return new


OPENER = urllib.request.build_opener(SafeRedirect())


def read_url(url, token=None):
    headers = {"User-Agent": "LITD-V1.10-evidence-assurance"}
    if token:
        headers.update({"Accept": "application/vnd.github+json",
                        "X-GitHub-Api-Version": "2022-11-28",
                        "Authorization": "Bearer " + token})
    with OPENER.open(urllib.request.Request(url, headers=headers), timeout=60) as response:
        return response.read()


def api_json(path, token):
    return json.loads(read_url(API + path, token).decode("utf-8"))


def raw(ref, path):
    return read_url(RAW + "/" + ref + "/" + urllib.parse.quote(path, safe="/"))


def tree_control():
    commits = {}
    for label, sha in (("pr_head", HEAD), ("actions_merge_ref", MERGE_REF), ("final_merge", FINAL_MERGE)):
        obj = api_json("/commits/" + sha, os.environ["GITHUB_TOKEN"])
        commits[label] = {"sha": obj["sha"], "tree": obj["commit"]["tree"]["sha"],
                          "parents": [p["sha"] for p in obj["parents"]]}
    if any(c["tree"] != TREE for c in commits.values()):
        raise ValueError("Commit tree mismatch")
    if set(commits["actions_merge_ref"]["parents"]) != {BASE, HEAD}:
        raise ValueError("Actions merge-ref parents do not match recorded base/head")
    return {"tree": TREE, "commits": commits}


def hash_control():
    manifest = raw(FINAL_MERGE, MANIFEST)
    blob_sha = hashlib.sha1(b"blob " + str(len(manifest)).encode() + bytes([0]) + manifest).hexdigest()
    if blob_sha != MANIFEST_BLOB:
        raise ValueError("Manifest Git blob SHA mismatch: " + blob_sha)
    rows = []
    for line in manifest.decode().splitlines():
        parts = line.split("  ", 1)
        if len(parts) != 2 or not re.fullmatch("[0-9a-f]{64}", parts[0]):
            raise ValueError("Malformed manifest row")
        if "/" in parts[1] or parts[1] in ("", ".", ".."):
            raise ValueError("Unsafe manifest filename")
        rows.append((parts[0], parts[1]))
    if len(rows) != 43 or len({name for _, name in rows}) != 43:
        raise ValueError("Expected 43 unique manifest entries")
    matches = []
    for expected, name in rows:
        data = raw(FINAL_MERGE, "tools/qa/litd_exploration_validator/v1_10/" + name)
        actual = hashlib.sha256(data).hexdigest()
        if actual != expected:
            raise ValueError("SHA-256 mismatch for " + name)
        matches.append({"file": name, "sha256": actual})
    return {"manifest_blob_sha1": blob_sha, "files_checked": len(matches),
            "files_matched": len(matches), "files": matches}


def metadata_control():
    token = os.environ["GITHUB_TOKEN"]
    run = api_json("/actions/runs/" + RUN, token)
    if run.get("head_sha") != HEAD or run.get("run_attempt") != ATTEMPT or run.get("conclusion") != "success":
        raise ValueError("Run metadata differs from the recorded successful attempt")
    jobs = api_json("/actions/runs/" + RUN + "/attempts/" + str(ATTEMPT) + "/jobs?per_page=100", token).get("jobs", [])
    job = next((x for x in jobs if str(x.get("id")) == JOB), None)
    if not job or job.get("name") != "validator-tests" or job.get("conclusion") != "success":
        raise ValueError("Validator job metadata did not pass")
    return {"run_id": RUN, "attempt": ATTEMPT, "head_sha": HEAD, "run_conclusion": run["conclusion"],
            "job_id": JOB, "job_conclusion": job["conclusion"]}


def log_control():
    token = os.environ["GITHUB_TOKEN"]
    import subprocess
    env = dict(os.environ)
    env["GH_TOKEN"] = token
    completed = subprocess.run(
        ["gh", "run", "view", RUN, "--attempt", str(ATTEMPT), "--job", JOB,
         "--log", "--repo", REPO],
        text=True, capture_output=True, env=env, check=False,
    )
    if completed.returncode != 0:
        raise ValueError("gh run view could not retrieve the pinned job logs: " + completed.stderr[-500:])
    log = completed.stdout
    workflow = raw(FINAL_MERGE, WORKFLOW).decode()
    checks = {
        "merge_ref_checkout": "refs/remotes/pull/642/merge" in log and "HEAD is now at bc7ffcd" in log,
        "unittest_command": "python -m unittest discover -s . -p 'test_*.py' -v" in log,
        "84_tests_and_ok": re.search(r"Ran 84 tests in [0-9.]+s", log) is not None and any(line.split()[-1:] == ["OK"] for line in log.splitlines()),
        "python_3_12": "python-version: '3.12'" in workflow,
        "jsonschema_4_26_0": "jsonschema-4.26.0" in log and "4.26.0" in workflow,
    }
    failed = [key for key, ok in checks.items() if not ok]
    if failed:
        raise ValueError("Missing Actions log/config evidence: " + ", ".join(failed))
    elapsed = re.search(r"Ran 84 tests in ([0-9.]+)s", log).group(1)
    return {"checks": checks, "tests": 84, "elapsed_seconds": elapsed,
            "python": "3.12", "jsonschema": "4.26.0"}


CONTROLS = {
    "tree": ("C01-git-tree-identity", tree_control),
    "hashes": ("C02-manifest-sha256", hash_control),
    "metadata": ("C03-actions-run-metadata", metadata_control),
    "logs": ("C04-actions-job-logs", log_control),
}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--control", choices=sorted(CONTROLS), required=True)
    control, check = CONTROLS[parser.parse_args().control]
    try:
        result = {"control": control, "status": "PASS", "evidence": check()}
        status = 0
    except Exception as exc:
        result = {"control": control, "status": "FAIL", "error": type(exc).__name__ + ": " + str(exc)}
        status = 1
    rendered = json.dumps(result, ensure_ascii=False, sort_keys=True)
    print(rendered)
    summary = os.getenv("GITHUB_STEP_SUMMARY")
    if summary:
        with open(summary, "a", encoding="utf-8") as out:
            out.write("## " + control + ": " + result["status"] + "\n\n")
            out.write(rendered + "\n")
    return status


if __name__ == "__main__":
    raise SystemExit(main())
