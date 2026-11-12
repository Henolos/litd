#!/usr/bin/env python3
"""Conservative selector for the retained technical foundation after the LITD 1 reset."""
from __future__ import annotations
import argparse
import json
from pathlib import Path
import re

ALL_DOMAINS = ('technical',)
ROOT = Path(__file__).resolve().parents[2]


def domain_test_owners() -> dict[str, set[str]]:
    runner = (ROOT / 'tools/build/run_godot_ci.sh').read_text()
    paths = re.findall(r'res://((?:tests/godot|scripts/tests|scenes/tests)/[\w.-]+\.(?:tscn|gd))', runner)
    if not paths:
        raise ValueError('The technical runner has no tests')
    return {path: {'technical'} for path in paths}


def select_domains(files: list[str]) -> list[str]:
    # No application domains remain. Unknown changes also get the complete suite.
    return list(ALL_DOMAINS)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument('--all', action='store_true')
    parser.add_argument('--files-from', type=Path)
    parser.add_argument('--github-output', type=Path)
    args = parser.parse_args()
    files = args.files_from.read_text().splitlines() if args.files_from and not args.all else []
    payload = {'domains': select_domains(files), 'mode': 'full', 'changed_count': len(files)}
    print(json.dumps(payload))
    if args.github_output:
        with args.github_output.open('a') as handle:
            for key, value in payload.items():
                handle.write(f'{key}={json.dumps(value) if isinstance(value, list) else value}\n')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
