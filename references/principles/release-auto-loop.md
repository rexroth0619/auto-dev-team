# 预发自动化闭环

> 仅定义自动化版预发测试的最小规则。细节优先下沉到 `release-plan.json` 与脚本。

## 触发

- 用户显式选择 `自动`
- 已生成 `.autodev/temp/release-plan.json`
- 当前项目已补充必要的 `.autodev/path.md` 事实
- 当前项目已补充 `.autodev/ai-sot.json` 机器真相源

## 固定顺序

1. 读取 `release-plan.json`
2. 读取 `.autodev/ai-sot.json`
3. 校验 `release-plan.json` 是否偏离 `ai-sot.json`
4. 输出 emoji executive summary
5. 清理上一轮预发测试临时产物
6. 认证态检测
7. 后端执行面检查（SSH / 工作目录 / allowed_paths）
8. 自动查数
9. 自动造单
10. 后端 UC 验证
11. 前端 GUI 验证
12. 证据归档
13. 输出简洁回执

## 认证策略优先级

1. `existing_session`
2. `browser_login_handoff`
3. `local_secret_store`
4. `manual_fallback`

规则：

- 自动化需要的是“认证态”，不是必须拿到明文密码
- 默认不得要求用户在聊天里输入账号密码
- 遇到验证码、扫码、强 MFA，直接转 `manual_fallback`
- 若 SSH 是自动化执行前提，优先使用本地已配置的 `ssh alias` / `jump alias`
- 不得要求用户在聊天里提供密码、私钥内容或完整敏感 SSH 凭证
- `web_terminal_only` 只表示用户可手动进入远端环境，不代表 runner 具备可复用 SSH 能力
- 后端执行面与 GUI 执行面必须分离建模：
  - 后端执行面：SSH / 工作目录 / 查数 / 造单 / 日志 / 状态检查
  - GUI 执行面：本机浏览器或本机 Playwright 默认优先
- 除非用户明确要求远端浏览器环境，否则不得把 GUI 自动化绑定到远端 SSH 宿主

## 启动前固定动作

- LLM 在真正启动自动化前，必须先输出 emoji executive summary：
  - 是否有后端测试
  - 是否有前端 GUI 测试
  - 本轮测试基本内容
  - 用户预期能看到的变化
- 每次新的预发自动化开始前，必须先脚本化清理上一轮预发测试的临时产物
- 清理范围默认只允许落在 `.autodev/temp/release/` 等临时目录
- 默认保留：
  - `.autodev/ai-sot.json`
  - `.autodev/path.md`
  - `.autodev/autodev-config.json`
  - 认证状态文件，如 `storage-state.json`
- 禁止把固定真相源、配置文件或用户明确要求保留的变量文件纳入 cleanup

## Fail-close

命中以下任一条件时，立即停止自动执行并转人工：

- 缺少 `release-plan.json`
- 缺少 `.autodev/ai-sot.json`
- `release-plan.json` 与 `ai-sot.json` 冲突
- 缺少预发入口或查询入口
- 缺少必需命令
- 写操作未显式放行
- GUI 校验被要求执行但未显式放行
- 检测到 `UI / GUI` 域，但 plan 中没有可执行 GUI checks
- SSH 访问方式为 `web_terminal_only`
- 自动模式缺少 SSH alias / jump alias / 远端工作目录 / `allowed_paths`
- 命令执行范围超出 `allowed_paths`
- GUI 执行面被错误绑定为后端 SSH 上下文

## 禁止 silent downgrade

- 用户明确要求“自动化预发测试”且目标包含 GUI 时：
  - 不得把 GUI checks 置空后继续执行
  - 不得把任务 silently 降级成后端-only 自动检查
- 用户明确要求预发环境自动执行时：
  - 不得忽略 SSH 语义，只在本地仓库里跑 shell 后宣称“预发自动化已通过”
  - 不得把 `web_terminal_only` 视作可复用 SSH 上下文
- 后端自动检查通过 != 自动化预发测试通过
  - 若 GUI、认证桥接、远端执行任一缺失，必须明确写成 `manual_fallback`

## 最小证据要求

- 每个自动化通过的 UC 至少有 1 条后端证据
- GUI 通过不能替代副作用验证
- 最终必须落盘 receipt JSON

## 固定回执标题

- `🛠️ 预发测试开始`
- `🧭 自动化测试计划已生成`
- `📋 执行摘要`
- `🧹 上轮临时文件清理`
- `🔐 认证态检测`
- `🔎 自动查数开始`
- `🧪 自动造单开始`
- `🛰️ 后端 UC 验证开始`
- `🖥️ 前端 GUI 验证开始`
- `📦 证据已归档`
- `⚠️ 待人工确认项与剩余风险`
- `✅ 自动化预发结论`

## 结束态

- `passed`
- `manual_fallback`

不得在 `manual_fallback` 状态下宣称“预发测试已通过”。
