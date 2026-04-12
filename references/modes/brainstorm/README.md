# Brainstorm 模式 (需求讨论)

> 适用: 需求还在讨论、边界未清、希望先达成共识再做方案 | 产出: `current-brainstorm.md`；若启用比喻层，再产出 `current-metaphor.md`

## 目录

- AI 必须主动执行
- 流程
- 产出物
- 阶段结束选项

## AI 必须主动执行

进入此模式时，AI 必须：

1. 调用 `scripts/flowctl.sh init <task-slug> brainstorm` 初始化或激活当前 flow。
2. 读取 `.autodev/current-flow.json`，确认 active flow。
3. 创建或更新 `.autodev/current-brainstorm.md`。
4. 若用户需要“人能听懂的比喻解释”，创建或更新 `.autodev/current-metaphor.md`。
5. 仅讨论目标、边界、验收，不直接进入代码实现。

## 流程

### Phase 1: 目标澄清

```text
AI:
1. 先确认用户真正要解决的问题
2. 区分“目标”与“解决方案”
3. 若需求描述模糊，每次只追问 1 个关键问题
```

### Phase 2: 边界与约束

```text
AI:
1. 明确本次要做什么
2. 明确本次不做什么
3. 补齐约束：时间、兼容性、权限、环境、成本
```

### Phase 3: 验收标准

```text
AI:
1. 把完成标准写成用户可确认的结果
2. 把规则不清的部分列成待确认问题
3. 标明推荐进入的下一个模式
```

### Phase 3.5: 用户表达层确认 (可选)

```text
AI:
1. 判断是否建议启用比喻层
   - PM / 业务 / 非技术用户：默认建议 `light`
   - 混合用户：建议 `light`
   - 专业开发：默认 `off`

2. 若启用，固定只提供 3 个标准模板：
   - 餐厅 / 做饭 (`restaurant`)
   - 物流 / 仓储配送 (`logistics`)
   - 工厂 / 流水线 (`factory`)

3. 确认输出深度：
   - off
   - light：一句类比 + 一句技术解释
   - full：用户回执优先带类比说明

4. 若用户要求别的比喻：
   - 先从 3 个标准模板里选最接近的基底
   - 再写入 `.autodev/current-metaphor.md` 的派生映射
5. 启用后，用户后续可以继续用同一比喻提问；AI 必须先在内部翻译回技术语义，再继续分析
```

### Phase 4: 写入 current-brainstorm

```text
AI:
1. 更新 .autodev/current-brainstorm.md
2. 写入 metadata header
3. 更新 .autodev/current-flow.json:
   - active_mode=Brainstorm
   - brainstorm_ref=当前 current-brainstorm artefact id
   - required_artifacts=["brainstorm"]
4. 若比喻层启用：
   - 执行 `scripts/flowctl.sh ensure metaphor`
   - 更新 `.autodev/current-metaphor.md`
   - 在 `.autodev/current-flow.json` 中记录 `metaphor_ref`
```

## 产出物

- `.autodev/current-brainstorm.md`
- `.autodev/current-metaphor.md` (可选)
- `.autodev/current-flow.json`

## 阶段结束选项

```text
📍 当前: 需求讨论已整理完成
📌 下一步:
[1] 进入 Architect - 基于 current-brainstorm 生成执行计划
[2] 进入 FastTrack - 若范围很小，可直接做快速修改
[3] 继续补充 current-brainstorm
[0] 结束
```
