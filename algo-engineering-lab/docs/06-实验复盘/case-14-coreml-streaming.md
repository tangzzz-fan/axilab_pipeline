# Case14 实验复盘：CoreML 流式滑窗推理

版本：0.1.0 · 日期：2026-07-29 · 作者：lab · 状态：草稿

> 对齐口径：[`coreml-streaming.md`](../02-算法对齐口径/coreml-streaming.md)

---

## 1. 假设

- 无丢包连续流下，StreamingFIR 窗输出与整段因果 FIR 切窗一致。
- 固定窗特征 + Case04 scaler + 缓存 Session，Swift 与 Python 概率可对齐。
- Actor 仅提供串行边界，不改变数值。

## 2. 做法

- Python：`synth_ppg(100)` → 因果 FIR → 4 窗特征 → scale → CoreML。
- Swift：`CoreMLStreamingPipeline` 吃同包序列；`CoreMLStreamingInferenceActor` 再跑一遍。

## 3. 数字

Parity：特征 1e-9、概率 5e-4（见 golden）。  
环境：与 T14 相同 Mac Debug 栈。

## 4. 坑

- 窗特征若与训练分布差太远，概率会挤向某一类——本 lab 只验证链路，不验证分类语义。
- Actor 持有 class pipeline：测试里勿跨隔离域并发 mutate。

## 5. 结论

**流式 FIR 与 CoreML Session 可以接到同一条 BLE 叙事链上。**

## 6. 面试卡片

- 分片 → 环缓 → FIR 窗 → 特征 → 缓存推理。
- compile 在 load；Actor 管并发。
- 黄金集钉死窗特征公式，防止「随口改特征」导致静默漂移。
