# 写入模式共享前置

> 所有会写文件、改配置、生成测试或落存档的流程，都先走这里。默认保持 strict 行为；策略细节可由 `.autodev/autodev-config.json` 调整。

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

## 共享前置步骤（默认 strict）

1. 初始化 `.autodev/`。
   - 优先执行 `scripts/init-autodev.sh`
   - 若脚本不可用，再手工复制 `assets/templates/` 中的必需模板
   - 必需文档包括 `.autodev/autodev-config.json`
   - 必须确保 `.autodev/temp/` 存在，用于承接 AI 生成的临时产物
2. 执行工作区边界检查。
   - AI 生成的临时台账、调试输出、草稿、诊断材料，必须统一写入 `.autodev/temp/`
   - 若发现仓库其他路径存在 AI 生成的非交付临时文件，先迁移到 `.autodev/temp/`、清理，或加入 ignore 后再继续
3. 读取 `.autodev/context-snapshot.md`，恢复最近任务上下文。
4. 读取 `.autodev/autodev-config.json`，加载 skill 策略。
5. 若任务涉及 Git、部署、路径、环境、服务端配置、运行时路径、日志路径或控制台入口，先读取 `.autodev/path.md`。
6. 读取 `references/gotchas.md` 中与当前任务最相关的部分。
   - Git / 回退 / 分支 / 存档任务：重点看 checkpoint gotchas
   - “添加 / 删除 / 重写”类编辑任务：重点看保留性 gotchas
   - 跨模块 / monorepo / 契约变更：重点看影响分析 gotchas
7. 执行 `git log -5 --oneline`，判断最近改动与当前任务的关联或冲突。
8. 执行分支守卫。
   - 优先执行 `scripts/checkpoint.sh ensure-branch <task-slug>`
   - 若脚本不可用，按 `references/principles/checkpoint-mechanism.md` 手工执行
9. 🎯 建立里程碑（任务开始基线）。
   - 默认开启；优先执行 `scripts/checkpoint.sh milestone "<任务>#起点" "任务开始前基线" <task-slug>`
   - 若脚本不可用，按 `references/principles/checkpoint-mechanism.md` 手工执行
10. 💿 注册执行前快照闸门。
   - 不在此步建立快照，延迟到实际执行指令到达时强制触发
   - 优先执行 `scripts/checkpoint.sh snapshot-gate <task>`

## 测试台账规则

- `.autodev/current-steps.md`：记录多步执行计划、每步覆盖场景、每步测试回执。
- `.autodev/current-test.md`：记录大测试的场景矩阵、执行记录、待业务确认问题、剩余风险，以及关键观测结论。
- `.autodev/current-debug.md`：记录复杂 Debug 的多轮假设、观测差异、修复与复诊结论。
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
| 涉及 Git / 部署 / 路径 / 环境时 | `references/principles/path-system.md` |
| 任意代码或配置写入前 | `references/principles/checkpoint-mechanism.md` |
| 开始实际执行代码改动时 | `references/principles/impact-analysis.md` |
| 开始实际执行代码改动时 | `references/principles/test-verification.md` |
| 任意会改变运行行为的代码或配置写入，在进入验证阶段前 | `references/principles/observation-driven-verification.md` |
| 进入 Step 执行阶段时 | `references/principles/incremental-testable.md` |
| 新增或修改 `.feature` / step definitions 时 | `references/principles/bdd-testing.md` |
| 做抽象、提取共享模块、设计通用接口时 | `references/principles/abstraction-rules.md` |
| 准备写入 Pattern 时 | `references/patterns/README.md` |

## 观测驱动验证启用规则

- Architect：计划阶段必须为每个 Step 标注观测驱动验证档位与观测面。
- Step / FastTrack / Hotfix / Tester：只要当前改动影响运行行为，默认至少执行 `L1 轻量观测验证`。
- Debug：默认执行 `L2 标准观测验证`，复杂问题直接升到 `L3 重度观测验证`。
- Refactor：默认执行 `L3 重度观测验证`，建立 before / after 基线。
- 回归定位：默认执行 `L3`，优先建立可重复运行的 oracle。
- 复杂 Debug / 回归定位：若需要多轮诊断，创建或更新 `.autodev/current-debug.md`。

## Patterns 按需读取

- Architect / Refactor / Optimize：默认检查是否有可复用 Pattern。
- Debug：仅在历史问题、语言陷阱、平台特性明显相关时读取。
- FastTrack / Hotfix / Cleanup / Tester：默认不预读，只有出现明确复用需求时再读取。

## 完成动作（写入模式通用）

1. 先做影响范围分析。
2. 再执行后台自动测试 + 对应档位的观测驱动验证，必要时发起前端链路测试判断，并保留证据 / 测试回执。
3. 再建立存档，输出固定回执：

```text
💾【存档】{任务}#{序号} → {hash}
```

4. 若达到阶段性完成点，询问是否合并到集成分支、是否推送。

## 禁止行为

- 跳过共享前置直接开始写代码。
- 未读 `path.md` 就做 Git / 部署 / 服务器路径相关操作。
- 跳过验证直接建立存档。
- 把观测驱动验证误写成“只在测试失败后才启用”。
- 命中大测试却不创建 / 更新 `.autodev/current-test.md`。
- 把 `Cleanup`、`Tester` 当成“非写入模式”处理。
