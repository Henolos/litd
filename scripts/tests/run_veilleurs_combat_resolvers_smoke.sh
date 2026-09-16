#!/usr/bin/env bash
set -euo pipefail

GODOT_BIN="${GODOT_BIN:-godot}"
"${GODOT_BIN}" --headless --path . --script res://scripts/tests/veilleurs_combat_resolvers_smoke.gd
