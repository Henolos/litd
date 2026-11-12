#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"
python3 -m pytest
python3 tools/qa/reconstruction_audit.py
bash tools/build/run_godot_ci.sh
