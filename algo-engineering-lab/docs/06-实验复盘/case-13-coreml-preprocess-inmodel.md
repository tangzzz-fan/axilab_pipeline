# Case13 实验复盘：CoreML 预处理入模对照

版本：0.1.0 · 日期：2026-07-29 · 作者：lab · 状态：草稿

> 对齐口径：[`coreml-preprocess-inmodel.md`](../02-算法对齐口径/coreml-preprocess-inmodel.md)

---

## 1. 假设

- 同权下，App 显式 StandardScaler 与图内对角 linear 应数值对齐。
- 双重 normalize 会把输入分布打穿，概率应显著偏离（本机 max abs ≈ 0.99）。

## 2. 做法

- 同 seed 训 MLP；导出 `activity_fp32`（scaled 输入）与 `activity_fp32_with_preprocess`（raw 输入）。
- 固定 3 条 raw；Python / Swift 双路径 parity；负例断言偏离下限。

## 3. 数字

| 指标 | 阈值 | 实测 |
| :--- | :--- | :--- |
| app vs in-model max abs | ≤1e-5 | ~7e-10 |
| double vs correct max abs | ≥0.01 | ~0.99 |

## 4. 坑

- 入模路径输入名是 `raw_features`；Swift 用 model description 首输入名，勿写死 `features`。
- 重生 T15 会覆写 `activity_fp32.mlpackage`；须与 Case04 同 seed，必要时同步重生 `coreml_quant`。

## 5. 结论

**单源两种落地可对齐；双重 normalize 必须能被测试抓住。**

## 6. 面试卡片

- 预处理要么全在 App，要么全进模型。
- 我用同权双包 + 固定向量证明对齐。
- 负例：double scale 后 top 概率可翻到接近 1 的偏差量级。
