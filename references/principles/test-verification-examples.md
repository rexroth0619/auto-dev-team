# 验证规则使用示例

> 本文档展示智能验证规则在不同场景下的应用

## 评估维度

| 维度 | 🟢 简单 | 🟡 中等 | 🔴 复杂 |
|------|--------|--------|--------|
| **改动量** | ≤2 文件 ≤30 行 | 3-5 文件 或 30-100 行 | >5 文件 或 >100 行 |
| **功能类型** | 文案/样式/小修复 | 单模块逻辑改动 | 核心流程/API 变更 |
| **影响范围** | 单点改动 | 单模块影响 | 跨模块/对外接口 |
| **验证复杂度** | 1 个存档 | 2-3 个存档 | 多场景/边界情况 |

## 场景 1：🟢 简单改动 - 修改按钮文案

**改动**：
- 文件：1 个（`Button.vue`）
- 行数：1 行
- 类型：文案修改

**评估**：
```
📊 复杂度评估: 🟢 简单改动
- 改动量: 1 文件, 1 行
- 功能类型: 文案修改
- 影响范围: 单点改动
- 验证方式: 即时验证（终端命令/临时脚本）
```

**验证方式**：
```bash
# 快速验证：启动应用，检查文案
npm run dev
# 或者用截图工具确认 UI 文案已更新
```

**输出**：
```
🧪 即时验证
方式: 启动应用 + 人工确认
结果: 通过
证据: 按钮文案已更新为"确认提交"
```

## 场景 2：🟡 中等改动 - 添加表单验证

**改动**：
- 文件：3 个（`Form.vue`, `validation.ts`, `utils.ts`）
- 行数：约 60 行
- 类型：单模块逻辑改动

**评估**：
```
📊 复杂度评估: 🟡 中等改动
- 改动量: 3 文件, 60 行
- 功能类型: 单模块逻辑改动（表单验证）
- 影响范围: 单模块影响（表单组件）
```

**验证方式选择**：
```
📌 验证方式选择:
[1] 即时验证 - 手动填写表单测试各种输入（快速）
[2] Cucumber 验证 - 跑 BDD 场景，覆盖正常/异常/边界情况（全面）

用户选择 [1]：
→ 使用即时验证，手动测试几种常见输入

用户选择 [2]：
→ 执行 `npx cucumber-js features/form-validation.feature`
```

## 场景 3：🔴 复杂改动 - 重构用户认证流程

**改动**：
- 文件：8 个（跨多个模块：auth, api, middleware, store）
- 行数：约 200 行
- 类型：核心流程改动 + API 变更

**评估**：
```
📊 复杂度评估: 🔴 复杂改动
- 改动量: 8 文件, 200 行
- 功能类型: 核心流程改动（用户认证）+ API 变更
- 影响范围: 跨模块（auth, api, middleware, store）+ 对外接口
- 验证方式: Cucumber 验证（必须）
```

**验证方式**：
```
🧪 BDD 验证 - 实际执行

📂 执行命令: npx cucumber-js features/user-auth.feature
📤 实际输出:
┌────────────────────────────────────────────────────
│ Feature: User Authentication
│ 
│   Scenario: User login with valid credentials
│     ✓ Given user "test@example.com" with password "password123"
│     ✓ When user submits login form
│     ✓ Then user should be redirected to dashboard
│     ✓ And session should be created
│ 
│   Scenario: User login with invalid credentials
│     ✓ Given user "test@example.com" with password "wrongpassword"
│     ✓ When user submits login form
│     ✓ Then user should see error message "Invalid credentials"
│     ✓ And no session should be created
│ 
│   Scenario: Token refresh flow
│     ✓ Given user is logged in
│     ✓ When access token expires
│     ✓ Then refresh token should be used automatically
│     ✓ And user should remain authenticated
│ 
│ 3 scenarios (3 passed)
│ 12 steps (12 passed)
│ 0m2.345s
└────────────────────────────────────────────────────

📊 结果汇总:
  ✅ Scenario: User login with valid credentials → passed
  ✅ Scenario: User login with invalid credentials → passed
  ✅ Scenario: Token refresh flow → passed
```

## 场景 4：🟢 简单改动 - 修改 CSS 样式

**改动**：
- 文件：1 个（`styles.css`）
- 行数：5 行
- 类型：样式调整

**评估**：
```
📊 复杂度评估: 🟢 简单改动
- 改动量: 1 文件, 5 行
- 功能类型: 样式调整
- 影响范围: 单点改动
- 验证方式: 即时验证（浏览器检查）
```

**验证方式**：
```bash
# 刷新浏览器，检查样式效果
# 使用开发者工具确认 CSS 规则已应用
```

**输出**：
```
🧪 即时验证
方式: 浏览器检查
结果: 通过
证据: 按钮边距已调整为 16px，与设计稿一致
```

## 场景 5：🟡 中等改动 - 添加新的 API 端点

**改动**：
- 文件：4 个（`routes.ts`, `controller.ts`, `service.ts`, `model.ts`）
- 行数：约 80 行
- 类型：单模块逻辑改动（新 API）

**评估**：
```
📊 复杂度评估: 🟡 中等改动
- 改动量: 4 文件, 80 行
- 功能类型: 单模块逻辑改动（新增 API 端点）
- 影响范围: 单模块影响（API 层）
```

**验证方式选择**：
```
📌 验证方式选择:
[1] 即时验证 - 用 curl/Postman 测试 API 端点（快速）
[2] Cucumber 验证 - 跑 API 测试场景（全面）

用户选择 [1]：
→ 使用 curl 测试新端点

用户选择 [2]：
→ 执行 `npx cucumber-js features/api/new-endpoint.feature`
```

**即时验证示例**：
```bash
# 测试 GET 请求
curl -X GET http://localhost:3000/api/users/123

# 测试 POST 请求
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com"}'
```

**输出**：
```
🧪 即时验证
方式: curl 命令测试
命令: curl -X GET http://localhost:3000/api/users/123
结果: 通过
证据:
┌────────────────────────────────────────────────────
│ HTTP/1.1 200 OK
│ Content-Type: application/json
│ 
│ {
│   "id": 123,
│   "name": "Test User",
│   "email": "test@example.com"
│ }
└────────────────────────────────────────────────────
```

## 边界情况处理

### 情况 A：项目没有 BDD 框架

如果项目没有配置 BDD 框架（无 `.feature` 文件）：

```
📊 复杂度评估: 🔴 复杂改动
- 改动量: 10 文件, 300 行
- 功能类型: 核心流程改动
- 影响范围: 跨模块
- 项目状态: 未配置 BDD 框架

⚠️ 建议: 复杂项目建议配置 BDD 框架，便于长期维护

📌 当前验证方式:
→ 使用即时验证（终端命令/临时脚本）
→ 覆盖核心路径 + 2-3 个关键边界情况
```

### 情况 B：不确定复杂度

如果 AI 无法明确判断复杂度：

```
📊 复杂度评估: 🟡 中等改动（不确定）
- 改动量: 3 文件, 50 行
- 功能类型: 可能影响核心流程
- 影响范围: 需要进一步确认

📌 验证方式选择:
[1] 即时验证 - 终端命令/临时脚本（快速）
[2] Cucumber 验证 - 跑 BDD 场景（保险）

💡 建议: 如果不确定影响范围，选择 [2] 更保险
```

## 总结

**选择验证方式的决策树**：

```
代码改动完成
    ↓
评估复杂度
    ↓
┌─────────┬─────────┬─────────┐
│ 🟢 简单  │ 🟡 中等  │ 🔴 复杂  │
│ ≤2 文件 │ 3-5文件 │ >5 文件 │
│ ≤30 行  │ 单模块  │ 跨模块  │
└─────────┴─────────┴─────────┘
    ↓         ↓         ↓
即时验证   用户选择   Cucumber
  (快)    (平衡)    (全面)
```

**核心原则**：
- 小改动不必跑 Cucumber（降低成本）
- 大改动必须跑 Cucumber（保证质量）
- 中等改动让用户根据实际情况选择（灵活平衡）
