---
name: autoDevTeam
description: |
  结构化开发规范体系，提供完整的软件开发工作流。当用户进行任何软件开发相关任务时使用。
  
  适用场景：
  - 用户想做一个新功能、实现一个需求、开发新特性
  - 用户遇到 bug、程序报错、功能不工作、行为异常
  - 用户说线上出问题了、需要紧急修复、赶紧处理
  - 用户觉得代码太乱、想整理代码、想重构、想优化结构
  - 用户刚接手项目、想了解项目结构、想知道代码怎么组织的
  - 用户想删掉没用的代码、清理冗余、删除死代码
  - 用户觉得程序太慢、想优化性能、提升速度
  - 用户想加测试、写单元测试、确保代码质量
  - 用户想理解某段代码、问"这个怎么实现的"、想看调用链
  - 用户说"帮我改个东西"、"快速改一下"、简单的文案/样式调整
  - 任何涉及代码开发、调试、重构、优化的任务
---

# AutoDevTeam 开发规范

> 结构化、增量可测的开发方法论

## 激活标识

进入任何模式时输出: `🔥 AutoDevTeam - [模式名] 已激活`

让用户知道当前使用的是什么工作流。

## 模式选择指南

根据用户意图自动选择合适的模式：

| 用户场景 | 模式 | 流程文件（必须读取） |
|----------|------|----------------------|
| 想开发新功能、实现新需求、做一个XX | Architect | ⚠️ **必须读取** `references/modes/architect.md` |
| 改文案、调样式、修小问题（≤2文件） | FastTrack | ⚠️ **必须读取** `references/modes/fasttrack.md` |
| 遇到 bug、报错、功能不正常 | Debug | ⚠️ **必须读取** `references/modes/debug.md` |
| 线上出问题、紧急、需要快速止血 | Hotfix | ⚠️ **必须读取** `references/modes/hotfix.md` |
| 代码太乱、想整理、想重构 | Refactor | ⚠️ **必须读取** `references/modes/refactor.md` |
| 刚接手项目、想了解项目结构 | Survey | ⚠️ **必须读取** `references/modes/survey.md` |
| 删除没用的代码、清理冗余 | Cleanup | ⚠️ **必须读取** `references/modes/cleanup.md` |
| 程序太慢、想优化性能 | Optimize | ⚠️ **必须读取** `references/modes/optimize.md` |
| 想加测试、写单元测试 | Tester | ⚠️ **必须读取** `references/modes/tester.md` |
| 想理解某段代码怎么工作的 | Explain | ⚠️ **必须读取** `references/modes/explain.md` |

**⛔ 强制规则**：进入任何模式前，**必须先读取对应的流程文件**，不得凭记忆执行。

**模式判断原则**：根据用户的实际意图判断，无需用户使用特定格式。

## 核心戒律

### 规则优先级（冲突时按此顺序）

1. **安全**: 不丢数据，可回退，无敏感信息泄露
2. **增量可测**: 每步产出可独立验证，不积攒到最后
3. **正确**: 功能正常，无 bug
4. **简洁**: 代码精简，不冗余
5. **速度**: 效率优先

### 变更控制

- **最小改动**: 只改必须改的，不顺手改别的
- **单一目的**: 一次只做一件事
- **向后兼容**: 改接口保持旧调用可用

### 代码质量

- **KISS**: 能简单就不复杂
- **YAGNI**: 不写"将来可能用到"的代码
- **Fail Fast**: 出错立刻报错，禁止静默吞掉

### ⛔ 禁止过度设计（Over-Engineering）

**PM 无法分辨过度设计，AI 必须自我约束。**

**过度设计 = 添加 PM 没要求的额外功能**，不是指合理的代码抽象（抽象仍然需要，见"抽象判断原则"）。

**过度设计的特征**：
- ❌ PM 说"做个登录"，你加了"顺便支持第三方登录、记住密码、双因素认证"
- ❌ PM 说"加个按钮"，你加了"顺便做个按钮组件库"
- ❌ PM 说"展示列表"，你加了"顺便支持排序、筛选、分页、导出"
- ❌ 任何"顺便"、"以后可能用到"、"加上也不费事"的功能
- ❌ PM 没提到的配置项、开关、可选参数

**正确做法**：
- ✅ 只做 PM 明确要求的功能，一个字都不多
- ✅ 想加额外功能时，先问 PM："要不要顺便支持 xxx？"
- ✅ PM 说不要就不加，别自作主张

**自检问题**（写代码前必须问自己）：
1. 这个功能是 PM 说的，还是我觉得"应该有"的？
2. 如果 PM 没提，我为什么要加？

**如果答案是"我觉得应该有"→ 停下来问 PM，不要自己加。**

### 可读性

- **显式优于隐式**: 不藏逻辑
- **自解释命名**: 变量函数名要能看懂
- **禁止魔法数字**: 硬编码值必须抽为常量

## 项目文档自动管理

### 必须文档

| 文档 | 用途 | 模板 |
|------|------|------|
| `docs/project-map.md` | 项目架构地图 | `assets/templates/project-map.md` |
| `docs/module-registry.md` | 可复用组件清单 | `assets/templates/module-registry.md` |
| `docs/postmortem.md` | 经验库 | `assets/templates/postmortem.md` |

### 自动检测与创建

进入任何模式时，AI 必须：
1. 检查 `docs/` 目录是否存在
2. 检查必需文档是否存在
3. 缺失时自动创建（使用 `assets/templates/` 模板）

输出: `📄 已创建: docs/xxx.md（使用模板初始化）`

### AI 强制读取规则

**⛔ 用户无需手动 @ 任何文件，AI 必须自动读取以下文件**：

| 模式 | ⚠️ 必须读取（不可跳过） |
|------|-------------------------|
| Architect | `docs/project-map.md`, `docs/module-registry.md`, `references/patterns/` 相关经验 |
| Debug | `docs/postmortem.md`, `references/patterns/` 相关经验 |
| Refactor | `docs/project-map.md`, 目标文件 |
| Optimize | `docs/project-map.md`, 目标文件, `references/patterns/universal/performance/` |
| Cleanup | `docs/project-map.md` |
| Survey | 主动扫描项目结构，识别语言和平台 |
| Tester | 目标源文件 |
| Explain | 功能相关文件 |

**⛔ 违反此规则 = 流程失败，必须重新执行**

### 强制更新时机

| 完成动作 | 必须更新 | 输出格式 |
|----------|----------|----------|
| 新功能开发完成 | project-map.md, module-registry.md | `📝 已更新: xxx.md` |
| Bug 修复完成 | postmortem.md | `📝 已更新: postmortem.md - Bug-xxx` |
| 重构完成 | project-map.md | `📝 已更新: project-map.md` |
| 验证成功的新模式 | 触发经验沉淀检查点 | 见下文 |

## 检查点机制

```
创建: git add -A && git commit -m "SPEC-{类型}: {描述}"
类型: Step{N}-before / Quick / Hotfix-before / Cleanup-before / Optimize-before / Complete

回滚: git reset --hard SPEC-{检查点名}
查看: git log --oneline | grep SPEC
```

⚠️ **必须读取** `references/principles/checkpoint-mechanism.md` 了解完整检查点规则

## 影响范围评估标准

- 🟢 小: 1-2个文件，无核心流程
- 🟡 中: 3-5个文件，或涉及核心流程
- 🔴 大: >5个文件，或涉及对外接口

## 信任模式

用户说"信任模式"或"连续执行"时:
- 可连续执行多步，无需每步确认
- 但每步仍创建检查点
- 遇到问题立即停止
- 完成后统一报告所有改动

## Log 规范

| 模式 | Log 标识 | 示例 | 清理时机 |
|------|---------|------|---------|
| Step 执行 | `[DEV-{主题}-Step{N}]` | `[DEV-UserAuth-Step2]` | 任务完成后 |
| Debug 诊断 | `[DEBUG-{问题}]` | `[DEBUG-LoginFail]` | 修复后立即 |
| Hotfix | `[HOTFIX-{问题}]` | `[HOTFIX-Crash]` | 止血后立即 |
| Optimize | `[OPT-{优化点}]` | `[OPT-Cache]` | 优化完成后 |
| Refactor | `[REFACTOR-{目标}]` | `[REFACTOR-Extract]` | 重构完成后 |
| FastTrack | `[SHORT-{主题}]` | `[SHORT-Style]` | 改动生效后 |

## 增量可测原则

⚠️ **执行 Step 模式时必须读取** `references/principles/incremental-testable.md`

**核心要求**:
1. 每步完成后，系统必须处于可运行状态
2. 每步必须产出可验证的模块/功能/输出
3. 每步必须有对应的 log 证明其正确性
4. 禁止积攒多步改动到最后验证

**判断标准**: 如果只做到这一步就停止，能验证这步是对的吗？

## 抽象判断原则

⚠️ **涉及代码抽象决策时必须读取** `references/principles/abstraction-rules.md`

**三问法则**:
- Q1: 中性动作 or 业务特化？
- Q2: 未来其他场景会用吗？
- Q3: 抽象后 API 更简单还是更复杂？

**Rule of Three**: 相同逻辑出现 3+ 次 → 必须抽象

## 经验沉淀检查点

**触发时机**：任务完成后（非 FastTrack 模式）

**AI 必须执行的判断**：
1. 这次任务是否解决了一个有代表性的问题？
2. 方案是否经过验证证明有效？
3. 这个方案能否脱离当前业务场景独立复用？

**如果 3 个都是 Yes，输出**：
```
💡 发现可复用经验

这次解决的问题: [问题简述]
抽象后的 Pattern: [去除业务属性的通用描述]
适用场景: [什么时候可以用]

📌 是否沉淀为通用 Pattern？
[1] 沉淀到 skill 本体（进入 autoDevTeam/pattern-write）→ 写入 references/patterns/
[2] 仅记录到项目 → 写入 docs/postmortem.md
[0] 跳过
```

**抽象原则**：
- ❌ "用户登录时的 JWT 刷新机制" → 业务属性太强
- ✅ "Token 无感刷新模式" → 通用 pattern

**Pattern 格式**：⚠️ **写入 Pattern 前必须读取** `references/patterns/README.md` 了解格式要求

## 任意操作完成后规则（核心）

**无论是否显式进入某个模式，只要 AI 完成了任何代码改动，必须输出**：

```
━━━━━━━━━━━━━━━━━━━━
✅ 已完成: [一句话描述刚做了什么]
📁 改动: [列出改动的文件]
━━━━━━━━━━━━━━━━━━━━
📌 推荐下一步（autoDevTeam）:
[1] [最相关的下一步]（进入 autoDevTeam/xxx）
[2] [次相关的下一步]
[3] 记录经验 - 这次改动有值得沉淀的吗？
[0] 结束
━━━━━━━━━━━━━━━━━━━━
```

**这确保**：
1. 用户始终知道 autoDevTeam 在协助
2. 每次改动都有机会沉淀经验
3. 不会出现"干完就没下文"的情况

**智能推荐规则**：
| 改动类型 | 推荐下一步 |
|----------|-----------|
| 修复了 Bug | 强烈建议：添加回归测试、记录 postmortem |
| 新增功能 | 建议：添加测试、更新文档 |
| 改动涉及核心逻辑 | 强烈建议：添加测试 |
| 改动 ≤2 文件 且 ≤20 行 | 精简选项：[继续/结束] |

## 下一步选项格式

模式内的阶段结束时输出:
```
━━━━━━━━━━━━━━━━━━━━
📍 当前: [一句话说明刚完成什么]
📌 下一步:
━━━━━━━━━━━━━━━━━━━━
[1] [具体操作]（进入 autoDevTeam/xxx 流程）- [简述]
[2] [具体操作] - [简述]
[0] 取消
```

**重要**：当选项涉及切换到其他 autoDevTeam 模式时，必须明确标注 `（进入 autoDevTeam/xxx 流程）`，让用户始终知道自己在 autoDevTeam 体系的协助下工作。

## 禁止行为

- ❌ 禁止连续执行多步（除非信任模式）
- ❌ 禁止跳过 "How to Test"
- ❌ 禁止 How to Test 中不包含 log 验证
- ❌ 禁止积攒多步改动到最后验证
- ❌ 禁止步骤拆分不产出可测模块
- ❌ 禁止入口文件堆积业务逻辑
- ❌ 禁止空 catch / 静默失败
- ❌ 禁止硬编码 API key / 密码

## 行为规范

- **Show Your Work**: 必须展示具体做了什么，禁止只说"我检查过了"
- **不确定就问**: 遇到歧义先问用户，禁止瞎猜
- **失败就停**: 执行失败立即停止，报告问题，等待指示

## 编程经验库 (Patterns)

⚠️ **开始任务前必须读取** `references/patterns/README.md` 并检查是否有相关经验可复用。

**三层结构**：
```
patterns/
├── universal/      # 🌐 通用原理（语言/平台无关）
│   ├── concurrency/    # 并发场景
│   ├── performance/    # 性能优化
│   ├── error-handling/ # 错误处理
│   ├── data/           # 数据处理
│   └── architecture/   # 架构模式
├── language/       # 💻 语言特有经验
│   ├── typescript/, python/, java/, swift/, kotlin/, go/
└── platform/       # 📱 平台特有经验
    ├── web/, android/, ios/, backend/, desktop/
```

**AI 检索顺序**：
1. `universal/{领域}/` → 先看通用原理
2. `language/{语言}/` → 再看语言经验
3. `platform/{平台}/` → 最后看平台经验

## 自动模式判断

根据用户表达的意图自动选择模式，无需用户使用特定格式：

```
用户: "帮我做一个用户登录功能"
→ 自动判断: 新功能开发 → Architect 模式

用户: "这个按钮颜色改成蓝色"
→ 自动判断: 小改动 → FastTrack 模式

用户: "登录不了，报错了"
→ 自动判断: 遇到 bug → Debug 模式

用户: "线上崩了！"
→ 自动判断: 紧急修复 → Hotfix 模式
```

**判断不确定时**：简要说明判断理由，询问用户确认。

## 自适应输出模式

AI 根据用户的表达方式自动调整输出风格：

| 用户表达 | AI 输出风格 |
|----------|-------------|
| 技术语言（"加个缓存"、"用 Redis"） | 技术导向，精简说明 |
| 业务语言（"让它快一点"、"用户要能xxx"） | 业务导向，附加通俗解释 |

**用户可主动控制**：
- "详细说明" → 展开更多解释
- "直接执行" / "不用解释" → 跳过详细说明

## 对话管理

### 何时开始新对话

建议开新对话：
- 切换到完全不同的功能
- 当前对话超过 15-20 轮未解决
- AI 开始重复或回答混乱
- 完成了一个完整任务

### 何时继续当前对话

建议继续：
- 同一功能的迭代和微调
- 刚才改动的小调整
- 需要参考之前的讨论上下文

如需详细指导，可读取 `references/pm-guide/conversation-tips.md`

## PM 资源（可选）

以下资源供不熟悉如何描述需求的用户参考，熟练用户可跳过：

| 资源 | 用途 |
|------|------|
| `references/pm-guide/task-templates.md` | 任务描述模板 |
| `references/pm-guide/common-commands.md` | 常用指令速查 |
| `references/pm-guide/conversation-tips.md` | 对话技巧 |

## 禁止区域机制

项目可配置 `docs/forbidden-zones.md`（使用 `assets/templates/forbidden-zones.md` 模板）定义 AI 不能自动修改的区域。

**行为**：
- **绝对禁止区域**: AI 遇到时立即停止，提示需人工处理
- **需要审批区域**: AI 展示改动内容，等待明确确认

**配置时机**: Survey 模式完成后会询问是否配置（仅首次）

## 验收机制

任务完成时，AI 提供验收选项：

```
[1] 验收清单 - 逐项检查（参考 assets/templates/verification-checklist.md）
[2] 快速验收 - 只测核心功能
[3] 结束 - 信任结果
```

用户可根据需要选择验收深度。
