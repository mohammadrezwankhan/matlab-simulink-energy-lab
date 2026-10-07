# Notation, units and conventions

[Book contents](README.md)

A symbol is local to a model unless this table explicitly gives it a shared
meaning. In particular, the letter $C$ can mean capacitance or thermal capacity;
the units decide which. The code uses unit-bearing field names so that these
distinctions do not depend only on typography.

| Symbol | Meaning | Units / convention |
| --- | --- | --- |
| $t_k$, $\Delta t_k$ | Sample time and following interval duration | s; $\Delta t_k=t_{k+1}-t_k$ |
| $z$ | State of charge, SOC | Fraction, not percent; $0.8=80\%$ |
| $Q_{\mathrm{Ah}}$ | Nominal charge capacity | Ah; multiply by 3600 for A·s |
| $I$ | Battery current | A; positive discharge, negative charge |
| $U(z)$ or $V_{oc}$ | Open-circuit voltage relationship | V; illustrative unless otherwise sourced |
| $V_t$ | Battery terminal voltage | V |
| $R_0,R_j,C_j$ | Ohmic resistance and polarization-branch parameters | Ω, Ω, F |
| $v_j$ | Polarization-branch voltage state | V; subtracted from OCV for the chosen convention |
| $\tau_j=R_jC_j$ | Relaxation time constant | s |
| $h$ | Normalized hysteresis memory | Dimensionless; not a heat-transfer coefficient in Chapter 5 |
| $M$ | Hysteresis voltage amplitude | V |
| $\hat x$, $P$, $Q$, $R$ | State estimate and EKF covariance matrices | Units depend on state/measurement; not converter power symbols |
| $H$ | Measurement Jacobian | Measurement units per state unit |
| $\nu$, $S$, $K$ | Innovation, innovation covariance and Kalman gain | Defined in Chapter 4 |
| $T$, $T_\infty$ | Temperature and surrounding-fluid temperature | °C for plots; K where absolute temperature is required |
| $\dot Q$ | Heat rate | W; not charge capacity |
| $m c_p$ or $C_{th}$ | Lumped thermal capacity | J/K |
| $h_c$, $UA$, $hA$ | Convection coefficient / thermal conductance | W/(m²·K) / W/K; distinguish from hysteresis $h$ |
| $k_{th}$, $A$, $L$ | Thermal conductivity, area and slab thickness | W/(m·K), m², m |
| $\dot m c_p$ | Coolant heat-capacity rate | W/K, not stored thermal capacity |
| $L_e,C_e$ | Converter inductance and capacitance | H, F; chapters may shorten to $L,C$ |
| $D$, $s$ | Duty ratio and switching state | $D\in[0,1]$; $s\in\{0,1\}$ |
| $P,Q$ | Active and reactive power in converter/BESS chapters | W/var or per-unit as explicitly labelled |
| $E_{dc}$ | DC-link capacitor energy | J; $E_{dc}=C_{dc}V_{dc}^2/2$ |
| $S_b$, $V_b$, $I_b$ | Apparent-power, voltage and current bases | Base definitions must use compatible RMS/peak and phase/line quantities |
| p.u. | Per unit | Physical quantity divided by its stated base |

## Samples are not intervals

An $N$-sample time vector contains $N-1$ intervals. For a zero-order-held input,
the value at $t_k$ acts on $[t_k,t_{k+1})$. The last sample has no following
interval. A terminal voltage may still be evaluated there, but it must not
silently contribute an additional charge or energy interval.

Battery charge balance, when the applied current is constant over an interval,
is

$$
z_{k+1}=z_k-\frac{I_{\mathrm{applied},k}\Delta t_k}{3600Q_{\mathrm{Ah}}}.
$$

The one-/two-RC models limit applied current to available interval charge.
The lumped electrothermal example instead clips its updated SOC; the latter
does not enforce the same boundary charge accounting. Always read a model's
specific limit semantics rather than transferring the equation's interpretation
from another chapter.

## Net transfer and absolute throughput

For the repository's interval-start convention, net discharged charge is
$\sum I_k\Delta t_k/3600$ Ah. Absolute charge throughput is
$\sum |I_k|\Delta t_k/3600$ Ah. Charge followed by discharge can have small net
transfer and large throughput. The duty-cycle helper normalizes absolute
throughput by $2Q_{\mathrm{Ah}}$ for its equivalent-full-cycle measure. That
definition is neither a rainflow count nor an ageing law.

The same distinction applies to signed terminal-energy transfer and absolute
terminal-energy throughput. Do not use a plotting interpolant or a trapezoidal
integral to silently replace an interval-start accounting convention when
comparing against a specific check.

## Temperature and power signs

A temperature difference of 1 °C is a difference of 1 K. An absolute
temperature of 25 °C is 298.15 K. Reversible heat terms involving absolute
temperature require the second quantity. Cooling heat is normally positive
when energy leaves the cell; it can be negative when the surrounding fluid
heats a colder cell.

The thermal example's terminal-loss proxy includes a polarization term. Do
not reinterpret it as a universally nonnegative instantaneous entropy-production
formula for arbitrary reversal histories. The chapters identify what the
implemented balance actually accounts for.

## Numerical and statistical vocabulary

“Exact” in an RC update means exact integration of that linear state equation
under its specified held input and parameters. It does not mean an exact
description of a battery. “Stable step” means a stated numerical restriction
is met, not that a controller is stable for every operating point. “Held-out”
means a record was excluded from fitting; it does not mean that record was
measured on a physical cell.

RMSE is $\sqrt{n^{-1}\sum_i e_i^2}$ and retains the error's units. A signed final
error answers a different question from an RMSE over a trajectory. Posterior
voltage residuals use measurements after an estimator correction and are not
out-of-sample voltage predictions. These distinctions matter when comparing the
SOC estimators.

## English / 简体中文 glossary

| English | 简体中文 |
| --- | --- |
| Equivalent-circuit model | 等效电路模型 |
| State of charge (SOC) | 荷电状态 |
| Open-circuit voltage (OCV) | 开路电压 |
| Polarization voltage | 极化电压 |
| Extended Kalman filter (EKF) | 扩展卡尔曼滤波器 |
| Hysteresis | 滞回 |
| Held-out validation | 留出验证 |
| Lumped thermal model | 集总参数热模型 |
| Finite-volume method | 有限体积法 |
| Pulse-width modulation (PWM) | 脉宽调制 |
| Grid-following control | 跟网型控制 |
| Grid-forming control | 构网型控制 |
| Islanding / reconnection | 孤岛运行／重新并网 |
| SOC reserve | 荷电状态预留裕度 |
| Power curtailment | 功率削减 |

The glossary is an onboarding aid, not a claim that every standards body uses
identical translations. Keep the English code identifier next to translated
terms when reporting a result.
