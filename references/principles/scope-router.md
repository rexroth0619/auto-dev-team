# Scope Router

> 由 AI 自动决定当前任务应落在哪个层级开始，而不是把所有任务一律拆成 `step`。

## 原则

选择 `Minimum Safe Planning Level`：

- 能安全交付
- 能明确验证
- 又不过度规划

## 主要信号

- 目标数量
- 影响面
- 不确定性
- 依赖关系
- 验证复杂度
- 持续时长
- 架构新颖度
- AI 当前把握度

## 路由结果

- `one-shot / step`
- `flow`
- `phase`
- `milestone`
- `project`
- `initiative`

## 动态升降级

- 发现复杂度上升、依赖增加、DoD 不再成立：升层
- 发现影响面集中、验证简单、已有成熟模式：降层

## 禁止事项

- 用户说“大”就一定升层
- 用户说“小”就一定 one-shot
- 只按文件数判断层级
