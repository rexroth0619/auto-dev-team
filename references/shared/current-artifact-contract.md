# Current Artifact Contract

> `current-*` 不再只是“当前文件名”，而是同一条工作流实例（flow）下的一组成套产物。目录归属、registry 和 metadata header 共同决定它是不是“正确的当前 artefact”。

## 目标

- 让 `current-*` 有稳定实例身份，不再主要依赖 Agent 上下文猜测
- 让初始化、补齐、切换 active、归档、清理可以脚本化
- 让 `Brainstorm -> Architect -> Step -> Review` 共用同一条 flow

## 目录模型

```text
.autodev/
├── current-flow.json
├── current-brainstorm.md
├── current-metaphor.md
├── current-steps.md
├── current-test.md
├── current-debug.md
├── current-blast-radius.md
├── current-gui-test.js
└── flows/
    └── <flow_id>/
        ├── flow.json
        ├── current-brainstorm.md
        ├── current-metaphor.md
        ├── current-steps.md
        ├── current-test.md
        ├── current-debug.md
        ├── current-blast-radius.md
        ├── current-gui-test.js
        ├── blast-radius/
        ├── evidence/
        └── temp/
```

- `flows/<flow_id>/`：真实归属目录
- `.autodev/current-*`：当前 active flow 的兼容入口
- `.autodev/current-flow.json`：当前 active flow 的 registry

## 强制规则

1. 同一时刻只能有 1 个 active flow。
2. 所有 `current-*` 都必须带 metadata header。
3. 派生产物必须继承同一个 `flow_id`。
4. `current-flow.json` 负责声明当前应该有哪些 artefacts。
5. 若 metadata 和 `current-flow.json` 不一致，视为 stale / 串线 artefact，禁止直接继续执行。

## 统一 metadata 字段

所有 markdown 类 `current-*` 文件在顶部写：

- `flow_id`
- `artifact_id`
- `artifact_type`
- `status`
- `brainstorm_ref`
- `metaphor_ref`
- `plan_ref`
- `step_ref`
- `derived_from`
- `updated_at`

JS 类 artefact（如 `current-gui-test.js`）使用注释块携带同样字段。

## 字段语义

| 字段 | 含义 |
|------|------|
| `flow_id` | 当前工作流实例 id，整条链路统一 |
| `artifact_id` | 当前 artefact 自己的实例 id |
| `artifact_type` | `brainstorm / metaphor-layer / steps / test-ledger / debug-ledger / blast-radius / gui-script` |
| `status` | `draft / active / superseded / archived` |
| `brainstorm_ref` | 当前 artefact 对应哪一份 `current-brainstorm` |
| `metaphor_ref` | 当前 artefact 对应哪一份 `current-metaphor` |
| `plan_ref` | 当前 artefact 对应哪一份 `current-steps` |
| `step_ref` | 若该 artefact 对应某个 Step，则写 `STEP-N` |
| `derived_from` | 该 artefact 从哪个 artefact 或输入派生 |
| `updated_at` | 最近更新时间 |

## current-flow.json 的职责

`current-flow.json` 只做控制面，不做大数据库：

- 当前 active `flow_id`
- 当前 `active_mode`
- 当前 `active_step`
- 当前 `brainstorm_ref`
- 当前 `metaphor_ref`
- 当前 `plan_ref`
- 当前 artefacts 路径
- 当前阶段要求补齐的 artefacts

它回答的是：“现在应该读哪一套 artefacts，缺了哪些，是否还属于同一条 flow”。

## flowctl.sh 的职责

优先用 `scripts/flowctl.sh` 管理 current artefacts：

- `init`：创建新 flow，初始化 brainstorm 和 registry
- `activate`：切换 active flow
- `ensure`：按模板补齐 artefact
- `validate`：校验 required artefacts 和 metadata 一致性
- `archive`：归档 flow
- `clean`：清理旧的 active 视图和临时产物

## 与模式的关系

- `Brainstorm`：生成 `current-brainstorm.md`，初始化 flow
- `Resume`：消费 `current-flow.json + current-*`，恢复当前任务记忆并推荐下一步模式
- `Metaphor Layer`：生成 `current-metaphor.md`，建立当前 flow 的表达层协议
- `Architect`：消费 `current-brainstorm.md`，生成 `current-steps.md`
- `Step`：消费 `current-brainstorm.md + current-steps.md`，并更新其他 `current-*`
- `Review`：先校验是否对齐 `current-brainstorm`，再看实现质量
