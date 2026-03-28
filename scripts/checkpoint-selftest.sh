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

milestone_output="$("$CHECKPOINT_SCRIPT" milestone "脚本验证#起点" "checkpoint selftest" gui-checkpoint)"
assert_contains "$milestone_output" "🎯 里程碑"
assert_contains "$milestone_output" "指纹: 脚本验证#起点"
assert_contains "$milestone_output" "标签: milestone/gui-checkpoint-"
if [[ "$(git log -1 --pretty=%s)" != "init" ]]; then
  fail "milestone should not create a commit"
fi

gate_output="$("$CHECKPOINT_SCRIPT" snapshot-gate "脚本验证")"
assert_contains "$gate_output" "💿"
assert_contains "$gate_output" "闸门通过"

git commit --allow-empty -q -m "after-milestone"
clean_gate_output="$("$CHECKPOINT_SCRIPT" snapshot-gate "干净保护")"
assert_contains "$clean_gate_output" "tag-only: snapshot/"

printf 'delta\n' >> README.md
archive_output="$("$CHECKPOINT_SCRIPT" archive "脚本验证#01" chore "checkpoint selftest archive")"
assert_contains "$archive_output" "💾【存档】脚本验证#01"

list_output="$("$CHECKPOINT_SCRIPT" list)"
assert_contains "$list_output" "📍 版本点列表"
assert_contains "$list_output" "脚本验证#起点"
assert_contains "$list_output" "脚本验证#01"
assert_contains "$list_output" "tag-only"

branch_output="$("$CHECKPOINT_SCRIPT" ensure-branch "checkpoint-selftest")"
assert_contains "$branch_output" "已创建工作分支"

rollback_output="$("$CHECKPOINT_SCRIPT" rollback 1)"
assert_contains "$rollback_output" "已回退"
assert_contains "$rollback_output" "tag 指向的 commit"

git reset --hard HEAD@{1} >/dev/null 2>&1 || true

printf 'more\n' >> README.md
git add README.md
git commit -q -m "「脚本验证#02」feat: functional change"
git commit --allow-empty -q -m "「脚本验证#保护」chore: 自动存档"

merge_advice_output="$("$CHECKPOINT_SCRIPT" merge-advice main)"
assert_contains "$merge_advice_output" "🧭 合并建议"
assert_contains "$merge_advice_output" "功能提交:"
assert_contains "$merge_advice_output" "工作流提交:"
assert_contains "$merge_advice_output" "建议 clean merge / cherry-pick"

printf 'checkpoint selftest passed\n'
