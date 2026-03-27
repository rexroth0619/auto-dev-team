# Changelog

## Unreleased

### Added

- `release-plan.json` 机器计划
- `release-auto-run.py`、`release-auth-bridge.sh` 与 `release-auto-selftest.sh`
- 预发自动化闭环原则与 plan schema

### Changed

- `release-pack.py` 改为生成统一机器计划，不再默认产出 markdown 草稿
- `Tester` 模式改为先生成 plan，再分流到手动或自动执行

## 1.0.0-zh-CN

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
