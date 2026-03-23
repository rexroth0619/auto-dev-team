# Tester 模式 (测试资产)

> 适用: 想写测试、补测试、验证某个 use case、检查覆盖缺口 | 产出: 测试文件；命中大测试时再产出 `current-test.md`

## 目录

- AI 必须主动读取
- Phase 0: 环境与现有覆盖检查
- Phase 1: 把需求翻译成行为场景
- Phase 2: 选择测试落层
- Phase 3: 写 / 补测试资产
- Phase 4: 执行验证
- Phase 5: 处理结果
- 典型使用场景
- 禁止行为

## AI 必须主动读取

进入此模式时，AI 必须主动读取：

- 用户提到的目标源文件
- 相关测试文件（若已有）
- 若存在 `.autodev/current-test.md`，一并读取

⚠️ 若新增或修改 `.feature` / step definitions，必须读取 `references/principles/bdd-testing.md`。
⚠️ 进入本模式时，必须读取 `references/principles/test-verification.md`。
⚠️ 若测试目标涉及运行行为验证或根因定位，必须读取 `references/principles/observation-driven-verification.md`。

## Phase 0: 环境与现有覆盖检查

```text
AI 检查项目当前测试能力:

1. 后台自动测试:
   ✅ 已配置 (vitest / jest / pytest / go test / ...)
   ❌ 未配置 -> 推荐最小可行方案

2. BDD 框架:
   ✅ 已配置 (cucumber / behave / godog / ...)
   ❌ 未配置 -> 不强制安装，可先用行为场景矩阵

3. GUI executor:
   ✅ 已配置 (Playwright / 桌面 driver / 宿主操作入口 / ...)
      - Web GUI 优先检查是否已有 `node xxx.ui.test.js` 或 `npx playwright test`
   ❌ 未配置 -> 记录为“暂不可自动化”

4. 现有覆盖:
   - 目标 use case 是否已有测试？
   - 是否已有历史失败案例 / 回归测试？
```

## Phase 1: 把需求翻译成行为场景

```text
AI 把用户输入翻译成行为场景:

1. 用户明确提出的场景
2. AI 自动补充的通用负例 / 错误链路 / 边界 case
3. 待业务确认的规则型场景
```

输出格式：

```text
📋 场景矩阵
| ID | 场景 | 来源 | 备注 |
|----|------|------|------|
| S1 | 登录成功 | 用户提出 | |
| S2 | 密码错误 | AI补充 | 通用负例 |
| S3 | 连续输错 5 次是否锁定 | 待确认 | 需业务确认阈值 |
```

若场景中含以下内容，必须先问用户：

- 锁定次数、重试上限、超时策略
- 权限矩阵、审批策略
- 对业务结果有直接影响的阈值

## Phase 2: 选择测试落层

```text
AI 为每个场景选择测试层:

- 单元测试: 纯规则 / 数据转换
- 集成 / 契约测试: 服务协作 / 接口 / 状态流
- GUI 自治验收: 页面流程 / 跳转 / 会话 / 表单 / 任意可交互界面
- 人工验收: 视觉 / 动效 / 体感 / 外部系统
```

同时判断：

- 这是小测试还是大测试？
- 是否需要创建 / 更新 `.autodev/current-test.md`？
- 是否需要进入 GUI 自治验收闭环？
- 当前 use case 是否需要 `L1 / L2 / L3` 观测驱动验证？

## Phase 3: 写 / 补测试资产

### 测试资产优先级

1. 修 bug -> 优先补“原始失败场景”的保护性测试
2. 核心逻辑 -> 补单元 / 集成测试
3. 用户链路 / GUI -> 在条件成熟时默认执行 GUI executor；Web GUI 优先评估 `Script-first Playwright`
4. 视觉 / 体感 -> 输出人工验收步骤

### 强制规则

- 测试文件跟随项目已有惯例
- 不测试实现细节，测试行为
- 优先补最有价值的保护性测试
- 能复用现有测试资产时，不重复造轮子
- 若当前项目没有 BDD 框架，也可以先用场景矩阵和自动测试组合，不强制装框架
- 第一行测试代码写入前，也要先做 Blast Radius，至少分析目标源文件和测试入口

## Phase 4: 执行验证

### 0. 执行前快照闸门（强制）

写测试前，必须通过闸门：

- 必须输出 `💿 已保护` 或 `💿 闸门通过`
- 规则见 `references/principles/checkpoint-mechanism.md`
- 随后必须执行 `scripts/blast-radius.py`
  - 目标至少包括：被测源文件 / 关键符号
  - 若本次会改已有测试入口，也把测试文件一起纳入目标
  - 结果写入 `.autodev/current-blast-radius.md`

### 默认执行方式

1. 先执行后台自动测试
   - 真正执行命令前，先输出 `🗄️ 后端测试开始 - [BE-{任务指纹}-{Step|Feature}-{场景ID或场景组}-{测试方式}] {scope=当前层/功能级回归 | layer=规则/API/集成 | level=L1/L2/L3}`
2. 再执行对应档位的观测驱动验证
3. 若当前步骤或功能已接通 GUI -> 默认执行 GUI 自治验收闭环
   - 真正拉起 GUI executor 前，先输出 `🖥️ 前端GUI测试开始 - [GUI-{任务指纹}-{Step|Feature}-{caseID}-{executor}-r{轮次}] {scope=主验证/supplemental | visual=headed/headless | gate=GUI}`
4. 若为多步骤任务，遵守“先当前层后端，再本步 GUI；最后再做功能级整体回归”
5. 若为大测试 -> 更新 `.autodev/current-test.md`
6. 输出 `🧾 测试回执`

### 输出格式

输出字段与完整模板统一以 `references/principles/test-verification.md` 为准。

Tester 模式只需额外强调：

- 当前补的是哪一层测试资产
- 是否采用 `Script-first Playwright`
- 当前是 Step 级增量验证，还是 Feature 级整体回归

## Phase 5: 处理结果

### 测试通过

```text
✅ 测试已通过

接下来可以：
[1] 保留这些测试作为回归保障
[2] 继续补其他 use case
[3] 回到原任务继续开发
[0] 结束
```

### 测试失败

```text
❌ 有测试失败

下一步:
[1] 修复代码（进入 Debug）
[2] 修复测试资产
[3] 先确认业务规则
[0] 取消
```

## 典型使用场景

| 场景 | 推荐做法 |
|------|----------|
| PM 突然想到一个 use case | 先翻译成行为场景，再查现有覆盖 |
| 修 bug 后补保护性测试 | 优先写失败测试，再修代码 |
| 新功能需要补回归 | 补场景矩阵 + 后台自动测试 + 轻量观测验证 |
| 想确认 GUI 用户链路 | 命中 GUI-capable task 时默认执行 GUI executor；Web 优先评估 `Script-first Playwright` |

## 禁止行为

- 只说“我帮你测过了”，不给命令和证据
- 遇到业务阈值就自己拍脑袋
- 命中大测试却不维护 `current-test.md`
- GUI 链路还没接通，却宣称整条链路已通过
- 命中 GUI-capable task 却仍停在“建议执行”
