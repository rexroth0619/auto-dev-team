#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INIT_SCRIPT="$SKILL_ROOT/scripts/init-autodev.sh"
CHECKPOINT_SCRIPT="$SKILL_ROOT/scripts/checkpoint.sh"

fail() {
  printf 'checkpoint-selftest: %s\n' "$1" >&2
  exit 1
}

assert_contains() {
  local haystack="$1"
  local needle="$2"
  if [[ "$haystack" != *"$needle"* ]]; then
    fail "expected output to contain: $needle"
  fi
}

TMPDIR_ROOT="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_ROOT"' EXIT

REPO_DIR="$TMPDIR_ROOT/repo"
mkdir -p "$REPO_DIR"
cd "$REPO_DIR"

git init -q
git config user.name "Checkpoint Selftest"
git config user.email "checkpoint-selftest@example.com"
printf 'seed\n' > README.md
git add README.md
git commit -q -m "init"

"$INIT_SCRIPT" "$REPO_DIR" >/dev/null

milestone_output="$("$CHECKPOINT_SCRIPT" milestone "script-check#start" "checkpoint selftest" gui-checkpoint)"
assert_contains "$milestone_output" "🎯 Milestone"
assert_contains "$milestone_output" "Fingerprint: script-check#start"
assert_contains "$milestone_output" "Tag: milestone/gui-checkpoint-"

gate_output="$("$CHECKPOINT_SCRIPT" snapshot-gate "script-check")"
assert_contains "$gate_output" "💿"

printf 'delta\n' >> README.md
archive_output="$("$CHECKPOINT_SCRIPT" archive "script-check#01" chore "checkpoint selftest archive")"
assert_contains "$archive_output" "💾 Archive script-check#01"

list_output="$("$CHECKPOINT_SCRIPT" list)"
assert_contains "$list_output" "📍 Archive List"
assert_contains "$list_output" "script-check#start"
assert_contains "$list_output" "script-check#01"

printf 'checkpoint selftest passed\n'
