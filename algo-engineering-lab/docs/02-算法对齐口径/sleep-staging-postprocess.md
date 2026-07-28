# 对齐口径：睡眠分期后处理（Post-processing）

版本：0.1.0 · 日期：2026-07-28 · 作者：lab · 状态：草稿

## 原理

逐 epoch 分类输出噪声高，直接展示会产生不合理跳转。  
后处理通过转移约束与时长约束，得到更平滑且可解释的 hypnogram。

## 本 case 口径（待冻结）

- 输入：每 30s 的 stage 概率
- 方法：HMM/Viterbi 或规则引擎（最小时长 + 合法跳转）
- 输出：平滑 stage 序列 + 统计指标（TST、SOL 等）

## 中间快照

- `stage_prob_raw`
- `transition_cost`
- `stage_smoothed`

## 验收目标

- 抖动频率明显下降
- 核心统计指标波动收敛
