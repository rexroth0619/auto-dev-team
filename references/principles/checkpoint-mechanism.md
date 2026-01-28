# 检查点机制

> 每次改动前创建 git 检查点，确保随时可回退

## 检查点命名规范

```
git add -A && git commit -m "SPEC-{类型}: {描述}"
```

### 类型定义

| 类型 | 使用场景 | 示例 |
|------|----------|------|
| `Step{N}-before` | Step 执行前 | `SPEC-Step2-before: 添加按钮组件` |
| `Quick` | FastTrack 执行前 | `SPEC-Quick: 改按钮颜色` |
| `Hotfix-before` | Hotfix 执行前 | `SPEC-Hotfix-before: 修复崩溃` |
| `Cleanup-before` | Cleanup 执行前 | `SPEC-Cleanup-before: 删除死代码` |
| `Optimize-before` | Optimize 执行前 | `SPEC-Optimize-before: 优化渲染` |
| `Refactor-before` | Refactor 执行前 | `SPEC-Refactor-before: 提取函数` |
| `Complete` | 任务完成后 | `SPEC-Complete: 用户登录功能` |
| `Save` | 用户临时保存 | `SPEC-Save: 用户更改` |

## 常用命令

### 创建检查点
```bash
git add -A && git commit -m "SPEC-{类型}: {描述}"
```

### 回滚到检查点
```bash
git reset --hard SPEC-{检查点名}
```

### 查看所有检查点
```bash
git log --oneline | grep SPEC
```

## Git 失败处理

当 git 操作失败时:

```
→ "检测到未保存的更改，是否先提交？"
→ 用户确认后: git commit -m "SPEC-Save: 用户更改"
```

## 检查点使用场景

### 1. Step 执行

```
每步开始前:
git commit -m "SPEC-Step{N}-before: {步骤描述}"

任务完成后:
git commit -m "SPEC-Complete: {任务名}"
```

### 2. 快速修改

```
FastTrack（快速小改）执行前:
git commit -m "SPEC-Quick: {改动描述}"
```

### 3. 紧急修复

```
Hotfix 执行前:
git commit -m "SPEC-Hotfix-before: {问题描述}"
```

### 4. 回滚操作

```
用户说 "回退" / "撤销":
1. 列出最近的检查点
2. 确认回退目标
3. 执行: git reset --hard SPEC-{检查点}
4. 报告回退完成
```

## 检查点原则

1. **改动前必建**: 任何代码改动前都要创建检查点
2. **描述要清晰**: 检查点描述要能回忆起改动内容
3. **粒度要合适**: 一个检查点对应一个逻辑单元
4. **保持可回退**: 确保任何时候都能回到安全状态
