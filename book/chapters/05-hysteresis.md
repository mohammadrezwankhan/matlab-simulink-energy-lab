# Chapter 5 — OCV Hysteresis and a Three-State EKF

**Book navigation:** [book contents](../README.md) · [worked solutions](../solutions/05-hysteresis.md) · [Chapter 4: SOC EKF](04-soc-ekf.md)

**Snapshot identity:** the current implementation and illustrative comparison are identified in [source-map.md](../source-map.md).

## Why equilibrium voltage can remember history

The one-RC voltage model assumes one OCV for each SOC. Real cells can show a
charge/discharge voltage gap at the same SOC. That gap is often called OCV
hysteresis. It is distinct from the dynamic polarization state: hysteresis can
remain as a history-dependent equilibrium offset after the RC voltage has
relaxed. If a two-state SOC EKF is given a hysteretic voltage record, it may
explain part of that offset by moving SOC. How much it moves depends on OCV
slope, state covariance and the uncertainty assigned to the voltage measurement.

This chapter adds a normalized memory state $h$ and uses the repository's
three-state estimator
[`estimate_battery_soc_hysteresis_ekf`](../../examples/battery-soc-hysteresis-ekf/estimate_battery_soc_hysteresis_ekf.m)
as the primary workflow. The synthetic plant is
[`simulate_battery_ocv_hysteresis`](../../examples/battery-ocv-hysteresis/simulate_battery_ocv_hysteresis.m);
its parameters and reversal profile are in
[`battery_hysteresis_default_parameters`](../../examples/battery-ocv-hysteresis/battery_hysteresis_default_parameters.m)
and [`battery_hysteresis_default_profile`](../../examples/battery-ocv-hysteresis/battery_hysteresis_default_profile.m).
The estimator options are supplied by
[`battery_soc_hysteresis_ekf_default_options`](../../examples/battery-soc-hysteresis-ekf/battery_soc_hysteresis_ekf_default_options.m).

The prerequisite is important: a dynamic OCV hysteresis model needs a
justified mean-OCV curve and reversal-rich data. A single monotonic pulse does
not establish the charge/discharge memory law. The repository comparison is an
illustrative synthetic benchmark, not a physical-cell identification.

### Prerequisites and notation

You should understand Chapters 1 and 4, first-order state updates, and EKF
linearization. The state is

$$
x_k=\begin{bmatrix}z_k\\v_k\\h_k\end{bmatrix},
$$

where $z$ is SOC, $v$ is dynamic RC polarization voltage, and
$h\in[-1,1]$ is dimensionless normalized hysteresis. Let $M\ge0$ be the
maximum hysteresis voltage magnitude. The mean OCV is $V_{\mathrm{mean}}(z)$,
interpolated from a single lookup table. Current is positive for discharge.

The source defaults use capacity 50 Ah, $R_0=0.004~\Omega$,
$R_1=0.002~\Omega$, $C_1=2400~\mathrm{F}$, $M=0.025$ V, and hysteresis
rate $\gamma=15$ per unit fractional throughput. These values are
educational and deterministic, not cell-specific.

## A dynamic hysteresis state

For nonzero current, define the direction target

$$
h_{\mathrm{target},k}=-\operatorname{sign}(I_k).
$$

Positive discharge drives $h$ toward $-1$, while negative charge drives it
toward $+1$. Let fractional throughput over an interval be

$$
\delta_k=\frac{|I_k|\Delta t_k}{3600Q}.
$$

The source uses an exact directional relaxation:

$$
\rho_k=e^{-\gamma\delta_k},
\qquad
h_{k+1}=h_{\mathrm{target},k}+(h_k-h_{\mathrm{target},k})\rho_k.
$$

This form has intuitive limits. With a tiny interval or tiny current,
$(\rho\approx1)$, so $h$ changes little. With enough throughput,
$(\rho\to0)$, so $h$ approaches the current-direction target. At rest,
$(I_k=0)$, the source holds $h_{k+1}=h_k$ exactly. It also holds the state
when $\gamma=0$. The state is clipped to $[-1,1]$ after updates, although
the exact convex combination already stays in that interval for bounded $h$
and target.

The hysteresis voltage is

$$
V_{\mathrm{hys},k}=Mh_k.
$$

The equilibrium voltage before dynamic drops is therefore

$$
V_{\mathrm{eq},k}=V_{\mathrm{mean}}(z_k)+Mh_k.
$$

The complete terminal equation is

$$
V_{t,k}=V_{\mathrm{mean}}(z_k)+Mh_k-R_0I_k-v_k.
$$

At the same SOC, $h=+1$ is $2M$ higher than $h=-1$: the same-SOC
equilibrium gap is $2M$, or 50 mV for $M=25$ mV. That gap is a model
parameter; it does not assert that every cell has a 50 mV hysteresis window.

## The three-state EKF equations

The estimator follows the Chapter 4 sequence: correct at a timestamp using the
prior, then propagate to the next timestamp. The prior predicted measurement is

$$
\hat y_k=V_{\mathrm{mean}}(z_k^-)+Mh_k^--R_0I_k-v_k^-.
$$

If $s_k=dV_{\mathrm{mean}}/dz$ on the active lookup segment, the measurement
Jacobian becomes

$$
H_k=\begin{bmatrix}s_k&-1&M\end{bmatrix}.
$$

This adds a direct voltage sensitivity to hysteresis. The innovation, scalar
innovation variance, gain, and Joseph correction are

$$
\nu_k=y_k-\hat y_k,
\qquad S_k=H_kP_k^-H_k^T+R_v,
$$

$$
K_k=P_k^-H_k^TS_k^{-1},
\qquad x_k^+=x_k^-+K_k\nu_k,
$$

$$
P_k^+=(I-K_kH_k)P_k^-(I-K_kH_k)^T+K_kR_vK_k^T.
$$

After correction, SOC and $h$ are bounded to $[0,1]$ and $[-1,1]$.

For the next interval, the exact state propagation is

$$
\begin{aligned}
z_{k+1}^-&=z_k^+-\frac{I_k\Delta t_k}{3600Q},\\
v_{k+1}^-&=a_kv_k^++R_1(1-a_k)I_k,\\
h_{k+1}^-&=h_{\mathrm{target},k}+(h_k^+-h_{\mathrm{target},k})\rho_k,
\end{aligned}
$$

with $a_k=e^{-\Delta t_k/(R_1C_1)}$, and $h_{k+1}^-=h_k^+$ at rest. The
linearized transition used for covariance propagation is

$$
F_k=\operatorname{diag}(1,a_k,\rho_k),
\qquad P_{k+1}^-=F_kP_k^+F_k^T+Q_c\Delta t_k.
$$

The source stores prior and posterior states/covariances, innovations,
innovation variances, normalized innovation squared, and Kalman gains. Those
fields make the correction/propagation order auditable.

## Why reversal-rich data is a prerequisite

Suppose a profile discharges and later charges back to approximately the same
SOC. Without hysteresis, the equilibrium voltages would coincide once $v$
relaxed. With this model, the voltage depends on the direction memory $h$.
The reversal gives the data a chance to distinguish SOC movement from history
offset. Long zero-current intervals are also valuable: $v$ decays but $h$
holds, so the experiment separates dynamic polarization from the persistent
hysteresis state.

The source plant's profile contains 30 A discharge and charge segments with
rest intervals and later reversals. It generates a deterministic measurement
noise signal from two sinusoids and feeds the same voltage/current record to the
three-state estimator and the two-state baseline. This isolates a structural
mismatch in a controlled setting. The baseline is not a straw-man safety
function; it is the Chapter 4 filter deliberately run without $h$.

The source/check expectation is approximately:

| Metric | Hysteresis-aware EKF | Two-state baseline |
| --- | ---: | ---: |
| SOC RMSE | 0.0023 | 0.0203 |
| Final SOC error | +0.0005 | +0.0285 |
| Posterior voltage RMSE | 0.589 mV | 3.672 mV |

These values are source/check expectations for an illustrative synthetic
comparison, not newly validated results and not a physical-cell claim. The
figure below is a stored source asset showing that comparison.

![Existing comparison of hysteresis-aware and two-state SOC estimators](../../assets/battery-soc-hysteresis-ekf-response.png)

*Figure 5.1 — The two estimators receive the same synthetic record. Their
difference isolates the declared model mismatch, not general BMS accuracy.*

The comparison is easiest to read in two phases. During a directional pulse,
the three-state filter propagates SOC and RC polarization while $h$ moves
toward the direction target. During rest, the RC state decays but $h$ holds,
so the estimator has a persistent voltage component available to explain the
remaining offset. At a reversal, the target changes sign; the state does not
jump instantly, which is why a reversal-rich record contains information about
the rate parameter $\gamma$. If the record has no rest, the slow RC state and
hysteresis state can both look like long voltage tails. If it has no reversal,
the target direction is never challenged. In either case, a lower residual may
be obtained without a well-identified decomposition.

A useful reduction check is to set $M=0$. The hysteresis voltage then vanishes,
and the three-state measurement equation reduces in voltage to the two-state
equation. The extra state can still have a numerical trajectory, but it cannot
affect terminal voltage. The source check uses this reduction to compare the
SOC result against the established two-state estimator. Such limiting-case
checks are valuable whenever a model adds a state: they show that a new feature
has a controlled zero-effect limit rather than silently changing older behavior.

## One primary workflow: model the state, then compare honestly

From the repository root, the reusable sequence is:

```matlab
addpath('examples/battery-ocv-hysteresis');
addpath('examples/battery-soc-hysteresis-ekf');
parameters = battery_hysteresis_default_parameters();
profile = battery_hysteresis_default_profile();
truth = simulate_battery_ocv_hysteresis(profile, parameters, 1);
[options, baselineOptions] = battery_soc_hysteresis_ekf_default_options();
time_s = truth.time_s;
noise_V = 0.004*sin(2*pi*time_s/37) + 0.002*cos(2*pi*time_s/113);
measured_V = truth.terminal_voltage_V + noise_V;
estimate = estimate_battery_soc_hysteresis_ekf(...
    time_s, truth.current_A, measured_V, parameters, options);
```

For the complete source workflow, use
[`simulate_battery_soc_hysteresis_ekf_example.m`](../../examples/battery-soc-hysteresis-ekf/simulate_battery_soc_hysteresis_ekf_example.m)
and the no-plot contract in
[`check_battery_soc_hysteresis_ekf.m`](../../examples/battery-soc-hysteresis-ekf/check_battery_soc_hysteresis_ekf.m).
The plotting runner clears workspace variables and closes figures, so save
important state before running it. An existing plant figure is also available
as [`battery-ocv-hysteresis-response.png`](../../assets/battery-ocv-hysteresis-response.png).

Inspect `hysteresis_state` during rest: it should hold while `v_rc_V` relaxes.
Inspect the innovation and gain around a reversal: the added $M$ column lets
the correction allocate voltage mismatch to history as well as SOC and RC
polarization. The source check also verifies zero hysteresis magnitude reduces
the three-state result to the two-state estimator for the same inputs.

## Limits and what the model does not prove

The one-state hysteresis law is compact. It omits nested minor-loop operators,
instantaneous hysteresis, temperature dependence, ageing, self-discharge,
cell-to-cell variation, sensor bias, and parameter drift. It assumes a known
mean-OCV curve, fixed $M$ and $\gamma$, and matching plant/estimator
parameters. If $M$ or $\gamma$ is fitted on the same reversal record used
for evaluation, apparent improvement can be optimistic.

Hysteresis adds a state but does not automatically make the system observable.
At a flat mean-OCV segment, SOC remains weakly visible; at rest, $h$ is
constant and the voltage can help distinguish it from $v$ only after the RC
state has relaxed. A suitable experiment needs direction changes, rest, and
independent OCV evidence. Covariances remain tuning assumptions, and bounded
state clipping is practical bookkeeping rather than a full constrained EKF.

The benchmark comparison is intentionally narrow: it demonstrates that a
known omitted voltage-memory mechanism can bias a two-state estimator. It does
not show that the compact hysteresis model is right for a particular cell, nor
that its SOC estimate is safe for a BMS. A cell-specific study requires
measured mean-OCV and charge/discharge curves, calibration/held-out separation,
temperature and ageing coverage, uncertainty analysis, and independent sensor
checks.

## Recap

Dynamic OCV hysteresis requires a history state and reversal-rich evidence. The
source model drives $h$ toward $-1$ on discharge, $+1$ on charge, and holds
it at rest. The three-state EKF corrects $[SOC,V_{rc},h]$ with
$H=[dOCV/dSOC,-1,M]$, then propagates all states exactly over the next
current-held interval. The synthetic comparison is illustrative: it teaches
the consequence of a structural mismatch without claiming physical validation.

## Exercises

### Exercise 1 — Conceptual: distinguish $v$ and $h$

During a zero-current rest interval, what happens to the dynamic RC state $v$
and the hysteresis state $h$? Why does this difference help an experiment
separate the two effects?

### Exercise 2 — Analytical: one hysteresis interval

Use $h_k=0$, $I_k=30$ A discharge, $\Delta t=600$ s,
$Q=50$ Ah, and $\gamma=15$. Compute fractional throughput $\delta$,
decay $\rho$, target, and $h_{k+1}$. Then compute the hysteresis-voltage
contribution for $M=0.025$ V, rounding $h$ to four decimals and voltage to
0.01 mV.

### Exercise 3 — Code/reproduction: check rest holding and bounds

Using `battery_hysteresis_default_parameters`,
`battery_hysteresis_default_profile`, and the plant simulator, write checks
that the normalized state remains in ([-1,1]) and equals its preceding value
across a zero-current interval. Identify the relevant profile indices or use
the timestamp values.

### Exercise 4 — Interpretation and limits: baseline improvement

The source comparison reports lower SOC RMSE for the three-state filter than
the two-state baseline. Explain the structural reason for the improvement and
give two reasons why this does not establish a cell-specific BMS estimator.
