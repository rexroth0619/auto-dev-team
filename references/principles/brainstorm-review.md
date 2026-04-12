# Brainstorm 对齐复核

> 执行后先确认“是不是按当前需求讨论结果做的”，再谈代码质量。

## 目标

- 检查实现是否真正覆盖 `current-brainstorm.md`
- 检查是否出现漏做、做偏、偷偷加戏
- 检查当前 artefacts 是否还属于同一条 flow

## 何时触发

- Step 模式最后一步完成后
- FastTrack 完成后
- Debug 修复完成后

## 必查项

1. `.autodev/current-flow.json` 存在且 active。
2. `current-brainstorm.md` 的 `flow_id` 与 active flow 一致。
3. 若存在 `current-steps.md`，其 `brainstorm_ref` 与 `current-brainstorm.md` 一致。
4. 当前改动是否覆盖了 `current-brainstorm.md` 的目标与验收标准。
5. 当前改动是否越界进入 `current-brainstorm.md` 的非目标区域。

## 输出建议

```text
━━━━━━━━━━━━━━━━━━━━
🔎 Brainstorm 对齐复核
━━━━━━━━━━━━━━━━━━━━
- Flow: [一致 / 不一致]
- Brainstorm: [artifact id]
- 覆盖情况: [满足 / 部分满足 / 不满足]
- 越界情况: [无 / 有]
- 结论: [可继续 / 需修正 / 需回到 Brainstorm]
━━━━━━━━━━━━━━━━━━━━
```
