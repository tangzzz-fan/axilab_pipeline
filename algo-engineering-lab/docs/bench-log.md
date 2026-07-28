# bench-log（追加式，禁止覆盖历史）

版本：0.1.0 · 日期：2026-07-28 · 作者：lab · 状态：生效

> 格式见 `docs/05-性能基准规范.md`。五项环境缺一，数字无效。

| 日期 | commit | case | 实现 | p50 (ms) | p95 (ms) | 加速比 | 环境摘要 |
| :--- | :--- | :--- | :--- | ---: | ---: | ---: | :--- |
| 2026-07-28 | _(填 T3 commit)_ | fir_ppg N=200 | AlgoC naive | 0.034 | 0.039 | 1.0×（基准） | Mac arm64；Apple Silicon；macOS (见下)；Xcode toolchain；Debug；电源供电/常温 |
| 2026-07-28 | _(填 T3 commit)_ | fir_ppg N=200 | Swift vDSP_dotpr | 1.448 | 1.642 | 0.02× vs naive | 同上；说明：Swift 逐点组窗开销主导，热路径应留在 C |

### 环境明细（上表两行共用）

| 字段 | 值 |
| :--- | :--- |
| 机型 | Mac（arm64，详见本机 `sysctl machdep.cpu.brand_string`） |
| 芯片 | Apple Silicon |
| OS | macOS（`sw_vers`） |
| 编译配置 | `swift test` **Debug**（精度优先；正式对比应改 Release） |
| 电量与发热 | 电源适配器；未观察到降频 |
| Xcode | 本机 `xcodebuild -version` |
