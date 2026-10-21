# Chapter 4 — Correcting SOC with a Two-State EKF

**Book navigation:** [book contents](../README.md) · [worked solutions](../solutions/04-soc-ekf.md) · [Chapter 1: one RC](01-one-rc.md)

**Snapshot identity:** implementation details and benchmark expectations refer to [source-map.md](../source-map.md).

## Why combine current and voltage?

Coulomb counting responds quickly but inherits every error in initial SOC,
capacity, and current measurement. OCV carries information about SOC, but only
when the OCV curve has a useful slope and the terminal voltage is not dominated
by transient polarization. An extended Kalman filter (EKF) combines the two:
it combines charge propagation with a voltage correction at the matching
timestamp.

The repository's transparent two-state implementation is
[`estimate_battery_soc_ekf`](../../examples/battery-soc-ekf/estimate_battery_soc_ekf.m).
The deterministic scenario and tuning are defined by
[`battery_soc_ekf_default_scenario`](../../examples/battery-soc-ekf/battery_soc_ekf_default_scenario.m).
This chapter derives the exact sequence used by the implementation. It does
not claim the covariances are identified sensor statistics: they are teaching
and regression values.

### Prerequisites and notation

You should know Chapter 1, matrix multiplication, covariance, and the basic
Kalman filter idea. Define the state at sample $k$ as

$$
x_k=\begin{bmatrix}z_k\\v_k\end{bmatrix},
$$

where $z$ is SOC and $v$ is one-RC polarization voltage. Positive current
is discharge. Let $u_k=I_k$ be the measured current, $y_k$ the measured
terminal voltage, and $Q$ the capacity. For each interval,

$$
\Delta t_k=t_{k+1}-t_k,
\qquad a_k=\exp\left(-\frac{\Delta t_k}{R_1C_1}\right).
$$

The filter stores a prior state/covariance before voltage correction and a
posterior state/covariance after correction. This distinction matters for both
understanding and debugging.

## Nonlinear state and measurement model

The exact zero-order-held state transition is

$$
f(x_k,u_k,\Delta t_k)=
\begin{bmatrix}
z_k-\dfrac{u_k\Delta t_k}{3600Q}\\[6pt]
a_kv_k+R_1(1-a_k)u_k
\end{bmatrix}.
$$

SOC is clipped to $[0,1]$ after propagation. The measurement model evaluated
at the sample before propagation is

$$
h(x_k,u_k)=V_{\mathrm{oc}}(z_k)-R_0u_k-v_k.
$$

The OCV lookup is piecewise linear. On the active segment, the slope is

$$
s_k=\frac{V_{\mathrm{oc},j+1}-V_{\mathrm{oc},j}}
 {z_{j+1}-z_j},
$$

so the measurement Jacobian is

$$
H_k=\begin{bmatrix}s_k&-1\end{bmatrix}.
$$

The source obtains both OCV and slope from the same lookup table. At a flat
segment, $s_k$ is small and the voltage measurement provides little direct
SOC information. A steeper segment makes voltage more sensitive to SOC. It
does not guarantee a larger SOC correction: the Kalman gain also depends on
state covariance, polarization uncertainty and measurement noise. In a static
OCV-only inversion, the same voltage difference gives a *smaller* SOC change
when the slope is steeper.

## The update order: correction, then propagation

The implementation processes each timestamp in this order:

1. Treat $x_k^-$ and $P_k^-$ as the prior at the timestamp.
2. Predict voltage from the prior state.
3. Correct with measured voltage to obtain $x_k^+$ and $P_k^+$.
4. If another timestamp exists, propagate $x_k^+$ through the current-held
   interval to create $x_{k+1}^-$ and $P_{k+1}^-$.

The superscripts distinguish prior and posterior, not time direction. The
innovation is

$$
\nu_k=y_k-h(x_k^-,u_k),
$$

and its variance is

$$
S_k=H_kP_k^-H_k^T+R_v,
$$

where $R_v>0$ is the measurement-voltage variance. The Kalman gain is

$$
K_k=P_k^-H_k^TS_k^{-1}.
$$

The posterior correction is

$$
x_k^+=x_k^-+K_k\nu_k.
$$

The source clips posterior SOC after this correction. That practical bound
keeps the state in the OCV table's domain; it is not a complete constrained
Kalman-filter derivation.

## Joseph covariance update

The numerically robust posterior covariance form is

$$
P_k^+=(I-K_kH_k)P_k^-(I-K_kH_k)^T+K_kR_vK_k^T.
$$

This is the Joseph form. It makes the positive-semidefinite contributions
explicit and behaves better under finite-precision arithmetic than simply
writing $(I-KH)P^-$, which can lose symmetry or produce a tiny negative
eigenvalue. The implementation symmetrizes the result afterward:

$$
P_k^+\leftarrow\frac{P_k^++(P_k^+)^T}{2}.
$$

The propagated covariance is also symmetrized. The linearization of the
state transition with respect to $x$ is diagonal:

$$
F_k=\begin{bmatrix}1&0\\0&a_k\end{bmatrix}.
$$

With process-noise covariance rate $Q_c$, the propagated covariance is

$$
P_{k+1}^-=F_kP_k^+F_k^T+Q_c\Delta t_k.
$$

The source names this option `process_noise_covariance_per_s`. It acknowledges
unmodelled state evolution while retaining the exact deterministic RC update.

## A small correction calculation

Suppose the prior is $z^-=0.60$, $v^-=0.020$ V, the OCV slope is
0.80 V per SOC unit, $R_0I=0.03$ V, and the measured voltage is 3.55 V.
If the prior OCV is 3.78 V, predicted voltage is

$$
\hat y=3.78-0.03-0.020=3.73~\mathrm{V},
\qquad \nu=3.55-3.73=-0.18~\mathrm{V}.
$$

The negative innovation says the measured voltage is lower than the prior
model prediction. The gain determines how that discrepancy is shared between
SOC and polarization. A voltage residual is not automatically an SOC error:
the $v$ state, OCV slope, and covariance correlations all matter.

Irregular timestamps do not require a new filter algorithm. At every step the
source computes the actual interval $\Delta t_k$ from adjacent time samples,
then recomputes the RC decay $a_k$ and scales process noise by that duration.
This is preferable to silently treating a delayed measurement as if it arrived
on a nominal clock. It also clarifies the input convention: current sample
$I_k$ is used for the voltage prediction at $t_k$ and is held through the
interval to $t_{k+1}$. A final sample is corrected but never propagated because
there is no next interval.

The prior/posterior fields are useful when diagnosing a surprising result. A
large first posterior correction can be expected when the initial SOC is
deliberately biased; a persistent innovation after a transient may indicate
wrong OCV or missing hysteresis. If innovation variance becomes nonpositive,
the covariance or measurement variance contract has been broken. If posterior
SOC repeatedly hits a bound, inspect the current balance and OCV range before
loosening a bound. These are model and data diagnostics, not automatic claims
that the sensor or battery is faulty.

## The prescribed current-bias experiment

The repository also evaluates a prescribed constant current bias. The true
plant current and measured voltage remain fixed, while the estimator receives

$$
I_k^{\mathrm{est}}=I_k^{\mathrm{true}}+b
$$

for $b\in[-0.50,-0.25,0,0.25,0.50]$ A. This is a sensitivity experiment for
an unmodelled input error. The two-state EKF has no current-bias state. It does
not estimate, detect, reject, or compensate the bias. A systematic bias changes
both coulomb-counting propagation and the predicted ohmic/polarization
response; voltage correction may partially mask the resulting SOC drift,
depending on OCV slope and excitation.

The source/check expectation for the fixed synthetic scenario is final signed
SOC error from about -0.0218 to +0.0217 across that prescribed grid, with SOC
RMSE 0.0066 at zero bias and about 0.0161/0.0154 at the negative/positive
edges. These are source/check expectations, not newly validated in this
chapter. The existing sensitivity figure
[`battery-soc-ekf-current-bias-sensitivity.png`](../../assets/battery-soc-ekf-current-bias-sensitivity.png)
is a source asset for that comparison.

## One primary workflow: reproduce the EKF benchmark

From the repository root, run the scenario and filter through the existing
APIs:

```matlab
addpath('examples/battery-soc-ekf');
[profile, modelParameters, filterOptions] = ...
    battery_soc_ekf_default_scenario();
truth = simulate_battery_soc_ekf_example();
estimate = estimate_battery_soc_ekf(...
    truth.truth.time_s, truth.truth.current_A, ...
    truth.measured_voltage_V, modelParameters, filterOptions);
```

For the compact no-plot contract use
[`check_battery_soc_ekf.m`](../../examples/battery-soc-ekf/check_battery_soc_ekf.m);
for the prescribed bias grid use
[`check_battery_soc_ekf_current_bias.m`](../../examples/battery-soc-ekf/check_battery_soc_ekf_current_bias.m).
The plotting runners clear workspace state and close open figures, so save
important work before running them. The example's current benchmark reports
about 0.0066 SOC RMSE and 1.581 mV posterior voltage RMSE in the source
validation record; label such numbers as benchmark expectations rather than
newly validated results here.

![Existing SOC-EKF example: truth, estimate and voltage residuals](../../assets/battery-soc-ekf-response.png)

*Figure 4.1 — Stored synthetic SOC-estimation result. A posterior residual
already uses the voltage correction and is not an out-of-sample prediction.*

## Limits and responsible tuning

An EKF linearizes a nonlinear model locally. Piecewise-linear OCV makes the
implementation transparent, but slope changes at lookup breakpoints can make
the local approximation abrupt. SOC is weakly observable when OCV slope is
small. If the filter and plant use the same parameters, convergence may look
stronger than it would under capacity, resistance, temperature, or OCV
mismatch.

The process and measurement covariances are tuning assumptions. Increasing
measurement variance makes voltage corrections weaker; increasing process
noise lets the estimate move more readily when the model is uncertain. Neither
choice creates information absent from the current/voltage record. Covariance
positive-semidefiniteness and finite innovation variance are useful numerical
checks, not proof of statistical consistency.

This two-state filter omits hysteresis, ageing, temperature, self-discharge,
cell variation, and current-bias estimation. Chapter 5 adds an explicit
hysteresis state. The example is an educational estimator and not a BMS safety
function or a substitute for sensor diagnostics and independent cell
validation.

## Recap

The state is $[SOC,V_{rc}]^T$. At each timestamp the EKF predicts voltage from
the prior, performs a Joseph-form correction, and only then propagates through
the next current-held interval with the exact RC decay. The OCV slope supplies
the SOC sensitivity in $H$. A prescribed current-bias study demonstrates
sensitivity; it does not turn the two-state filter into a bias estimator or
rejection mechanism.

## Exercises

### Exercise 1 — Conceptual: read the innovation

Why is the innovation computed from the prior state at a timestamp rather than
from the already propagated next state? What do the two entries of
$H=[dOCV/dSOC,-1]$ mean physically?

### Exercise 2 — Analytical: one scalar voltage correction

Use prior state $x^-=[0.60;0.020]$, prior covariance
$P^-=\operatorname{diag}(0.01^2,0.01^2)$, OCV slope 0.8 V/SOC,
measurement variance $R_v=0.01^2$ V$^2$, prior OCV 3.78 V, $R_0I=0.03$ V,
and measured voltage 3.55 V. Compute predicted voltage, innovation, $S$,
the gain, and posterior state, rounding the gain to four decimals.

### Exercise 3 — Code/reproduction: assert the covariance contract

Using `battery_soc_ekf_default_scenario` and the existing scenario simulator,
write MATLAB checks that every posterior covariance is symmetric within
$10^{-12}$, has minimum eigenvalue at least $-10^{-12}$, and every
`innovation_variance_V2` is positive. State why these checks are related to
the Joseph form.

### Exercise 4 — Interpretation and limits: what does a +0.25 A bias mean?

Explain what the prescribed (+0.25) A case changes in the estimator and what
it does not do. If the resulting SOC error improves after voltage correction,
why is it still incorrect to say that the filter estimated the current bias?
