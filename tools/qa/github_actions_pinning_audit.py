#!/usr/bin/env python3
from __future__ import annotations

import argparse
import pathlib
import re
import subprocess
import sys

SHA_RE = re.compile(r"^[0-9a-fA-F]{40}$")
USES_RE = re.compile(r"^\s*-?\s*uses:\s*([^\s#]+)")
WORKFLOWS_DIR = pathlib.Path(".github/workflows")


def git(*args: str) -> str:
    return subprocess.check_output(["git", *args], text=True).strip()


def changed_workflows(base: str, head: str) -> list[pathlib.Path]:
    out = git("diff", "--name-only", f"{base}...{head}", "--", str(WORKFLOWS_DIR))
    return [pathlib.Path(p) for p in out.splitlines() if p.endswith((".yml", ".yaml"))]


def all_workflows() -> list[pathlib.Path]:
    return sorted(
        path
        for path in WORKFLOWS_DIR.rglob("*")
        if path.is_file() and path.suffix in (".yml", ".yaml")
    )


def validate(path: pathlib.Path) -> list[str]:
    errors: list[str] = []
    if not path.exists():
        return errors
    for lineno, raw in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        match = USES_RE.match(raw)
        if not match:
            continue
        ref = match.group(1)
        if ref.startswith("./") or ref.startswith("docker://"):
            continue
        if "@" not in ref:
            errors.append(f"{path}:{lineno}: action sans ref immuable: {ref}")
            continue
        _, version = ref.rsplit("@", 1)
        if not SHA_RE.fullmatch(version):
            errors.append(f"{path}:{lineno}: action non pinnee sur SHA 40 hex: {ref}")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--base", default="origin/main")
    parser.add_argument("--head", default="HEAD")
    parser.add_argument(
        "--all",
        action="store_true",
        help="audit every workflow in .github/workflows instead of changed workflows only",
    )
    args = parser.parse_args()

    files = all_workflows() if args.all else changed_workflows(args.base, args.head)
    failures: list[str] = []
    for path in files:
        failures.extend(validate(path))

    scope = "repository-wide" if args.all else "changed-workflows"
    if failures:
        print(f"GitHub Actions pinning audit: FAIL ({scope})", file=sys.stderr)
        for item in failures:
            print(f"- {item}", file=sys.stderr)
        return 1

    print(f"GitHub Actions pinning audit: PASS ({scope}, {len(files)} workflow(s))")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
