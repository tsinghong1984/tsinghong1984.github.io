---
layout: post
title: "附录 B 详解：原子接收机频率响应 H(δω)"
date: 2026-06-17
tags: [里德堡原子, RAOFDM]
---

# 附录 B 详解：原子接收机频率响应 H(δω)

## 推导链概览

```
Lindblad 主方程 → 16 实变量 Bloch 方程 → 零阶稳态 (Ω_s=0)
→ 一阶线性化 (Liouvillian 超算符) → 解 16×16 复线性系统 → H(δω) = 2ρ₂₁^(1)/Ω_s
```

---

## 1. Lindblad 主方程

四能级系统 {|1⟩, |2⟩, |3⟩, |4⟩}，共振条件（Δ_p = Δ_c = Δ_RF = 0），忽略 Rydberg 态衰减（Γ₃ ≈ Γ₄ ≈ 0），采用角频率约定（ħ=1）：

$$\frac{d\rho}{dt} = -j[H_0, \rho] + \mathcal{D}[\rho]$$

**哈密顿量 H₀**（矩阵形式，Ω 为 Rabi 频率）：

$$H_0 = \begin{pmatrix}
0 & \Omega_p/2 & 0 & 0 \\
\Omega_p/2 & 0 & \Omega_c/2 & 0 \\
0 & \Omega_c/2 & 0 & \Omega_l/2 \\
0 & 0 & \Omega_l/2 & 0
\end{pmatrix}$$

**耗散子 D[ρ]**（仅 |2⟩→|1⟩ 通道）：

$$\mathcal{D}[\rho] = \Gamma_2\begin{pmatrix}
\rho_{22} & -\rho_{12}/2 & 0 & 0 \\
-\rho_{21}/2 & -\rho_{22} & -\rho_{23}/2 & -\rho_{24}/2 \\
0 & -\rho_{32}/2 & 0 & 0 \\
0 & -\rho_{42}/2 & 0 & 0
\end{pmatrix}$$

**物理参数**：

| 参数 | 值 (/2π) | 含义 |
|------|---------|------|
| Ω_p | 6.0 MHz | 探针 Rabi 频率 (σ⁺, 852 nm) |
| Ω_c | 3.0 MHz | 耦合 Rabi 频率 (σ⁺, 510 nm) |
| Ω_l | 1.0 MHz | LO 微波 Rabi 频率 (σ⁻) |
| Γ₂ | 5.2 MHz | |2⟩→|1⟩ 衰减率 |
| Ω_s | 1.0 kHz | 信号微波微扰 Rabi 频率 |

---

## 2. 密度矩阵 → 16 实变量

4×4 厄米矩阵 ⇒ 16 个独立实变量：

| 变量 | 密度矩阵元素 | 类型 |
|------|-------------|------|
| x₁, x₂, x₃, x₄ | ρ₁₁, ρ₂₂, ρ₃₃, ρ₄₄ | 布居数（实） |
| (x₅, x₆) | (Re ρ₁₂, Im ρ₁₂) | 探针相干 |
| (x₇, x₈) | (Re ρ₁₃, Im ρ₁₃) | 基态-Rydberg1 相干 |
| (x₉, x₁₀) | (Re ρ₁₄, Im ρ₁₄) | 基态-Rydberg2 相干 |
| (x₁₁, x₁₂) | (Re ρ₂₃, Im ρ₂₃) | 中间态-Rydberg1 相干 |
| (x₁₃, x₁₄) | (Re ρ₂₄, Im ρ₂₄) | 中间态-Rydberg2 相干 |
| (x₁₅, x₁₆) | (Re ρ₃₄, Im ρ₃₄) | Rydberg 微波相干 |

> 下三角由厄米性确定：ρ_ji = ρ_ij*，即 Re(ρ_ji) = Re(ρ_ij)、Im(ρ_ji) = −Im(ρ_ij)。

---

## 3. 16 实变量 Bloch 方程

将主方程展开为实部和虚部，得 16 耦合 ODE：

**布居数（角线）：**

$$\begin{aligned}
\dot{x}_1 &= \Omega_p x_6 + \Gamma_2 x_2, \\
\dot{x}_2 &= -\Omega_p x_6 + \Omega_c x_{12} - \Gamma_2 x_2, \\
\dot{x}_3 &= -\Omega_c x_{12} + \Omega_l x_{16}, \\
\dot{x}_4 &= -\Omega_l x_{16}.
\end{aligned}$$

> 物理解读：各布居数的变化来自 Rabi 振荡耦合（Ω·x 项）和自发辐射重布居（Γ₂ 项）。粒子在四个能级间循环流动。

**相干项 x₅–x₁₀（涉及 |1⟩ 的相干）：**

$$\begin{aligned}
\dot{x}_5 &= \tfrac{\Omega_p}{2}(x_2-x_1) - \tfrac{\Omega_c}{2}x_8 - \tfrac{\Gamma_2}{2}x_5, \\
\dot{x}_6 &= -\tfrac{\Omega_p}{2}x_5 + \tfrac{\Omega_c}{2}x_7 - \tfrac{\Gamma_2}{2}x_6, \\
\dot{x}_7 &= -\tfrac{\Omega_p}{2}x_{12} + \tfrac{\Omega_c}{2}x_6 - \tfrac{\Omega_l}{2}x_{10}, \\
\dot{x}_8 &= \tfrac{\Omega_p}{2}x_{11} - \tfrac{\Omega_c}{2}x_5 + \tfrac{\Omega_l}{2}x_9, \\
\dot{x}_9 &= -\tfrac{\Omega_p}{2}x_{14} + \tfrac{\Omega_l}{2}x_8, \\
\dot{x}_{10} &= \tfrac{\Omega_p}{2}x_{13} - \tfrac{\Omega_l}{2}x_7.
\end{aligned}$$

**相干项 x₁₁–x₁₄（涉及 |2⟩ 的微波边相干）：**

$$\begin{aligned}
\dot{x}_{11} &= \tfrac{\Omega_c}{2}(x_3-x_2) + \tfrac{\Omega_p}{2}x_8 - \tfrac{\Omega_l}{2}x_{14} - \tfrac{\Gamma_2}{2}x_{11}, \\
\dot{x}_{12} &= -\tfrac{\Omega_c}{2}(x_3-x_2) - \tfrac{\Omega_p}{2}x_7 + \tfrac{\Omega_l}{2}x_{13} - \tfrac{\Gamma_2}{2}x_{12}, \\
\dot{x}_{13} &= -\tfrac{\Omega_c}{2}x_{16} + \tfrac{\Omega_p}{2}x_{10} - \tfrac{\Omega_l}{2}x_{12} - \tfrac{\Gamma_2}{2}x_{13}, \\
\dot{x}_{14} &= \tfrac{\Omega_c}{2}x_{15} - \tfrac{\Omega_p}{2}x_9 + \tfrac{\Omega_l}{2}x_{11} - \tfrac{\Gamma_2}{2}x_{14}.
\end{aligned}$$

**相干项 x₁₅–x₁₆（Rydberg 微波相干）：**

$$\begin{aligned}
\dot{x}_{15} &= -\tfrac{\Omega_l}{2}(x_4-x_3) + \tfrac{\Omega_c}{2}x_{14}, \\
\dot{x}_{16} &= \tfrac{\Omega_l}{2}(x_4-x_3) - \tfrac{\Omega_c}{2}x_{13}.
\end{aligned}$$

---

## 4. 零阶稳态解（Ω_s = 0）

令 ẋ = 0，加上迹约束 Tr(ρ) = 1，解出所有非零稳态密度矩阵元。定义分母：

$$D_l = 2\Omega_p^2(\Omega_c^2+\Omega_p^2) + (\Gamma_2^2+2\Omega_p^2)\Omega_l^2$$

稳态解：

$$
\rho_{11}^{(0)} = \frac{\Gamma_2^2\Omega_l^2 + \Omega_p^2(\Omega_l^2+\Omega_c^2)}{D_l}, \quad
\rho_{22}^{(0)} = \frac{\Omega_l^2\Omega_p^2}{D_l},
$$
$$
\rho_{33}^{(0)} = \frac{\Omega_p^4}{D_l}, \quad
\rho_{44}^{(0)} = \frac{\Omega_p^2(\Omega_c^2+\Omega_p^2)}{D_l},
$$
$$
\rho_{13}^{(0)} = -\frac{\Omega_c\Omega_p^3}{D_l}, \quad
\rho_{14}^{(0)} = -j\frac{\Gamma_2\Omega_l\Omega_c\Omega_p}{D_l}, \quad
\rho_{24}^{(0)} = -\frac{\Omega_l\Omega_c\Omega_p^2}{D_l},
$$
$$
\rho_{12}^{(0)} = \rho_{23}^{(0)} = \rho_{34}^{(0)} = 0.
$$

**关键特征**：无信号微扰时，相邻能级间相干为零（ρ₁₂ = ρ₂₃ = ρ₃₄ = 0），因此 H(δω) 全由一阶微扰贡献。

---

## 5. 一阶线性化（Liouvillian 超算符）

### 5.1 微扰源项

加入小信号 H₁ = (Ω_s/2)(|3⟩⟨4| + h.c.)，Ω_s ≪ Ω_l。对 Bloch 方程做一阶展开 x = x^(0) + δx：

$$\dot{\delta\mathbf{x}} = \mathcal{L}\,\delta\mathbf{x} + \mathbf{b}(t)$$

其中：
- **L**（16×16 Jacobian）：$\mathcal{L}_{kl} = \partial\dot{x}_k/\partial x_l|_{x^{(0)}}$，即 16 个 ODE 对 16 个变量的一阶导数矩阵
- **b(t)**（源项向量）：由 H₁ 与 ρ^(0) 的对易子产生，驱动一阶扰动

源项的物理来源——H₁ 作用于零阶 ρ 产生推动力：

$$-j[H_1, \rho^{(0)}]_{34} = -j\frac{\Omega_s}{2}(\rho_{44}^{(0)}-\rho_{33}^{(0)})$$

这对应于 b 向量的第 15、16 分量（ρ₃₄ 的实部和虚部源），其余分量为零。

### 5.2 频域求解

Fourier 变换后（∂/∂t → jδω）：

$$(j\delta\omega\,I_{16} - \mathcal{L})\,\delta\mathbf{r} = \mathbf{b}$$

对每个 δω，这是 16×16 复线性系统。式中：
- **I₁₆**：16×16 单位矩阵
- **δr**：δx 的频域表示
- **δω**：信号相对于 LO 的频率偏移
- **b**：源项的 Fourier 变换（频域常数向量）

直接数值求解：

$$\delta\mathbf{r} = (j\delta\omega\,I_{16} - \mathcal{L})^{-1}\,\mathbf{b}$$

---

## 6. 频率响应 H(δω) 提取

从 δr 中提取探针相干项（第 5、6 分量）：

$$\rho_{21}^{(1)} = \delta x_5 - j\delta x_6$$

归一化为频率响应：

$$\boxed{H(\delta\omega) \triangleq \frac{2\,\rho_{21}^{(1)}(\delta\omega)}{\Omega_s}}$$

> 因子 2 来自 ρ₂₁^(1) / (Ω_s/2) 的归一化——哈密顿量以 Ω_s/2 耦合 ρ₃₄，密度矩阵响应需标定回单位 Rabi 频率。

最终探针功率 AC 响应（可观测量）：

$$\delta P_{\text{out}}(t) = -P_{\text{out}}^{(0)} k_p L C\,|H(\delta\omega)|\,\Omega_s\cos(\delta\omega t + \delta\phi + H_\phi(\delta\omega))$$

其中 k_p = 2π/λ_p 为探针波数，L 为气室长度，C 为原子常数，H_ϕ = arg H。

---

## 7. DC 极限（解析验证）

在 δω = 0 处，系统退化，可解析求解 ρ₂₁^(1)：

$$\boxed{\mathrm{Im}[H(0)] = -\frac{4\Gamma_2\Omega_l\Omega_p^3(\Omega_c^2+\Omega_p^2)}{D_l^2}}$$

代入选定参数得 **|H(0)| ≈ 5.77 × 10⁻⁹**，与数值解一致（`h_superop.py` 返回 5.7721×10⁻⁹），且与 Jing et al. (2020) 的超外差 DC 结果一致。

---

## 8. BDF 全非线性验证

用刚性 BDF 积分器（scipy solve_ivp, rtol=1e-8）直接求解 16 个全非线性 Bloch 方程：

$$\Omega(t) = \Omega_l + \Omega_s\cos(\delta\omega t)$$

与线性预测 H(δω) 对比：

| δω/2π | 幅值比 (BDF/线性) | 相位差 | 二次谐波占比 |
|--------|:---:|:---:|:---:|
| 50 kHz | 0.998 | < 0.3° | < 1% |
| 200 kHz | 1.001 | < 0.8° | < 2% |
| 400 kHz | 0.996 | < 1.5° | < 3% |
| 800 kHz | 0.993 | < 3° | < 5% |

**结论**：线性化误差 < 1%，二次谐波 < 5%，频谱在 Ω_s = 2π×1 kHz 处严格落在线性区间。

---

## 9. 频率响应关键指标

| 指标 | 值 |
|------|-----|
| \|H(0)\| | 5.77 × 10⁻⁹ |
| −3 dB 带宽 | ≈ 500 kHz |
| 距 1 子载波 (200 kHz) | −0.6 dB |
| 距 2 子载波 (400 kHz) | −2.5 dB |
| 距 4 子载波 (800 kHz) | −8.9 dB |

> −3 dB 带宽仅覆盖 ~3 个子载波——这是本文需要 N>1 接收机阵列的根本原因。

---

## 10. 与代码的对应

| 步骤 | h_superop.py |
|------|-------------|
| 主方程 → 16 ODE | `build_bloch_rhs(x)` |
| 稳态求解 | `compute_steady_state()` |
| Jacobian L | `build_jacobian(x0)` |
| 源项 b | `build_source_term(rho0)` |
| 频域求解 | `H_dw_superop(dw)` → `np.linalg.solve` |
| H 提取 | `rho21 = x[5] - 1j*x[6]` → `H = 2*rho21/Om_s` |
| F 矩阵预计算 | `get_F_matrix(N_sc, df)` |
| BDF 验证 | `verify_multi_tone.py` → `scipy.integrate.solve_ivp` |
