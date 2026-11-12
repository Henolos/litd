#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
case "${1:-}" in
  technical) bash "$ROOT_DIR/tools/build/run_godot_ci.sh" ;;
  *) echo "Unknown or retired Godot domain: ${1:-}" >&2; exit 2 ;;
esac
