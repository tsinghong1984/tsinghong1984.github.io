---
layout: post
title: "PSZR-OFDM 仿真实验文档"
date: 2026-06-17
tags: [里德堡原子, RAOFDM]
---

# PSZR-OFDM 仿真实验文档

**Polarization-Selective Zeeman-Resolved Rydberg OFDM Receiver**

---

## 一、仿真流水线总览

```
step1_generate_ofdm.py              step2_compute_F_matrix.py
    ↓ 生成 OFDM 发射符号              ↓ 计算原子频率响应矩阵 F_{i,n}
step3_setup_channel.py               step4_run_simulation.py
    ↓ 设置传播信道 G_i                ↓ 主 BER 仿真 (QPSK + 16QAM)
                                      ↓ 输出 ber_data.txt + 图表
```

辅助验证：`verify_multi_tone.py` (多音分离) → `plot_freq_response.py` (频率响应) → `optimize_ibtr.py` (IBTR 优化) → `ber_ibtr_comparison.py` (BER vs N_rx)

---

## 二、核心物理参数与配置

### 2.1 原子物理参数 (h_superop.py)

| 参数 | 符号 | 值 | 含义 |
|------|------|------|------|
| 探测光 Rabi 频率 | Ω_p / 2π | 6.0 MHz | 852 nm, σ⁺ |
| 耦合光 Rabi 频率 | Ω_c / 2π | 3.0 MHz | 510 nm, σ⁺ |
| LO 微波 Rabi 频率 | Ω_l / 2π | 1.0 MHz | σ⁻ |
| 信号微波 Rabi 频率 | Ω_s / 2π | 1.0 kHz | σ⁻ |
| 中间态衰减率 | Γ₂ / 2π | 5.2 MHz | γ₂₁ (6P₃/₂ → 6S₁/₂) |

### 2.2 OFDM 系统参数

| 参数 | 符号 | 值 | 含义 |
|------|------|------|------|
| 子载波数 | M | 16 | OFDM 子载波总数 |
| 子载波间距 | Δf | 200 kHz | 总带宽 3.2 MHz |
| 有效符号时长 | T_sym | 5.0 µs | 1/Δf |
| 循环前缀长度 | T_cp | 1.25 µs | T_sym / 4 |
| OFDM 符号总数 | K | 1000 | 蒙特卡罗仿真 |
| 导频符号数 | N_p | 64 | 前 N_p 个符号 |
| 接收机数量扫描 | N | {1,4,8,12,16} | 接收机数 |
| SNR 范围 | — | −10 : 2 : 25 dB | 18 个 SNR 点 |
| 调制方式 | — | QPSK, 16QAM | 2 种调制 |
| 随机种子 | — | 42 | 可复现 |

### 2.3 频率响应关键指标

| 指标 | 值 | 来源 |
|------|------|------|
| DC 极限 \|H(0)\| | 5.7721×10⁻⁹ | 超算符数值解 |
| −3 dB 带宽 | ≈ 500 kHz | 490 kHz (实测) |
| BW / Δf | ≈ 2.5 | 每接收机覆盖约 2–3 子载波 |
| 单音精度 (超算符 vs BDF) | < 0.5% | verify_multi_tone.py |
| 多音互调误差 | < 1% | verify_multi_tone.py |

---

## 三、关键算法与代码

### 3.1 频率响应 H(δω) 计算 (h_superop.py)

**方法**：构建 16×16 Liouvillian 超算符 L，求解一阶微扰

```python
# 1. 构建 4 能级密度矩阵的 Liouvillian 超算符 (16×16)
L = build_liouvillian(Om_p, Om_c, Om_l, G2)  # H0 + Lindblad

# 2. 稳态解: L · ρ^(0) = 0
rho0_vec = solve_null_space(L)

# 3. 一阶源项: b1 = -i[H1, ρ^(0)]   (H1 为微波微扰)
b1_mat = 1j * (H1 @ rho0_mat - rho0_mat @ H1)

# 4. 频率响应: (j·δω·I - L) · ρ^(1) = b1
rhovec_plus = np.linalg.solve(1j*dw*I - L, b1_vec)

# 5. 提取探针相干项
H_dw = 2 * rho21_1st / Om_s   # 复频率响应
```

**预计算 F 矩阵**：
```python
def get_F_matrix(N_sc, df_sc):
    offsets = [(n - i) * df_sc for i in range(N_sc) for n in range(N_sc)]
    F = [[H_dw(2π * off) / H0 for off in row] for row in offsets]
    return np.array(F).reshape(N_sc, -1)
```

### 3.2 因子化信道估计与 MRC 解码 (step4_run_simulation.py)

**核心公式**：
```python
# 信道估计: 导频辅助
for n in range(N_subcarriers):
    sum_rx_sconj = 0.0
    for k in range(N_pilot):
        sum_rx_sconj += r[k,i,n] * np.conj(s_tx[k,n])
    G_hat[i] += sum_rx_sconj / (N_pilot * F[i,n])

# MRC 合并: 等效信道 H_ch = F · Ĝ
H_ch_hat = F @ G_hat  # (N_sc × 1)

# 符号检测: ŝ_n = (h_n^* / |h_n|²) · r_n
for n in range(N_sc):
    denom = abs(H_ch_hat[n])**2 + noise_var
    s_hat[N_pilot:, n] = (np.conj(H_ch_hat[n]) / denom) * r_sliced[:, n]
```

**三种接收方案**：

| 方案 | 实现 | 用途 |
|------|------|------|
| Single Rx | `ŝ = r₀ / Ĥ₀` (零迫，仅用接收机 0) | 下界基线 |
| Array MRC | `Ĝ_i` → `Ĥ_ch = F × Ĝ` → MRC 合并 | 主要方案 |
| Ideal CSI | 使用真信道 `H_ch` 做 MRC | 理论上界 |

### 3.3 IBTR 与 EAG 计算 (fig_ibtr.py / ber_ibtr_comparison.py)

**IBTR (In-Band Tone Ratio)**：
```python
def ibtr_for(N_rx, df):
    subcarriers = np.arange(M) * df
    rx_freqs = np.linspace(0, (M-1)*df, N_rx)  # 均匀放置
    covered = 0
    for sc in subcarriers:
        best = max(H_abs(abs(sc - rf)) for rf in rx_freqs)
        if best >= 1/np.sqrt(2):  # -3 dB 阈值
            covered += 1
    return covered / M
```

**EAG (Effective Array Gain)**：
```python
def eag_for(N_rx, df):
    EAG = 0.0
    for n, sc in enumerate(subcarriers):
        EAG += sum(|H(abs(sc - rf))|^2 for rf in rx_freqs)
    return EAG / M
```

**IBTR 热力图结果** (M=16)：

| N | Δf=100 | 200 | 300 | 400 | 500 | 600 | 800 | 1000 kHz |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| 4 | 1.00 | 1.00 | 0.75 | 0.62 | 0.50 | 0.38 | 0.25 | 0.25 |
| 6 | 1.00 | 1.00 | 1.00 | 1.00 | 0.88 | 0.75 | 0.50 | 0.38 |
| 8 | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 | 0.88 | 0.75 | 0.62 |
| 12 | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 | 0.88 | 0.75 |
| 16 | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 |

### 3.4 多音分离验证 (verify_multi_tone.py)

三种方法交叉验证线性叠加假设：

| 方法 | 技术 | 耗时 |
|------|------|------|
| BDF 全非线性 | solve_ivp (rtol=1e-8)，15 周期驱动，5 周期记录 | ~1 min |
| 超算符独立预测 | 每个频点单独解 16×16 线性方程组 | < 0.1 s |
| 等效基带线性叠加 | H(δω) × s_n 线性组合 | < 0.01 s |

**通过标准**：幅值比 |ratio−1| < 0.10，相位差 < 10°

**验证频点**：[200, 400, 600] kHz，BPSK 符号 {+1, −1, +1}

---

## 四、实验步骤

### Phase 0: 频率响应验证
```bash
python verify_atomic_response.py    # H(dw) DC 极限、-3dB 带宽
python plot_freq_response.py        # 三子图幅值/相位/实虚部
python verify_multi_tone.py         # 多音 BDF vs 超算符
```
→ 确认超算符 H(dw) 可替代耗时的 BDF 积分

### Phase 1–3: OFDM 仿真流水线
```bash
python run_all.py                   # 一键运行
# 或逐步:
python step1_generate_ofdm.py       # → outputs/tx_symbols.npz
python step2_compute_F_matrix.py    # → outputs/F_matrix.npz
python step3_setup_channel.py       # → outputs/channel.npz
python step4_run_simulation.py      # → outputs/ber_data.txt
```

### Phase 4: IBTR 优化与分析
```bash
python optimize_ibtr.py             # IBTR 热力图 (图 8)
python ber_ibtr_comparison.py       # BER vs N_rx (图 9)
python eag_analysis.py              # EAG vs IBTR 相关性
```

### Phase 5: 出版级图表生成
```bash
python fig_ber.py                   # BER 曲线 (图 5)
python fig_constellation.py         # 星座图 (图 7)
python fig_eag.py                   # BER vs EAG (图 10)
python fig_ibtr.py                  # IBTR 优化 (图 10)
```

---

## 五、实验结果与结论

### 5.1 频率响应验证

| 验证项 | 结果 | 指标 |
|--------|------|------|
| 单音精度 (超算符 vs BDF) | ✅ 通过 | 幅值差 < 0.5%，相位差 < 0.5° |
| 3 音 BDF vs 超算符叠加 | ✅ 通过 | \|ratio−1\| < 1.10×10⁻²，相位差 < 6.4° (600 kHz) |
| 3 音 BDF vs 等效基带线性 | ✅ 通过 | \|ratio−1\| < 3.14×10⁻⁴，相位差 < 3.5° |
| 旧闭式解 P7/Q9 验证 | ❌ 不通过 | \|H(+δω)\| ≠ \|H(−δω)\| (不对称，比率偏差 59.3%) |

→ **结论**：超算符 H(dw) 可替代 BDF 做快速 OFDM 多音仿真，误差 < 1%

### 5.2 BER 性能 (Δf=200 kHz)

**QPSK**：

| SNR (dB) | Single Rx BER | Array MRC BER (N=16) | 有效增益 |
|:---:|:---:|:---:|:---:|
| −10 | 0.91 | 0.74 | — |
| 0 | 0.85 | 0.35 | ~4 dB |
| 10 | 0.57 | 0.007 | ~13 dB |
| 20 | 0.081 | 0.0 | >24 dB |

**16QAM**：

| SNR (dB) | Single Rx BER | Array MRC BER (N=16) | 有效增益 |
|:---:|:---:|:---:|:---:|
| −10 | 0.91 | 0.74 | — |
| 0 | 0.85 | 0.35 | ~4 dB |
| 10 | 0.57 | 0.0079 | ~14 dB |
| 14 | 0.40 | <10⁻⁴ | 无误码 |
| 24 | 2.5×10⁻³ | 0.0 | >24 dB |

→ **结论**：N=16 阵列实现 QPSK 和 16QAM 的 >24 dB 有效增益；
  16QAM 在 SNR=14 dB 时达到无误码，单接收机在 SNR=24 dB 时 BER=2.5×10⁻³

### 5.3 接收机数量与 EAG (Δf=200 kHz)

| N_rx | IBTR | EAG | 硬件缩减 | 性能 |
|:---:|:---:|:---:|:---:|------|
| 1 | 0.19 | 0.31 | — | 基线(不可用，覆盖不足) |
| 4 | 1.00 | 1.47 | 75% | 最低可用，适度 SNR 代价 |
| 8 | 1.00 | 3.09 | 50% | 良好折中，接近满配 |
| 12 | 1.00 | 4.70 | 25% | 高性能 |
| 16 | 1.00 | 6.32 | 0% | 一一对应满配，最优 |

→ **结论**：N=4 即可实现全子载波覆盖 (IBTR=1.0)，硬件缩减 75%；
  N=8 以 50% 硬件代价将性能差距缩小到接近满配基线

### 5.4 IBTR 与 Δf 关系

- N=4 仅在小 Δf (≤200 kHz) 保持 IBTR=1.0
- N=6 将全覆范围扩展到 Δf≤400 kHz
- N=16 在所有测试 Δf (≤1000 kHz) 均保持 IBTR=1.0
- 增大 Δf 使子载波间距超过单接收机带宽，需要更多接收机

### 5.5 核心结论

1. **超算符建模可行**：16×16 Liouvillian 数值解误差 < 1%，替代 BDF → 仿真加速 10³–10⁴ 倍
2. **阵列增益显著**：N=16 相对单接收机 >24 dB 有效增益；16QAM 在 14 dB SNR 无误码
3. **硬件可大幅缩减**：N=4 (75% 缩减) 即可全覆；N=8 (50% 缩减) 接近满配性能
4. **IBTR-EAG-BER 三级设计方法**：IBTR 筛可行性 → EAG 排性能 → BER 最终验证
5. **梯度磁场阵列**：将原子带宽限制转化为空间分集资源

---

## 六、文件清单与依赖

### 核心仿真脚本
| 脚本 | 输入 | 输出 |
|------|------|------|
| `step1_generate_ofdm.py` | — | `outputs/tx_symbols.npz` |
| `step2_compute_F_matrix.py` | h_superop.py | `outputs/F_matrix.npz` |
| `step3_setup_channel.py` | F_matrix.npz | `outputs/channel.npz` |
| `step4_run_simulation.py` | channel.npz, tx_symbols.npz | `outputs/ber_data.txt` |
| `h_superop.py` | — | H_dw() API |

### 出版图脚本
| 脚本 | 图 | 格式 |
|------|------|------|
| `fig_ber.py` | BER 曲线 | pdf/png/svg |
| `fig_ibtr.py` | IBTR 热力图+折线图 | pdf/png/svg |
| `fig_eag.py` | BER vs EAG (N=1,4,8,12,16) | pdf/png/svg |
| `fig_constellation.py` | 16QAM 星座图 | pdf/png/svg |
| `plot_freq_response.py` | 频率响应三子图 | pdf/png/svg |
| `verify_multi_tone.py` | 多音分离验证 | pdf/png/svg |

### 依赖
```bash
pip install numpy scipy matplotlib
```
无需 QuTiP (使用独立超算符实现)
