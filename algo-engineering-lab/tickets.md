# Tickets: algo-engineering-lab

验证性原型：Python 算法原型 → golden → C/Swift → parity 回归。  
规格来源：`Talk with K3/algo-engineering-lab技术文档要求说明书.md`。

Work the **frontier**：blocker 全完成后即可开工。线性上优先 T0 → T1 → T2。

## T0 · 仓库骨架 + uv 环境 + 三份核心规范初稿

**What to build:** 可克隆的 lab 仓库；用 `uv` 一键同步 Python 环境；`docs/01`、`03`、`05` 初稿可指导后续 case；目录与 README 定位清晰。

**Blocked by:** None — can start immediately.

- [x] `algo-engineering-lab/` 目录结构符合说明书 1.1
- [x] `uv sync` 可进入虚拟环境（依赖锁定）
- [x] `docs/01-数值一致性规范.md`、`03-黄金数据集规范.md`、`05-性能基准规范.md` 含元信息与必填表格骨架
- [x] README 含一句话定位、链路图、快速开始（≤3 条命令进环境）

## T1 · C 库集成规范 + SPM/C 目标可编译空壳

**What to build:** Swift Package 能 `swift build`；Parity / Benchmark 测试目标分离；C 集成规范可对照 review。

**Blocked by:** T0 · 仓库骨架 + uv 环境 + 三份核心规范初稿

- [x] `docs/04-C库集成规范.md` 含职责/所有权/零拷贝/批次/错误码/线程
- [x] `Package.swift` 定义 AlgoC、AlgoSwift、ParityTests、BenchmarkTests
- [x] `swift build` 成功
- [x] `swift test --filter ParityTests` 冒烟通过

## T2 · Case1 HRV 时域：端到端 parity 全绿

**What to build:** 输入 RR 间期，输出 SDNN/RMSSD/pNN50；Python 生成 golden；C + Swift 实现过同一套 parity。

**Blocked by:** T0 · 仓库骨架 + uv 环境 + 三份核心规范初稿；T1 · C 库集成规范 + SPM/C 目标可编译空壳

- [x] 对齐口径文档 `docs/02-算法对齐口径/hrv-time-domain.md`
- [x] `uv run` 生成 golden，覆盖正常/边界/病态，病态占比 ≥40%
- [x] Parity 测试全绿；复盘草稿 `docs/06-实验复盘/case-01-hrv-time-domain.md`

## T3 · Case2 FIR 滤波：C 卷积 vs vDSP + 系数精度

**What to build:** PPG 带通滤波；scipy 系数导出；naive C 与 vDSP 同 golden；记录加速比。

**Blocked by:** T2 · Case1 HRV 时域：端到端 parity 全绿

- [x] 对齐口径含系数有效位陷阱
- [x] naive 与 vDSP 均过同一 golden
- [x] benchmark 记录含机型/芯片/iOS或macOS/配置/电量发热五项

## T4 · Case3 HRV 频域：中间快照逐环对齐

**What to build:** LF/HF 链路；每环中间快照；跨平台口径差异表。

**Blocked by:** T2 · Case1 HRV 时域：端到端 parity 全绿

- [x] `docs/02-算法对齐口径/hrv-freq-domain.md` 环节表完整
- [x] 逐快照比对通过

## T5 · Case4 CoreML 量化漂移（FP32 vs FP16）

**What to build:** 小模型 FP32/FP16 对比；top-1 一致率与置信度分布；预处理单源约定。

**Blocked by:** T0 · 仓库骨架 + uv 环境 + 三份核心规范初稿；T2 · Case1 HRV 时域：端到端 parity 全绿

- [x] 量化对比报告可复现
- [x] 文档口径为验证性原型，非生产项目

## T6 · Case5 流式滑窗：RingBuffer + FIR overlap + 丢包注入

**What to build:** 模拟 BLE 分片到达；滑窗 FIR 无边界跳变；缺口策略可演示。

**Blocked by:** T3 · Case2 FIR 滤波：C 卷积 vs vDSP + 系数精度

- [x] 窗口边界无跳变可验证
- [x] 注入丢包/乱序时行为符合对齐口径

## T7 · README 结果看板收口 + 三张面试口述卡片

**What to build:** 精度表 + 性能表收口；三张口述卡片（精度漂移 / C 集成 / 流式状态）。

**Blocked by:** T2 · Case1 HRV 时域：端到端 parity 全绿；T3 · Case2 FIR 滤波：C 卷积 vs vDSP + 系数精度；T4 · Case3 HRV 频域：中间快照逐环对齐；T5 · Case4 CoreML 量化漂移（FP32 vs FP16）；T6 · Case5 流式滑窗：RingBuffer + FIR overlap + 丢包注入

- [x] 陌生人按 README 15 分钟内跑通已完成 case 的 parity
- [x] 三张卡片各 ≤5 条 bullet，可被追问一层
