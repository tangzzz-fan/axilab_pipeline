# algo-engineering-lab

> **定位：** 验证 Python 算法原型 → golden 数据集 → C 库 / Swift → iOS 侧 parity 回归的数值一致性与性能链路。  
> **对外口径：** 面试前针对目标公司技术栈的**验证性原型**，不是生产项目。

版本：0.2.0 · 日期：2026-07-28 · 作者：lab · 状态：生效

---

## 链路架构

```mermaid
flowchart LR
    Py["Python 原型\n(uv 环境)"] --> Golden["golden/\n冻结真值"]
    Golden --> Parity["ParityTests\n精度断言"]
    C["AlgoC"] --> Parity
    Swift["AlgoSwift / Accelerate / CoreML"] --> Parity
    C --> Bench["BenchmarkTests\n性能记录"]
    Swift --> Bench
```

---

## 环境依赖

| 项 | 要求 |
| :--- | :--- |
| Python | 3.11+（由 `uv` 管理） |
| uv | [https://github.com/astral-sh/uv](https://github.com/astral-sh/uv) |
| Xcode / Swift | Xcode 15+（Swift 5.9+） |
| CoreML case | `uv sync --extra ml`（coremltools + scikit-learn&lt;1.6） |
| 平台 | macOS 跑 SPM；真机数字须按 `docs/05` 记环境 |

---

## 快速开始（陌生人 15 分钟）

```bash
cd algo-engineering-lab
uv sync
swift test --filter ParityTests
```

可选：重生全部 golden（含 CoreML 报告）：

```bash
uv sync --extra ml
uv run python -m python.generate_golden hrv_time_domain
uv run python -m python.generate_golden fir_ppg
uv run python -m python.generate_golden hrv_freq_domain
uv run python -m python.generate_golden coreml_quant
uv run python -m python.generate_golden streaming_fir
swift test --filter ParityTests
```

---

## 结果看板

### 精度误差表

| Case | 指标 | 阈值 | 实测 | 结论 |
| :--- | :--- | :--- | :--- | :--- |
| 01 HRV 时域 | SDNN/RMSSD | ≤0.1 ms | parity 全绿 | 通过 |
| 01 HRV 时域 | pNN50 | ≤0.5 pp | parity 全绿 | 通过 |
| 02 FIR PPG | 滤波输出 | ≤1e-4 | naive + vDSP 全绿 | 通过 |
| 03 HRV 频域 | 时域快照 | abs ≤1e-9 | 全绿 | 通过 |
| 03 HRV 频域 | PSD / LF/HF | 见口径 | 全绿 | 通过 |
| 04 CoreML | FP16↔FP32 top-1 | ≥95% | **100%** | 通过 |
| 04 CoreML | 置信度偏移均值 | abs ≤0.05 | ~1e-5 | 通过 |
| 05 流式 FIR | 连续窗 vs 因果整段 | abs ≤1e-12 | 全绿 | 通过 |
| 05 流式 FIR | 丢包 zero_fill | abs ≤1e-12 | 全绿 | 通过 |

### 性能数字表

| 实现 | p50 / p95 | 备注 | 环境 |
| :--- | :--- | :--- | :--- |
| FIR AlgoC naive | 见 [`docs/bench-log.md`](docs/bench-log.md) | 热路径基准 | Debug · Apple Silicon |
| FIR Swift vDSP_dotpr | 见 bench-log | 逐点组窗开销大 | 同上 |

> 裸数字无效；必须带机型 / 芯片 / OS / 编译配置 / 电量与发热（`docs/05`）。

---

## 三张面试口述卡片

完整版：[`docs/07-面试口述卡片.md`](docs/07-面试口述卡片.md)

| 卡片 | 一句话 |
| :--- | :--- |
| **精度漂移** | 对不上先查口径与中间快照，不要先怪 FFT / 量化。 |
| **C 集成** | 边界规则写进规范：所有权、零拷贝、错误码、批次调用。 |
| **流式状态** | FIR 延迟线跨窗连续；和 BLE 分片同构，中间层是 iOS 价值。 |

---

## 扩展路线图（新增 case 候选）

详见：[`docs/08-扩展案例建议.md`](docs/08-扩展案例建议.md)

建议优先级：

1. HRV 伪差校正（Artifact Correction）
2. OTA/DFU 断点续传仿真（状态机 + 漏斗指标）
3. 多通道同步与时间戳漂移校正

扩展 case 仍遵循同一交付链路：

`Python 原型 → golden → C/Swift 实现 → Parity/Benchmark → 复盘`

---

## Case 导航

| Case | 对齐口径 | 复盘 | 状态 |
| :--- | :--- | :--- | :--- |
| 01 HRV 时域 | [`hrv-time-domain.md`](docs/02-算法对齐口径/hrv-time-domain.md) | [`case-01`](docs/06-实验复盘/case-01-hrv-time-domain.md) | 完成 |
| 02 FIR 滤波 | [`fir-ppg-bandpass.md`](docs/02-算法对齐口径/fir-ppg-bandpass.md) | [`case-02`](docs/06-实验复盘/case-02-fir-filter.md) | 完成 |
| 03 HRV 频域 | [`hrv-freq-domain.md`](docs/02-算法对齐口径/hrv-freq-domain.md) | [`case-03`](docs/06-实验复盘/case-03-hrv-freq-domain.md) | 完成 |
| 04 CoreML 量化 | [`coreml-quant.md`](docs/02-算法对齐口径/coreml-quant.md) | [`case-04`](docs/06-实验复盘/case-04-coreml-quant.md) | 完成 |
| 05 流式滑窗 | [`streaming-fir.md`](docs/02-算法对齐口径/streaming-fir.md) | [`case-05`](docs/06-实验复盘/case-05-streaming-fir.md) | 完成 |

实施任务清单：[`tickets.md`](./tickets.md)  
文档要求说明书：[`../Talk with K3/algo-engineering-lab技术文档要求说明书.md`](../Talk%20with%20K3/algo-engineering-lab技术文档要求说明书.md)
