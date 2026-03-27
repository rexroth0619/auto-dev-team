#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RUNNER="$SKILL_ROOT/scripts/release-auto-run.py"

fail() {
  printf 'release-auto-selftest: %s\n' "$1" >&2
  exit 1
}

assert_file_contains() {
  local file_path="$1"
  local needle="$2"
  if ! grep -q -- "$needle" "$file_path"; then
    fail "expected $file_path to contain: $needle"
  fi
}

TMPDIR_ROOT="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_ROOT"' EXIT

REPO_DIR="$TMPDIR_ROOT/repo"
mkdir -p "$REPO_DIR/.autodev/temp/release"
cd "$REPO_DIR"

git init -q
git config user.name "Release Auto Selftest"
git config user.email "release-auto-selftest@example.com"
printf '# release auto selftest\n' > README.md
git add README.md
git commit -q -m "chore: seed repository"

cat > .autodev/temp/release-plan.json <<'EOF'
{
  "schema_version": "1.0",
  "task": "release auto selftest",
  "environment": "预发",
  "target": "HEAD",
  "focus_summary": "验证自动化 runner 状态机",
  "selected_execution_mode": "auto",
  "automation_scope": "be_plus_gui",
  "available_execution_modes": ["manual", "auto"],
  "domains": ["ui", "service"],
  "needs_auth": false,
  "auth_strategy": ["existing_session"],
  "ai_sot": {
    "path": ".autodev/ai-sot.json",
    "lock_id": "selftest-ai-sot-v1",
    "mutation_policy": {
      "default": "read_only",
      "requires_user_confirmation": true
    }
  },
  "staging_context": {
    "requires_ssh": false,
    "ssh_access_mode": "none",
    "ssh_alias": "",
    "execution_host": "",
    "working_directory": "",
    "allowed_paths": [],
    "protected_target": false,
    "requires_gui": true,
    "auth_required_reason": ""
  },
  "backend_execution_context": {
    "mode": "none",
    "ssh_alias": "",
    "execution_host": "",
    "working_directory": "",
    "allowed_paths": []
  },
  "gui_execution_context": {
    "mode": "local_runner",
    "base_url": "",
    "auth_mode": "none"
  },
  "cleanup_spec": {
    "required": true,
    "root": ".autodev/temp/release/",
    "preserve_paths": [
      ".autodev/ai-sot.json",
      ".autodev/path.md",
      ".autodev/autodev-config.json",
      ".autodev/temp/release/storage-state.json"
    ],
    "description": "cleanup stale temp artifacts before a new automated release run"
  },
  "query_spec": {
    "required": false,
    "dialect": "SQLite",
    "entry_candidates": ["db"],
    "command": "",
    "statements": [],
    "skip_reason": "selftest"
  },
  "seed_spec": {
    "required": false,
    "method_candidates": ["manual_only"],
    "command": "",
    "allow_write": false,
    "skip_reason": "selftest"
  },
  "use_cases": [
    {
      "id": "UC-1",
      "title": "backend + gui",
      "priority": "high",
      "requires_gui": true,
      "be_checks": [
        {
          "id": "BE-1",
          "title": "be check",
          "kind": "cli",
          "required": true,
          "command": "python3 -c \"print('be ok')\"",
          "success_criteria": "be ok"
        }
      ],
      "gui_checks": [
        {
          "id": "GUI-1",
          "title": "gui check",
          "kind": "cli",
          "required": true,
          "command": "python3 -c \"print('gui ok')\"",
          "success_criteria": "gui ok"
        }
      ]
    }
  ],
  "executive_summary": {
    "has_backend_tests": true,
    "has_gui_tests": true,
    "summary_items": [
      "先验证后端和 GUI 都能跑通。"
    ],
    "expected_user_visible_changes": [
      "页面和副作用都应符合预期。"
    ]
  },
  "receipt_protocol": {
    "stages": []
  },
  "evidence": {
    "root": ".autodev/temp/release/",
    "receipt_path": ".autodev/temp/release/release-auto-receipt.json"
  }
}
EOF

printf 'stale\n' > .autodev/temp/release/old-artifact.txt
printf 'state\n' > .autodev/temp/release/storage-state.json

cat > .autodev/ai-sot.json <<'EOF'
{
  "schema_version": "1.0",
  "lock_id": "selftest-ai-sot-v1",
  "ai_mutation_policy": {
    "default": "read_only",
    "requires_user_confirmation": true
  },
  "pre_release": {
    "staging_context": {
      "requires_ssh": false,
      "ssh_access_mode": "none",
      "ssh_alias": "",
      "execution_host": "",
      "working_directory": "",
      "allowed_paths": [],
      "protected_target": false,
      "requires_gui": true,
      "auth_required_reason": ""
    },
    "backend_execution_context": {
      "mode": "none",
      "ssh_alias": "",
      "execution_host": "",
      "working_directory": "",
      "allowed_paths": []
    },
    "gui_execution_context": {
      "mode": "local_runner",
      "base_url": "",
      "auth_mode": "none"
    },
    "auth_hints": {}
  }
}
EOF

python3 "$RUNNER" \
  --plan ".autodev/temp/release-plan.json" \
  --receipt ".autodev/temp/release/release-auto-receipt.json" \
  --allow-gui \
  --stdout >/dev/null

RECEIPT_PATH=".autodev/temp/release/release-auto-receipt.json"
[[ -f "$RECEIPT_PATH" ]] || fail "expected receipt output file to exist"
[[ ! -f ".autodev/temp/release/old-artifact.txt" ]] || fail "expected stale artifact to be cleaned"
[[ -f ".autodev/temp/release/storage-state.json" ]] || fail "expected storage-state to be preserved"
assert_file_contains "$RECEIPT_PATH" '"final_status": "passed"'
assert_file_contains "$RECEIPT_PATH" '"stage": "summary"'
assert_file_contains "$RECEIPT_PATH" '"stage": "cleanup"'
assert_file_contains "$RECEIPT_PATH" '"stage": "be"'
assert_file_contains "$RECEIPT_PATH" '"stage": "gui"'
assert_file_contains "$RECEIPT_PATH" '"status": "passed"'

printf 'release-auto selftest passed\n'
