# 🤖 auto-dev-team

> 你的 AI 赛博开发团队 — 让不懂代码的 PM 也能驾驭软件开发

[![Agent Skills](https://img.shields.io/badge/Agent%20Skills-Compatible-blue)](https://agentskills.io)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 📖 简介

auto-dev-team 是一个基于 [Agent Skills 规范](https://agentskills.io/specification) 的 Cursor Skill，它将 AI 转变为一个完整的开发团队，提供结构化、增量可测的软件开发工作流。

**核心理念**：PM 只需用自然语言描述需求，AI 自动选择合适的工作流，一步步完成开发任务。

## ✨ 特点

- 🎯 **自动模式判断** — 根据用户意图自动选择合适的开发流程
- 📋 **增量可测** — 每一步都可验证，不会积攒到最后才发现问题
- 🔄 **检查点机制** — 随时可回退，安全有保障
- 📚 **经验沉淀** — 自动积累可复用的开发模式
- 🛡️ **禁止区域** — 保护关键文件不被误改
- 👔 **PM 友好** — 无需技术背景也能高效协作

## 🚀 安装

### 方式一：克隆到 Cursor Skills 目录

```bash
cd ~/.cursor/skills/
git clone git@github.com:rexroth0619/auto-dev-team.git auto-dev-team
```

### 方式二：作为项目级 Skill

```bash
cd your-project/.cursor/skills/
git clone git@github.com:rexroth0619/auto-dev-team.git auto-dev-team
```

## 📂 目录结构

```
auto-dev-team/
├── SKILL.md                    # 主技能文件
├── assets/
│   └── templates/              # 项目文档模板
│       ├── project-map.md      # 项目架构地图
│       ├── module-registry.md  # 可复用组件清单
│       ├── postmortem.md       # 经验库
│       └── ...
├── references/
│   ├── modes/                  # 开发模式流程
│   │   ├── architect.md        # 新功能开发
│   │   ├── debug.md            # 问题调试
│   │   ├── hotfix.md           # 紧急修复
│   │   ├── refactor.md         # 代码重构
│   │   └── ...
│   ├── patterns/               # 编程经验库
│   │   ├── universal/          # 通用原理
│   │   ├── language/           # 语言特有经验
│   │   └── platform/           # 平台特有经验
│   ├── pm-guide/               # PM 使用指南
│   └── principles/             # 核心原则
└── scripts/                    # 辅助脚本
```

## 🎮 开发模式

| 模式 | 触发场景 | 用途 |
|------|----------|------|
| **Architect** | "帮我做一个用户登录功能" | 新功能开发 |
| **Debug** | "登录接口报错了" | 问题调试 |
| **Hotfix** | "线上崩了！紧急！" | 紧急修复 |
| **FastTrack** | "把按钮颜色改成蓝色" | 小改动 |
| **Refactor** | "这段代码太乱了" | 代码重构 |
| **Optimize** | "页面加载太慢" | 性能优化 |
| **Survey** | "帮我看看这个项目" | 项目测绘 |
| **Cleanup** | "删掉没用的代码" | 清理冗余 |
| **Tester** | "给这个函数加测试" | 编写测试 |
| **Explain** | "这段代码什么意思" | 代码解释 |

## 💬 使用示例

### 示例 1：开发新功能

```
PM: 我想加一个深色模式

AI: 🔥 auto-dev-team - Architect 已激活

📋 需求理解：
用户能在设置页面切换深色/浅色模式，切换后整个应用立即生效。

确认这个理解对吗？
```

### 示例 2：修复问题

```
PM: 提交按钮点了没反应

AI: 🔥 auto-dev-team - Debug 已激活

📋 症状记录：
- 现象：点击提交按钮无响应
- 复现：填写表单 → 点提交 → 卡住

🔍 搜索历史经验...
生成假设中...
```

### 示例 3：紧急修复

```
PM: 线上挂了！支付接口报 500！

AI: 🔥 auto-dev-team - Hotfix 已激活

⚡ 快速定位中...
⚡ 最小修复方案: [xxx]

执行？
```

## 📚 PM 资源

不熟悉如何描述需求？参考：

- `references/pm-guide/task-templates.md` — 任务描述模板
- `references/pm-guide/common-commands.md` — 常用指令速查
- `references/pm-guide/conversation-tips.md` — 对话技巧

## 🔧 核心原则

1. **安全第一** — 不丢数据，可回退，无敏感信息泄露
2. **增量可测** — 每步产出可独立验证
3. **最小改动** — 只改必须改的
4. **经验沉淀** — 每次解决问题都可能产生可复用的模式

## 🤝 贡献

欢迎贡献！特别是：

- 新的开发模式
- 语言/平台特有的经验模式
- PM 友好性改进
- Bug 修复

## 📄 许可证

MIT License

---

**让 AI 成为你的赛博开发团队 🚀**
