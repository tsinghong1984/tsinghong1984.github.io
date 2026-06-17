---
layout: post
title: "原子 OFDM 接收机噪声模型详细分析与推导（含 1/f 噪声）"
date: 2026-06-17
tags: [里德堡原子, RAOFDM]
---

# 原子 OFDM 接收机噪声模型详细分析与推导（含 1/f 噪声）

> 对应论文：Section III-B, bare_jrnl.tex

---

## 1. 现有噪声模型回顾

当前模型三个分量均为**白噪声**（平坦 PSD）：

$$\sigma^2 = \sigma_{\text{QPN}}^2 + \sigma_{\text{PSN}}^2 + \sigma_E^2$$

| 分量 | 公式 | 域 |
|------|------|-----|
| QPN | $\sigma_{\text{QPN}}^2 = \dfrac{4\pi^2}{T \cdot T_r \cdot N_a}$ | FFT bin (等效 Rabi 频率) |
| PSN | $\sigma_{\text{PSN}}^2 = \dfrac{2q P_0 \Delta f}{\alpha G} \cdot \dfrac{1}{\kappa_{i,n}^2}$ | FFT bin (等效 Rabi 频率) |
| 外部 | $\sigma_E^2$（预设参数） | FFT bin |

---

## 2. 量子投影噪声 (QPN) 的物理推导

### 2.1 物理源头

里德堡接收机对原子相干态的探针光读出是**投影量子测量**。密度矩阵 $\rho_{21}$ 的每次测量将波函数坍缩，引入量子涨落。这个涨落在时域是白噪声，其方差源自原子态的量子力学不确定关系。

### 2.2 时域方差

单次投影测量的等效 Rabi 频率方差（Gong et al. [ref3] 的结果）：

$$\sigma_{\text{QPN, time}}^2 = \frac{4\pi^2}{T_r \cdot N_a} \cdot \frac{1}{\Delta t}$$

其中：
- $T_r$：里德堡态 $|3\rangle$ 的相干弛豫时间（$\sim 1$ μs）——原子"记住"相位的时间
- $N_a$：相互作用体积内有效原子数（$\sim 10^5$–$10^6$）——独立传感器的数量
- $\Delta t$：单次测量的采样间隔

物理直觉：$N_a$ 个独立原子相当于 $N_a$ 次独立测量，量子噪声按 $\sqrt{N_a}$ 降低，方差按 $1/N_a$ 降低。

### 2.3 FFT 域转换（关键步骤）

**FFT 特性**：$N$ 点 FFT → 每个 bin 是全部 $N$ 个样本的相干叠加 → 等效积分时间 $T = N \cdot \Delta t$。

代入 $\Delta t = T/N$，且 FFT 归一化 $1/N$：

$$\sigma_{\text{QPN}}^2 = \frac{1}{N} \cdot \frac{4\pi^2}{T_r \cdot N_a} \cdot \frac{1}{T/N} = \frac{1}{N} \cdot \frac{4\pi^2}{T_r N_a} \cdot \frac{N}{T} = \boxed{\frac{4\pi^2}{T \cdot T_r \cdot N_a}}$$

**关键结论**：$N$ 恰好消去——FFT 的 $1/N$ 归一化与 $N$ 个样本的积分效应相消，所以最终结果仅依赖等效积分时间 $T$（OFDM 符号长度），与 FFT 点数无关。

### 2.4 数值验证

$$T = \frac{1}{\Delta f} = \frac{1}{200 \times 10^3} = 5\ \mu\text{s}, \quad T_r \sim 1\ \mu\text{s}, \quad N_a \sim 5\times 10^5$$

$$\sigma_{\text{QPN}}^2 = \frac{4\pi^2}{5\cdot 10^{-6} \cdot 1\cdot 10^{-6} \cdot 5\cdot 10^5} \approx \frac{39.5}{2.5} \times 10^6 \approx 1.6 \times 10^7\ \text{rad}^2/\text{s}^2$$

$$\sigma_{\text{QPN}} \approx 4000\ \text{rad/s} = 2\pi \times 640\ \text{Hz}$$

信号 Rabi 频率 $\Omega_s \sim 2\pi \times 1$ kHz，单 bin 信噪比约 4 dB；16 接收机 MRC 后约 16 dB。与仿真结果定性一致。

---

## 3. 光子散粒噪声 (PSN) 的物理推导

### 3.1 物理源头

平衡光电探测器（APD）上的直流探针功率 $P_0$ → 直流光电流 $I_0 = \alpha G P_0$。每个光子的到达是泊松过程 → 光电流存在散粒噪声，**单边**功率谱密度：

$$S_I(f) = 2q I_0 \quad [\text{A}^2/\text{Hz}]$$

其中 $q = 1.602 \times 10^{-19}$ C 是基本电荷。

### 3.2 频域推导链

$$I_0 = \alpha G P_0 \quad \xrightarrow{\text{散粒噪声}} \quad S_I = 2q \alpha G P_0$$

单子载波带宽 $B = \Delta f$（注：OFDM 每个 FFT bin 等效带宽 = 子载波间隔）：

$$\sigma_I^2 = S_I \cdot \Delta f = 2q \alpha G P_0 \Delta f \quad [\text{A}^2]$$

转换为探测光功率域（除以 $(\alpha G)^2$）：

$$\sigma_P^2 = \frac{2q P_0 \Delta f}{\alpha G} \quad [\text{W}^2]$$

转换为等效 Rabi 频率域：探测光功率变化 $\delta P$ 与 Rabi 频率 $\Omega_s$ 的关系是 $\delta P = \kappa \Omega_s$（$\kappa$ 是 EIT 斜率）。所以：

$$\sigma_{\text{PSN}}^2 = \frac{\sigma_P^2}{\kappa^2} = \boxed{\frac{2q P_0 \Delta f}{\alpha G} \cdot \frac{1}{\kappa_{i,n}^2}} \quad [\text{rad}^2/\text{s}^2]$$

### 3.3 信号处理链中的处理

$F_{i,n} \propto \kappa_{i,n}$（因式分解模型），所以在 $r_{i,k,n} = F_{i,n} G_i s_{k,n} + w_{i,k,n}$ 中，$\sigma_{\text{PSN}}^2$ 经 $F_{i,n}$ 传播后变为与 $\kappa$ 无关的常数——这就是论文中"PSN 贡献可视为常数"的含义。

### 3.4 数值验证

$$P_0 = 10\ \mu\text{W},\ \alpha = 0.6\ \text{A/W},\ G = 30\ \text{dB} = 1000,\ \Delta f = 200\ \text{kHz},\ \kappa \sim 10^{-8}$$

$$\sigma_{\text{PSN}}^2 = \frac{2 \cdot 1.6\times 10^{-19} \cdot 10^{-5} \cdot 2\times 10^5}{0.6 \cdot 1000} \cdot \frac{1}{(10^{-8})^2} \approx \frac{6.4\times 10^{-19}}{600} \cdot 10^{16} \approx 1.1\times 10^7\ \text{rad}^2/\text{s}^2$$

**结论**：$\sigma_{\text{PSN}}^2 \approx 1.1\times 10^7$，与 $\sigma_{\text{QPN}}^2 \approx 1.6\times 10^7$ 同量级——两者物理来源不同但贡献可比。

---

## 4. 1/f 噪声（新增分析）

### 4.1 物理来源

里德堡原子接收机中 1/f 噪声至少有三个独立来源：

| 来源 | 物理机制 | 典型拐角频率 $f_c$ | 影响 |
|------|---------|-------------------|------|
| **激光强度噪声** | 探针/耦合激光的功率涨落，半导体激光器本征 | 1–10 kHz（稳频后） | 通过 EIT 斜率 $|\kappa|$ 转化 |
| **电子 1/f 噪声** | 跨阻放大器（TIA）输入 MOSFET 的闪烁噪声 | 10–100 Hz | 叠加在光电流上 |
| **原子低频漂移** | 气室温度涨落、杂散磁场漂移 | < 0.1 Hz | 极低频，OFDM 符号内可视为静态偏置 |

### 4.2 数学模型

通用 1/f 噪声双边功率谱密度（PSD）：

$$S_{1/f}(f) = \frac{A}{|f|^\alpha}, \quad \alpha \approx 0.8 \sim 1.2$$

工程上常用**拐角频率模型**（物理意义更清晰）：

$$S_{1/f}(f) = S_0 \left(1 + \frac{f_c}{|f|}\right)$$

其中 $S_0$ 为白噪声平台 PSD，$f_c$ 为 1/f 噪声拐角频率（白噪声 = 1/f 噪声的交点）。

### 4.3 对 OFDM 各子载波的影响

FFT 第 $m$ 个 bin（中心频率 $f_m = m \cdot \Delta f$，$m = 0,1,\dots,N-1$）的噪声方差为 PSD 在 $[f_m - \Delta f/2,\ f_m + \Delta f/2]$ 上的积分。

对于 DC bin ($m=0$)：理论 1/f PSD 在 $f \to 0$ 发散 → 实际中由最低有效频率截断 $f_{\min} = 1/T_{\text{obs}}$（观测时长的倒数）。

#### 情形 1：白噪声平台 + 1/f（拐角频率模型）

$$\sigma^2(m) = \sigma_{\text{white}}^2 + \sigma_{\text{white}}^2 \cdot f_c \int_{f_m-\Delta f/2}^{f_m+\Delta f/2} \frac{df}{f}$$

对 $m \ge 1$：

$$\sigma^2(m) = \sigma_{\text{white}}^2 \left[1 + \frac{f_c}{\Delta f} \ln\left(\frac{m+1/2}{m-1/2}\right)\right]$$

对 $m = 0$（DC bin，低频截断至 $f_{\min}$）：

$$\sigma^2(0) = \sigma_{\text{white}}^2 \left[1 + \frac{f_c}{\Delta f} \ln\left(\frac{\Delta f/2}{f_{\min}}\right)\right]$$

#### 简化近似（$m$ 较大时）

当 $m \ge 2$ 时，$\ln((m+1/2)/(m-1/2)) \approx 1/m$：

$$\sigma^2(m) \approx \sigma_{\text{white}}^2 \left(1 + \frac{f_c}{m \cdot \Delta f}\right) = \sigma_{\text{white}}^2 \left(1 + \frac{f_c}{f_m}\right)$$

### 4.4 对系统的实际影响

| 子载波索引 m | $f_m$ (Δf=200 kHz) | 1/f 超标比 ($f_c=1$ kHz) | 超标比 ($f_c=10$ kHz) |
|:---:|:---:|:---:|:---:|
| 0 (DC) | 0 | $\frac{1000}{200}\ln(\frac{100\text{ kHz}}{f_{\min}})$ → 大 | 更大 |
| 1 | 200 kHz | 1 + 1000/200 ≈ **6.0** | 1 + 10000/200 ≈ **51** |
| 2 | 400 kHz | 1 + 1000/400 ≈ **3.5** | 1 + 10000/400 ≈ **26** |
| 4 | 800 kHz | 1 + 1000/800 ≈ **2.25** | 1 + 10000/800 ≈ **13.5** |
| 8 | 1.6 MHz | 1 + 1000/1600 ≈ **1.6** | 1 + 10000/1600 ≈ **7.25** |
| 16 | 3.2 MHz | 1 + 1000/3200 ≈ **1.3** | 1 + 10000/3200 ≈ **4.1** |

**关键发现**：

1. 若 $f_c \approx 1$ kHz（激光稳频后典型值），低频 $2\sim 3$ 个子载波受显著影响（超标 3–6×）
2. 若 $f_c \approx 10$ kHz（未稳频或宽线宽激光），前 $\sim 10$ 个子载波严重劣化
3. DC bin ($m=0$) 总是严重受扰，但 OFDM 的 DC 子载波通常不用——**恰好避开**
4. 高于 $f_c$ 的子载波（$m > f_c/\Delta f$）几乎不受 1/f 影响

### 4.5 论文中如何加入 1/f 噪声

#### 方案 A：扩展总噪声公式（推荐）

将式 (26) 改为：

$$\sigma^2(m) = \sigma_{\text{QPN}}^2 + \sigma_{\text{PSN}}^2 + \sigma_E^2 + \sigma_{1/f}^2(m)$$

其中：

$$\sigma_{1/f}^2(m) = \sigma_0^2 \cdot \frac{f_c}{f_m}, \quad f_m = m \Delta f \quad (m \ge 1)$$

$\sigma_0^2$ 为白噪声基准（可取 $\sigma_{\text{QPN}}^2 + \sigma_{\text{PSN}}^2$ 为参考），$f_c$ 为 1/f 拐角频率。

对 DC bin ($m=0$)，直接用有限值 $\sigma_{1/f}^2(0) = \sigma_0^2 \cdot f_c / f_{\min}$，或用 OFDM 惯例直接不做数据映射。

#### 方案 B：归入 $\sigma_E^2$（不推荐，丢失频选性）

简单但不严谨——抹平了 1/f 噪声最重要的特征（**频率选择性**），对 IBTR 和 EAG 指标的设计失去指导意义。

#### 方案 C：不影响论文主线，在 Discussion 中定性讨论（折中）

在 Section V（讨论）中加入一段：

> Low-frequency intensity noise of the probe and coupling lasers introduces a 1/f component with a corner frequency $f_c$ typically in the 1--10 kHz range. For subcarrier $m$ at frequency $f_m=m\Delta f$, the excess noise variance is approximately $\sigma_0^2 \cdot f_c/f_m$, where $\sigma_0^2$ is the white-noise floor. Consequently, the first one or two OFDM subcarriers may experience a 3--6 dB SNR penalty relative to higher subcarriers, depending on the laser noise characteristics. Since OFDM systems conventionally avoid the DC subcarrier, and the 1/f excess rolls off as $1/m$, the net impact on overall BER performance is limited. For lasers with poor amplitude stability ($f_c>10$ kHz), active intensity stabilization is recommended to keep $f_c$ below 1 kHz, which confines the 1/f excess to within 1 dB at subcarrier index $m\ge 5$.

---

## 5. 综合噪声预算表

代入 $\Delta f = 200$ kHz，$T = 5$ μs，$T_r = 1$ μs，$N_a = 5\times 10^5$：

| 噪声分量 | 方差 (rad²/s²) | 等效标准差 Hz | 备注 |
|----------|:---:|:---:|------|
| $\sigma_{\text{QPN}}^2$ | $1.6\times 10^7$ | 636 Hz | 原子投影测量极限 |
| $\sigma_{\text{PSN}}^2$ | $1.1\times 10^7$ | 528 Hz | APD 光电流散粒噪声 |
| $\sigma_E^2$ | 可调 | — | 外部电磁环境 |
| 白噪声合计 (无外部) | $2.7\times 10^7$ | 827 Hz | — |
| **1/f ($f_c=1$ kHz, $m=1$)** | **+ $1.35\times 10^8$** | **+ 5.0 kHz** | **低频子载波严重劣化** |
| **1/f ($f_c=1$ kHz, $m=8$)** | **+ $3.4\times 10^6$** | **+ 293 Hz** | **高频子载波基本无影响** |

**结论**：1/f 噪声对 OFDM 系统最重要的影响是**子载波间 SNR 不均**——这是白噪声模型完全无法捕捉的效应。对 IBTR/EAG 设计有直接指导意义：低频子载波应优先部署更多接收机补偿 1/f 劣化。

---

## 6. 各噪声项独立性的论证

论文声称 $w_{i,k,n} \sim \mathcal{CN}(0,\sigma^2)$ 跨 $i,k,n$ 独立，其物理依据：

| 维度 | QPN | PSN | 1/f | 外部 |
|------|-----|-----|-----|------|
| **跨接收机 $i$** | ✅ 独立（独立光电探测链路） | ✅ 独立（独立 APD） | ✅ 独立（独立激光分束） | $\approx$ 独立（空间分离） |
| **跨符号 $k$** | ✅ 独立（白噪声） | ✅ 独立（白噪声） | ⚠️ **相关**（1/f = 长程记忆） | 视情况 |
| **跨子载波 $n$** | ✅ 独立（白噪声 + FFT 正交） | ✅ 独立 | ⚠️ 功率不同（频选）但独立 | 视情况 |

⚠️ **关键警告**：1/f 噪声打破"跨符号独立性"假设——相邻 OFDM 符号的 1/f 噪声是相关的。对导频信道估计的影响：
- 短块（少量符号）：1/f 近似为固定偏置 → LS 估计仍有效
- 长块（大量符号）：1/f 的低频漂移需差分导频追踪

对本文 $K=1000$ 符号（$=5$ ms 总时长），1/f 噪声的自相关时间 $\sim 1/f_c \approx 0.1$–$1$ ms——**不可完全忽略**，好在本文的因子化估计利用了所有子载波的导频平均，对每个 $G_i$ 的静态偏置有一定抵消效果。

---

## 7. 建议写入论文的内容

### 7.1 在 Section III-B 尾部加入

```latex
\emph{1/f noise.} In addition to the white noise components, the probe 
and coupling lasers exhibit intensity noise with a $1/f$ power spectral 
density, characterized by a corner frequency $f_c$ (typically 
$1$--$10$~kHz for intensity-stabilized diode lasers). After FFT 
demodulation, the $1/f$ noise variance at subcarrier $m$ ($m\ge 1$) is

\begin{equation}
\sigma_{1/f}^{2}(m) = \sigma_{0}^{2}\cdot\frac{f_c}{f_m},
\quad f_m = m\Delta f,
\label{eq:one_over_f}
\end{equation}

where $\sigma_{0}^{2} = \sigma_{\mathrm{QPN}}^{2} + 
\sigma_{\mathrm{PSN}}^{2}$ is the white-noise floor. Eq.~\eqref{eq:one_over_f} 
follows from integrating $S_{1/f}(f) = S_0(1 + f_c/|f|)$ over the 
$m$-th FFT bin bandwidth. The DC subcarrier ($m=0$) is not used for 
data in standard OFDM, so its higher $1/f$ excess is inconsequential.

For $f_c \le 1$~kHz and $\Delta f = 200$~kHz, the $1/f$ excess at 
$m\ge 5$ is below $1$~dB and the white-noise approximation remains 
valid for most subcarriers. The total per-bin variance is 

\begin{equation}
\sigma^{2}(m) = \sigma_{\mathrm{QPN}}^{2} + \sigma_{\mathrm{PSN}}^{2} 
+ \sigma_{E}^{2} + \sigma_{1/f}^{2}(m).
\label{eq:total_noise_with_1f}
\end{equation}
```

### 7.2 在 Section V (Discussion) 中补充

可以简要讨论 1/f 噪声对子载波间 SNR 不均匀性的影响，以及如何通过 IBTR/EAG 设计方法（在低频子载波上配置更多接收机）来补偿。

---

## 8. 参考文献

- Gong et al. [ref3]：QPN 公式的原始来源
- Wang et al. [ref8] (MC-RAQR)：光子散粒噪声在 Rydberg 接收机中的显式处理
- Fancher et al. [ref7]：Rydberg 接收机作为电场传感器，讨论了激光噪声的影响
- 标准 1/f 噪声理论：Hooge's law, Keshner 1982 "1/f noise", IEEE Proc.
