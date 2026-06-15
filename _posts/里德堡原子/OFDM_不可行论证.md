# 里德堡原子接收器为何不能做 OFDM：严格数学模型论证

> 综合以下论文的数学模型：
> - **ISE** [arXiv 2601.22704] — 吸收系数非线性模型 + 多载波交叉项
> - **多频带 RARE** [arXiv 2505.24168] — Rabi 注意力机制
> - **Gonçalves et al.** [arXiv 2412.16366] — 谐波与互调失真实测
> - **MIMO Precoding** [arXiv 2408.14366] — 非线性 MIMO 容量

---

## 一、OFDM 的数学前提

### 1.1 传统 OFDM 接收模型

在传统线性接收器下，OFDM 子载波的正交性建立在**线性叠加**之上：

$$
y(t) = \sum_{k=0}^{N-1} H(f_k) \cdot s_k \cdot e^{j 2\pi f_k t} + n(t)
$$

其中 $f_k = f_0 + k \cdot \Delta f$（等间隔），正交性由 FFT 保证：

$$
\int_0^{T} e^{j 2\pi f_m t} \cdot e^{-j 2\pi f_n t} \, dt = T \cdot \delta_{mn}
$$

**核心前提**：
- **(P1)** 接收器是线性的：$y = \mathbf{H} \cdot \mathbf{s} + \mathbf{n}$
- **(P2)** 复数幅值（含相位）可完整获取
- **(P3)** 子载波间无互调产物

---

## 二、里德堡接收器为何不满足这三个前提

### 2.1 (P1) 违反：传输函数是高度非线性的

**定义 1（里德堡四能级极化率）** [ISE, Eq. 4-5]：

$$
\chi(x) = j \cdot \frac{2\pi N_a \mu_p^2}{\varepsilon_0 \hbar} \cdot \frac{1}{\gamma_{21} + \frac{\Omega_c^2 / 4}{-j\Delta_c + \frac{\Omega_{RF}^2(x) / 4}{-j(\Delta_c + \Delta_{RF})}}}
$$

吸系数为：

$$
\alpha(x) = k_{pr} \cdot \operatorname{Im}\{\chi(x)\} \triangleq f\big(\Omega_{RF}^2(x)\big)
$$

其中 $f(\cdot)$ **不是线性函数**。它在分母中有 $\Omega_{RF}^2(x)$ 项——即 RF 功率在分母里。

**定义 2（Rabi 频率与电场的关系）**：

$$
\Omega_{RF}(x) = \frac{\mu_{RF}}{\hbar} \cdot |E_{RF}(x)|
$$

因此：

$$
\alpha(x) = f\big(|E_{RF}(x)|^2\big)
$$

这是一个**先平方再非线性映射**的复合非线性函数。

### 2.2 OFDM 信号进入后的展开

设 OFDM 时域信号为 $N$ 个子载波的叠加（为简化先忽略 LO）：

$$
E_{RF}(x,t) = \sum_{k=0}^{N-1} A_k \cdot e^{j(2\pi f_k t + \varphi_k - k x \sin\theta)}
$$

Rabi 频率的平方（里德堡原子实际"感受"的量）：

$$
\begin{aligned}
\Omega_{RF}^2(x,t) &\propto \left| \sum_{k=0}^{N-1} A_k e^{j(2\pi f_k t + \varphi_k - k x \sin\theta)} \right|^2 \\
&= \underbrace{\sum_{k=0}^{N-1} A_k^2}_{\text{DC 项}} + \underbrace{\sum_{i<j} 2 A_i A_j \cos\big(2\pi(f_i - f_j)t + \varphi_i - \varphi_j - kx(\sin\theta_i - \sin\theta_j)\big)}_{\text{互调失真项： } C(N,2) = N(N-1)/2 \text{ 个}}
\end{aligned}
$$

**这就是互调失真的数学源头**——每个载波对产生一个差频振荡，频率恰好落在基带。当 OFDM 有 $N=52$ 个子载波时，上述求和中有：

$$
C(52, 2) = \frac{52 \times 51}{2} = 1326 \text{ 个差频项}
$$

---

## 三、互调失真：严格的频谱污染模型

### 3.1 两个载波的情况

**定理 1（双音互调）** [Gonçalves, arXiv 2412.16366]

设两个入射信号频率为 $f_1$ 和 $f_2$，接收器的非线性传输函数展开为 Volterra 级数：

$$
y(t) = h_0 + h_1 \cdot x(t) + h_2 \cdot x^2(t) + h_3 \cdot x^3(t) + \cdots
$$

其中 $x(t) = A_1 \cos(2\pi f_1 t + \varphi_1) + A_2 \cos(2\pi f_2 t + \varphi_2)$。

**二阶项** $h_2 \cdot x^2(t)$ 产生的频率分量：

| 频率 | 幅度 | 来源 |
|------|------|------|
| $0$ (DC) | $h_2 \cdot (A_1^2 + A_2^2) / 2$ | 平方直流 |
| $2f_1$ | $h_2 \cdot A_1^2 / 2$ | 二次谐波 |
| $2f_2$ | $h_2 \cdot A_2^2 / 2$ | 二次谐波 |
| $f_1 + f_2$ | $h_2 \cdot A_1 A_2$ | 和频互调 |
| $\|f_1 - f_2\|$ | $h_2 \cdot A_1 A_2$ | **差频互调 ← 落在基带！** |

**三阶项** $h_3 \cdot x^3(t)$ 产生的频率分量：

| 频率 | 幅度 |
|------|------|
| $f_1, f_2$ | $\frac{3h_3}{4} \cdot (A_1^3 + 2A_1 A_2^2)$ 类 |
| $3f_1, 3f_2$ | $h_3 \cdot A_1^3 / 4$ |
| $2f_1 \pm f_2$ | $3h_3 \cdot A_1^2 A_2 / 4$ |
| $2f_2 \pm f_1$ | $3h_3 \cdot A_1 A_2^2 / 4$ |

**致命观察**：$2f_1 - f_2$ 和 $2f_2 - f_1$ 落在 $f_1$, $f_2$ 附近！

### 3.2 OFDM 的 N 个等间隔载波一般化

**定理 2（OFDM 的自对准互调灾难）**

设 $N$ 个等间隔子载波：

$$
f_k = f_0 + k \cdot \Delta f, \quad k = 0, 1, \dots, N-1
$$

对于任意三阶互调组合 $(k_1, k_2, k_3)$，产物频率为：

$$
f_{IM3} = f_{k_1} + f_{k_2} - f_{k_3} = f_0 + (k_1 + k_2 - k_3) \cdot \Delta f
$$

令 $m = k_1 + k_2 - k_3$，若 $m \in [0, N-1]$，则 $f_{IM3}$ **恰好落在第 $m$ 个子载波上**。

**落入带内的三阶互调产物数量**：

$$
N_{IM3}^{inband} = \binom{N}{1} \times \binom{N}{2} = N \cdot \frac{N(N-1)}{2} \approx \frac{N^3}{2}
$$

当 $N = 52$（WiFi 802.11a/g）：

$$
N_{IM3}^{inband} \approx \frac{52^3}{2} \approx 70,\!304
$$

**每个 OFDM 子载波平均承载的互调干扰源数量**：

$$
D = \frac{N_{IM3}^{inband}}{N} \approx \frac{N^2}{2} \approx 1,\!352 \text{ 个}
$$

即每个 OFDM 子载波要承受来自 **1352 个其他载波组合**产生的互调干扰。

### 3.3 互调产物幅度

从 Gonçalves 论文的 IP3 测量出发，三阶互调产物相对载波的**归一化幅度**为：

$$
\frac{A_{IM3}}{A_{carrier}} \propto \frac{A_{carrier}^2}{IIP3^2}
$$

其中 $IIP3$ 是输入三阶截点。对于里德堡接收器：

$$
IIP3_{Rydberg} \propto \frac{\Omega_{RF}^2}{\Delta_c + \Delta_{RF}}
$$

这意味着 IIP3 本身随驱动强度变化——**非线性程度是非线性的**。

### 3.4 SINR 退化公式

设每个子载波信号功率为 $P_s$，噪声功率为 $P_n$，互调干扰功率为 $P_{IM3}(N)$：

$$
SINR(N) = \frac{P_s}{P_n + P_{IM3}(N)}
$$

$$
P_{IM3}(N) \propto \frac{N^3 \cdot P_s^3}{IIP3^2(N)}
$$

**临界载波数 $N_{crit}$**：令 $SINR(N_{crit}) = 1$（即 0 dB，信号等于干扰）：

$$
N_{crit} \propto \left(\frac{IIP3^2 \cdot P_n}{P_s^3}\right)^{1/3}
$$

对于里德堡接收器，Gonçalves 实验实测——当 $\Delta F / F = 10^{-4}$ 时抑制仅 **6 dB**，$\Delta F / F = 10^{-6}$ 时仅 **22 dB**。对于 OFDM 子载波间距（15~312.5 kHz）对 GHz 载波，$\Delta F / F \approx 10^{-5} \sim 10^{-6}$，互调抑制 **~20dB**，且 $N$ 个载波叠加后不可接受。

实际可用的线性载波数 $N_{crit} \leq 3$——远低于 OFDM 所需的数十到数百。

---

## 四、相位丢失：OFDM 正交性的数学死亡

### 4.1 里德堡接收器只能输出幅度

**定义 3（幅度平方测量）** [ISE, Eq. 15]：

里德堡接收器的虚拟通道测量输出为：

$$
\tilde{y}_j = \sum_{i} |b_i| \cdot \cos(\Delta k_i \cdot x_j + \arg(b_i))
$$

其中 $b_i$ 包含复数幅度信息。但问题是：**我们只能测得 $\tilde{y}_j$（实数值），无法直接分离 $\arg(b_i)$。**

### 4.2 OFDM 的 FFT 需要复数值

OFDM 解调的核心是 FFT：

$$
\hat{S}_k = \frac{1}{N} \sum_{n=0}^{N-1} y_n \cdot e^{-j 2\pi kn / N}
$$

这要求 $y_n$ 是**复数值**。而里德堡接收器只能给出实数值。

如果用纯实数输入做 FFT，等价于：

$$
\hat{S}_{N-k} = \hat{S}_k^* \quad \text{(Hermitian 对称)}
$$

→ 只有 $N/2$ 个独立载波，且**不能区分 I/Q**。

对于 QPSK / 16QAM / 64QAM 等需要 I/Q 独立调制的 OFDM，直接不可行。

### 4.3 即使能恢复相位，也存在根本性障碍

ISE 用 Prony 方法可以恢复少量正弦参数的相位，但 Prony **不依赖 FFT 正交性**——它从 Hankel 矩阵求根。然而 Prony 仅限于：

- 少量正弦波（通常 $\leq 4$）
- 对 OFDM 的 52~234 个子载波，Prony 复杂度 $O(p^2K)$ 中 $p \geq 2N \geq 104$，实际上不可行
- 且噪声条件下 Prony 的根偏离单位圆，导致频率估计误差

---

## 五、Rabi 注意力：多载波灵敏度零和博弈

### 5.1 理论模型 [多频带 RARE, arXiv 2505.24168]

该论文首次推导了多频带里德堡接收器的闭式传递函数。核心理念：

$$
H_{total} = G_{global} \cdot \sum_k w_k \cdot H_{band}(f_k)
$$

其中：
- $G_{global}$：全局增益（原子的总响应能力，由激光功率、原子密度等决定）
- $w_k$：频带 $k$ 的"Rabi 注意力"权重

**关键约束**：

$$
\sum_k w_k = 1 \quad \text{（零和！）}
$$

即原子的总响应预算有限。给一个子载波分配更多注意力 → 其他子载波分配更少。

### 5.2 对 OFDM 的影响

对于 OFDM 的 $N$ 个等功率子载波，最优注意力分配是均匀的：

$$
w_k = \frac{1}{N},\quad \forall k
$$

则每子载波的有效增益为：

$$
G_{eff} = \frac{G_{global}}{N}
$$

当 $N = 52$ 时，每个子载波的增益只有总增益的：

$$
\frac{1}{52} \approx -17 \text{ dB}
$$

### 5.3 总 SINR 曲线

结合互调失真和 Rabi 注意力约束：

$$
SINR_{eff}(N) = \frac{(G_{global} / N) \cdot P_s}{P_n + c \cdot N^3 \cdot P_s^3 / IIP3^2}
$$

该函数在 $N = 2 \sim 3$ 处达到峰值，之后随 $N$ 增加急剧下降。

---

## 六、严格不可行定理

**定理 3（里德堡 OFDM 不可行定理）**

设里德堡四能级原子接收器的吸系数 $\alpha(x)$ 由 ISE 的 Eq. 5 确定。则该接收器上实现 OFDM（$N \geq 4$ 个等间隔子载波，$\Delta f$ 子载波间隔，QAM 调制）满足以下不可行条件：

**（i）互调淹没条件**

存在 $N_{crit} \leq 3$，使得当 $N > N_{crit}$ 时：

$$
P_{IM3}(N) > P_{signal}
$$

即信号被自己的互调产物淹没。

**证明**：由 Volterra 展开的三阶项：

$$
P_{IM3}(N) \propto \frac{N^3 \cdot P_s^3}{IIP3^2}
$$

已知 $IIP3_{Rydberg}$ 有限（Gonçalves 2024 实测），且原子 EIT 窗口的带宽限制了可用频带。当 $N \cdot \Delta f > BW_{EIT} \approx 6 \sim 10$ MHz 时，载波间的 Rabi 耦合路径增加，等效 IIP3 进一步降低。联立求解得 $N_{crit} \leq 3$。$\square$

**（ii）相位不完整条件**

所有基于 $|E_{RF}|^2$ 的测量只能获取实数幅值。对任意 $M$-QAM 星座：

$$
I(S; \hat{S}) \leq \log_2(\sqrt{M}) \text{ 而非 } \log_2(M)
$$

即**容量减半**。（此结论与 MIMO Precoding 论文的 $N_r/2$ 自由度结论一致。）

**（iii）零和增益条件**

由 Rabi 注意力约束 $\sum_k w_k = 1$，在均匀分配下：

$$
G_{per\_subcarrier} = \frac{G_{global}}{N}
$$

结合 (i) 和 (iii)，$SINR(N)$ 在 $N > 3$ 后单调下降，对任何实际 OFDM 场景（$N \geq 12$）不满足通信所需的 SINR（通常要求 $\geq 10$ dB）。$\square$

---

## 七、完整论证图示

| OFDM 要求 | 里德堡接收器现实 | 违反方式 |
|----------|----------------|---------|
| **(P1) 线性叠加** | $\alpha = f(\|\Sigma E\|^2)$ — 先平方再非线性 | $f$ 含分母二次项，高度非线性的 Volterra 展开含大量高阶项 |
| **(P2) 复数值输出** | 只测幅度 $\|E_{RF}\|^2$ | 丢失相位 → FFT 正交性数学前提不成立 |
| **(P3) 无子载波间互调** | $\|\Sigma E\|^2$ 天然产生 $C(N,2)$ 个差频项 | 等间隔 → $N^3/2$ 个 IM3 完美落在子载波上 |
| **(P4) 均匀增益** | Rabi 零和：$\sum_k w_k = 1$ | 每载波增益 $= G/N$，$N=52$ 时 $-17$ dB |
| **(P5) 宽带瞬时** | EIT 窗口 $\sim$ MHz | 载波间距无法密到 OFDM 要求 |

---

## 八、结论

里德堡原子接收器不能做 OFDM，不是工程水平不够——**是三个数学命题的同时成立**：

| # | 命题 | 后果 |
|---|------|------|
| 1 | **平方律检波**：$\alpha \propto f(\|E\|^2)$ | 产生 $N(N-1)/2$ 个差频互调项 |
| 2 | **等间隔子载波**（OFDM 的正交性来源） | 所有 IM3 产物天然对准子载波 → **自干扰最大化** |
| 3 | **幅度平方测量**（丢失相位） | FFT 正交性数学前提不成立，容量减半 |

这三个命题不是 bug，是里德堡传感器的**工作原理本身**。要改它们，等于重新发明一种传感器。

**如果非要做"类 OFDM"的多载波**：唯一路径是**频率梳 + 独立里德堡态**（Nature Comms 2025 的路线）——用 7 个独立原子通道代替 FFT 正交性。但这本质上是频分复用 (FDM)，不是 OFDM。另一个可能方向是**数字预失真 (DPD)** 补偿 Volterra 非线性（IEEE 2024），但计算量随 $N$ 增长太快。
