# Changelog

## 1.1.1-zh-CN

### Added

- `Brainstorm`、`Resume`、`current-brainstorm.md`、`current-flow.json` 与 `current-metaphor.md`
- `current-artifact` 契约、`scripts/flowctl.sh`、`brainstorm-review` 与 `quality-review`
- 比喻层：`metaphor-layer.md` 与餐厅 / 物流 / 工厂三套标准模板
- `ai-sot.json` 锁定层、`release-plan.schema.json`、`release-auth-bridge.sh`
- `release-auto-run.py`、`release-auto-selftest.sh` 与预发自动化闭环原则

### Changed

- `current-*` 模板增加 flow metadata header
- 推荐主路径升级为 `Resume / Brainstorm -> Architect -> Step -> Review`
- `Brainstorm / Survey / Explain / Step / Debug / Tester` 接入可选比喻层
- `Debug` 模式强化为系统性修复：要求做同型扩散扫描、修复层级评估与防复发回归
- 测试回执支持在技术回执前增加 `🪄 类比说明`
- `release-pack.py` 改为生成统一机器计划，不再默认产出 markdown 草稿
- `Tester` 模式改为先生成 plan，再分流到手动或自动执行
- GUI 验收改为强制可见浏览器并进一步收敛当前改动直连 case

### Fixed

- `checkpoint` 输出噪音与 workflow 提交过滤
- 自测脚本与预发自动化执行链路的一致性问题

## 1.1.0-zh-CN

### Added

- 交互式预发测试链路
- `release-pack.py` 与 `release-pack-selftest.sh`
- 预发测试会话草稿模板
- 防屎山快速检查

### Changed

- `Tester` 模式扩展为测试资产与交互式验证流程
- `path.md` 增加长期事实更新规则
- SQL 查询改为一次性整段输出，并按项目数据库方言生成
- README 结构优化，补充版本、分支与 Agent Quick Start

### Fixed

- `blast-radius-selftest.sh` 的工作目录问题
- 多个自测脚本与交互式预发测试链路的一致性问题
