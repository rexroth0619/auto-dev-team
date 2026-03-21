# GUI 自治验收闭环

> canonical GUI 执行文档。定义“识别 GUI 任务 → 执行 use case → 采集证据 → 自修复 → 重跑 → 完成 gate”的统一方法。

## 目标

- 让 GUI 成为第一等公民，而不是后台自动测试后的可选附加项。
- 让 AI 自己进入界面、模拟人类操作、采集前后端证据并完成自修复。
- 让用户在条件允许时看到执行过程；做不到用户可见时，也必须留下可回放证据。

## GUI-capable task 触发器

命中以下任一条件时，默认进入 GUI 自治验收闭环：

- 页面、窗口、表单、弹窗、路由、菜单、列表、搜索筛选
- 登录 / 注册 / 支付 / 权限 / 会话 / 上传下载
- 任何“用户可点击、可输入、可见结果”的界面
- 用户显式提到“前端验收”“全链路”“从用户角度”“模拟操作”

未命中以上条件时，可不进入本闭环。

## GUI executor 选择

按“能真实模拟用户操作”优先选择：

1. Web GUI → `Playwright`
2. Desktop / Electron / Tauri → 当前环境可用的 GUI driver
3. 宿主插件 / 嵌入面板 → 当前宿主可用的操作入口
4. 无自动化入口 → 状态标记为 `Manual only`

要求：

- 必须在计划或测试回执中写明本轮 executor。
- Web 场景默认不要把 Playwright 写成“可选提示”；它是默认 executor。

## 可视化执行策略

`visual_mode` 统一使用以下枚举：

- `required`：用户明确要求看见执行过程
- `preferred`：默认值；优先用户可见
- `unavailable`：当前环境无法把 GUI 过程直接展示给用户

规则：

- 能 `headed` / 用户可见时，优先这样执行。
- 若只能后台运行，必须补足截图、trace、timeline 等可回放证据。
- 不能把“后台执行且无证据”说成“用户已看到过程”。

## GUI case matrix（强制）

每个 GUI-capable task 至少要有一组 GUI case matrix，最少覆盖：

- `Happy`
- `Negative` 或 `Boundary`
- 若涉及会话 / 权限 / 状态流转，再补 1 个恢复或拒绝场景

每个 case 至少包含：

- `前置条件`
- `操作步骤`
- `预期页面变化`
- `预期网络行为`
- `预期后端结果 / 副作用`
- `失败时优先采集的观测面`

## 证据包（evidence bundle）

每轮 GUI 验收至少保留：

- `action_timeline`：点击、输入、跳转、等待点
- `screenshots`：关键节点截图
- `browser_console`：错误、警告、关键日志
- `network_trace`：关键请求、状态码、失败点
- `page_state`：DOM / URL / 关键元素状态摘要
- `backend_trace`：可关联的 request id / trace id / 服务端证据（如适用）

若项目支持 trace viewer / 视频 / HAR，可作为增强证据。

## 标准流程

1. 判断当前任务是否为 GUI-capable task。
2. 选择 executor 与 `visual_mode`。
3. 组装 GUI case matrix。
4. 先执行后台自动测试与观测驱动验证，确认底层行为可测。
5. 执行 GUI case，并同步采集 evidence bundle。
6. 若失败，先分类，再进入自修复循环：
   - 视觉问题
   - locator / 选择器问题
   - 交互问题
   - 页面状态问题
   - 网络问题
   - 后端问题
   - 环境问题
7. 修复后，必须重跑同一 case。
8. 关键 case 通过后，执行一轮最小 GUI 回归。
9. 更新 `current-test.md` 或测试回执。

## 自修复循环

```text
GUI case 失败
-> 失败分类
-> 采集最小必要证据
-> 修复代码或测试资产
-> 重跑同一 case
-> 若通过则更新状态
-> 若仍失败则继续诊断
-> 超过上限则停止并报告
```

约束：

- 默认最多 3 轮。
- 不能跳过“重跑同一 case”直接宣布修复。
- 不能把 locator 问题、环境问题、业务规则问题混成一句“测试失败”。

## Completion Gate

GUI-capable task 完成前，必须满足以下之一：

- `passed`：GUI case 已执行并通过
- `blocked`：当前步骤尚不具备 GUI 联调条件，且已说明阻塞点
- `disabled_by_user`：用户明确要求本轮不执行 GUI 自动验收
- `manual_only`：环境无自动化入口，且已提供开发者手测教程

若状态为以下任一，禁止宣称完成：

- `planned`
- `ready`
- `running`
- `failed`

## 与观测驱动验证的关系

- GUI 自治验收闭环负责“执行、回放、自修复”。
- 观测驱动验证负责“定义预期观测、解释差异、帮助定位根因”。
- 两者必须协同使用，不能互相替代。

## fallback 规则

以下情况允许不自动跑 GUI executor：

- 当前步骤尚未接通 GUI
- 当前环境无 GUI 自动化能力
- 用户明确禁用
- 关键观测面只能在真机、私有 IDE、第三方后台获取

但此时必须：

- 明确写出状态与原因
- 输出 `🧭 开发者手测教程`
- 在 `剩余风险` 中记录未执行的 GUI 场景

## 输出字段（建议统一）

```text
GUI 自治验收:
- 状态: [未触发 / 规划中 / 执行中 / 已通过 / 失败修复中 / 暂不可执行 / 用户禁用 / Manual only]
- Executor: [...]
- 可视化执行: [required / preferred / unavailable]
- 覆盖用例: [...]
- 证据: [timeline / screenshot / console / network / trace]
- 修复轮次: [0 / 1 / 2 / 3]
- Gate 结论: [允许完成 / 不允许完成]
```
