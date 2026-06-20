#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: stackctl.sh <command> [args]

Commands:
  init [task-slug]             Ensure .autodev/current-stack.json exists
  sync-from-flow               Sync flow_ref/step_ref from .autodev/current-flow.json
  set-active [flags]           Update active stack refs
  touch [reason]               Refresh last_meaningful_touch_at
  should-resume                Print JSON describing whether auto-resume should trigger
  summary                      Print a concise current stack summary
  validate                     Validate current stack shape and refs

Flags for set-active:
  --initiative-ref VALUE
  --project-ref VALUE
  --milestone-ref VALUE
  --phase-ref VALUE
  --flow-ref VALUE
  --step-ref VALUE
EOF
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATE_DIR="$SKILL_ROOT/assets/templates"
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
AUTODEV_DIR="$REPO_ROOT/.autodev"
STACK_FILE="$AUTODEV_DIR/current-stack.json"
FLOW_FILE="$AUTODEV_DIR/current-flow.json"

mkdir -p "$AUTODEV_DIR"

timestamp() {
  date +"%Y-%m-%dT%H:%M:%S%z" | sed 's/\(..\)$/:\1/'
}

slugify() {
  printf '%s' "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//; s/-{2,}/-/g'
}

ensure_stack() {
  local task_slug="${1:-default}"
  if [[ ! -f "$STACK_FILE" ]]; then
    cp "$TEMPLATE_DIR/current-stack.json" "$STACK_FILE"
  fi
  python3 - "$STACK_FILE" "$task_slug" "$(timestamp)" <<'PY'
import json, sys
path, task_slug, now = sys.argv[1:]
with open(path, "r", encoding="utf-8") as fh:
    data = json.load(fh)
if data.get("stack_id") == "STACK-REPLACE-ME":
    data["stack_id"] = f"STACK-{task_slug}-v1"
if str(data.get("updated_at", "")).startswith("YYYY-"):
    data["updated_at"] = now
if str(data.get("last_meaningful_touch_at", "")).startswith("YYYY-"):
    data["last_meaningful_touch_at"] = now
with open(path, "w", encoding="utf-8") as fh:
    json.dump(data, fh, ensure_ascii=False, indent=2)
    fh.write("\n")
PY
}

read_flow_field() {
  python3 - "$FLOW_FILE" "$1" <<'PY'
import json, sys
path, key = sys.argv[1:]
with open(path, "r", encoding="utf-8") as fh:
    data = json.load(fh)
print("" if data.get(key) is None else data.get(key))
PY
}

command_init() {
  local task_slug="${1:-}"
  if [[ -z "$task_slug" && -f "$FLOW_FILE" ]]; then
    task_slug="$(read_flow_field task_slug)"
  fi
  ensure_stack "${task_slug:-default}"
  if [[ -f "$FLOW_FILE" ]]; then
    command_sync_from_flow >/dev/null
  fi
  echo "Initialized current stack"
}

command_sync_from_flow() {
  [[ -f "$FLOW_FILE" ]] || { echo "stackctl.sh sync-from-flow: no current-flow.json" >&2; exit 1; }
  ensure_stack "$(read_flow_field task_slug)"
  python3 - "$STACK_FILE" "$FLOW_FILE" "$(timestamp)" <<'PY'
import json, sys
stack_path, flow_path, now = sys.argv[1:]
with open(stack_path, "r", encoding="utf-8") as fh:
    stack = json.load(fh)
with open(flow_path, "r", encoding="utf-8") as fh:
    flow = json.load(fh)
flow_id = flow.get("flow_id")
active_step = flow.get("active_step")
stack["flow_ref"] = flow_id
stack["step_ref"] = active_step
if flow_id:
    recent = [item for item in stack.get("recent_flow_ids", []) if item != flow_id]
    recent.insert(0, flow_id)
    stack["recent_flow_ids"] = recent[:10]
stack["updated_at"] = now
if not stack.get("last_meaningful_touch_at") or str(stack.get("last_meaningful_touch_at")).startswith("YYYY-"):
    stack["last_meaningful_touch_at"] = now
with open(stack_path, "w", encoding="utf-8") as fh:
    json.dump(stack, fh, ensure_ascii=False, indent=2)
    fh.write("\n")
PY
  echo "Synced current stack from active flow"
}

command_set_active() {
  ensure_stack "${1:-default}"
  local initiative_ref="" project_ref="" milestone_ref="" phase_ref="" flow_ref="" step_ref=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --initiative-ref) initiative_ref="${2:-}"; shift 2 ;;
      --project-ref) project_ref="${2:-}"; shift 2 ;;
      --milestone-ref) milestone_ref="${2:-}"; shift 2 ;;
      --phase-ref) phase_ref="${2:-}"; shift 2 ;;
      --flow-ref) flow_ref="${2:-}"; shift 2 ;;
      --step-ref) step_ref="${2:-}"; shift 2 ;;
      *)
        echo "stackctl.sh set-active: unknown flag $1" >&2
        exit 1
        ;;
    esac
  done
  python3 - "$STACK_FILE" "$(timestamp)" "$initiative_ref" "$project_ref" "$milestone_ref" "$phase_ref" "$flow_ref" "$step_ref" <<'PY'
import json, sys
path, now, initiative_ref, project_ref, milestone_ref, phase_ref, flow_ref, step_ref = sys.argv[1:]
with open(path, "r", encoding="utf-8") as fh:
    data = json.load(fh)
mapping = {
    "initiative_ref": initiative_ref,
    "project_ref": project_ref,
    "milestone_ref": milestone_ref,
    "phase_ref": phase_ref,
    "flow_ref": flow_ref,
    "step_ref": step_ref,
}
for key, value in mapping.items():
    if value != "":
        data[key] = value
data["updated_at"] = now
with open(path, "w", encoding="utf-8") as fh:
    json.dump(data, fh, ensure_ascii=False, indent=2)
    fh.write("\n")
PY
  echo "Updated active stack"
}

command_touch() {
  ensure_stack "${1:-default}"
  python3 - "$STACK_FILE" "$(timestamp)" <<'PY'
import json, sys
path, now = sys.argv[1:]
with open(path, "r", encoding="utf-8") as fh:
    data = json.load(fh)
data["last_meaningful_touch_at"] = now
data["updated_at"] = now
with open(path, "w", encoding="utf-8") as fh:
    json.dump(data, fh, ensure_ascii=False, indent=2)
    fh.write("\n")
PY
  echo "Touched current stack"
}

command_should_resume() {
  ensure_stack "default"
  python3 - "$STACK_FILE" "$(timestamp)" <<'PY'
import json, sys
from datetime import datetime

path, now = sys.argv[1:]
with open(path, "r", encoding="utf-8") as fh:
    data = json.load(fh)

fmt = "%Y-%m-%dT%H:%M:%S%z"
now_dt = datetime.strptime(now, fmt)
last_touch = data.get("last_meaningful_touch_at")
threshold = int(data.get("resume_threshold_hours", 24))
enabled = bool(data.get("auto_resume_enabled", True))
status = data.get("status", "active")

should = False
hours_since = None
reason = "disabled"
if enabled and last_touch and status in {"active", "paused", "blocked"}:
    touch_dt = datetime.strptime(last_touch, fmt)
    hours_since = (now_dt - touch_dt).total_seconds() / 3600
    if hours_since >= threshold:
        should = True
        reason = "threshold_exceeded"
    else:
        reason = "within_threshold"
elif status not in {"active", "paused", "blocked"}:
    reason = "status_not_resumable"

result = {
    "should_resume": should,
    "reason": reason,
    "hours_since_touch": hours_since,
    "threshold_hours": threshold,
    "flow_ref": data.get("flow_ref"),
    "step_ref": data.get("step_ref"),
    "project_ref": data.get("project_ref"),
    "milestone_ref": data.get("milestone_ref"),
    "phase_ref": data.get("phase_ref"),
}
print(json.dumps(result, ensure_ascii=False, indent=2))
sys.exit(0 if should else 1)
PY
}

command_summary() {
  ensure_stack "default"
  python3 - "$STACK_FILE" <<'PY'
import json, sys
with open(sys.argv[1], "r", encoding="utf-8") as fh:
    data = json.load(fh)
print("Current Stack")
print(f"- Initiative: {data.get('initiative_ref') or '—'}")
print(f"- Project: {data.get('project_ref') or '—'}")
print(f"- Milestone: {data.get('milestone_ref') or '—'}")
print(f"- Phase: {data.get('phase_ref') or '—'}")
print(f"- Flow: {data.get('flow_ref') or '—'}")
print(f"- Step: {data.get('step_ref') or '—'}")
print(f"- Last meaningful touch: {data.get('last_meaningful_touch_at') or '—'}")
PY
}

command_validate() {
  [[ -f "$STACK_FILE" ]] || { echo "stackctl.sh validate: no current-stack.json" >&2; exit 1; }
  python3 - "$STACK_FILE" "$FLOW_FILE" <<'PY'
import json, pathlib, sys
stack_path = pathlib.Path(sys.argv[1])
flow_path = pathlib.Path(sys.argv[2])
with open(stack_path, "r", encoding="utf-8") as fh:
    stack = json.load(fh)
required = [
    "stack_id",
    "status",
    "flow_ref",
    "last_meaningful_touch_at",
    "updated_at",
]
missing = [key for key in required if key not in stack]
if missing:
    raise SystemExit(f"Missing required stack keys: {', '.join(missing)}")
if flow_path.exists():
    with open(flow_path, "r", encoding="utf-8") as fh:
        flow = json.load(fh)
    flow_id = flow.get("flow_id")
    if stack.get("flow_ref") and flow_id and stack.get("flow_ref") != flow_id:
        raise SystemExit(
            f"current-stack.json flow_ref {stack.get('flow_ref')} does not match current-flow.json {flow_id}"
        )
print("Current stack is valid")
PY
}

main() {
  local command="${1:-}"
  if [[ -z "$command" ]]; then
    usage
    exit 1
  fi
  shift || true
  case "$command" in
    init) command_init "$@" ;;
    sync-from-flow) command_sync_from_flow "$@" ;;
    set-active) command_set_active "$@" ;;
    touch) command_touch "$@" ;;
    should-resume) command_should_resume "$@" ;;
    summary) command_summary "$@" ;;
    validate) command_validate "$@" ;;
    -h|--help|help) usage ;;
    *)
      echo "stackctl.sh: unknown command: $command" >&2
      usage
      exit 1
      ;;
  esac
}

main "$@"
