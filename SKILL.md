---
name: auto-dev-team
description: 当用户要求进行代码变更（新功能开发、bug 修复、代码重构、性能优化、写测试、清理代码）、调查项目结构、解释代码逻辑、预发验收、或执行需要安全护栏的开发流程时激活。写入任务会自动选择模式、恢复 .autodev 上下文、执行验证与版本保护。
---

# auto-dev-team

> 像对待生命一样对待代码。入口保持轻量，细则按需加载。

## 目录

- 激活标识
- 典型触发
- 读取总顺序
- 首要原则
- 默认严格策略
- Current Artifact Pipeline
- `.autodev` 记忆与配置
- 版本保护与任务收尾
- Bundled Resources
- Patterns
- PM 资源与验收
- 禁止行为（高信号）
- 输出风格

## 激活标识

进入任何模式时输出：`🔥 auto-dev-team - [模式名] 已激活`

## 典型触发

- 半路回来、热重启、切模型、断网后恢复、忘了现在做到哪了
- 开发新功能、实现需求、交付 use case
- 排查 bug、线上止血、做最小修复
- 小改动、调样式、改文案、补日志
- 重构、优化、清理、补测试
- 预发验收、根据最近提交生成测试计划，并选择手动或自动执行
- 需求讨论、边界澄清、先对齐再做方案
- Survey 项目结构、Explain 代码逻辑
- 任何需要“先验证、可回退、别误删”的开发任务

## 读取总顺序

1. **先读** `references/mode-index.md`
2. **若命中 Resume**，直接读 `references/modes/resume/README.md`
3. **若为写入模式**，先读 `references/write-preflight.md`
4. **再读唯一模式文件**：对应的 `references/modes/*/README.md`
5. **按模式、阶段、产物**加载对应 principles

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
- 新增代码先判断归属：优先融入现有模块，避免同域重复新建
- 默认检查复用与抽象机会：该复用先复用，1-2 次不强抽象，3 次以上必须抽象
- 发现单文件继续堆职责时，先拆分或升级模式，禁止顺手堆成屎山

### 编辑语义

| 用户说 | AI 必须理解为 | ⛔ 禁止理解为 |
|--------|--------------|--------------|
| 添加 X | 在现有内容基础上追加 X | 用包含 X 的新内容整体替换 |
| 修改 X | 只改 X 本身，保留其他内容 | 重写整个文件或整个函数 |
| 删除 X | 只删除 X，保留其他部分 | 删除 X 所在的整个结构 |
| 重写 X | 替换 X 的全部内容 | 超出用户明确范围的替换 |

未明确要求删除的内容，一律保留。

### 成本意识

推荐顺序：免费且简单 → 免费但复杂 → 花钱方案  
根因未确认时，禁止优先推荐花钱方案。

## 默认严格策略

- 所有写入模式都会走 `write-preflight`
- 所有写入模式都会恢复 `.autodev/context-snapshot.md`
- 所有写入模式默认都执行会诊
  - 能用 Subagent 时优先走独立会诊
  - 环境不支持时降级为本地 checklist，会诊能力不丢
- 文件写入前必须完成版本保护闸门
- 第一行代码写入前必须完成脚本化 Blast Radius 分析，默认执行 `scripts/blast-radius.py`
- 代码更新后默认先执行后台自动测试
- 行为变化必须做至少一轮对应档位的观测驱动验证
- 命中 GUI-capable task 时，默认进入 `GUI 自治验收闭环`
- 命中 GUI-capable task 时，必须先准备或更新 `.autodev/current-gui-test.js`，并确认它与当前改动直接对应
- 历史 GUI 脚本只能作为补充回归，不能替代当前步骤的直连 GUI 验证
- GUI use case 未达到 `已通过 / 暂不可执行 / 用户禁用 / Manual only` 前，不得宣称完成
- 验证通过后才允许建立存档

## Current Artifact Pipeline

- `.autodev/current-*` 是 active flow 的兼容入口，不再只是同名“当前文件”
- 真实归属目录为 `.autodev/flows/<flow_id>/`
- `.autodev/current-flow.json` 是当前 active flow 的 registry
- `Resume` 模式默认把 `.autodev/current-flow.json + current-*` 视为记忆恢复入口，用于回答“现在在做什么、做到哪里了、还差多少”
- 所有 `current-*` artefact 都必须带 metadata header，至少包含：
  - `flow_id`
  - `artifact_id`
  - `artifact_type`
  - `brainstorm_ref`
  - `metaphor_ref`
  - `plan_ref`
  - `step_ref`
- 优先使用 `scripts/flowctl.sh` 管理：
  - `init`
  - `activate`
  - `ensure`
  - `validate`
  - `archive`
  - `clean`
- 若 `current-flow.json` 与 artefact header 不一致，视为 stale / 串线，不能直接继续执行

完整激活矩阵见 `references/write-preflight.md`。

## `.autodev` 记忆与配置

`.autodev/` 存放在项目根目录下，通过 `.git/info/exclude` 忽略（本地生效，不入库）。
首次创建 `.autodev/` 时自动追加忽略规则；如需团队共享，确认后可追加到 `.gitignore`。

### 工作区边界

- 结构化长期记忆文档保留在 `.autodev/` 根下（如 `context-snapshot.md`、`current-brainstorm.md`、`current-steps.md`、`current-test.md`、`current-gui-test.js`）。
- 可选的用户表达层协议保留在 `.autodev/current-metaphor.md`；它用于比喻说明和反向解析，不替代技术真相源。
- 当前 active flow 的兼容入口保留在 `.autodev/current-*`；真实归属保留在 `.autodev/flows/<flow_id>/`
- Blast Radius 报告保留在 `.autodev/blast-radius/`；最近一次结论镜像到 `.autodev/current-blast-radius.md`
- AI 生成的临时台账、调试输出、草稿、诊断材料，一律写入 `.autodev/temp/`。
- 非最终交付物，不得写入仓库其他路径。
- 若工具必须在 `.autodev/temp/` 之外生成临时文件，生成后必须立即清理，或加入 ignore 后再继续执行。
- Skill 本体、模板、schema、runner 中禁止写入项目实例化数据：
  - 真实域名
  - 真实 SSH alias
  - 真实服务器路径
  - 真实账号
  - 真实样本订单号 / 手机号 / 密文
  - 任何私有业务标识
- 以上实例化数据只能存在于具体项目的 `.autodev/`、运行时环境变量、本地 `~/.ssh/config`、secret store 中；若是长期固定事实，优先落到 `.autodev/ai-sot.json`，不要漂在临时 `release-plan.json` 里。

### 必需文档

| 文档 | 用途 | 模板 |
|------|------|------|
| `.autodev/context-snapshot.md` | 最近上下文摘要 | `assets/templates/context-snapshot.md` |
| `.autodev/project-map.md` | 项目结构地图 | `assets/templates/project-map.md` |
| `.autodev/module-registry.md` | 可复用模块清单 | `assets/templates/module-registry.md` |
| `.autodev/postmortem.md` | 问题与教训沉淀 | `assets/templates/postmortem.md` |
| `.autodev/path.md` | 环境、路径、Git 与部署配置 | `assets/templates/path.md` |
| `.autodev/ai-sot.json` | AI 专用固定事实锁定层（预发/部署/SSH/GUI/认证真相源） | `assets/templates/ai-sot.json` |
| `.autodev/autodev-config.json` | Skill 策略开关与默认行为 | `assets/templates/autodev-config.json` |

### 条件文档

| 文档 | 用途 | 模板 | 触发条件 |
|------|------|------|----------|
| `.autodev/current-brainstorm.md` | 当前需求讨论结果、边界、验收标准 | `assets/templates/current-brainstorm.md` | 进入 Brainstorm / Architect 前置 / 修复与测试需补对齐时 |
| `.autodev/current-metaphor.md` | 当前 flow 的比喻层协议、映射表与用户问法 | `assets/templates/current-metaphor.md` | 用户要求“讲人话 / 用比喻解释”，或 Brainstorm 判断适合启用时 |
| `.autodev/current-steps.md` | 多步执行计划与逐步记录 | `assets/templates/current-steps.md` | 多步任务 / Step 模式 |
| `.autodev/current-test.md` | 大测试场景矩阵、执行记录、剩余风险 | `assets/templates/current-test.md` | 大测试 / 关键链路 / 跨模块任务 |
| `.autodev/current-debug.md` | 多轮诊断假设、观测记录、复诊结论 | `assets/templates/current-debug.md` | 复杂 Debug / 多轮排查 / 回归定位 |
| `.autodev/current-gui-test.js` | 当前任务的 GUI 主测试入口，要求与本步改动直接对应 | `assets/templates/current-gui-test.js` | 命中 GUI-capable task 且可自动化时 |
| `.autodev/current-blast-radius.md` | 最近一次 Blast Radius 结论、Gate 与验证范围 | `assets/templates/current-blast-radius.md` | 任意代码 / 测试 / 配置写入前 |

配置职责拆分：

- `.autodev/path.md`：项目环境、部署、Git、路径真相源
- `.autodev/ai-sot.json`：AI 专用机器真相源；锁定预发/部署/SSH/GUI/认证等长期固定事实
- `.autodev/autodev-config.json`：skill 行为策略真相源
  - 包括 blast radius 深度、输出、fail-close 策略

`path.md` 的完整规则以 `references/principles/path-system.md` 为准。
`ai-sot.json` 的完整规则以 `references/principles/ai-single-source-of-truth.md` 为准。

## 版本保护与任务收尾

版本保护机制以 `references/principles/checkpoint-mechanism.md` 为准。三层体系：

- 🎯 **里程碑**：任务开始时自动建立，信任模式开始前建立，默认 tag-only 标记当前 `HEAD`
- 💿 **保护快照**：执行前强制闸门 + 智能补充；工作区脏时 commit 保存现场，工作区干净时 tag-only 保护基线
- 💾 **存档**：每步改动验证通过后建立，使用业务指纹

任何代码改动的固定执行顺序为：

```text
脚本化 Blast Radius → 执行改动 → 即时验证 → 建立存档 → 任务完成报告
```

## Bundled Resources

- `scripts/init-autodev.sh`
  - 初始化 `.autodev/`、复制模板、补 `autodev-config.json`
- `scripts/flowctl.sh`
  - 初始化 / 激活 / 补齐 / 校验 / 归档 / 清理 current artefact flow
- `references/principles/metaphor-layer.md`
  - 比喻层总原则；规定餐厅 / 物流 / 工厂三套标准模板，以及用户反向提问如何翻译回技术语义
- `scripts/checkpoint.sh`
  - 处理分支守卫、里程碑、快照闸门、存档、读档、回退
- `scripts/checkpoint-selftest.sh`
  - 最小回归验证 checkpoint 脚本，防止里程碑 / 存档 / 列表输出回归
- `scripts/blast-radius.py`
  - 写代码前的脚本化 Blast Radius 闸门；输出 `.autodev/current-blast-radius.md` 和 `.autodev/blast-radius/*.md`
- `scripts/blast-radius-step.sh`
  - Step 模式专用包装脚本；从 `.autodev/current-steps.md` 自动解析当前 Step 的 Blast Radius 目标与风险阈值
- `scripts/blast-radius-selftest.sh`
  - Blast Radius 脚本自检，确保报告产物与核心字段存在
- `scripts/blast-radius-step-selftest.sh`
  - Step 包装脚本自检，验证解析、转发与超阈值 fail-close
- `scripts/release-pack.py`
  - 根据最近提交生成 `release-plan.json`，作为手动/自动预发测试的统一机器计划
- `scripts/release-pack-selftest.sh`
  - `release-pack.py` 自检脚本；验证 plan JSON 的关键字段存在
- `scripts/release-auto-run.py`
  - 自动化预发执行 runner；按 auth/query/seed/be/gui/evidence 顺序执行
- `scripts/release-auth-bridge.sh`
  - 认证态桥接；优先 existing session，再尝试 browser handoff / local secret store
- `scripts/release-auto-selftest.sh`
  - `release-auto-run.py` 自检脚本；验证状态机、回执和 fail-close 行为
- `references/gotchas.md`
  - 高信号坑位；优先放真实踩坑经验，而不是通用编程常识
- `assets/templates/playwright-script-loop.js`
  - Web GUI 的脚本式 Playwright 闭环模板，适合本地快速验证与自修复
- `assets/templates/current-gui-test.js`
  - 当前任务专用 GUI 主脚本模板；默认 headed，要求填写与本步改动的直接对应关系
- `assets/templates/current-blast-radius.md`
  - 最新 Blast Radius 结论模板；脚本不可用时按此模板手工降级
- `assets/templates/gui-case-matrix.md`
  - GUI 用例矩阵模板，统一记录前置条件、页面变化、网络与副作用预期
- `assets/templates/gui-evidence-bundle.md`
  - GUI 证据包模板，统一 timeline / screenshot / console / network / page state
- `assets/templates/release-plan.schema.json`
  - `release-plan.json` schema；约束 plan 字段，避免 runner 读取自然语言
- `references/shared/menu-contract.md`
  - 菜单型 UI 的统一协议；用于阶段确认、计划选择、任务收尾等编号菜单
- `references/shared/flow-snippets.md`
  - 共用回执、会诊、测试回执、菜单骨架模板

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

## 禁止行为（高信号）

- 凭感觉开方，不验证就下结论
- 跳过基础检查就开始 Debug 猜测
- 连续堆积多步改动到最后才统一验证
- 伪造测试结果，或把验证责任甩给用户
- 用户说“添加”却偷偷删除现有内容
- 用整体替换实现一行级修改
- 在受保护分支上直接做代码改动

## 输出风格

- 技术用户：偏技术、简洁
- 业务用户：偏业务、附带通俗解释
- 用户说“直接执行”“不用解释”时，减少说明但不减少验证
- 菜单型 UI 遵循 `references/shared/menu-contract.md`，保持轻量引导，不做 railroading
