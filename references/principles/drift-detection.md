# Drift Detection

> 动态重规划不靠 AI 凭感觉触发，而是“脚本检测异常，AI 裁决层级，脚本 reconcile 状态”。

## 机制

```text
precheck -> full detect -> AI replan decision -> reconcile
```

## 轻量 precheck

默认在以下时机自动运行：

- 每次新消息到来且存在 active stack
- Resume 前
- Step 完成后
- 用户明确改目标 / 优先级后
- 长时间中断后重新进入执行前

precheck 只检测“当前层已经声明应该存在的东西”：

- 若 flow 还停留在 Brainstorm，缺少 `current-steps.md` 不算漂移
- 只有 `required_artifacts`、`plan_ref`、`artifacts.steps` 或 `active_mode=Step` 已声明进入步骤规划/执行后，缺少 `current-steps.md` 才算 drift

## 触发 full detect 的条件

- `precheck` 报警
- 节点不存在或已 `superseded`
- 层级引用不一致
- 长期停滞
- 计划节点数量明显失真
- 实际新增子项超出原计划阈值
- 依赖变化
- 验证路径失效
- phase / milestone 边界变化

## full detect 输出

- `drift_detected`
- `signals`
- `severity`
- `suspected_level`
- `evidence`

## AI 裁决

AI 不负责发现所有异常，只负责：

- 判断异常是否需要重规划
- 决定回到 `flow / phase / milestone / project` 哪一层
- 说明为什么

## reconcile

若决定重规划：

- 旧规划标记 `superseded`
- 生成新规划
- 更新 active stack
- 复用仍然有效的 artefact

## 禁止事项

- 只靠 AI 感觉就回顶层重规划
- 发现漂移后全量暴力重写所有 current 文件
