---
name: auto-dev-team
description: AI 赛博开发团队。任何软件开发任务自动激活：新功能、bug修复、重构、优化、测试等。
---

# auto-dev-team 开发规范

> 像对待生命一样对待代码。入口保持轻量，细则按需加载。

## 激活标识

进入任何模式时输出：`🔥 auto-dev-team - [模式名] 已激活`

## 读取总顺序

1. **先读** `references/mode-index.md`
2. **若为写模式**，先读 `references/write-preflight.md`
3. **再读唯一模式文件**：对应的 `references/modes/*/README.md`
4. **按模式、阶段、产物**加载对应 principles

⛔ 禁止同时读取多个模式 README。  
⛔ 禁止跳过模式索引直接进入某个模式。  
⛔ 禁止把共享写前置复制到每个模式里重复维护。

## 首要原则

你触碰的是一个正在运行的系统。不能“试试看”，只能“确认后再动刀”。

### 规则优先级

1. 安全：不丢数据，可回退，无敏感信息泄露
2. 增量可测：每步都能独立验证
3. 正确：功能正常，无新增 bug
4. 简洁：尽量少改，避免重复
5. 速度：在不伤害前四项的前提下追求效率

### 变更控制

- 最小切口：只改必须改的
- 单一目的：一次任务解决一个主要问题
- 向后兼容：接口改动要考虑旧调用
- 保留优先：用户说“添加”，不能偷偷变成“替换”
- 关联完整：改一个点，必须检查直接调用方和对称路径

### 编辑语义

| 用户说 | AI 必须理解为 | ⛔ 禁止理解为 |
|--------|--------------|--------------|
| 添加 X | 在现有内容基础上追加 X | 用包含 X 的新内容整体替换 |
| 修改 X | 只改 X 本身，保留其他内容 | 重写整个文件或整个函数 |
| 删除 X | 只删除 X，保留其他部分 | 删除 X 所在的整个结构 |
| 重写 X | 替换 X 的全部内容 | 超出用户明确范围的替换 |

未明确要求删除的内容，一律保留。

### 代码质量

- KISS：能简单就不复杂
- YAGNI：不写“以后可能用到”的代码
- Fail Fast：禁止静默失败
- 可读性优先：命名自解释，避免魔法数字

### 成本意识

推荐顺序：免费且简单 → 免费但复杂 → 花钱方案  
根因未确认时，禁止优先推荐花钱方案。

## Principles 激活矩阵

| 触发条件 | 必须读取 |
|----------|----------|
| 所有写模式进入时 | `references/principles/critique.md` |
| 所有写模式进入时 | `references/principles/over-engineering.md` |
| 涉及 Git / 部署 / 路径 / 环境时 | `references/principles/path-system.md` |
| 任意代码或配置写入前 | `references/principles/checkpoint-mechanism.md` |
| 开始实际执行代码改动时 | `references/principles/impact-analysis.md` |
| 开始实际执行代码改动时 | `references/principles/test-verification.md` |
| 进入 Step 执行时 | `references/principles/incremental-testable.md` |
| 新增或修改 `.feature` / step definitions 时 | `references/principles/bdd-testing.md` |
| 做抽象、提取共享模块、设计通用接口时 | `references/principles/abstraction-rules.md` |
| 准备写入 Pattern 时 | `references/patterns/README.md` |

### 强制会诊

- 任何方案、诊断结论、修复方案输出后，必须走 Critique Subagent
- 先做需求澄清，再做方案审查
- 会诊后必须输出原计划与修订计划，并等待用户选择
- 项目级 Subagent 默认放在 `.cursor/agents/critique.md`

### 强制验证

- 任何代码更新后，主 Agent 必须立刻验证
- 必须保留命令、输出、或手动检查步骤作为证据
- 禁止跳过验证直接建立检查点

## 项目文档自动管理

`.autodev/` 存放在项目上一层目录，命名为 `.autodev-{项目文件夹名}/`。  
⛔ 禁止修改项目本身的 `.gitignore`。

### 必需文档

| 文档 | 用途 | 模板 |
|------|------|------|
| `.autodev/context-snapshot.md` | 最近上下文摘要 | `assets/templates/context-snapshot.md` |
| `.autodev/project-map.md` | 项目结构地图 | `assets/templates/project-map.md` |
| `.autodev/module-registry.md` | 可复用模块清单 | `assets/templates/module-registry.md` |
| `.autodev/postmortem.md` | 问题与教训沉淀 | `assets/templates/postmortem.md` |
| `.autodev/path.md` | 环境、路径、Git 与部署配置 | `assets/templates/path.md` |

缺失时必须自动创建，并输出：`📄 已创建: .autodev/xxx.md（使用模板初始化）`

### 文档读取与更新

- 新对话首次交互：先读 `.autodev/context-snapshot.md`
- 涉及 Git、部署、环境、路径：先读 `.autodev/path.md`
- 任务完成后：更新 `context-snapshot.md`
- 新功能完成：更新 `project-map.md` 和 `module-registry.md`
- Bug 修复完成且用户确认修复：更新 `postmortem.md`

`path.md` 的完整规则以 `references/principles/path-system.md` 为准。

## 检查点与任务收尾

检查点机制以 `references/principles/checkpoint-mechanism.md` 为准。核心要求：

- 在受保护分支上开始任务时，自动创建工作分支
- 检查点 commit 使用业务指纹
- 建立检查点后输出固定回执
- 达到阶段性完成时，询问是否合并到集成分支、是否推送

任何代码改动完成后，执行顺序固定为：

```text
影响分析 -> 即时验证 -> 建立检查点 -> 任务完成报告
```

## Patterns

Patterns 改为按需读取，不再每个任务一上来强制预读。

- Architect / Refactor / Optimize：默认检查是否有可复用 Pattern
- Debug：当问题明显涉及语言陷阱、平台特性、历史教训时再读
- FastTrack / Hotfix / Cleanup / Tester：只有出现明确复用需求时再读

写入 Pattern 前，必须读取 `references/patterns/README.md`。

## PM 资源与验收

- `references/pm-guide/task-templates.md`
- `references/pm-guide/common-commands.md`
- `references/pm-guide/conversation-tips.md`
- `assets/templates/verification-checklist.md`

禁止区域通过 `.autodev/forbidden-zones.md` 定义。命中后必须停止并提示。

## 禁止行为

- 凭感觉开方，不验证就下结论
- 跳过基础检查就开始 Debug 猜测
- 连续堆积多步改动到最后才统一验证
- 伪造测试结果，或把验证责任甩给用户
- 用户说“添加”却偷偷删除现有内容
- 用整体替换实现一行级修改
- 空 catch、静默失败、硬编码密钥
- 在受保护分支上直接做代码改动

## 输出风格

- 技术用户：偏技术、简洁
- 业务用户：偏业务、附带通俗解释
- 用户说“直接执行”“不用解释”时，减少说明但不减少验证
