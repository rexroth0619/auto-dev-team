# auto-dev-team

> 一个实验性的 Agent Skill，面向软件交付场景下的 Harness engineering。

[![Agent Skills](https://img.shields.io/badge/Agent%20Skills-Compatible-blue)](https://agentskills.io)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 这是什么

`auto-dev-team` 是一个面向软件交付的实验性 Agent Skill。它把更偏 harness 的 workflow 带进仓库内部，让编码 Agent 在明确的模式路由、写入护栏、验证闭环和回退点之上工作。

它仍然是一个轻量、可直接使用的 skill，但会随着真实的开发、调试、重构、测试和预发验证场景持续演化。

## 适合谁

- 使用 coding agents 参与软件交付的团队和个人
- 了解现代 Web 工作流、但不想深挖实现细节的 PM
- 希望给 Agent 增加验证、回退和执行护栏的工程师
- 想在仓库内落地实用 workflow harness，而不是先搭完整 runtime 的团队

## 获取语言版本

- 中文版：分支 `zh-CN`
- 英文版：分支 `main`

获取中文版：

```bash
git clone -b zh-CN https://github.com/rexroth0619/auto-dev-team.git
```

获取英文版：

```bash
git clone -b main https://github.com/rexroth0619/auto-dev-team.git
```

## 当前版本

- 中文版标签：`v1.1.1-zh-CN`
- 英文版标签：`v1.1.1`

## 最近更新

- 版本说明见 [CHANGELOG.md](CHANGELOG.md)
- 当前重点能力：
  - Brainstorm + flow control plane + 双层 Review
  - Resume 模式：半路回来 / 切模型后快速恢复 current-* 上下文
  - Debug 系统性修复约束：不再只做单点补丁
  - 预发测试 plan + manual/auto 双执行器
  - release-pack / release-auto-run / 自测脚本
  - 中英文双分支发布

## Agent Quick Start

- 先读 `SKILL.md`
- 需求还在讨论时，优先进入 `Brainstorm`
- 写入模式前，先读 `references/mode-index.md`
- 再读 `references/write-preflight.md`
- 改脚本后，运行对应 selftest
- 中文工作使用 `zh-CN`，英文发布工作使用 `main`

## 目录

- 简介
- 适合谁
- 当前入口结构
- 目录结构
- 主要模式
- V2 测试协议
- 使用方式
- 配置与脚本
- PM 资源
- 许可证

## 简介

`auto-dev-team` 基于 [Agent Skills 规范](https://agentskills.io/specification) 构建，并以更偏 harness 的方式组织软件交付流程。目标是把“开发流程知识”拆成可组合、可按需加载的文档和脚本，而不是把所有规则都堆进 `SKILL.md`。

核心思路：

- 主入口保持轻量
- 模式判断和写前置分离
- Principles 按模式、阶段、产物触发
- 机械步骤优先交给脚本，减少重复推理
- Skill 策略由 `.autodev/autodev-config.json` 配置
- 所有 `current-*` artefact 由 `.autodev/current-flow.json` + `scripts/flowctl.sh` 管理
- 可选的比喻层由 `.autodev/current-metaphor.md` 管理，标准模板内置为餐厅 / 物流 / 工厂
- 所有改动都要求验证和可回退
- 第一行代码写入前默认执行脚本化 Blast Radius
- 代码变更后默认执行后台自动测试
- GUI-capable task 默认进入 GUI 自治验收闭环
- Web GUI 支持 `Script-first Playwright` 和 `Suite-first Playwright`
- 大测试使用 `.autodev/current-test.md` 记录场景、执行和风险
- 前期推荐主路径升级为 `Brainstorm -> Architect -> Step -> Review`

## 当前入口结构

```text
SKILL.md
references/mode-index.md
references/write-preflight.md
references/shared/current-artifact-contract.md
references/modes/*/README.md
references/principles/*.md
```

## 目录结构

```text
auto-dev-team/
├── SKILL.md
├── assets/
│   └── templates/
│       ├── autodev-config.json
│       ├── context-snapshot.md
│       ├── current-brainstorm.md
│       ├── current-flow.json
│       ├── current-metaphor.md
│       ├── current-test.md
│       ├── current-steps.md
│       ├── current-blast-radius.md
│       ├── forbidden-zones.md
│       ├── module-registry.md
│       ├── gui-case-matrix.md
│       ├── gui-evidence-bundle.md
│       ├── path.md
│       ├── playwright-script-loop.js
│       ├── postmortem.md
│       ├── project-map.md
│       ├── release-plan.schema.json
│       └── verification-checklist.md
├── scripts/
│   ├── blast-radius.py
│   ├── blast-radius-step.sh
│   ├── blast-radius-selftest.sh
│   ├── blast-radius-step-selftest.sh
│   ├── checkpoint.sh
│   ├── checkpoint-selftest.sh
│   ├── flowctl.sh
│   ├── release-auth-bridge.sh
│   ├── release-auto-run.py
│   ├── release-auto-selftest.sh
│   ├── release-pack.py
│   ├── release-pack-selftest.sh
│   └── init-autodev.sh
└── references/
    ├── gotchas.md
    ├── mode-index.md
    ├── shared/
    │   ├── current-artifact-contract.md
    │   └── flow-snippets.md
    ├── metaphors/
    ├── write-preflight.md
    ├── modes/
│   ├── brainstorm/README.md
    │   ├── architect/README.md
    │   ├── cleanup/README.md
    │   ├── debug/README.md
    │   ├── explain/README.md
    │   ├── fasttrack/README.md
    │   ├── hotfix/README.md
    │   ├── optimize/README.md
    │   ├── refactor/README.md
    │   ├── resume/README.md
    │   ├── step/README.md
    │   ├── survey/README.md
    │   └── tester/README.md
    ├── patterns/
    ├── pm-guide/
    └── principles/
```

## 主要模式

| 模式 | 触发场景 | 用途 |
|------|----------|------|
| Brainstorm | 需求讨论、边界澄清、先对齐 | 产出 `current-brainstorm.md`，初始化 active flow |
| Resume | 半路回来、热重启、切模型恢复 | 读取 `current-flow.json + current-*`，恢复当前任务记忆 |
| Architect | 新功能、实现需求 | 方案设计与拆步 |
| Debug | bug、报错、异常 | 先诊断后修复 |
| Hotfix | 线上故障、紧急止血 | 最小改动恢复服务 |
| FastTrack | 小改动、文案、样式 | 快速处理单点变更 |
| Refactor | 重构、拆分、提取 | 控制风险地下刀 |
| Optimize | 性能问题 | 先诊断再优化 |
| Cleanup | 删除冗余、死代码 | 安全清理 |
| Tester | 新增测试、补覆盖、验证 use case、预发验收、发版手测 | 测试资产与交互式验证流程 |
| Survey | 了解项目结构 | 项目测绘 |
| Explain | 解释代码 | 帮助理解 |
| Step | Architect / Refactor / Optimize 的执行阶段 | 逐步落地 |

## 可选比喻层

- 默认关闭，对专业开发保持技术语言
- Brainstorm 阶段可按用户需要启用
- 固定内置三套模板：
  - 餐厅 / 做饭
  - 物流 / 仓储配送
  - 工厂 / 流水线
- 启用后，回执可先输出 `🪄 类比说明`，用户也可以继续用同一比喻提问

## 推荐主路径

```text
半路回来 / 切模型 / 断网恢复
  -> Resume
  -> Step / Architect / Debug / Tester

需求讨论 / 边界不清
  -> Brainstorm
  -> Architect
  -> Step
  -> Brainstorm Review
  -> Quality Review

小改动且范围明确
  -> FastTrack

问题排查 / 修复
  -> Debug
  -> Brainstorm Review
  -> Quality Review
```

## V2 测试协议

- `行为场景层`：PM 可读的 use case、异常链路、边界 case。
- `Blast Radius 闸门`：改代码前先扫描目标文件/符号、直接调用方、邻近测试、reverse import chain 和风险等级。
- `Step Blast Radius wrapper`：Step 模式优先由 `scripts/blast-radius-step.sh` 从 `current-steps.md` 自动解析 target 和阈值，减少手填参数。
- `后台自动测试层`：代码变更后默认执行，优先覆盖改动点、边界和直接影响面。
- `GUI 自治验收层`：命中页面流程、窗口、表单、会话、权限、可交互界面等风险时，AI 默认执行 GUI executor；Web 默认 Playwright。
- `Web GUI executor`：既接受 `npx playwright test`，也接受 `node xxx.ui.test.js` 的脚本式 Playwright 闭环。
- `人工验收层`：视觉、体感、外部系统等难以稳定自动化的部分。
- `预发测试计划层`：先生成 `release-plan.json`，再分流到手动或自动执行。
- `小测试`：输出 `🧾 测试回执`。
- `大测试`：创建 `.autodev/current-test.md`，持续记录场景矩阵、执行状态和剩余风险。

## 使用方式

在支持 Agent Skills 的工具中安装后，直接用自然语言描述任务即可。

示例：

- “帮我做一个用户登录功能”
- “这个接口突然报 500”
- “把按钮颜色改成蓝色”
- “这段代码太乱了，帮我重构”
- “根据最近提交带我走一遍预发测试”
- “根据最近提交自动跑一轮预发测试”

## 配置与脚本

- 项目环境与路径：`.autodev/path.md`
- Skill 策略与阈值：`.autodev/autodev-config.json`
- 初始化 `.autodev/`：`scripts/init-autodev.sh`
- current artefact flow 管理：`scripts/flowctl.sh`
- 写入前 Blast Radius：`scripts/blast-radius.py`
- Step 模式 Blast Radius 包装：`scripts/blast-radius-step.sh`
- Blast Radius 自检：`scripts/blast-radius-selftest.sh`
- Step 包装自检：`scripts/blast-radius-step-selftest.sh`
- 版本保护原语：`scripts/checkpoint.sh`
- checkpoint 自检：`scripts/checkpoint-selftest.sh`
- 预发测试 plan 生成：`scripts/release-pack.py`
- 预发自动化 runner：`scripts/release-auto-run.py`
- 预发 plan 自检：`scripts/release-pack-selftest.sh`
- 预发自动化自检：`scripts/release-auto-selftest.sh`
- 高频坑位沉淀：`references/gotchas.md`

### 预发测试脚本示例

给后续 agent 的标准调用示例：

```bash
python3 scripts/release-pack.py --commits 3 --mode auto --task "最近三次提交的预发验收"
python3 scripts/release-pack.py --range abc123..def456 --mode auto --task "审批流改造预发验收"
bash scripts/release-pack-selftest.sh
bash scripts/release-auto-selftest.sh
```

## PM 资源

- `references/pm-guide/task-templates.md`
- `references/pm-guide/common-commands.md`
- `references/pm-guide/conversation-tips.md`

## 许可证

MIT License
