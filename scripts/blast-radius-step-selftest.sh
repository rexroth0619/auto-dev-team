#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
STEPS_FILE="$REPO_ROOT/.autodev/temp/blast-radius-step-selftest.md"

mkdir -p "$REPO_ROOT/.autodev/temp"

cat >"$STEPS_FILE" <<'EOF'
# Current Task

## Key Decisions (read before every step)

- **Log marker**: [DEV-blast-radius-step-selftest]

## Plan (every step must stay incrementally testable)

- [ ] 🌀 Step 1: selftest success path [testable output: selftest] [Blast Radius: scripts/init-autodev.sh::copy_if_missing -> <= 🔴]
- [ ] 🌀 Step 2: selftest fail-close path [testable output: selftest] [Blast Radius: scripts/init-autodev.sh::copy_if_missing -> <= 🟢]
EOF

"$REPO_ROOT/scripts/blast-radius-step.sh" \
  --steps-file "$STEPS_FILE" \
  --step 1 \
  --task "blast-radius-step-selftest-pass" \
  --no-current \
  --quiet >/dev/null

if "$REPO_ROOT/scripts/blast-radius-step.sh" \
  --steps-file "$STEPS_FILE" \
  --step 2 \
  --task "blast-radius-step-selftest-fail" \
  --no-current \
  --quiet >/dev/null 2>&1; then
  echo "blast-radius-step-selftest.sh: expected threshold fail-close did not happen" >&2
  exit 1
fi

echo "✅ blast-radius-step selftest passed"
