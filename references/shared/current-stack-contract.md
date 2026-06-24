# Current Stack Contract

> `current-stack.json` 不是新的任务台账，而是更高一层的注意力指针。它回答的是“当前整个工作应聚焦在哪一条层级栈上”，并与 `current-flow.json` 一起构成 V2 控制面。

## 目标

- 在 `flow` 之上表达 `project / milestone / phase`
- 支持并行项目下的恢复、切换和自动 Resume
- 让高层状态不必拆成多个 `current-phase.md / current-milestone.md`
- 为 drift detection 和 replan/reconcile 提供统一指针输入

## 最小字段

| 字段 | 含义 |
|------|------|
| `stack_id` | 当前 stack 自己的实例 id |
| `status` | `active / paused / blocked / dormant / archived` |
| `initiative_ref` | 当前所属 initiative，可选 |
| `project_ref` | 当前所属 project |
| `milestone_ref` | 当前所属 milestone |
| `phase_ref` | 当前所属 phase |
| `flow_ref` | 当前 active flow id |
| `step_ref` | 当前 active step id |
| `last_meaningful_touch_at` | 最近一次有效推进时间 |
| `last_resume_at` | 最近一次 Resume 时间 |
| `auto_resume_enabled` | 是否启用自动 Resume |
| `resume_threshold_hours` | 自动 Resume 阈值 |
| `drift_precheck_enabled` | 是否启用轻量 drift precheck |
| `recent_flow_ids` | 最近活跃 flow 历史 |
| `updated_at` | 最近写入时间 |

## 强制规则

1. `flow_ref` 若存在，必须与 `.autodev/current-flow.json.flow_id` 对齐。
2. `current-stack.json` 只维护当前活跃注意力栈，不做完整项目数据库。
3. 小任务允许只有 `flow_ref / step_ref`，不强制填满全部上层字段。
4. 大任务只细化当前活跃前沿；未激活的 milestone / phase 保持粗粒度。
5. `last_meaningful_touch_at` 只在有效推进发生时更新，不用普通 metadata 刷新替代。

## 与其他 artefact 的关系

- `current-flow.json`：当前 flow 级控制面
- `current-stack.json`：当前多尺度注意力控制面
- `current-brainstorm.md`：目标与边界真相源
- `current-steps.md`：当前 flow 的执行真相源
- `project-roadmap.md` / `milestone-plan.md` / `phase-plan.md`：更高层规划真相源

## 典型路径

```text
initiative -> project -> milestone -> phase -> flow -> step
```

其中：

- 小任务可退化为 `flow -> step`
- 中任务可为 `phase -> flow -> step`
- 大任务才需要完整路径
