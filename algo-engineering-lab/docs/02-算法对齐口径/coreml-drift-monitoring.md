# 对齐口径：CoreML 在线漂移监控

版本：0.1.0 · 日期：2026-07-28 · 作者：lab · 状态：生效

## 原理

模型精度退化常由输入分布漂移触发。  
用统计距离（如 PSI、KL）监控线上输入与训练分布差异，触发预警与回滚策略。

## 指标

- 特征分布漂移：逐特征 `PSI`（10 bins）
- 置信度分布漂移：`KL(conf_current || conf_ref)`
- 聚合指标：`max_psi`

## 告警策略

- `low`：`max_psi < 0.10` 且 `kl_confidence < 0.08`
- `medium`：`max_psi >= 0.10` 或 `kl_confidence >= 0.08`
- `high`：`max_psi >= 0.25` 或 `kl_confidence >= 0.20`

## 集成约定

- 若 `artifacts/coreml/activity_fp32.mlpackage` 或 `golden/coreml_quant/compare_report.json` 缺失，
  T11 脚本会先调用 T5 Python 链路重生模型与预处理参数，再执行漂移评估。
- 监控评估输入使用与 T5 同维度特征并套用同一 `StandardScaler` 参数（单源预处理）。

## 验收目标

- 正常样本不过度告警
- 合成漂移样本稳定触发告警
- 漂移场景指标显著大于稳定场景
