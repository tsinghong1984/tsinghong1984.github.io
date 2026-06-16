---
layout: post
title: "频率响应验证：超算符理论 vs BDF 全非线性仿真"
date: 2026-06-17
tags: [里德堡原子, RAOFDM]
---

# 频率响应验证：超算符理论 vs BDF 全非线性仿真

## 目的

验证线性化假设：在小信号驱动下（Ω_s = 1 kHz ≪ Ω_l = 1 MHz），全非线性 Bloch 方程的频率响应是否与线性化系统（超算符）的预测一致。

这是整个 OFDM 仿真链条的物理基础验证。

## 理论框架

### 物理系统

4 能级 Rydberg 原子：|1⟩ (基态), |2⟩ (6P₃/₂), |3⟩ (Rydberg 1), |4⟩ (Rydberg 2)。

| 参数 | 符号 | 值 |
|------|------|------|
| 探针 Rabi | Ω_p/2π | 6.0 MHz |
| 耦合 Rabi | Ω_c/2π | 3.0 MHz |
| LO Rabi | Ω_l/2π | 1.0 MHz |
| 信号 Rabi | Ω_s/2π | 1.0 kHz |
| 衰减率 | Γ₂/2π | 5.2 MHz |

微扰信号单频调制：Ω(t) = Ω_l + Ω_s·cos(δω·t)

### 两条路径

```
     方法 A: 线性化 (超算符)                方法 B: 全非线性 (BDF)
     ──────────────────────                ──────────────────────
  dρ/dt = -i[H₀+H₁, ρ] + D[ρ]          dρ/dt = -i[H(t), ρ] + D[ρ]
        ↓ 展开: ρ = ρ⁽⁰⁾ + δρ                 ↓ scipy solve_ivp(method='BDF')
  频域: (jδω·I − ℒ)·δr = b                     ↓ 时域 Im[ρ₂₁](t)
        ↓ numpy.linalg.solve                    ↓ FFT
  得到 δρ₂₁⁽¹⁾(δω)                           得到 Im[ρ₂₁] 复幅值
```

两种方法从**同一组 Bloch 方程**出发。方法 A 在频域线性化后用标准线性代数求解（无数值误差）。方法 B 求解全非线性方程后用 FFT 提取频域响应（验证线性化）。

### 关键：对比同一量

两种方法都输出 **Im[ρ₂₁(t)] 的 FFT 复幅值** ——记为 `C(δω)`。这是一个复数量：

$$C(\delta\omega) = \text{FFT}[\operatorname{Im}[\rho_{21}](t)] \big|_{f=\delta\omega}$$

包含幅值和相位两部分：

$$C(\delta\omega) = |C|\cdot e^{j\,\arg C}$$

**为什么对比 `Im[ρ₂₁]` 的 FFT 而不是 `ρ₂₁` 本身？** 因为实验中探测的是探针功率 P_out，它正比于 Im[ρ₂₁]。FFT 提取了时域谐波分量，直接对应于超外差接收机的中频输出。

### 理论 FFT 计算中两边带的处理

cos(δω·t) 驱动含正频和负频两边带。对正频边带：
$$r_{\text{pos}} = (j\delta\omega I - \mathcal{L})^{-1}\cdot \frac{\mathbf{b}}{2}$$

对负频边带：
$$r_{\text{neg}} = (-j\delta\omega I - \mathcal{L})^{-1}\cdot \frac{\mathbf{b}}{2}$$

两个边带的响应叠加得到 Im[ρ₂₁](t)，其 FFT 复幅值为：

$$C_{\text{th}} = (\operatorname{Im}[r_{\text{pos}}] + \operatorname{Im}[r_{\text{neg}}]) - j(\operatorname{Re}[r_{\text{pos}}] - \operatorname{Re}[r_{\text{neg}}])$$

其中 r_pos 和 r_neg 是 vec[δρ] 中对应 ρ₂₁ 的元素（索引 4）。

## 数值方法

### 方法 A: 超算符 (theory_fft_amplitude)

- 构建 16×16 Liouvillian ℒ（从附录 B Bloch 方程提取 Jacobian）
- 在正频和负频分别求解 (sI−ℒ)·r = b/2
- 代入上式得到 C_th
- 对 200 个对数间隔频率点采样 → 连续曲线

**复杂度**：每频点两次 16×16 矩阵求逆（O(16³)），200 点约 0.1 秒。

### 方法 B: BDF 全非线性仿真 (bdf_measure)

- 16 个实变量的全非线性 ODE 系统
- `scipy.integrate.solve_ivp`，方法 `BDF`（后向差分，专用于刚性系统）
- 仿真 12 个驱动周期（暂态衰减后），最后 3 周期做 FFT
- 容差：rtol=1e-8, atol=1e-12

**复杂度**：每频点约 1000-3000 次函数调用，8 点约 1 分钟。

### 为什么用 BDF 而非 QuTiP mesolve？

系统刚度比约 10³（Γ₂=5.2 MHz 对信号 1 kHz~5 MHz）。Adams 自适应步长（QuTiP 默认）在此类刚性问题上步长控制不稳定，产生误差。BDF 是专门设计的刚性求解器。

## 输出图说明

三幅子图共享 x 轴（对数频率 1 kHz~10 MHz），灰虚线标注 OFDM 子载波位置（200 kHz 间隔）。

### (a) 幅值 |C|（归一化）

- **蓝色曲线**：超算符预测
- **红色方块**：BDF 实测（8 个频点）
- **红色虚线**：-3 dB 参考线

期望：红色方块落在蓝色曲线上 → 幅值响应一致。

### (b) 实部/虚部 Re[C], Im[C]（归一化）

- **实线**：超算符预测
- **蓝色方块**：BDF 实测虚部
- **红色菱形**：BDF 实测实部

期望：蓝色方块/红色菱形落在对应曲线上 → Re/Im 分解一致。

### (c) 相位 arg[C]（unwrap）

- **蓝色曲线**：超算符预测
- **红色方块**：BDF 实测

相位已 unwrap（消除 ±180° 跳变），BDF 点自动对齐到最近理论值。

期望：红色方块落在蓝色曲线上 → 相位响应一致。

## 判定标准

| 指标 | 判定 | 含义 |
|------|------|------|
| 幅值 ratio 跨频恒定 (std/mean < 5%) | PASS | 理论幅值形状正确 |
| Re/Im BDF 点与理论曲线吻合 | PASS | 复数分解正确 |
| 相位差恒定 (std < 5°) | PASS | 理论相位响应正确 |
| 二次谐波 < 5% | PASS | 线性化成立 |

**三个子图同时 PASS → 超算符的线性化结果是全非线性系统的精确线性响应 → 基于超算符的 OFDM 仿真物理可靠。**

## 运行

```bash
cd simulation/
python plot_freq_response.py
```

输出：`../latex/.../frequency_response.png`（论文附录 B 用图）。
