#!/usr/bin/env bash
set -euo pipefail

ERROR_PATTERN='SCRIPT ERROR:|ERROR: Failed to load script|ERROR: Failed to create an autoload|ERROR: Failed to instantiate an autoload|ERROR: FATAL:|handle_crash: Program crashed'

usage() {
  cat >&2 <<'EOF'
Usage:
  run_godot_checked.sh --log <path> [--expect <text>] [--reject <text>]... -- <command> [args...]

The wrapped command output is tee'd to the log. The wrapper fails when:
- the command exits non-zero;
- a canonical Godot fatal/script error is present;
- any --reject marker is present;
- an --expect marker is missing.
EOF
  exit 2
}

log_path=""
expect_marker=""
declare -a reject_markers=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --log)
      [[ $# -ge 2 ]] || usage
      log_path="$2"
      shift 2
      ;;
    --expect)
      [[ $# -ge 2 ]] || usage
      expect_marker="$2"
      shift 2
      ;;
    --reject)
      [[ $# -ge 2 ]] || usage
      reject_markers+=("$2")
      shift 2
      ;;
    --)
      shift
      break
      ;;
    *)
      usage
      ;;
  esac
done

[[ -n "$log_path" ]] || usage
[[ $# -gt 0 ]] || usage

mkdir -p "$(dirname "$log_path")"

set +e
"$@" 2>&1 | tee "$log_path"
command_status=${PIPESTATUS[0]}
set -e

if [[ $command_status -ne 0 ]]; then
  echo "GODOT_CHECKED_COMMAND_FAILED status=$command_status log=$log_path" >&2
  exit "$command_status"
fi

if grep -E "$ERROR_PATTERN" "$log_path" >/dev/null; then
  echo "GODOT_CHECKED_FATAL_PATTERN log=$log_path" >&2
  grep -E "$ERROR_PATTERN" "$log_path" >&2 || true
  exit 1
fi

for marker in "${reject_markers[@]}"; do
  if grep -F -- "$marker" "$log_path" >/dev/null; then
    echo "GODOT_CHECKED_REJECT marker=$marker log=$log_path" >&2
    exit 1
  fi
done

if [[ -n "$expect_marker" ]] && ! grep -F -- "$expect_marker" "$log_path" >/dev/null; then
  echo "GODOT_CHECKED_EXPECT_MISSING marker=$expect_marker log=$log_path" >&2
  exit 1
fi

echo "GODOT_CHECKED_OK log=$log_path"
