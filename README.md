# auto-dev-team

> 一个面向软件开发任务的 Agent Skill：自动选模式、结构化执行、即时验证、可回退。

[![Agent Skills](https://img.shields.io/badge/Agent%20Skills-Compatible-blue)](https://agentskills.io)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 简介

`auto-dev-team` 基于 [Agent Skills 规范](https://agentskills.io/specification) 构建，目标是把“开发流程知识”拆成可组合、可按需加载的文档，而不是把所有规则都堆进 `SKILL.md`。

核心思路：

- 主入口保持轻量
- 模式判断和写前置分离
- Principles 按模式、阶段、产物触发
- 所有改动都要求验证和可回退
- 代码变更后默认执行后台自动测试
- 前端用户链路测试由 AI 主动判断并提示
- 大测试使用 `.autodev/current-test.md` 记录场景、执行和风险

## 当前入口结构

```text
SKILL.md
references/mode-index.md
references/write-preflight.md
references/modes/*/README.md
references/principles/*.md
```

## 目录结构

```text
auto-dev-team/
├── SKILL.md
├── .cursor/
│   └── agents/
│       ├── critique.md
│       ├── test-runner.md
│       └── test-writer.md
├── assets/
│   └── templates/
│       ├── context-snapshot.md
│       ├── current-test.md
│       ├── current-steps.md
│       ├── forbidden-zones.md
│       ├── module-registry.md
│       ├── path.md
│       ├── postmortem.md
│       ├── project-map.md
│       └── verification-checklist.md
└── references/
    ├── mode-index.md
    ├── write-preflight.md
    ├── modes/
    │   ├── architect/README.md
    │   ├── cleanup/README.md
    │   ├── debug/README.md
    │   ├── explain/README.md
    │   ├── fasttrack/README.md
    │   ├── hotfix/README.md
    │   ├── optimize/README.md
    │   ├── refactor/README.md
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
| Architect | 新功能、实现需求 | 方案设计与拆步 |
| Debug | bug、报错、异常 | 先诊断后修复 |
| Hotfix | 线上故障、紧急止血 | 最小改动恢复服务 |
| FastTrack | 小改动、文案、样式 | 快速处理单点变更 |
| Refactor | 重构、拆分、提取 | 控制风险地下刀 |
| Optimize | 性能问题 | 先诊断再优化 |
| Cleanup | 删除冗余、死代码 | 安全清理 |
| Tester | 新增测试、补覆盖、验证 use case | 测试资产维护 |
| Survey | 了解项目结构 | 项目测绘 |
| Explain | 解释代码 | 帮助理解 |
| Step | Architect / Refactor / Optimize 的执行阶段 | 逐步落地 |

## V1 测试协议

- `行为场景层`：PM 可读的 use case、异常链路、边界 case。
- `后台自动测试层`：代码变更后默认执行，优先覆盖改动点、边界和直接影响面。
- `前端链路测试层`：命中页面流程、跳转、会话、权限、表单等风险时，AI 主动提示是否执行 Playwright。
- `人工验收层`：视觉、体感、外部系统等难以稳定自动化的部分。
- `小测试`：输出 `🧾 测试回执`。
- `大测试`：创建 `.autodev/current-test.md`，持续记录场景矩阵、执行状态和剩余风险。

## 使用方式

在支持 Agent Skills 的工具中安装后，直接用自然语言描述任务即可。

示例：

- “帮我做一个用户登录功能”
- “这个接口突然报 500”
- “把按钮颜色改成蓝色”
- “这段代码太乱了，帮我重构”

## PM 资源

- `references/pm-guide/task-templates.md`
- `references/pm-guide/common-commands.md`
- `references/pm-guide/conversation-tips.md`

## 许可证

MIT License
