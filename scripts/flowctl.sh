#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: flowctl.sh <command> [args]

Commands:
  init <task-slug> <mode>   Create and activate a new flow
  activate <flow-id>        Switch active flow
  ensure <artifact-type>    Ensure artifact exists for active flow
  validate                  Validate active flow registry and artifacts
  archive <flow-id>         Mark flow archived
  clean                     Clean stale active links and flow temp outputs
EOF
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATE_DIR="$SKILL_ROOT/assets/templates"
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
AUTODEV_DIR="$REPO_ROOT/.autodev"
FLOWS_DIR="$AUTODEV_DIR/flows"
ACTIVE_REGISTRY="$AUTODEV_DIR/current-flow.json"

mkdir -p "$AUTODEV_DIR" "$FLOWS_DIR"

timestamp() {
  date +"%Y-%m-%dT%H:%M:%S%z" | sed 's/\(..\)$/:\1/'
}

slugify() {
  printf '%s' "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//; s/-{2,}/-/g'
}

flow_template() {
  python3 - "$@" <<'PY'
import json, pathlib, sys

template_path = pathlib.Path(sys.argv[1])
flow_id = sys.argv[2]
task_slug = sys.argv[3]
mode = sys.argv[4]
updated_at = sys.argv[5]

data = json.loads(template_path.read_text())
data["flow_id"] = flow_id
data["task_slug"] = task_slug
data["active_mode"] = mode
data["updated_at"] = updated_at
data["brainstorm_ref"] = f"BRAINSTORM-{task_slug}-v1"
data["artifacts"]["brainstorm"] = ".autodev/current-brainstorm.md"
print(json.dumps(data, ensure_ascii=False, indent=2))
PY
}

read_json_field() {
  python3 - "$1" "$2" <<'PY'
import json, sys
path, key = sys.argv[1], sys.argv[2]
data = json.load(open(path))
for part in key.split('.'):
    data = data.get(part)
print("" if data is None else data)
PY
}

update_flow_json() {
  python3 - "$@" <<'PY'
import json, pathlib, sys

path = pathlib.Path(sys.argv[1])
artifact_type = sys.argv[2]
artifact_path = sys.argv[3]
artifact_id = sys.argv[4]
updated_at = sys.argv[5]

data = json.loads(path.read_text())
data["updated_at"] = updated_at

mapping = {
    "brainstorm": "brainstorm",
    "metaphor": "metaphor",
    "steps": "steps",
    "test": "test",
    "debug": "debug",
    "blast_radius": "blast_radius",
    "gui": "gui",
}

key = mapping[artifact_type]
data["artifacts"][key] = artifact_path
if artifact_type == "brainstorm":
    data["brainstorm_ref"] = artifact_id
elif artifact_type == "metaphor":
    data["metaphor_ref"] = artifact_id
    if "metaphor" not in data["required_artifacts"]:
        data["required_artifacts"].append("metaphor")
elif artifact_type == "steps":
    data["plan_ref"] = artifact_id
    if "steps" not in data["required_artifacts"]:
        data["required_artifacts"].append("steps")

path.write_text(json.dumps(data, ensure_ascii=False, indent=2))
PY
}

write_registry_links() {
  local flow_dir="$1"
  local src dest
  for name in current-brainstorm.md current-metaphor.md current-steps.md current-test.md current-debug.md current-blast-radius.md current-gui-test.js; do
    src="$flow_dir/$name"
    dest="$AUTODEV_DIR/$name"
    rm -f "$dest"
    if [[ -e "$src" ]]; then
      ln -s "$src" "$dest" 2>/dev/null || cp "$src" "$dest"
    fi
  done
}

sync_metaphor_ref_into_artifacts() {
  python3 - "$@" <<'PY'
import pathlib, re, sys

flow_dir = pathlib.Path(sys.argv[1])
metaphor_ref = sys.argv[2]

targets = [
    flow_dir / "current-brainstorm.md",
    flow_dir / "current-steps.md",
    flow_dir / "current-test.md",
    flow_dir / "current-debug.md",
    flow_dir / "current-blast-radius.md",
    flow_dir / "current-gui-test.js",
]

patterns = [
    (r'(?m)^- metaphor_ref: .*$' , f'- metaphor_ref: {metaphor_ref}'),
    (r'(?m)^\\* metaphor_ref: .*$' , f'* metaphor_ref: {metaphor_ref}'),
    (r'(?m)^Metaphor 对应: \\[.*\\]$' , f'Metaphor 对应: [{metaphor_ref}]'),
    (r'(?m)^\\s*metaphorRef: \".*\",$' , f'  metaphorRef: "{metaphor_ref}",'),
]

for path in targets:
    if not path.exists():
        continue
    text = path.read_text()
    original = text
    for pattern, repl in patterns:
        text = re.sub(pattern, repl, text)
    if text != original:
        path.write_text(text)
PY
}

ensure_artifact_file() {
  local flow_dir="$1"
  local task_slug="$2"
  local flow_id="$3"
  local brainstorm_ref="$4"
  local metaphor_ref="$5"
  local plan_ref="$6"
  local artifact_type="$7"
  local dest template artifact_id step_ref derived_from

  case "$artifact_type" in
    brainstorm)
      template="$TEMPLATE_DIR/current-brainstorm.md"
      dest="$flow_dir/current-brainstorm.md"
      artifact_id="BRAINSTORM-${task_slug}-v1"
      step_ref="null"
      derived_from="user-request"
      ;;
    metaphor)
      template="$TEMPLATE_DIR/current-metaphor.md"
      dest="$flow_dir/current-metaphor.md"
      artifact_id="METAPHOR-${task_slug}-v1"
      step_ref="null"
      derived_from="$brainstorm_ref"
      ;;
    steps)
      template="$TEMPLATE_DIR/current-steps.md"
      dest="$flow_dir/current-steps.md"
      artifact_id="PLAN-${task_slug}-v1"
      step_ref="null"
      derived_from="$brainstorm_ref"
      ;;
    test)
      template="$TEMPLATE_DIR/current-test.md"
      dest="$flow_dir/current-test.md"
      artifact_id="TEST-${task_slug}-v1"
      step_ref="null"
      derived_from="${plan_ref:-$brainstorm_ref}"
      ;;
    debug)
      template="$TEMPLATE_DIR/current-debug.md"
      dest="$flow_dir/current-debug.md"
      artifact_id="DEBUG-${task_slug}-v1"
      step_ref="null"
      derived_from="${plan_ref:-$brainstorm_ref}"
      ;;
    blast_radius)
      template="$TEMPLATE_DIR/current-blast-radius.md"
      dest="$flow_dir/current-blast-radius.md"
      artifact_id="BR-${task_slug}-v1"
      step_ref="STEP-UNKNOWN"
      derived_from="${plan_ref:-$brainstorm_ref}"
      ;;
    gui)
      template="$TEMPLATE_DIR/current-gui-test.js"
      dest="$flow_dir/current-gui-test.js"
      artifact_id="GUI-${task_slug}-v1"
      step_ref="STEP-UNKNOWN"
      derived_from="${plan_ref:-$brainstorm_ref}"
      ;;
    *)
      echo "flowctl.sh: unsupported artifact type: $artifact_type" >&2
      exit 1
      ;;
  esac

  mkdir -p "$(dirname "$dest")"
  if [[ -e "$dest" ]]; then
    printf '%s\n' "$artifact_id"
    return 0
  fi

  cp "$template" "$dest"
  python3 - "$dest" "$flow_id" "$artifact_id" "$artifact_type" "$brainstorm_ref" "$metaphor_ref" "$plan_ref" "$step_ref" "$derived_from" "$(timestamp)" <<'PY'
import pathlib, sys

path = pathlib.Path(sys.argv[1])
flow_id, artifact_id, artifact_type, brainstorm_ref, metaphor_ref, plan_ref, step_ref, derived_from, updated_at = sys.argv[2:]
text = path.read_text()
effective_plan_ref = artifact_id if artifact_type == "steps" else (plan_ref if plan_ref else "null")
effective_metaphor_ref = artifact_id if artifact_type == "metaphor" else (metaphor_ref if metaphor_ref else "null")

replacements = {
    "FLOW-REPLACE-ME": flow_id,
    "BRAINSTORM-REPLACE-ME": artifact_id if artifact_type == "brainstorm" else brainstorm_ref,
    "PLAN-REPLACE-ME": plan_ref if plan_ref else "null",
    "REPLACE-ARTIFACT-ID": artifact_id,
    "REPLACE-ARTIFACT-TYPE": artifact_type,
    "REPLACE-STATUS": "active",
    "REPLACE-BRAINSTORM-REF": brainstorm_ref,
    "REPLACE-METAPHOR-REF": effective_metaphor_ref,
    "REPLACE-PLAN-REF": effective_plan_ref,
    "REPLACE-STEP-REF": step_ref,
    "REPLACE-DERIVED-FROM": derived_from,
    "YYYY-MM-DDTHH:MM:SS+08:00": updated_at,
}

for old, new in replacements.items():
    text = text.replace(old, new)

path.write_text(text)
PY

  printf '%s\n' "$artifact_id"
}

sync_registry() {
  local flow_dir="$1"
  local flow_json="$flow_dir/flow.json"
  cp "$flow_json" "$ACTIVE_REGISTRY"
  write_registry_links "$flow_dir"
}

command_init() {
  local task_slug mode now short_ts flow_id flow_dir flow_json
  task_slug="$(slugify "${1:-}")"
  mode="${2:-Brainstorm}"
  if [[ -z "$task_slug" ]]; then
    echo "flowctl.sh init: task slug is required" >&2
    exit 1
  fi

  now="$(timestamp)"
  short_ts="$(date +"%Y%m%d-%H%M%S")"
  flow_id="FLOW-${task_slug}-${short_ts}"
  flow_dir="$FLOWS_DIR/$flow_id"
  flow_json="$flow_dir/flow.json"

  mkdir -p "$flow_dir/blast-radius" "$flow_dir/evidence" "$flow_dir/temp"
  flow_template "$TEMPLATE_DIR/current-flow.json" "$flow_id" "$task_slug" "$mode" "$now" >"$flow_json"
  local brainstorm_id
  brainstorm_id="$(ensure_artifact_file "$flow_dir" "$task_slug" "$flow_id" "BRAINSTORM-${task_slug}-v1" "" "" "brainstorm")"
  update_flow_json "$flow_json" "brainstorm" ".autodev/current-brainstorm.md" "$brainstorm_id" "$now"
  sync_registry "$flow_dir"

  echo "$flow_id"
}

command_activate() {
  local flow_id="$1"
  local flow_dir="$FLOWS_DIR/$flow_id"
  local flow_json="$flow_dir/flow.json"
  [[ -f "$flow_json" ]] || { echo "flowctl.sh activate: unknown flow $flow_id" >&2; exit 1; }
  sync_registry "$flow_dir"
  echo "Activated $flow_id"
}

command_ensure() {
  local artifact_type="$1"
  [[ -f "$ACTIVE_REGISTRY" ]] || { echo "flowctl.sh ensure: no active flow" >&2; exit 1; }
  local flow_id flow_dir task_slug brainstorm_ref metaphor_ref plan_ref artifact_id now
  flow_id="$(read_json_field "$ACTIVE_REGISTRY" "flow_id")"
  task_slug="$(read_json_field "$ACTIVE_REGISTRY" "task_slug")"
  brainstorm_ref="$(read_json_field "$ACTIVE_REGISTRY" "brainstorm_ref")"
  metaphor_ref="$(read_json_field "$ACTIVE_REGISTRY" "metaphor_ref")"
  plan_ref="$(read_json_field "$ACTIVE_REGISTRY" "plan_ref")"
  flow_dir="$FLOWS_DIR/$flow_id"
  artifact_id="$(ensure_artifact_file "$flow_dir" "$task_slug" "$flow_id" "$brainstorm_ref" "$metaphor_ref" "$plan_ref" "$artifact_type")"
  now="$(timestamp)"
  case "$artifact_type" in
    brainstorm) update_flow_json "$flow_dir/flow.json" "brainstorm" ".autodev/current-brainstorm.md" "$artifact_id" "$now" ;;
    metaphor)
      update_flow_json "$flow_dir/flow.json" "metaphor" ".autodev/current-metaphor.md" "$artifact_id" "$now"
      sync_metaphor_ref_into_artifacts "$flow_dir" "$artifact_id"
      ;;
    steps) update_flow_json "$flow_dir/flow.json" "steps" ".autodev/current-steps.md" "$artifact_id" "$now" ;;
    test) update_flow_json "$flow_dir/flow.json" "test" ".autodev/current-test.md" "$artifact_id" "$now" ;;
    debug) update_flow_json "$flow_dir/flow.json" "debug" ".autodev/current-debug.md" "$artifact_id" "$now" ;;
    blast_radius) update_flow_json "$flow_dir/flow.json" "blast_radius" ".autodev/current-blast-radius.md" "$artifact_id" "$now" ;;
    gui) update_flow_json "$flow_dir/flow.json" "gui" ".autodev/current-gui-test.js" "$artifact_id" "$now" ;;
  esac
  sync_registry "$flow_dir"
  echo "Ensured $artifact_type for $flow_id"
}

command_validate() {
  [[ -f "$ACTIVE_REGISTRY" ]] || { echo "flowctl.sh validate: no active flow registry" >&2; exit 1; }
  local flow_id brainstorm_ref metaphor_ref plan_ref
  flow_id="$(read_json_field "$ACTIVE_REGISTRY" "flow_id")"
  brainstorm_ref="$(read_json_field "$ACTIVE_REGISTRY" "brainstorm_ref")"
  metaphor_ref="$(read_json_field "$ACTIVE_REGISTRY" "metaphor_ref")"
  plan_ref="$(read_json_field "$ACTIVE_REGISTRY" "plan_ref")"

  python3 - "$ACTIVE_REGISTRY" "$AUTODEV_DIR" "$flow_id" "$brainstorm_ref" "$metaphor_ref" "$plan_ref" <<'PY'
import json, pathlib, sys

registry_path = pathlib.Path(sys.argv[1])
autodev_dir = pathlib.Path(sys.argv[2])
flow_id, brainstorm_ref, metaphor_ref, plan_ref = sys.argv[3:]
registry = json.loads(registry_path.read_text())

required = registry.get("required_artifacts", [])
artifact_files = {
    "brainstorm": autodev_dir / "current-brainstorm.md",
    "metaphor": autodev_dir / "current-metaphor.md",
    "steps": autodev_dir / "current-steps.md",
    "test": autodev_dir / "current-test.md",
    "debug": autodev_dir / "current-debug.md",
    "blast_radius": autodev_dir / "current-blast-radius.md",
    "gui": autodev_dir / "current-gui-test.js",
}

missing = [name for name in required if not artifact_files[name].exists()]
if missing:
    raise SystemExit(f"Missing required current artifacts: {', '.join(missing)}")

for name, path in artifact_files.items():
    if not path.exists():
        continue
    text = path.read_text()
    if flow_id not in text:
        raise SystemExit(f"{path.name} does not match active flow_id {flow_id}")
    if name not in {"brainstorm", "metaphor"} and brainstorm_ref and brainstorm_ref != "null" and brainstorm_ref not in text:
        raise SystemExit(f"{path.name} does not reference brainstorm_ref {brainstorm_ref}")
    if name != "metaphor" and metaphor_ref and metaphor_ref != "null" and metaphor_ref not in text:
        raise SystemExit(f"{path.name} does not reference metaphor_ref {metaphor_ref}")
    if name in {"test", "debug", "blast_radius", "gui"} and plan_ref and plan_ref != "null" and plan_ref not in text:
        raise SystemExit(f"{path.name} does not reference plan_ref {plan_ref}")

if artifact_files["metaphor"].exists() and (not metaphor_ref or metaphor_ref == "null"):
    raise SystemExit("current-metaphor.md exists but active registry has no metaphor_ref; use flowctl ensure metaphor or refresh the flow registry")

if artifact_files["steps"].exists() and (not plan_ref or plan_ref == "null"):
    raise SystemExit("current-steps.md exists but active registry has no plan_ref; use flowctl ensure steps or refresh the flow registry")

print("Active flow is valid")
PY
}

command_archive() {
  local flow_id="$1"
  local flow_json="$FLOWS_DIR/$flow_id/flow.json"
  [[ -f "$flow_json" ]] || { echo "flowctl.sh archive: unknown flow $flow_id" >&2; exit 1; }
  python3 - "$flow_json" "$(timestamp)" <<'PY'
import json, sys
path, updated_at = sys.argv[1], sys.argv[2]
data = json.load(open(path))
data["status"] = "archived"
data["updated_at"] = updated_at
json.dump(data, open(path, "w"), ensure_ascii=False, indent=2)
PY
  echo "Archived $flow_id"
}

command_clean() {
  rm -f "$AUTODEV_DIR"/current-brainstorm.md \
        "$AUTODEV_DIR"/current-metaphor.md \
        "$AUTODEV_DIR"/current-steps.md \
        "$AUTODEV_DIR"/current-test.md \
        "$AUTODEV_DIR"/current-debug.md \
        "$AUTODEV_DIR"/current-blast-radius.md \
        "$AUTODEV_DIR"/current-gui-test.js
  find "$FLOWS_DIR" -type d \( -name temp -o -name evidence \) -prune -exec find {} -mindepth 1 -maxdepth 1 -exec rm -rf {} + \;
  echo "Cleaned active view and flow temp outputs"
}

cmd="${1:-}"
shift || true

case "$cmd" in
  init) command_init "$@" ;;
  activate) command_activate "$@" ;;
  ensure) command_ensure "$@" ;;
  validate) command_validate "$@" ;;
  archive) command_archive "$@" ;;
  clean) command_clean "$@" ;;
  ""|-h|--help) usage ;;
  *) echo "flowctl.sh: unknown command: $cmd" >&2; usage; exit 1 ;;
esac
