#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RELEASE_PACK_SCRIPT="$SKILL_ROOT/scripts/release-pack.py"

fail() {
  printf 'release-pack-selftest: %s\n' "$1" >&2
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
mkdir -p "$REPO_DIR"
cd "$REPO_DIR"

git init -q
git config user.name "Release Pack Selftest"
git config user.email "release-pack-selftest@example.com"

mkdir -p src/services src/repositories
cat > README.md <<'EOF'
# release-pack selftest
EOF
git add README.md
git commit -q -m "chore: seed repository"

cat > src/services/order-service.ts <<'EOF'
export function updateOrderStatus(id: string, status: string) {
  return { id, status };
}
EOF
git add src/services/order-service.ts
git commit -q -m "feat: add order status service"

cat > src/repositories/order-repository.ts <<'EOF'
export function findRecentOrders() {
  return [];
}
EOF
git add src/repositories/order-repository.ts
git commit -q -m "feat: add order repository"

git commit --allow-empty -q -m "「预发自动化#保护」chore: 自动存档"

OUTPUT_PATH=".autodev/temp/release-plan.json"

python3 "$RELEASE_PACK_SCRIPT" \
  --commits 3 \
  --task "release-pack selftest" \
  --mode auto \
  --output "$OUTPUT_PATH" >/dev/null

[[ -f "$OUTPUT_PATH" ]] || fail "expected json plan file to exist"

assert_file_contains "$OUTPUT_PATH" '"selected_execution_mode": "auto"'
assert_file_contains "$OUTPUT_PATH" '"feature_commits"'
assert_file_contains "$OUTPUT_PATH" '"workflow_commits"'
assert_file_contains "$OUTPUT_PATH" '"query_spec"'
assert_file_contains "$OUTPUT_PATH" '"auth_strategy"'
assert_file_contains "$OUTPUT_PATH" '"staging_context"'
assert_file_contains "$OUTPUT_PATH" '"backend_execution_context"'
assert_file_contains "$OUTPUT_PATH" '"gui_execution_context"'
assert_file_contains "$OUTPUT_PATH" '"ssh_access_mode"'
assert_file_contains "$OUTPUT_PATH" '"allowed_paths"'
assert_file_contains "$OUTPUT_PATH" '"use_cases"'
assert_file_contains "$OUTPUT_PATH" '"receipt_protocol"'
assert_file_contains "$OUTPUT_PATH" '"SELECT id, status, updated_at'
assert_file_contains "$OUTPUT_PATH" "order"
assert_file_contains "$OUTPUT_PATH" '"manual_mode_contract"'
assert_file_contains "$OUTPUT_PATH" '"domain_confidence"'
assert_file_contains "$OUTPUT_PATH" '"plan_ambiguities"'
assert_file_contains "$OUTPUT_PATH" '"Workflow commits were filtered'

mkdir -p agent_test/integration
cat > agent_test/integration/order-flow.test.js <<'EOF'
console.log('integration test only');
EOF
git add agent_test/integration/order-flow.test.js
git commit -q -m "test: add integration-only regression"

OUTPUT_PATH_TEST_ONLY=".autodev/temp/release-plan-test-only.json"

python3 "$RELEASE_PACK_SCRIPT" \
  --commit HEAD \
  --task "release-pack test-only selftest" \
  --mode auto \
  --output "$OUTPUT_PATH_TEST_ONLY" >/dev/null

[[ -f "$OUTPUT_PATH_TEST_ONLY" ]] || fail "expected test-only json plan file to exist"

assert_file_contains "$OUTPUT_PATH_TEST_ONLY" '"automation_scope": "be_only"'
assert_file_contains "$OUTPUT_PATH_TEST_ONLY" '"entities": \[\]'
assert_file_contains "$OUTPUT_PATH_TEST_ONLY" '"plan_ambiguities"'

if grep -q '"has_gui_tests": true' "$OUTPUT_PATH_TEST_ONLY"; then
  fail "test-only plan should not require gui"
fi

printf 'release-pack selftest passed\n'
