# Resume Router

## 目标

把 Resume 从“恢复单个 flow”升级为“恢复当前活跃注意力栈”。

## 三种触发

- `hard resume`：用户显式要求继续 / resume
- `implicit resume`：用户输入模糊，明显在续接旧任务
- `auto resume`：超过时间阈值后自动触发

## 自动 Resume 原则

- 不比较普通文件修改时间
- 比较 `last_meaningful_touch_at`
- 只对 `active / paused / blocked` 状态触发
- 默认阈值由 `.autodev/autodev-config.json` 控制

## 输出重点

- 当前 project / milestone / phase / flow / step
- 当前卡点
- 整体进度
- 最近一次有效推进
- 下一步建议

## 禁止事项

- 自动 Resume 打断明显的新任务
- 只恢复 step，不恢复整体上下文
