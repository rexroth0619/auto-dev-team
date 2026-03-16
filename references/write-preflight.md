# 写入模式共享前置

> 所有会写文件、改配置、生成测试或落存档的流程，都先走这里。

## 适用模式

- Architect
- FastTrack
- Debug
- Refactor
- Optimize
- Hotfix
- Cleanup
- Tester
- Step（执行阶段）

`Survey` 和 `Explain` 默认只读，不进入本流程。

## 共享前置步骤

1. 检查 `.autodev/` 是否存在，缺失时用 `assets/templates/` 初始化必需文档。
   - 首次创建 `.autodev/` 时，检查 `.git/info/exclude` 是否已包含 `.autodev/`，若没有则追加。
   - 输出：`🛡️ 已将 .autodev/ 加入 .git/info/exclude（本地忽略，不影响项目 .gitignore）`
2. 读取 `.autodev/context-snapshot.md`，恢复最近任务上下文。
3. 若任务涉及 Git、部署、路径、环境、服务端配置，先读取 `.autodev/path.md`。
4. 执行 `git log -5 --oneline`，判断最近改动与当前任务的关联或冲突。
5. 执行分支守卫：
   - 当前位于受保护分支时，按 `references/principles/checkpoint-mechanism.md` 创建工作分支。
   - 禁止在受保护分支上直接改代码。
6. 🎯 建立里程碑（任务开始基线）：
   - 按 `references/principles/checkpoint-mechanism.md` 建立里程碑。
   - 输出里程碑回执。
7. 💿 注册执行前快照闸门：
   - 不在此步建立快照，延迟到实际执行指令到达时强制触发。
   - 闸门规则见 `references/principles/checkpoint-mechanism.md` 的"执行前快照闸门"。

## 测试台账规则

- `.autodev/current-steps.md`：记录多步执行计划、每步覆盖场景、每步测试回执。
- `.autodev/current-test.md`：记录大测试的场景矩阵、执行记录、待业务确认问题、剩余风险。
- 命中以下任一条件，视为**大测试**，缺失时必须初始化 `.autodev/current-test.md`：
  - 认证、支付、权限、审批、上传下载
  - 多步表单、多页面跳转、会话状态、核心用户链路
  - 外部系统联动、API / 数据契约变更、跨模块改动
  - 业务规则不清，需要先补齐场景或阈值
- 未命中大测试条件时，不强制创建 `current-test.md`，但仍必须输出 `🧾 测试回执`。

## Principles 激活矩阵

| 触发条件 | 必须读取 |
|----------|----------|
| 所有写入模式进入时 | `references/principles/critique.md` |
| 所有写入模式进入时 | `references/principles/over-engineering.md` |
| 涉及 Git / 部署 / 路径 / 环境时 | `references/principles/path-system.md` |
| 任意代码或配置写入前 | `references/principles/checkpoint-mechanism.md` |
| 开始实际执行代码改动时 | `references/principles/impact-analysis.md` |
| 开始实际执行代码改动时 | `references/principles/test-verification.md` |
| 进入 Step 执行阶段时 | `references/principles/incremental-testable.md` |
| 新增或修改 `.feature` / step definitions 时 | `references/principles/bdd-testing.md` |
| 做抽象、提取共享模块、设计通用接口时 | `references/principles/abstraction-rules.md` |
| 准备写入 Pattern 时 | `references/patterns/README.md` |

## Patterns 按需读取

- Architect / Refactor / Optimize：默认检查是否有可复用 Pattern。
- Debug：仅在历史问题、语言陷阱、平台特性明显相关时读取。
- FastTrack / Hotfix / Cleanup / Tester：默认不预读，只有出现明确复用需求时再读取。

## 完成动作（写入模式通用）

1. 先做影响范围分析。
2. 再执行后台自动测试，必要时发起前端链路测试判断，并保留证据 / 测试回执。
3. 再建立存档，输出固定回执：

```
💾【存档】{任务}#{序号} → {hash}
```

4. 若达到阶段性完成点，询问是否合并到集成分支、是否推送。

## 禁止行为

- 跳过共享前置直接开始写代码。
- 未读 `path.md` 就做 Git / 部署 / 服务器路径相关操作。
- 跳过验证直接建立存档。
- 命中大测试却不创建 / 更新 `.autodev/current-test.md`。
- 把 `Cleanup`、`Tester` 当成"非写入模式"处理。
