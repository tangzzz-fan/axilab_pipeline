# 对齐口径：CoreML 预处理入模对照（App 侧 vs 图内 StandardScaler）

版本：0.1.0 · 日期：2026-07-29 · 作者：lab · 状态：生效

> Case13 / T15。零基础请先读 [`docs/09-CoreML入门/04-预处理单源与量化语义.md`](../09-CoreML入门/04-预处理单源与量化语义.md)。

---

## 1. 环节分解表

| 环节 | 参数 | 取值 | Python | iOS / CoreML |
| :--- | :--- | :--- | :--- | :--- |
| 权重 | — | 与 Case04 同 seed MLP | `generate_coreml_preprocess_inmodel.py` | 同权两包 |
| 路径 A | 输入 | **scaled** 8 维 | `activity_fp32.mlpackage` | App 显式 `(x-mean)/scale` |
| 路径 B | 输入 | **raw** 8 维 | `activity_fp32_with_preprocess.mlpackage` | 图内对角 linear 实现 scaler |
| 负例 | — | 对 raw **套两次** scaler 再喂路径 A | 期望与正确路径 max abs ≥ 0.01 | 同断言 |

---

## 2. 指标与阈值

| 指标 | 阈值 |
| :--- | :--- |
| 路径 A vs B 概率 max abs | ≤ **1e-5** |
| 双重 normalize vs 正确路径 max abs | ≥ **0.01**（必须显著偏离） |

---

## 3. 产物

| 产物 | 路径 |
| :--- | :--- |
| App 侧模型 | `artifacts/coreml/activity_fp32.mlpackage` |
| 入模预处理模型 | `artifacts/coreml/activity_fp32_with_preprocess.mlpackage` |
| 报告 | `golden/coreml_preprocess_inmodel/compare_report.json` |

重跑：`uv run python -m python.generate_golden coreml_preprocess_inmodel`

---

## 4. 面试金句

> 预处理单源有两种合法落地：全在 App，或全烘进模型。事故形态是各做一半或双重 normalize——本 lab 用负例测试把它钉死。
