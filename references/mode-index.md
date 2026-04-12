# 模式索引

> 先选模式，再读唯一的模式文档。写入模式在进入具体流程前，必须先读 `references/write-preflight.md`。

## 读取顺序

1. 先读本文件，判断唯一模式。
2. 若该模式会写文件或改配置，先执行 `references/write-preflight.md`。
3. 只读取该模式对应的一个 `README.md`。
4. Architect / Refactor / Optimize 生成计划并获批后，再进入 `references/modes/step/README.md`。

## 模式匹配规则（按顺序命中）

| # | 模式 | 触发场景 | 读取路径 | 是否写入模式 |
|---|------|----------|----------|-----------|
| 1 | Resume | 半路回来、热重启、切模型后恢复、忘了做到哪里、想看当前进度 | `references/modes/resume/README.md` | 否 |
| 2 | Hotfix | 线上、紧急、生产问题、先止血 | `references/modes/hotfix/README.md` | 是 |
| 3 | Debug | bug、报错、异常、不工作 | `references/modes/debug/README.md` | 是 |
| 4 | Brainstorm | 需求讨论、边界澄清、先对齐再做 | `references/modes/brainstorm/README.md` | 是 |
| 5 | FastTrack | 小改动、改文案、调样式、单点修复 | `references/modes/fasttrack/README.md` | 是 |
| 6 | Refactor | 重构、拆分、整理、抽取 | `references/modes/refactor/README.md` | 是 |
| 7 | Optimize | 慢、卡、性能、加速 | `references/modes/optimize/README.md` | 是 |
| 8 | Cleanup | 删除无用代码、清理冗余 | `references/modes/cleanup/README.md` | 是 |
| 9 | Tester | 写测试、补测试、增加覆盖、验证 use case、预发验收、根据最近提交生成测试数据和手测步骤 | `references/modes/tester/README.md` | 是 |
| 10 | Survey | 了解项目、摸底结构、刚接手 | `references/modes/survey/README.md` | 否 |
| 11 | Explain | 解释代码、说明流程、帮助理解 | `references/modes/explain/README.md` | 否 |
| 12 | Architect | 新功能、实现需求、开发能力 | `references/modes/architect/README.md` | 是 |

## 写入意图兜底

用户说"帮我改一下"/"调整一下"/"修改 xxx"等，即使未明确匹配上述模式：
- 视为写入意图，默认进入 **FastTrack** 模式
- 必须先走 `references/write-preflight.md` + 执行前快照闸门
- ⛔ 禁止未经模式判断就直接写文件

## 推荐主路径

- 半路回来 / 切模型 / 断网恢复：`Resume -> Step / Architect / Debug / Tester`
- 需求还在讨论 / 边界未清：`Brainstorm -> Architect -> Step`
- 范围明确的小改动：`FastTrack`
- 新功能已明确：可从 `Architect` 开始；若缺少 `current-brainstorm.md`，先补 mini-brainstorm
- 修 bug：`Debug`；若问题已经从原需求分叉，先补 `current-brainstorm.md`

## 渐进式披露规则

- 禁止同时读取多个模式的 `README.md`。
- 禁止跳过模式判断直接读模式文件。
- 禁止把共享写前置复制到每个模式里重复维护。
