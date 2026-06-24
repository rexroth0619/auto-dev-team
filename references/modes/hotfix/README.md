# Hotfix 模式 (紧急修复)

> 适用: 线上出问题、紧急、需要快速止血 | 原则: 先止血后复盘，最小改动 | 产出: postmortem [HOTFIX]

⚠️ 若本次故障位于 GUI 链路，执行验证前必须读取 `references/principles/gui-autonomous-loop.md`。
⚠️ 若本次故障涉及已有代码定位、调用链或影响面，执行前必须读取 `references/principles/code-navigation.md`。
⚠️ 若止血涉及模块归属、接口面、契约、接缝或测试落层，必须读取 `references/principles/language-lock.md`，把“组件 / 服务 / API / 边界 / 抽象”翻译成精确术语。

## 核心原则

```
先止血，后复盘
最小改动，快速恢复
```

## 流程

### 0. 需求确认与澄清

- Hotfix 也必须先完成 `references/shared/interaction-contract.md` 的 `需求确认与澄清闸门`。
- 紧急场景可以把 `🧾 需求澄清问题包` 压缩到 1-3 个问题，但不能为 0。
- 输出澄清问题包后必须停下来等用户回复；用户回复前不得定位、出方案、快照、Blast Radius 或写代码。

### 0.5 版本保护

- 💿 修复前（强制）：按 `references/principles/checkpoint-mechanism.md` 的"执行前快照闸门"执行。用户确认方案后、第一行代码写入前，必须通过闸门。
- 💾 修复完成且验证通过后：建立 1 个存档。详见 `references/principles/checkpoint-mechanism.md`。

### 1. 快速定位
```
用户: [描述紧急问题]
      [报错信息]

AI:   1. 跳过深度分析，但不跳过导航定位
      2. 若代码导航器可用且项目已索引，先用 semantic_explore 定位出错路径和最小止血点；否则说明降级原因后直接定位出错位置
      3. 提出最小改动方案
         - 若改动碰到接口面或接缝，必须说明止血改的是哪个接口面、临时适配在哪里、测试穿过哪个测试面
      
      4. ⭐ 按 `references/principles/critique.md` 的模式集成流程执行自动会诊（紧急也不跳过）
         传递：【用户原始问题描述】+ 问题、最小修复方案
      5. 等待用户选择执行哪一个
```

### 1.5 Blast Radius 快速止血评估（强制）

```text
AI:   在第一行修复代码前，先用代码导航器收窄目标，再运行 `scripts/blast-radius.py`
      目标: 本次止血文件 / 符号 / 原始故障路径
      输出: 风险等级、直接调用方、原始回归入口、Gate 结论

      若结果 = 🔴 且无法缩小到单点止血:
      - 明确说明风险
      - 让用户确认是否继续临时止血
```

### 2. 快速修复
```
AI:   0. 💿 执行前快照闸门（强制）
         - 必须输出 "💿 已保护" 或 "💿 闸门通过" 后才能继续
         - 规则见 references/principles/checkpoint-mechanism.md
      0.5 Blast Radius 闸门（强制）
      1. 执行最小改动 (插入 log: [HOTFIX-{问题}])
      2. "⚠️ 这是临时止血，非根治"
      3. How to Test
         - 若执行后台 smoke / API / CLI 验证，先输出 `🗄️ 后端测试开始 - [BE-HOTFIX-{问题}-{场景}-{方式}] {scope=止血验证 | layer=API/CLI/smoke | level=L1}`
         
         过滤 `[HOTFIX-{问题}]` 应看到:
         → [HOTFIX-{问题}] 修复点: xxx
         → [HOTFIX-{问题}] 验证: xxx
```

若本次故障位于 GUI 链路：

```text
GUI 止血验证:
- 真正拉起 GUI executor 前，先输出 `🖥️ 前端GUI测试开始 - [GUI-HOTFIX-{问题}-{caseID}-{executor}-r{轮次}] {scope=主验证 | visual=headed-required | gate=GUI}`
- 默认执行 GUI executor 复现原故障路径
- 证据至少保留 screenshot / console / network / 关键操作时间线
- 止血后必须重跑原 GUI case，确认症状消失
- 若 GUI Gate 未满足，只能声明“已止血到当前层”，不能说“整条用户链路已恢复”
```

### 3. 事后补票 (强制)
```
AI:   1. 自动写入 postmortem.md (标记 [HOTFIX])
         输出: "📝 已自动更新: postmortem.md - [HOTFIX] Bug-YYYY-MM-DD-00X"
      2. "建议后续创建 Debug 任务彻底排查"
      3. 清理 [HOTFIX-*] log (临时诊断用)
```

## 与 Debug 区别

| | Hotfix | Debug |
|---|--------|-------|
| 目标 | 止血 | 根治 |
| 分析 | 跳过 | 深入 |
| 方案 | 最小改动 | 完整修复 |
| 时间 | 分钟级 | 按需 |

## 修复完成后选项

```
📍 当前: 已临时止血，修复了"[问题简述]"
⚠️ 这是临时方案，建议后续彻底排查
📌 下一步:
[1] 深入排查（进入 auto-dev-team/debug 流程）- 找到根因，做彻底修复
[2] 查看 postmortem - 确认 [HOTFIX] 记录内容
[3] 开发新功能（进入 auto-dev-team/architect 流程）
[0] 结束
```
