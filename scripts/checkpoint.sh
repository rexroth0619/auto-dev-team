#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: checkpoint.sh <command> [args]

Commands:
  ensure-branch <task-slug>
  milestone <fingerprint> [description] [task-slug]
  snapshot-gate [task]
  archive <fingerprint> [type] [description]
  list
  rollback <hash|tag|index|fingerprint>
  merge-advice [integration-branch]
EOF
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

if ! REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  echo "checkpoint.sh: current directory is not inside a git repository" >&2
  exit 1
fi

cd "$REPO_ROOT"
CONFIG_FILE="$REPO_ROOT/.autodev/autodev-config.json"

json_get() {
  local path="$1"
  local fallback="$2"

  if [[ ! -f "$CONFIG_FILE" ]]; then
    printf '%s\n' "$fallback"
    return 0
  fi

  python3 - "$CONFIG_FILE" "$path" "$fallback" <<'PY'
import json
import sys

config_path, dotted_path, fallback = sys.argv[1:]

try:
    with open(config_path, "r", encoding="utf-8") as fh:
        data = json.load(fh)
except Exception:
    print(fallback)
    raise SystemExit(0)

value = data
for part in dotted_path.split("."):
    if not isinstance(value, dict) or part not in value:
        print(fallback)
        raise SystemExit(0)
    value = value[part]

if isinstance(value, bool):
    print("true" if value else "false")
elif isinstance(value, list):
    for item in value:
        print(item)
else:
    print(value)
PY
}

timestamp() {
  date "+%m%d%H%M"
}

actor_slug() {
  local raw
  raw="$(git config user.name || true)"
  raw="${raw%% *}"
  raw="$(printf '%s' "$raw" | tr '[:upper:]' '[:lower:]' | tr -cs '[:alnum:]' '-')"
  raw="${raw#-}"
  raw="${raw%-}"
  printf '%s\n' "${raw:-agent}"
}

slugify() {
  local raw="${1:-task}"
  raw="$(printf '%s' "$raw" | tr '[:upper:]' '[:lower:]' | tr -cs '[:alnum:]' '-')"
  raw="${raw#-}"
  raw="${raw%-}"
  printf '%s\n' "${raw:-task}"
}

current_branch() {
  git branch --show-current
}

head_tags() {
  git tag --points-at HEAD
}

head_has_tag_prefix() {
  local prefix="$1"
  head_tags | grep -q "^${prefix}/"
}

integration_mode() {
  json_get "integration_mode" "merge_allowed"
}

protected_branches() {
  json_get "protected_branches" "main"
}

matches_branch_pattern() {
  local branch="$1"
  local pattern
  while IFS= read -r pattern; do
    [[ -z "$pattern" ]] && continue
    if [[ "$branch" == $pattern ]]; then
      return 0
    fi
  done < <(protected_branches)
  return 1
}

repo_is_dirty() {
  [[ -n "$(git status --porcelain)" ]]
}

last_subject() {
  git log -1 --pretty=%s 2>/dev/null || true
}

subject_fingerprint() {
  local subject="${1:-}"
  if [[ "$subject" =~ 「([^」]+)」 ]]; then
    printf '%s\n' "${BASH_REMATCH[1]}"
    return 0
  fi
  printf '\n'
}

subject_task_key() {
  local subject="${1:-}"
  local fingerprint
  fingerprint="$(subject_fingerprint "$subject")"
  if [[ -n "$fingerprint" ]]; then
    printf '%s\n' "${fingerprint%%#*}"
    return 0
  fi
  printf '其他\n'
}

workflow_commit_kind() {
  local subject="${1:-}"
  if [[ "$subject" == *"#保护"* ]]; then
    printf 'snapshot\n'
    return 0
  fi
  if [[ "$subject" == *"#起点"* || "$subject" == *"#信任起点"* || "$subject" == *"#完成"* ]]; then
    printf 'milestone\n'
    return 0
  fi
  printf 'feature\n'
}

is_workflow_commit() {
  [[ "$(workflow_commit_kind "${1:-}")" != "feature" ]]
}

entry_icon() {
  local kind="$1"
  case "$kind" in
    milestone) printf '🎯' ;;
    snapshot) printf '💿' ;;
    archive|feature|head) printf '💾' ;;
    *) printf '•' ;;
  esac
}

entry_backing() {
  local kind="$1"
  local ref="$2"
  if [[ "$ref" == milestone/* || "$ref" == snapshot/* ]]; then
    printf 'tag-only'
    return 0
  fi
  if [[ "$kind" == "snapshot" || "$kind" == "archive" || "$kind" == "feature" ]]; then
    printf 'commit'
    return 0
  fi
  printf 'commit'
}

integration_branch_name() {
  local explicit="${1:-}"
  if [[ -n "$explicit" ]]; then
    printf '%s\n' "$explicit"
    return 0
  fi

  local configured
  configured="$(json_get "integration_branch" "")"
  if [[ -n "$configured" ]]; then
    printf '%s\n' "$configured"
    return 0
  fi

  local origin_head
  origin_head="$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null || true)"
  if [[ -n "$origin_head" ]]; then
    printf '%s\n' "${origin_head#origin/}"
    return 0
  fi

  printf '%s\n' "$(current_branch)"
}

collect_checkpoint_entries() {
  local -a milestone_entries=() archive_entries=()
  local latest_snapshot_ts=0 latest_snapshot=""
  local tag subject created hash line kind task

  while IFS=$'\t' read -r created tag subject; do
    [[ -z "$tag" ]] && continue
    hash="$(git rev-list -n 1 "$tag")"
    kind="archive"
    [[ "$tag" == milestone/* ]] && kind="milestone"
    [[ "$tag" == snapshot/* ]] && kind="snapshot"
    task="$(subject_task_key "$subject")"
    line="${created}|${kind}|$(entry_backing "$kind" "$tag")|${hash}|${tag}|${subject}|${task}"
    if [[ "$kind" == "milestone" ]]; then
      milestone_entries+=("$line")
      continue
    fi
    if [[ "$kind" == "snapshot" && "${created:-0}" -ge "$latest_snapshot_ts" ]]; then
      latest_snapshot_ts="${created:-0}"
      latest_snapshot="$line"
    fi
  done < <(git for-each-ref --sort=-creatordate --format='%(creatordate:unix)%09%(refname:short)%09%(subject)' refs/tags/milestone refs/tags/snapshot)

  local commit_ts full_hash short_hash kind_subject
  while IFS=$'\t' read -r commit_ts full_hash short_hash subject; do
    [[ -z "$short_hash" ]] && continue
    if [[ -n "$(git tag --points-at "$full_hash" | grep '^milestone/' || true)" ]]; then
      continue
    fi
    kind_subject="$(workflow_commit_kind "$subject")"
    task="$(subject_task_key "$subject")"
    if [[ "$kind_subject" == "snapshot" ]]; then
      line="${commit_ts:-0}|snapshot|commit|${full_hash}|${short_hash}|${subject}|${task}"
      if [[ "${commit_ts:-0}" -ge "$latest_snapshot_ts" ]]; then
        latest_snapshot_ts="${commit_ts:-0}"
        latest_snapshot="$line"
      fi
      continue
    fi
    if [[ "$kind_subject" == "milestone" ]]; then
      line="${commit_ts:-0}|milestone|commit|${full_hash}|${short_hash}|${subject}|${task}"
      milestone_entries+=("$line")
      continue
    fi
    archive_entries+=("${commit_ts:-0}|archive|commit|${full_hash}|${short_hash}|${subject}|${task}")
  done < <(git log --pretty='%ct%x09%H%x09%h%x09%s' -80)

  printf '%s\n' "${milestone_entries[@]}"
  [[ -n "$latest_snapshot" ]] && printf '%s\n' "$latest_snapshot"
  local count=0 item
  for item in "${archive_entries[@]}"; do
    printf '%s\n' "$item"
    count=$((count + 1))
    [[ "$count" -ge 5 ]] && break
  done
}

review_staging() {
  local mode="$1"
  local branch_mode
  branch_mode="$(integration_mode)"
  local -a staged=()
  local staged_file
  while IFS= read -r staged_file; do
    staged+=("$staged_file")
  done < <(git diff --cached --name-only)
  [[ ${#staged[@]} -eq 0 ]] && return 0

  local file
  for file in "${staged[@]}"; do
    case "$file" in
      .env|.env.*|*.pem|*.key|*.p12|credentials.*|secrets.*)
        git reset HEAD -- "$file" >/dev/null 2>&1 || true
        echo "⛔ 已从暂存区移除敏感文件: $file" >&2
        ;;
      .autodev/*|.cursor/*)
        if [[ "$mode" == "archive" && "$branch_mode" == "pr_only" ]]; then
          git reset HEAD -- "$file" >/dev/null 2>&1 || true
          echo "⛔ pr_only 模式下已移出暂存区: $file" >&2
        elif [[ "$mode" == "archive" ]]; then
          echo "⚠️ 暂存区发现非代码文件: $file" >&2
        fi
        ;;
    esac
  done
}

tag_base_for() {
  local prefix="$1"
  local task_slug="$2"
  local base
  base="${prefix}/${task_slug}-$(timestamp)"
  if [[ "$(integration_mode)" == "pr_only" ]]; then
    base="${prefix}/$(actor_slug)/${task_slug}-$(timestamp)"
  fi
  printf '%s\n' "$base"
}

create_annotated_tag() {
  local prefix="$1"
  local task_slug="$2"
  local fingerprint="$3"
  local description="$4"

  local tag_base tag_name idx
  tag_base="$(tag_base_for "$prefix" "$task_slug")"
  tag_name="$tag_base"
  idx=2
  while git rev-parse -q --verify "refs/tags/$tag_name" >/dev/null 2>&1; do
    tag_name="${tag_base}-${idx}"
    idx=$((idx + 1))
  done

  git tag -a "$tag_name" -m "「${fingerprint}」chore: ${description}"
  printf '%s\n' "$tag_name"
}

ensure_branch() {
  local task_slug
  task_slug="$(slugify "${1:-task}")"

  local branch
  branch="$(current_branch)"
  if ! matches_branch_pattern "$branch"; then
    echo "🌿 已在工作分支: $branch"
    return 0
  fi

  local branch_mode new_branch
  branch_mode="$(integration_mode)"
  if [[ "$branch_mode" == "pr_only" ]]; then
    new_branch="autodev/$(actor_slug)/${task_slug}-$(timestamp)"
  else
    new_branch="autodev/${task_slug}-$(timestamp)"
  fi

  git switch -c "$new_branch" >/dev/null
  local base_hash
  base_hash="$(git rev-parse --short HEAD)"

  cat <<EOF
━━━━━━━━━━━━━━━━━━━━
🌿 已创建工作分支
分支: $new_branch
基于: $branch ($base_hash)
━━━━━━━━━━━━━━━━━━━━
EOF
}

create_milestone() {
  local fingerprint="${1:?fingerprint required}"
  local description="${2:-任务开始前基线}"
  local task_slug
  task_slug="$(slugify "${3:-$fingerprint}")"

  local tag_name hash
  tag_name="$(create_annotated_tag "milestone" "$task_slug" "$fingerprint" "$description")"
  hash="$(git rev-parse --short HEAD)"

  cat <<EOF
━━━━━━━━━━━━━━━━━━━━
🎯 里程碑
━━━━━━━━━━━━━━━━━━━━
指纹: ${fingerprint}
哈希: ${hash}
标签: ${tag_name}
━━━━━━━━━━━━━━━━━━━━
💡 随时可说「回退到 ${fingerprint}」
$(if repo_is_dirty; then printf '📝 工作区有未提交改动；里程碑只标记当前 HEAD，未提交现场将由后续 💿 快照保护\n'; fi)━━━━━━━━━━━━━━━━━━━━
EOF
}

snapshot_gate() {
  local task="${1:-现场保护}"
  local subject
  subject="$(last_subject)"

  if repo_is_dirty; then
    git add -A
    review_staging "snapshot"
    git commit -m "「${task}#保护」chore: 自动存档" >/dev/null
    echo "💿 已保护 → $(git rev-parse --short HEAD)（执行前闸门）"
    return 0
  fi

  if head_has_tag_prefix "milestone" || head_has_tag_prefix "snapshot" || [[ "$subject" == *"#保护"* || "$subject" == *"#起点"* ]]; then
    echo "💿 闸门通过（基线 $(git rev-parse --short HEAD) 即保护点）"
    return 0
  fi

  local task_slug tag_name
  task_slug="$(slugify "$task")"
  tag_name="$(create_annotated_tag "snapshot" "$task_slug" "${task}#保护" "执行前基线保护（tag-only）")"
  echo "💿 已保护 → $(git rev-parse --short HEAD)（tag-only: ${tag_name}）"
}

archive_commit() {
  local fingerprint="${1:?fingerprint required}"
  local kind="${2:-chore}"
  local description="${3:-自动存档}"

  if ! repo_is_dirty; then
    echo "ℹ️ 无改动，跳过存档"
    return 0
  fi

  git add -A
  review_staging "archive"
  git commit -m "「${fingerprint}」${kind}: ${description}" >/dev/null
  echo "💾【存档】${fingerprint} → $(git rev-parse --short HEAD)"
}

list_archives() {
  local head_hash head_subject head_task
  head_hash="$(git rev-parse --short HEAD)"
  head_subject="$(git log -1 --pretty=%s)"
  head_task="$(subject_task_key "$head_subject")"
  echo "━━━━━━━━━━━━━━━━━━━━"
  echo "📍 版本点列表"
  echo "━━━━━━━━━━━━━━━━━━━━"
  echo "HEAD: ${head_hash} ${head_subject}"
  echo "任务: ${head_task}"
  echo "━━━━━━━━━━━━━━━━━━━━"
  local idx=1 current_task="" item ts kind backing hash ref subject task icon short_hash
  while IFS= read -r item; do
    [[ -z "$item" ]] && continue
    IFS='|' read -r ts kind backing hash ref subject task <<<"$item"
    if [[ "$task" != "$current_task" ]]; then
      current_task="$task"
      echo "【任务: ${current_task}】"
    fi
    icon="$(entry_icon "$kind")"
    short_hash="${hash:0:7}"
    echo "[$idx] ${icon} ${short_hash} ${subject} (${backing})"
    idx=$((idx + 1))
  done < <(collect_checkpoint_entries)
  echo "━━━━━━━━━━━━━━━━━━━━"
  echo "回退到哪个？（输入序号 / tag / hash / 指纹）"
  echo "━━━━━━━━━━━━━━━━━━━━"
}

resolve_checkpoint_target() {
  local target="${1:?target required}"

  if [[ "$target" =~ ^[0-9]+$ ]]; then
    local idx=1 item ts kind backing hash ref subject task
    while IFS= read -r item; do
      [[ -z "$item" ]] && continue
      if [[ "$idx" -eq "$target" ]]; then
        IFS='|' read -r ts kind backing hash ref subject task <<<"$item"
        printf '%s|%s|%s|%s\n' "$kind" "$ref" "$hash" "$subject"
        return 0
      fi
      idx=$((idx + 1))
    done < <(collect_checkpoint_entries)
    return 1
  fi

  if git rev-parse -q --verify "refs/tags/$target" >/dev/null 2>&1; then
    local hash subject
    hash="$(git rev-list -n 1 "$target")"
    subject="$(git for-each-ref --format='%(subject)' "refs/tags/$target")"
    local kind="archive"
    [[ "$target" == milestone/* ]] && kind="milestone"
    [[ "$target" == snapshot/* ]] && kind="snapshot"
    printf '%s|%s|%s|%s\n' "$kind" "$target" "$hash" "$subject"
    return 0
  fi

  if git rev-parse -q --verify "$target^{commit}" >/dev/null 2>&1; then
    local hash subject kind
    hash="$(git rev-parse "$target^{commit}")"
    subject="$(git log -1 --pretty=%s "$hash")"
    kind="$(workflow_commit_kind "$subject")"
    [[ "$kind" == "feature" ]] && kind="archive"
    printf '%s|%s|%s|%s\n' "$kind" "$target" "$hash" "$subject"
    return 0
  fi

  local item ts kind backing hash ref subject task
  while IFS= read -r item; do
    [[ -z "$item" ]] && continue
    IFS='|' read -r ts kind backing hash ref subject task <<<"$item"
    if [[ "$subject" == *"$target"* ]]; then
      printf '%s|%s|%s|%s\n' "$kind" "$ref" "$hash" "$subject"
      return 0
    fi
  done < <(collect_checkpoint_entries)
  return 1
}

rollback_to() {
  local target="${1:?target required}"
  local branch
  branch="$(current_branch)"
  if matches_branch_pattern "$branch"; then
    cat <<EOF
━━━━━━━━━━━━━━━━━━━━
⚠️ 当前在受保护分支 $branch 上，无法直接回退
请选择切换到工作分支后再回退
━━━━━━━━━━━━━━━━━━━━
EOF
    exit 1
  fi

  if repo_is_dirty; then
    snapshot_gate "现场保存"
  fi

  local resolved kind ref hash subject
  if ! resolved="$(resolve_checkpoint_target "$target")"; then
    echo "❌ 找不到回退目标: $target" >&2
    exit 1
  fi
  IFS='|' read -r kind ref hash subject <<<"$resolved"

  git reset --hard "$hash" >/dev/null
  cat <<EOF
━━━━━━━━━━━━━━━━━━━━
✅ 已回退
目标: ${kind} ${ref}
$(if [[ "$ref" == milestone/* || "$ref" == snapshot/* ]]; then printf '说明: 已回退到 tag 指向的 commit\n'; fi)当前位置: $(git log -1 --pretty=%s) $(git rev-parse --short HEAD)
分支: $branch
━━━━━━━━━━━━━━━━━━━━
EOF
}

merge_advice() {
  local integration
  integration="$(integration_branch_name "${1:-}")"

  if ! git rev-parse -q --verify "$integration" >/dev/null 2>&1; then
    echo "❌ 找不到集成分支: $integration" >&2
    exit 1
  fi

  local branch
  branch="$(current_branch)"
  local -a feature_commits=() workflow_commits=()
  local hash subject
  while IFS=$'\t' read -r hash subject; do
    [[ -z "$hash" ]] && continue
    if is_workflow_commit "$subject"; then
      workflow_commits+=("${hash:0:7}|$subject")
    else
      feature_commits+=("${hash:0:7}|$subject")
    fi
  done < <(git log --reverse --format='%H%x09%s' "${integration}..HEAD")

  echo "━━━━━━━━━━━━━━━━━━━━"
  echo "🧭 合并建议"
  echo "━━━━━━━━━━━━━━━━━━━━"
  echo "当前分支: $branch"
  echo "目标分支: $integration"
  echo "功能提交: ${#feature_commits[@]}"
  echo "工作流提交: ${#workflow_commits[@]}"
  echo "━━━━━━━━━━━━━━━━━━━━"

  local item
  if (( ${#feature_commits[@]} == 0 && ${#workflow_commits[@]} == 0 )); then
    echo "结论: 当前分支没有领先提交"
  elif (( ${#feature_commits[@]} == 0 )); then
    echo "结论: 当前分支仅包含工作流提交，建议不要直接 merge"
    echo "建议: 无可合并代码成果"
  elif (( ${#workflow_commits[@]} > 0 )); then
    echo "结论: 当前分支混有工作流提交，建议 clean merge / cherry-pick 真实功能提交"
  else
    echo "结论: 当前分支只包含真实功能提交，可直接 merge"
  fi

  if (( ${#feature_commits[@]} )); then
    echo "功能提交:"
    for item in "${feature_commits[@]}"; do
      IFS='|' read -r hash subject <<<"$item"
      echo "- ${hash} ${subject}"
    done
  fi
  if (( ${#workflow_commits[@]} )); then
    echo "工作流提交:"
    for item in "${workflow_commits[@]}"; do
      IFS='|' read -r hash subject <<<"$item"
      echo "- ${hash} ${subject}"
    done
  fi
  echo "━━━━━━━━━━━━━━━━━━━━"
}

command="${1:-}"
shift || true

case "$command" in
  ensure-branch)
    ensure_branch "$@"
    ;;
  milestone)
    create_milestone "$@"
    ;;
  snapshot-gate)
    snapshot_gate "$@"
    ;;
  archive)
    archive_commit "$@"
    ;;
  list)
    list_archives
    ;;
  rollback)
    rollback_to "$@"
    ;;
  merge-advice)
    merge_advice "$@"
    ;;
  -h|--help|help)
    usage
    ;;
  *)
    echo "Unknown command: $command" >&2
    usage
    exit 1
    ;;
esac
