#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

ERROR_PATTERN='SCRIPT ERROR:|ERROR: Failed to load script|ERROR: Failed to create an autoload|ERROR: Failed to instantiate an autoload|ERROR: FATAL:|handle_crash: Program crashed'
TOTAL_STEPS="$(grep -cE '^run_checked "' "${BASH_SOURCE[0]}")"
CURRENT_STEP=0

progress_file_from_args() {
  local arg
  for arg in "$@"; do
    if [[ "$arg" == res://* ]]; then
      printf '%s' "$arg"
      return 0
    fi
  done
  printf '%s' 'PROJECT_IMPORT'
}

run_checked() {
  local label="$1"
  shift
  local log_file source_file repo_file percent
  log_file="$(mktemp)"
  source_file="$(progress_file_from_args "$@")"
  repo_file="${source_file#res://}"
  CURRENT_STEP=$((CURRENT_STEP + 1))
  percent=$((CURRENT_STEP * 100 / TOTAL_STEPS))

  echo "::group::[GODOT ${CURRENT_STEP}/${TOTAL_STEPS} - ${percent}%] ${label}"
  echo "GODOT_PROGRESS step=${CURRENT_STEP}/${TOTAL_STEPS} percent=${percent} status=START file=${source_file}"
  echo "==> ${label}"

  set +e
  "$@" 2>&1 | tee "$log_file"
  local command_status=${PIPESTATUS[0]}
  set -e

  if [[ $command_status -ne 0 ]]; then
    echo "GODOT_PROGRESS step=${CURRENT_STEP}/${TOTAL_STEPS} percent=${percent} status=ERROR file=${source_file} exit_code=${command_status}" >&2
    if [[ "$source_file" == res://* ]]; then
      echo "::error file=${repo_file}::Godot a quitté avec le code ${command_status} pendant: ${label}" >&2
    else
      echo "::error::Godot a quitté avec le code ${command_status} pendant: ${label}" >&2
    fi
    echo "Godot a quitté avec le code ${command_status} pendant: ${label}" >&2
    rm -f "$log_file"
    echo "::endgroup::"
    return "$command_status"
  fi

  if grep -E "$ERROR_PATTERN" "$log_file" >/dev/null; then
    echo "GODOT_PROGRESS step=${CURRENT_STEP}/${TOTAL_STEPS} percent=${percent} status=ERROR file=${source_file} detected=strict_error_pattern" >&2
    if [[ "$source_file" == res://* ]]; then
      echo "::error file=${repo_file}::Erreurs GDScript/autoload détectées pendant: ${label}" >&2
    else
      echo "::error::Erreurs GDScript/autoload détectées pendant: ${label}" >&2
    fi
    echo "Des erreurs GDScript/autoload ont été détectées pendant: ${label}" >&2
    grep -E "$ERROR_PATTERN" "$log_file" >&2 || true
    rm -f "$log_file"
    echo "::endgroup::"
    return 1
  fi

  echo "GODOT_PROGRESS step=${CURRENT_STEP}/${TOTAL_STEPS} percent=${percent} status=DONE file=${source_file}"
  rm -f "$log_file"
  echo "::endgroup::"
}

sandbox_dir=$(mktemp -d)
trap 'rm -rf "$sandbox_dir"' EXIT
export XDG_DATA_HOME="$sandbox_dir"
export LITD_SAVE_TEST_SANDBOX="$sandbox_dir"
export LITD_SAVE_DELETE_SANDBOX="$sandbox_dir"

run_checked "Import strict du socle" godot --headless --path . --import --quit
run_checked "Compilation et génération déterministe" bash tools/ci/run_godot_checked.sh --log "$sandbox_dir/technical.log" --expect TECHNICAL_FOUNDATION_OK -- godot --headless --path . --script res://tests/godot/test_technical_foundation_headless.gd
run_checked "Intégrité stockage" bash tools/ci/run_godot_checked.sh --log "$sandbox_dir/runtime.log" --expect SAVE_RUNTIME_CONTRACT_PASS -- godot --headless --path . --script res://tests/godot/test_save_runtime_headless.gd
run_checked "Rejets checksum et version" bash tools/ci/run_godot_checked.sh --log "$sandbox_dir/negative.log" --expect SAVE_NEGATIVE_CONTRACT_PASS -- godot --headless --path . --script res://tests/godot/test_save_negative_headless.gd
run_checked "Sauvegarde et chargement" bash tools/ci/run_godot_checked.sh --log "$sandbox_dir/roundtrip.log" --expect SAVE_ROUNDTRIP_CONTRACT_PASS -- godot --headless --path . --script res://tests/godot/test_save_roundtrip_headless.gd
run_checked "Récupération après panne" bash tools/ci/run_godot_checked.sh --log "$sandbox_dir/recovery.log" --expect SAVE_RECOVERY_REGRESSION_OK -- godot --headless --path . res://scenes/tests/save_recovery_regression_smoke.tscn
run_checked "Isolation des slots" bash tools/ci/run_godot_checked.sh --log "$sandbox_dir/delete.log" --expect SAVE_SLOT0_DELETE_REGRESSION_OK -- godot --headless --path . res://scenes/tests/save_slot0_delete_regression_smoke.tscn

echo "GODOT_CI_STRICT_OK"
