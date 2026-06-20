# Resume 模式 (热重启 / 半路回来)

> 适用: 用户忘了做到哪里、切了模型、断网后恢复、想先看当前 active flow 进度 | 产出: 当前任务摘要、当前进度、剩余工作、推荐下一步
> 路由 / 回执遵循 `references/shared/interaction-contract.md`

## 目录

- AI 必须主动读取
- 适用场景
- 流程
- 输出原则
- 与其他模式的边界
- 完成后选项
- 强制规则

## AI 必须主动读取

进入此模式时，AI 必须按以下顺序主动读取：

1. 若存在 `.autodev/current-stack.json`，先读取它
2. `.autodev/current-flow.json`
3. `.autodev/current-brainstorm.md`
4. `.autodev/current-steps.md`
5. `.autodev/current-test.md`
6. `.autodev/current-debug.md`
7. `.autodev/current-blast-radius.md`
8. `.autodev/current-gui-test.js`
9. `.autodev/context-snapshot.md`
10. 若存在 `.autodev/project-map.md`，读取其头部状态与核心摘要，恢复最近 Survey 的项目级结构认知
11. 若存在 `.autodev/module-registry.md`，读取其头部状态与可复用模块摘要

若需要确认快照是否落后于真实代码状态，再补充读取：

- `git status -sb`
- `git log -5 --oneline`

## 适用场景

- 用户说“我们做到哪了”“继续昨天那个”“半路回来”
- 用户明显忘了当前任务进度
- 新会话 / 新模型需要接手当前 active flow
- 断网、重启、切模型后，需要先恢复任务记忆，再决定继续哪个模式
- 检测到当前 stack 超过自动 Resume 阈值，需要先恢复上下文

## 流程

### Phase 1: 恢复 active flow

```text
AI:   🔥 auto-dev-team - Resume 已激活
      🧭 路由命中: Resume

      1. 若存在 `.autodev/current-stack.json`，先看当前 project / milestone / phase / flow / step
      2. 读取 `.autodev/current-flow.json`
      3. 确认当前是否存在 active flow
      4. 确认 `.autodev/current-*` 是否与 active flow 对齐
      5. 若 metadata 与 registry 不一致:
         - 明确提示 stale / 串线风险
         - 不得假装已经成功恢复
```

### Phase 2: 识别当前任务

```text
AI:   从 `current-brainstorm.md` 和 `current-steps.md` 提炼:

      - 当前在开发什么
      - 当前位于哪条活跃栈:
        `project > milestone > phase > flow > step`
      - 本次不做什么
      - 当前关键决策
      - 当前属于哪一阶段:
        Brainstorm / Planning / Step / Debug / Tester
```

### Phase 3: 识别当前进度

```text
AI:   若存在 `current-steps.md`:
      - 统计总步骤数
      - 统计已完成步骤数
      - 识别当前步骤:
        - 优先取最近一个 `❌失败`
        - 否则取第一个 `🌀待执行`
        - 若全部完成，则标记为计划已完成

      若存在 `current-test.md`:
      - 补充测试状态、待确认问题、剩余风险

      若存在 `current-debug.md`:
      - 补充当前假设、最近观测、卡住点

      若存在 `current-blast-radius.md`:
      - 补充最近一次 Gate 结论和风险等级
```

### Phase 4: 输出恢复结果

```text
AI:   当前在做:
      [一句话描述当前任务]

      现在进度:
      - Active Stack: [Project / Milestone / Phase / Flow / Step]
      - Active Flow: [FLOW-xxx]
      - 当前阶段: [Brainstorm / Planning / Step / Debug / Tester]
      - 已完成: [N/M 步]
      - 当前步骤: [Step N / 无]
      - 最近一次状态: [已通过 / 失败待修 / 暂不可执行 / 待确认]
      - Survey 摘要: [存在 / 缺失 / 可能过期]

      还差这些:
      - 剩余步骤: [...]
      - 测试状态: [...]
      - GUI 状态: [...]
      - 待用户确认: [...]

      风险与提醒:
      - Blast Radius: [🟢 / 🟡 / 🔴 / 无]
      - 当前主要风险: [...]
      - Snapshot 状态: [正常 / 可能过期 / 串线]

      推荐下一步:
      [1] 继续当前步骤
      [2] 看计划细节
      [3] 回到讨论层修正范围
      [4] 先补测试或验收
      [0] 结束
```

## 输出原则

- 先回答“现在在做什么”，再回答“做到哪里了”
- 优先引用 active flow 和 `current-*`，不要先靠猜
- 若计划与代码现状可能不一致，要明确写“可能落后于真实代码状态”
- Resume 先用 `.autodev/project-map.md` / `.autodev/module-registry.md` 恢复宏观结构，不把旧 Survey 当成当前精确代码证据；继续写代码前仍按代码导航原则重新定位目标符号和影响面
- 默认给用户一句话摘要 + 结构化进度，不展开大段实现细节
- 复述模块策略、接口面、接缝、适配器或测试面时，沿用 `references/principles/language-lock.md`；若旧 artefact 用词模糊，只标记“需重新对齐”，不要在 Resume 中擅自改写计划
- 若存在 `current-metaphor.md` 且用户明显是非技术背景，可先输出 `🪄 类比说明`，再输出技术进度

## 与其他模式的边界

| 情况 | 用哪个模式 |
|------|-----------|
| 先恢复任务记忆，再决定继续做什么 | **Resume** |
| 只想理解代码实现路径 | **Explain** |
| 已有计划，准备真正开始当前步骤 | **Step** |
| 当前没有计划，需要设计新功能 | **Architect** |
| 当前主要是排查问题 | **Debug** |
| 当前主要是补测试或做验收 | **Tester** |

## 完成后选项

```text
📍 当前: 已恢复当前任务记忆
📌 下一步:
[1] 继续当前流程 - 进入推荐模式继续执行
[2] 展开计划 - 查看 current-steps 细节
[3] 重新对齐 - 回到 Brainstorm / Architect 修正范围
[0] 结束
```

## 强制规则

- 若存在 `.autodev/current-stack.json`，必须先读 stack，再读 `.autodev/current-flow.json`
- 必须明确说明当前是否存在 active flow
- 必须区分“已确认事实”和“基于 current artefact 的推测”
- 若 `current-flow.json` 与 artefact metadata 不一致，禁止直接建议“继续写代码”
- Resume 默认只读，禁止在未获用户明确指示前推进 Step、改计划、或写代码
- 若存在 Survey 摘要，必须在恢复结果里说明是否已读取；若未使用，必须说明缺失、过期或与当前任务无关的原因
