---
name: auto-dev-team
description: 当用户要求进行代码变更（新功能开发、bug 修复、代码重构、性能优化、写测试、清理代码）、接手项目、预发验收，或需要按任务尺度自动选层、安全执行、可恢复上下文的开发流程时激活。支持从轻量 flow/step 到 project/milestone/phase 的渐进式规划。
---

# auto-dev-team

> 像对待生命一样对待代码。入口保持轻量，细则按需加载。

## 激活标识

进入任何模式时输出：`🔥 auto-dev-team - [模式名] 已激活`
用户可见的激活 / 路由 / 回执骨架以 `references/shared/interaction-contract.md` 为准。

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
- 涉及架构、模块归属、接口面、接缝、抽象或测试落层时，按 `references/principles/language-lock.md` 使用术语锁，避免概念漂移
- 保留优先：用户说“添加”，不能偷偷变成“替换”
- 关联完整：改一个点，必须检查直接调用方和对称路径
- 新增代码先判断归属：优先融入现有模块，避免同域重复新建
- 已有代码理解、定位、影响面和复用检查优先走 `references/principles/code-navigation.md`，把具体工具当 provider 而不是流程本身；命中代码导航器时必须输出用户可见导航回执，并声明任何 raw read 降级
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

- 新的写入意图在进入执行前，必须先按 `references/shared/interaction-contract.md` 完成 `🧾 需求确认` 和 `🧾 需求澄清问题包`
- 所有写入模式都会走 `write-preflight`
- 所有写入模式都会恢复 `.autodev/context-snapshot.md`
- 所有写入模式默认都执行会诊
  - 能用 Subagent 时优先走独立会诊
  - 环境不支持时降级为本地 checklist，会诊能力不丢
- 文件写入前必须完成版本保护闸门
- 第一行代码写入前必须完成脚本化 Blast Radius 分析，默认执行 `${AUTODEV_SKILL_ROOT}/scripts/blast-radius.py`
- 代码更新后默认先执行后台自动测试
- 行为变化必须做至少一轮对应档位的观测驱动验证
- 命中 GUI-capable task 时，默认进入 `GUI 自治验收闭环`
- 命中 GUI-capable task 时，必须先准备或更新 `.autodev/current-gui-test.js`，并确认它与当前改动直接对应
- 历史 GUI 脚本只能作为补充回归，不能替代当前步骤的直连 GUI 验证
- GUI use case 未达到 `已通过 / 暂不可执行 / 用户禁用 / Manual only` 前，不得宣称完成
- 验证通过后才允许建立存档

## Current Artifact Pipeline

- `.autodev/current-*` 是 active flow 的兼容入口，不再只是同名“当前文件”
- `.autodev/current-stack.json` 是更高一层的 active attention stack，用于表达 `project / milestone / phase / flow / step`
- 真实归属目录为 `.autodev/flows/<flow_id>/`
- `.autodev/current-flow.json` 是当前 active flow 的 registry
- `Resume` 模式默认把 `.autodev/current-stack.json + current-flow.json + current-*` 视为记忆恢复入口，用于回答“现在在做什么、做到哪里了、整体进度如何”
- 所有 `current-*` metadata、registry 对齐规则和 artefact 归属，以 `references/shared/current-artifact-contract.md` 为准
- `current-stack.json` 的字段、时间语义和层级指针，以 `references/shared/current-stack-contract.md` 为准
- 优先使用 `scripts/flowctl.sh` 管理 flow，`scripts/stackctl.sh` 管理 active stack
- 优先使用 `scripts/stackctl.sh` 管理当前活跃栈与自动 Resume 判断
- 优先使用 `scripts/planctl.py` 做 drift precheck / full detect
- 若 `current-flow.json` 与 artefact header 不一致，视为 stale / 串线，不能直接继续执行

完整激活矩阵见 `references/write-preflight.md`。

## `.autodev` 记忆与配置

`.autodev/` 存放在项目根目录下，由 `${AUTODEV_SKILL_ROOT}/scripts/init-autodev.sh` 初始化，并通过 `.git/info/exclude` 本地忽略。
如需团队共享，再明确追加到 `.gitignore`。

- 基线文档：`context-snapshot.md`、`project-map.md`、`module-registry.md`、`postmortem.md`、`path.md`、`ai-sot.json`、`autodev-config.json`
- Flow artefact：`current-brainstorm.md`、`current-metaphor.md`、`current-steps.md`、`current-test.md`、`current-debug.md`、`current-gui-test.js`、`current-blast-radius.md`
- V2 控制面与上层规划：`current-stack.json`、`project-roadmap.md`、`milestone-plan.md`、`phase-plan.md`
- AI 生成的临时台账、调试输出、草稿、诊断材料，一律写入 `.autodev/temp/`
- 非最终交付临时文件不得散落仓库其他路径；若工具必须越界生成，必须立即清理或加入 ignore
- Skill 本体、模板、schema、runner 禁止承载项目实例化私密数据；这类事实只允许落在具体项目 `.autodev/`、环境变量、本地 `~/.ssh/config` 或 secret store 中

工作区边界、flow artefact 归属与 metadata 规则见 `references/shared/current-artifact-contract.md`。
stack 语义与 Resume 时间规则见 `references/shared/current-stack-contract.md`。
环境 / 路径真相源见 `references/principles/path-system.md`；AI 固定事实锁定层见 `references/principles/ai-single-source-of-truth.md`。

## 版本保护与任务收尾

版本保护机制以 `references/principles/checkpoint-mechanism.md` 为准。三层体系：

- 🎯 **里程碑**：任务开始时自动建立，信任模式开始前建立，默认 tag-only 标记当前 `HEAD`
- 💿 **保护快照**：执行前强制闸门 + 智能补充；工作区脏时必须 scoped commit 保存本轮确认范围，工作区干净时 tag-only 保护基线
- 💾 **存档**：每步改动验证通过后建立，使用业务指纹

路径约定：

- `AUTODEV_SKILL_ROOT` 指向 AutoDevTeam skill 本体目录，例如 `/Users/rexroth/.codex/skills/AutoDevTeam`
- canonical 脚本入口是 `${AUTODEV_SKILL_ROOT}/scripts/checkpoint.sh`
- 项目内最多存在 `.autodev/bin/checkpoint` 薄 wrapper，指向 skill 本体脚本
- ⛔ 禁止把 `scripts/checkpoint.sh` 理解为项目根目录下的真实脚本
- 若 wrapper 不存在，先执行 `${AUTODEV_SKILL_ROOT}/scripts/init-autodev.sh <project_dir>`，或直接调用 canonical 绝对路径

任何代码改动的固定执行顺序为：

```text
脚本化 Blast Radius → 执行改动 → 即时验证 → 建立存档 → 任务完成报告
```

## Bundled Resources

高频热路径：

- `${AUTODEV_SKILL_ROOT}/scripts/init-autodev.sh`：初始化 `.autodev/`、基础模板与 `.autodev/bin/checkpoint` wrapper
- `${AUTODEV_SKILL_ROOT}/scripts/flowctl.sh`：管理 active flow、current artefact 与兼容入口
- `${AUTODEV_SKILL_ROOT}/scripts/stackctl.sh`：管理 active stack、touch、resume 判断与摘要
- `${AUTODEV_SKILL_ROOT}/scripts/planctl.py`：执行 drift precheck / full detect，为动态重规划提供结构化信号
- `${AUTODEV_SKILL_ROOT}/scripts/checkpoint.sh`、`${AUTODEV_SKILL_ROOT}/scripts/blast-radius.py`、`${AUTODEV_SKILL_ROOT}/scripts/blast-radius-step.sh`：执行版本保护与 Blast Radius 闸门
- `assets/templates/current-stack.json`、`project-roadmap.md`、`milestone-plan.md`、`phase-plan.md`：V2 多尺度规划模板
- `references/shared/interaction-contract.md`、`menu-contract.md`、`flow-snippets.md`：用户可见的路由、回执、菜单共享骨架

完整目录树、辅助脚本与模板清单见 `README.md`。

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
- 用户说“直接执行”“不用解释”时，减少说明但不跳过精简需求确认、澄清问题包和验证
- 菜单型 UI 遵循 `references/shared/menu-contract.md`，保持轻量引导，不做 railroading
