# 写模式共享前置

> 所有会写文件、改配置、生成测试或落检查点的流程，都先走这里。

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
2. 读取 `.autodev/context-snapshot.md`，恢复最近任务上下文。
3. 若任务涉及 Git、部署、路径、环境、服务端配置，先读取 `.autodev/path.md`。
4. 执行 `git log -5 --oneline`，判断最近改动与当前任务的关联或冲突。
5. 执行分支守卫：
   - 当前位于受保护分支时，按 `references/principles/checkpoint-mechanism.md` 创建工作分支。
   - 禁止在受保护分支上直接改代码。

## Principles 激活矩阵

| 触发条件 | 必须读取 |
|----------|----------|
| 所有写模式进入时 | `references/principles/critique.md` |
| 所有写模式进入时 | `references/principles/over-engineering.md` |
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

## 完成动作（写模式通用）

1. 先做影响范围分析。
2. 再做即时验证，并保留证据。
3. 再建立检查点，输出固定回执：

```
【已建立检查点】分支:{branch} 指纹:{fingerprint} 哈希:{hash}
```

4. 若达到阶段性完成点，询问是否合并到集成分支、是否推送。

## 禁止行为

- 跳过共享前置直接开始写代码。
- 未读 `path.md` 就做 Git / 部署 / 服务器路径相关操作。
- 跳过验证直接建立检查点。
- 把 `Cleanup`、`Tester` 当成“非写模式”处理。
