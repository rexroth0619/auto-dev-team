#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

mkdir -p "$REPO_ROOT/.autodev/temp"

REPORT_PATH=".autodev/temp/blast-radius-selftest.md"
JSON_PATH=".autodev/temp/blast-radius-selftest.json"
SCOPED_JSON_PATH=".autodev/temp/blast-radius-selftest-scoped.json"
SCOPED_REPORT_PATH=".autodev/temp/blast-radius-selftest-scoped.md"

"$REPO_ROOT/scripts/blast-radius.py" \
  --file "scripts/init-autodev.sh" \
  --symbol "copy_if_missing" \
  --task "blast-radius-selftest" \
  --mode "fasttrack" \
  --depth 2 \
  --no-current \
  --report "$REPORT_PATH" \
  --json "$JSON_PATH" \
  --quiet >/dev/null

grep -q "Blast Radius Report" "$REPO_ROOT/$REPORT_PATH"
grep -q "风险等级" "$REPO_ROOT/$REPORT_PATH"
grep -q '"risk_level"' "$REPO_ROOT/$JSON_PATH"

if "$REPO_ROOT/scripts/blast-radius.py" \
  --symbol "__AutoDevDefinitelyMissingSymbol__" \
  --task "blast-radius-selftest-missing-symbol" \
  --mode "fasttrack" \
  --no-current \
  --quiet >/dev/null 2>&1; then
  echo "blast-radius-selftest.sh: missing symbol should fail closed" >&2
  exit 1
fi

if "$REPO_ROOT/scripts/blast-radius.py" \
  --file "__missing__/nope.ts" \
  --task "blast-radius-selftest-missing-file" \
  --mode "fasttrack" \
  --no-current \
  --quiet >/dev/null 2>&1; then
  echo "blast-radius-selftest.sh: missing file should fail closed" >&2
  exit 1
fi

"$REPO_ROOT/scripts/blast-radius.py" \
  --target "scripts/blast-radius.py::main" \
  --task "blast-radius-selftest-scoped" \
  --mode "fasttrack" \
  --no-current \
  --report "$SCOPED_REPORT_PATH" \
  --json "$SCOPED_JSON_PATH" \
  --quiet >/dev/null

python3 - "$REPO_ROOT/$SCOPED_JSON_PATH" <<'PY'
import json
import sys

with open(sys.argv[1], "r", encoding="utf-8") as fh:
    report = json.load(fh)

target_files = report["target_files"]
definition_files = {item["file"] for item in report["definitions"]}
direct_files = {item["file"] for item in report["direct_references"]}
doc_files = {item["file"] for item in report["documentation_mentions"]}

if target_files != ["scripts/blast-radius.py"]:
    raise SystemExit(f"scoped target leaked files: {target_files}")
if definition_files != {"scripts/blast-radius.py"}:
    raise SystemExit(f"scoped symbol leaked definitions: {sorted(definition_files)}")
if "README.md" in direct_files:
    raise SystemExit("documentation mention counted as a direct code reference")
if "README.md" not in doc_files:
    raise SystemExit("expected README.md to be tracked as documentation mention")
PY

echo "✅ blast-radius 自检通过"
