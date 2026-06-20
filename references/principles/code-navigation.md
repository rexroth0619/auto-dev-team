# 代码导航原则

> 先看地图，再进现场。导航器负责定位和关系，验证仍由测试、观测和直接证据负责。

## 目标

在解释架构、定位 bug、设计改动、执行已有代码修改、重构、优化、清理或测试影响面前，优先使用可用的代码导航器获取符号、入口、调用链、相关文件、复用点和影响面，避免先进入 raw `rg` / `Read` 探索循环。

## 条件强制

当同时满足以下条件时，必须先使用代码导航器：

- 当前会话暴露了可用导航工具。
- 当前项目已建立对应索引或导航上下文。
- 当前任务涉及已有代码理解、定位、修改、重构、优化、清理、测试影响面或架构归属判断。

若任一条件不满足，必须记录原因，并降级为 `rg` / `Read` / 脚本化 Blast Radius。不要把“如果有的话”写成软建议；使用条件强制：

```text
当代码导航器可用且项目已索引时，必须先使用导航器；若不可用、未索引或命中 stale 文件，说明原因并降级。
```

## 抽象动作

AutoDevTeam 只依赖这些抽象动作，不依赖某个具体 provider：

| 抽象动作 | 用途 |
|----------|------|
| `semantic_explore(query)` | 理解功能区域、架构路径、核心实现、数据/调用流 |
| `semantic_search(symbol)` | 定位符号、文件、入口 |
| `semantic_callers(symbol)` | 查调用方、引用方、入口路径 |
| `semantic_callees(symbol)` | 查被调用方、本地依赖、下游实现 |
| `semantic_impact(symbol)` | 查改动影响面、受影响调用链和测试范围 |
| `semantic_node(symbol)` | 获取单个符号完整实现或重载定义 |
| `semantic_files(path_or_pattern)` | 查看已索引文件树、模块候选和测试邻近关系 |

## 当前 Provider: CodeGraph

| 抽象动作 | CodeGraph 工具 |
|----------|----------------|
| `semantic_explore(query)` | `codegraph_explore` |
| `semantic_search(symbol)` | `codegraph_search` |
| `semantic_callers(symbol)` | `codegraph_callers` |
| `semantic_callees(symbol)` | `codegraph_callees` |
| `semantic_impact(symbol)` | `codegraph_impact` |
| `semantic_node(symbol)` | `codegraph_node` |
| `semantic_files(path_or_pattern)` | `codegraph_files` |

优先使用 `codegraph_explore` 做区域理解；不要先串联 `search -> node -> Read` 来重建同一个上下文。`codegraph_node` 只用于补一个明确符号的完整实现。

## 用户可见导航回执

命中“条件强制”时，在首次 raw `rg` / `Read` 探索前，必须输出一张轻量导航回执，让用户能判断确实先用了代码导航器，而不是事后补口径。

推荐格式：

```text
🧭 CodeGraph 导航回执
- Provider: CodeGraph
- 已触发: semantic_files / semantic_explore / semantic_node / semantic_impact
- Query: "目标功能 / 入口符号 / 相关模块"
- 结果用途: 定位入口、调用链、影响面、复用点或测试面
- Raw Read 降级: 无
```

若需要直接读源码、`rg` 或其他 raw 探索，必须在读取前或同一条进展中声明降级：

```text
📄 Raw Read 降级
- 文件 / 范围: path/to/file.ts:1-120
- 原因: CodeGraph 未覆盖具体细节 / 结果 stale / 文件刚编辑过 / 需要读取非代码配置
```

执行规则：

- 同一轮任务已输出过导航回执后，后续继续使用同一批 CodeGraph 结果时，可简写为“沿用本轮 CodeGraph 结果”，不要重复刷屏。
- 若用户质疑是否使用了 CodeGraph，最终回执必须补充列出本轮使用过的 `semantic_*` 动作和 raw read 降级清单。
- 导航回执只记录动作、查询意图、用途和降级原因；不要粘贴 CodeGraph 原始回传或源码。
- 不允许先大范围 raw read / `rg`，再输出“已用 CodeGraph”的回执。

## CodeGraph 使用策略

CodeGraph 是代码结构与符号关系的一手导航工具，不需要为每次查询自建结果台账。AutoDevTeam 只保留必要的计划决策、目标符号和验证范围；具体结构、调用链和影响面在需要时直接向 CodeGraph 查询。

当用户要了解【当前代码结构 / 代码架构 / 模块分布】时，优先使用：

1. `semantic_files(path_or_pattern)` 获取已索引文件树、模块候选和测试邻近关系。
2. `semantic_explore(query)` 获取核心入口、模块协作、关键符号和架构路径。
3. 必要时用 `semantic_search(symbol)` 精确定位符号。

当用户要了解【某个功能怎么实现】时，优先使用 `semantic_explore(query)`，不要先 raw `rg` 再逐个读源码。

当用户要评估【改动影响面】时，优先使用 `semantic_impact(symbol)`；必要时补 `semantic_callers(symbol)` / `semantic_callees(symbol)`。

当只需要【单个符号完整实现】时，才使用 `semantic_node(symbol)`；仍不要扩大成整文件读取。

## 输出与轻量摘要

CodeGraph 回传后，只把对后续执行真正有用的结论写进现有 artefact：

- 项目级架构理解：更新 `.autodev/project-map.md` 的短摘要，记录模块分布、入口、关键测试面。不要粘贴 CodeGraph 原始回传或源码。
- 计划 / Step：在 `.autodev/current-steps.md` 记录目标文件、目标符号、复用点、验证范围和降级原因。
- Blast Radius：在 `.autodev/current-blast-radius.md` 记录导航器发现的目标符号、候选调用方、邻近测试和 stale 降级原因。

树状“绘制”只作为用户可见解释或回执，不作为必须落盘的独立 artefact：

```text
用户问题 / 目标功能
└─ 入口符号 @ path/to/file.ts:line
   ├─ 下游调用 @ path/to/next.ts:line
   ├─ 关键分支 / 副作用
   └─ 邻近测试 / 验证入口
```

复用规则：

- 同一轮对话中，已拿到的 CodeGraph 结果可以直接继续使用，不要为了“确认一下”重复查询。
- 跨 Resume / 新任务时，若只需要项目宏观结构，先看 `.autodev/project-map.md` / `.autodev/module-registry.md` 的短摘要；若需要当前、精确、局部结构，直接重新调用 CodeGraph。
- 不为节省一次 CodeGraph 调用而维护庞大缓存；CodeGraph 的索引才是结构真相源，`.autodev` 只记录人类可读的短决策。
- 需要精确代码行、最近刚被编辑过的行、或 CodeGraph 结果明确缺失 / stale 时，才允许直接读源码的最小范围。

## 项目配置

项目初始化后的 `.autodev/autodev-config.json` 可以声明导航策略：

```json
{
  "code_navigation": {
    "enabled": true,
    "preferred_provider": "codegraph",
    "provider_order": ["codegraph"],
    "fallback": "rg-read",
    "required_before_raw_search": true,
    "record_downgrade_reason": true,
    "user_visible_receipt": true,
    "trust_non_stale_results": true
  }
}
```

新增或替换导航器时，优先更新 `provider_order` 和本文件的 provider 映射；模式流程继续使用 `semantic_*` 抽象动作。

## 模式使用规则

| 模式 / 动作 | 导航器用法 |
|-------------|------------|
| Survey / 代码架构理解 | `semantic_files` + `semantic_explore` 获取模块、入口、核心符号和测试面；只把短摘要写入 `project-map.md` |
| Explain | `semantic_explore` 输出实现路径、调用链、核心文件，超过 3 层折叠 |
| Debug | 生成假设前先 `semantic_explore`；必要时用 `semantic_callers` / `semantic_callees` 查同型路径 |
| Architect | 设计前查现有模块、复用点、接口面和归属位置，避免重复新建 |
| FastTrack / Hotfix / Step | 第一行代码前查目标符号和影响面，再跑 Blast Radius |
| Refactor / Optimize | 先查调用链、依赖面、同类实现和受影响测试，再设计方案 |
| Cleanup | 删除前用调用方/影响面证明无活跃引用，再执行 Blast Radius 删除证明 |
| Tester | 根据影响面找邻近测试、回归入口、受影响 use case 和测试落层 |

## Staleness 与降级

- CodeGraph 返回 staleness 提示时，只直接读取提示中的过期文件。
- 未标记过期的导航结果默认可信，不要重复 grep 复验。
- 若索引不存在，提示可运行 `codegraph init -i`，但不要阻塞用户明确要求的紧急修复；记录降级原因后用 `rg` / `Read`。
- 若导航结果不能覆盖具体细节，允许读取目标文件的最小范围。

## 与 Blast Radius 的关系

代码导航器是语义预扫描，不替代 `scripts/blast-radius.py`：

1. 先用导航器缩小目标符号、入口、调用链和候选文件。
2. 再运行脚本化 Blast Radius 固化机械影响面。
3. 最后补业务数据流、隐式契约、动态注册、配置和运行时观测。

## 禁止行为

- 有可用导航器且项目已索引，却先做大范围 raw `rg` / `Read` 探索。
- 命中导航器却不输出用户可见导航回执，或 raw read 降级不说明原因。
- 把导航结果当成测试结果。
- CodeGraph 标记 stale 后继续信任对应文件内容。
- 换 provider 时改散落在各模式里的工具名；只更新本文件的 provider 映射。
