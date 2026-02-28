# BDD 行为测试规范

> 用 .feature 文件描述系统行为，用 step definitions 绑定到真实代码，用 Cucumber 运行验证。

## 框架选择

| 语言 | BDD 框架 | 安装 |
|------|---------|------|
| JS/TS | @cucumber/cucumber | `npm i -D @cucumber/cucumber` |
| Python | behave | `pip install behave` |
| Go | godog | `go install github.com/cucumber/godog/cmd/godog` |
| Java | cucumber-jvm | Maven/Gradle 依赖 |
| Ruby | cucumber | `gem install cucumber` |

## 文件约定

```
{项目根}/features/          ← 跟随项目惯例，默认 features/
  ├── {功能名}.feature      ← 场景文件（PM 可读写）
  └── steps/
      └── {功能名}.steps.*  ← 胶水代码（开发者/AI 写）
```

## .feature 文件规则

- 一个 Feature = 一个功能需求
- 一个 Scenario = 一个独立行为（可单独通过/失败）
- Given = 前置状态 / When = 触发动作 / Then = 预期结果
- 只覆盖 PM 要求的功能，不自创场景（禁止过度设计）
- 无法自动化的场景标注 `@manual`（UI/视觉/外部系统）
- 语言跟随项目惯例（中文或英文）

## Step Definitions 规则

- 用 `{string}` `{int}` `{float}` 等占位符提取参数
- 一个 step 写一次，跨场景复用（避免重复胶水代码）
- 需要 Mock 的外部依赖在 steps 里处理
- 断言失败 = 场景失败，无需额外判断

## 何时用 BDD vs 单元测试

| 场景 | 用什么 |
|------|--------|
| 有明确的 前置→触发→结果 | .feature (BDD) |
| 纯函数/工具函数的输入输出 | 单元测试 |
| 两者都适用 | 优先 .feature |
| UI/视觉/手动操作 | .feature 标注 @manual |

## 验证命令

```bash
# JS/TS
npx cucumber-js

# Python
behave

# Go
godog

# Java
mvn test (cucumber-jvm 通过 JUnit 集成)
```
