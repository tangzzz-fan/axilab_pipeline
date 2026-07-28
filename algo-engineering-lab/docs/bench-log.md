# bench-log（追加式，禁止覆盖历史）

版本：0.1.0 · 日期：2026-07-28 · 作者：lab · 状态：生效

> 格式见 `docs/05-性能基准规范.md`。五项环境缺一，数字无效。

| 日期 | commit | case | 实现 | p50 (ms) | p95 (ms) | 加速比 | 环境摘要 |
| :--- | :--- | :--- | :--- | ---: | ---: | ---: | :--- |
| 2026-07-28 | a7e8eb2 | fir_ppg N=200 | AlgoC naive | 0.034 | 0.039 | 1.0×（基准） | MacBook / Apple M2 / macOS 26.3.1 / Xcode 26.6 / **Debug** / 电源·常温 |
| 2026-07-28 | a7e8eb2 | fir_ppg N=200 | Swift vDSP_dotpr | 1.448 | 1.642 | 0.02× vs naive | 同上；Swift 逐点组窗开销主导 → 热路径应留在 C |

### 环境明细

| 字段 | 值 |
| :--- | :--- |
| 机型 | Mac（Apple M2） |
| 芯片 | Apple M2 |
| OS | macOS 26.3.1 (25D2128) |
| 编译配置 | `swift test` **Debug**（正式对比应改 Release） |
| 电量与发热 | 电源适配器；常温 |
| Xcode | Xcode 26.6 |
