# Gotchas

> 这里放 Claude 真会踩的坑，而不是通用编程常识。命中相关场景时优先读这里。

## 保留性与编辑语义

- 用户说“添加”，不要整体替换原文件或原函数。
- 用户说“修改 X”，只改 X 本身；不要顺手重写整段相邻逻辑。
- 用户说“删除 X”，只删目标对象；不要把整个结构一起删掉。
- 清理、重构、格式化时最容易误伤同级内容；动手前先列出“会保留什么”。

## Git / Checkpoint

- 建立存档前要检查未跟踪文件，否则新文件最容易漏进提交之外。
- `git add -A` 后必须审查暂存区，尤其注意 `.env`、密钥、`.cursor/`。
- 在 monorepo 中，当前包改动很小，不代表影响范围很小；先看直接消费方。
- 工作区干净不等于“已有当前任务保护点”；首次写入前仍要过快照闸门。
- 回退列表必须基于真实 `git` 数据生成，不能凭会话记忆“猜你要回哪个”。

## Debug / 验证

- “之前好好的，现在坏了”时，优先看最近改动，不要先发散到所有可能原因。
- 自动测试通过不等于链路正确；观测驱动验证仍要检查预期/实际观测。
- GUI-capable task 里，后台自动测试通过不等于界面链路通过；GUI 自治验收仍要真正执行。
- 还没联调到 GUI 时，只能声明“当前层已验证”，不能说“整条用户链路已完成”。
- 大测试命中后别忘了维护 `.autodev/current-test.md`。
- 命中 GUI-capable task 却只写“建议执行”= 还没执行。
- GUI 失败后必须重跑同一 case，不能只修代码不复验。
- Web GUI 不要只会写 `@playwright/test`；`node xxx.ui.test.js` 的脚本式 Playwright 往往更适合本地快速闭环。
- 脚本式 GUI 测试不要只堆 selector；优先抽出登录、上传、筛选、打开详情等业务 helper。
- 上传 / 下载 / 媒体预览场景不要只断言按钮点击；至少补一层 network 或 response headers 断言。
- 移动 Web 场景不要只改 viewport；优先考虑 device context、UA 和真实下载行为差异。
- 如果 GUI case 失败，先分类是 locator、timing、frontend_state、network 还是 backend，不要一上来就说“Playwright 不稳定”。

## 模式切换

- FastTrack 超出 2 文件 / 30 行后要及时升级，不要硬顶着做成半个 Architect。
- Refactor / Optimize 如果已经拆步，执行阶段必须进入 Step，不要跳过逐步验证。
- Tester、Cleanup 都是写入模式，不能按只读模式处理。
