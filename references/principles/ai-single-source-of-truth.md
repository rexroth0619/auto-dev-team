# AI Single Source Of Truth

> 给 AI 用的项目级固定事实锁定层。`path.md` 偏人读，`ai-sot.json` 偏机读。

## 目标

- 把预发 / 部署 / 远端执行 / GUI 宿主 / 认证方式等长期固定事实，从临时 `release-plan.json` 中剥离出来
- 避免 AI 在每次自动化预发、部署、远端运维时重新猜测 SSH alias、工作目录、allowed paths、base URL、认证方式
- 让 `release-plan.json` 只承载“本次任务的动态计划”，不再偷偷承载项目级静态事实

## 文件约定

- 项目级固定事实文件：`.autodev/ai-sot.json`
- 推荐只锁“长期事实”，不要把当前任务 commit range、单次 use case、临时证据路径写进去

## 角色分工

| 文件 | 定位 | 允许变动 |
|------|------|----------|
| `.autodev/path.md` | 人类可读事实总览 | 可维护，但只写长期事实 |
| `.autodev/ai-sot.json` | AI 专用机器真相源 | 默认只读，变更需用户确认 |
| `.autodev/temp/release-plan.json` | 本次任务动态计划 | 每次自动化预发都可重建 |

## `ai-sot.json` 最低结构

```json
{
  "schema_version": "1.0",
  "lock_id": "project-ai-sot-v1",
  "ai_mutation_policy": {
    "default": "read_only",
    "requires_user_confirmation": true
  },
  "pre_release": {
    "staging_context": {},
    "backend_execution_context": {},
    "gui_execution_context": {},
    "auth_hints": {},
    "public_entry": {}
  }
}
```

## 读取规则

以下场景必须先读取 `.autodev/ai-sot.json`：

- 自动化预发测试
- 部署 / 发布 / 回滚
- 远端 SSH 执行
- GUI 宿主选择
- 认证桥接
- 任何需要判断 `ssh_alias / working_directory / allowed_paths / base_url / auth_mode` 的场景

## 变更规则

- AI 默认禁止修改 `.autodev/ai-sot.json`
- 若发现其中事实过期：
  1. 先指出差异
  2. 给出最小 diff
  3. 等用户明确确认后再改
- 未确认前，不得 silently 覆盖或“顺手修一下”

## 与预发自动化的关系

- `release-pack.py` 若检测到 `.autodev/ai-sot.json`，应优先用它填充固定上下文
- `release-auto-run.py` 若检测到 `.autodev/ai-sot.json`，应校验 `release-plan.json` 是否偏离锁定事实
- 偏离则直接 `manual_fallback`，不得继续执行
