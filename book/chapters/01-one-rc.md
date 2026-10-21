# Chapter 1 — The One-RC Battery Pulse Model

**Book navigation:** [book contents](../README.md) · [worked solutions](../solutions/01-one-rc.md)

**Snapshot identity:** the code and numerical expectations in this chapter are bound to the repository snapshot recorded in [source-map.md](../source-map.md).

## Why start with one RC branch?

A battery terminal is not an ideal voltage source. If a cell is at rest, its
voltage is close to an open-circuit voltage (OCV) set mostly by state of charge
(SOC). The instant a load is connected, the measured terminal voltage also
moves because of ohmic resistance. During the next seconds or minutes, slower
electrochemical and transport effects produce a further transient. A useful
first teaching model keeps those ideas separate without claiming to reproduce
cell chemistry:

1. SOC records net charge removed from or returned to the cell.
2. An OCV lookup maps SOC to an equilibrium voltage.
3. $R_0$ represents an immediate current-dependent drop.
4. One $R_1-C_1$ branch represents a relaxing polarization voltage.

The repository implementation is the reusable Base MATLAB function
[`simulate_battery_rc_model`](../../examples/battery-rc-model/simulate_battery_rc_model.m),
with defaults in
[`battery_rc_default_parameters`](../../examples/battery-rc-model/battery_rc_default_parameters.m).
It accepts a table with `time_s` and `current_A`, keeps irregular timestamps
when requested, and can create a uniform zero-order-held grid. The companion
[README](../../examples/battery-rc-model/README.md) is the operational reference;
this chapter supplies the derivation behind it.

### Prerequisites and notation

You should be comfortable with units, first-order differential equations,
exponentials, and basic MATLAB tables. We use the following notation:

| Symbol | Meaning | Units |
| --- | --- | --- |
| $t_k$ | timestamp of sample $k$ | s |
| $\Delta t_k=t_{k+1}-t_k$ | interval after sample $k$ | s |
| $I_k$ | current held over that interval; positive is discharge | A |
| $Q$ | nominal capacity | Ah |
| $z_k$ | SOC at $t_k$, bounded to $[0,1]$ | 1 |
| $V_{\mathrm{oc}}(z)$ | OCV lookup at SOC | V |
| $R_0$ | ohmic resistance | $\Omega$ |
| $R_1,C_1$ | polarization resistance and capacitance | $\Omega$, F |
| $v_k$ | voltage across the RC branch | V |
| $V_{t,k}$ | terminal voltage at the sample | V |

The sign convention is worth fixing before doing any algebra. Positive current
removes charge, so a discharge should decrease SOC. Negative current is charge
and should increase SOC. This convention is shared by the battery examples,
the identification workflow, and the EKF in later chapters.

## From charge balance to coulomb counting

Current is charge per unit time. Over one interval, zero-order-holding the
sampled current gives the signed charge removed in ampere-hours:

$$
\Delta q_k = \frac{I_k\Delta t_k}{3600}\quad\mathrm{Ah}.
$$

The factor 3600 converts seconds to hours. Dividing by nominal capacity and
subtracting gives the discrete SOC update:

$$
z_{k+1}^{\ast}=z_k-\frac{I_k\Delta t_k}{3600Q}.
$$

The star reminds us that this is the unconstrained result. The simulator then
uses

$$
z_{k+1}=\min\{1,\max\{0,z_{k+1}^{\ast}\}\}.
$$

For a physically feasible interval, the requested current must obey

$$
-\frac{(1-z_k)Q3600}{\Delta t_k}\le I_k\le
\frac{z_kQ3600}{\Delta t_k}.
$$

The lower bound is the most negative (largest charging) current that can fit
inside the remaining charge headroom. The upper bound is the largest discharge
current that can be supplied before SOC reaches zero. This is an energy-boundary
limiter, not a thermal current rating, fuse limit, converter limit, or battery
manufacturer specification.

The distinction between requested and applied current is central. Let $I_k^r$
be the input command and $I_k$ the feasible value after clipping. The
implementation stores both as `requested_current_A` and `current_A`, and uses
the applied value for SOC, polarization, and voltage. If it clipped only SOC
but still used $I_k^r$ in the voltage equation, the result would describe a
cell that delivers an impossible instantaneous voltage after its charge is
already exhausted. `current_limited` records where the two differ.

## The polarization differential equation

The one-RC branch is a parallel $R_1$-$C_1$ polarization submodel placed in
series with the ideal OCV source and $R_0$ in the terminal path. Both parallel
elements see voltage $v$. Current balance splits the branch input between
resistive current $v/R_1$ and capacitive current $C_1\dot v$:

$$
I(t)=\frac{v(t)}{R_1}+C_1\dot v(t).
$$

Multiply by $R_1$ to obtain the state equation for the branch voltage:

$$
\tau\dot v(t)+v(t)=R_1 I(t),\qquad \tau=R_1C_1.
$$

The steady value for constant current $I$ is $R_1I$. A positive discharge
therefore produces a positive $v$ that lowers terminal voltage. When current
goes to zero, the branch decays back toward zero. The time constant $\tau$
sets the meaning of “fast”: after one $\tau$, the distance to the new steady
value is multiplied by $e^{-1}$, or about 0.368.

The exact solution on interval $k$, assuming $I(t)=I_k$ from $t_k$ up to
but not including $t_{k+1}$, is

$$
v_{k+1}=a_kv_k+R_1(1-a_k)I_k,
\qquad a_k=\exp\left(-\frac{\Delta t_k}{R_1C_1}\right).
$$

This is an exact zero-order-hold update, not an Euler approximation. It is
stable for a long interval: as $\Delta t_k$ becomes large, $a_k$ tends to
zero and the state approaches $R_1I_k$. It also handles a short interval
without subtracting a large state increment. The same formula works on
irregular data because each interval gets its own $\Delta t_k$.

For the default $R_1=0.002~\Omega$ and $C_1=2400~\mathrm{F}$,

$$
\tau=4.8~\mathrm{s}.
$$

After a 10 A discharge applied for 4.8 s from a rested branch,
$a=e^{-1}$, so $v_1=0.002(1-e^{-1})10\approx0.01264$ V. This is a
branch drop, not the total terminal-voltage drop: $R_0I$ contributes another
0.04 V for the default $R_0=0.004~\Omega$.

## OCV, ohmic drop, and terminal voltage

The simulator linearly interpolates paired SOC breakpoints and OCV values. For
the default table, $V_{\mathrm{oc}}(z)=3.65+0.10z$ at its sampled breakpoints,
so at $z=0.80$, OCV is 3.73 V. In a measured-cell workflow this table should
come from a justified OCV experiment; the bundled table is an educational
placeholder.

The terminal-voltage balance is

$$
V_{t,k}=V_{\mathrm{oc}}(z_k)-R_0I_k-v_k.
$$

At a positive discharge current, both subtractive terms lower the terminal
voltage. At a negative charge current, (-R_0I_k) is positive and may raise
the terminal voltage relative to OCV, while the branch state eventually becomes
negative and contributes a corresponding charge-side transient. The equation
is a bookkeeping identity for this model, not a guarantee that every physical
cell has symmetric charge and discharge behavior.

The current sample at $t_k$ is the input to the interval beginning at $t_k$.
Therefore, voltage at sample $k$ uses the already accumulated state $v_k$
and the applied $I_k$, while the RC update creates $v_{k+1}$ for the next
sample. This is why the first sample can show an ohmic step even though the RC
state is initially zero.

## The terminal timestamp is not an interval

With $N$ timestamps there are only $N-1$ intervals. The final sample $t_N$
has no duration after it, so it cannot add charge or terminal energy. The
implementation still returns a current at that timestamp for a complete signal.
If SOC is exactly zero and the final requested current points outward (positive
discharge), or SOC is exactly one and the request is negative (charge), the
final current is set to zero and marked limited. Otherwise it is left as the
last command. Either way, charge and energy summaries integrate only samples
1 through $N-1$ with their interval durations.

This convention prevents a common off-by-one error. A 10-second record with
samples at 0, 1, ..., 10 has ten one-second intervals, not eleven. For every
interval the implementation returns `interval_s`,
`interval_net_discharge_Ah`, and cumulative charge. The charge-balance check is

$$
e_{z,k}=z_k-\left(z_0-
\frac{\sum_{j=0}^{k-1}\Delta q_j}{Q}\right).
$$

It should be at numerical roundoff for an interior feasible profile. Near a
boundary, clipping and the applied-current record must be considered together.

## One primary workflow: pulse, inspect, then challenge assumptions

Use the existing first-order example as one coherent workflow:

```matlab
addpath('examples/battery-rc-model');
profile = readtable('examples/battery-rc-model/data/pulse_current_profile.csv');
parameters = battery_rc_default_parameters();
result = simulate_battery_rc_model(profile, parameters, 1);
assert(max(abs(result.terminal_voltage_V - ...
    (result.ocv_V - result.current_A*parameters.r0_Ohm - result.v_rc_V))) < 1e-12)
```

The command uses repository-root paths and invokes the checked implementation,
not a copied state-update loop. For a no-plot reproduction, run
[`check_battery_rc_model.m`](../../examples/battery-rc-model/check_battery_rc_model.m);
for a visual inspection, use
[`run_battery_rc_model.m`](../../examples/battery-rc-model/run_battery_rc_model.m).
The run script clears workspace state and closes open figures, so save anything
important before running it. That state/figure-safety warning applies to the
other plotting scripts in this book as well.

The repository check expects, at this snapshot, a 600-second profile resampled
at 1 Hz, final SOC near 0.767, and terminal voltage approximately 3.425–3.877 V.
Those values are source/check expectations recorded for reproduction; they are
not newly validated by writing this chapter and are not measured-cell claims.
The existing figure below illustrates this source example. Read a current edge
first, then follow the slower voltage recovery while SOC records net charge.

![Existing one-RC pulse example: current, SOC and terminal voltage](../../assets/battery-rc-response.png)

*Figure 1.1 — Stored companion result, not a new measurement or a regenerated
figure from this manuscript pass.*

## Limits that should change your interpretation

The model assumes constant nominal capacity, a fixed OCV-SOC curve, fixed
resistances, fixed temperature, zero initial polarization, no self-discharge,
and a cell represented by one lumped electrical state. It does not model
ageing, rate-dependent capacity, hysteresis, sensor bias, cell imbalance, or
power-electronics constraints. A good voltage trace on the bundled profile
therefore means the equations and implementation are internally consistent;
it does not establish predictive accuracy for a named cell or pack.

The limiter deserves the same care. It prevents SOC from crossing its bounds
under the stated nominal-capacity assumption, but it does not decide whether a
requested current is safe. A real BMS combines electrical, thermal, ageing,
and hardware limits. If you need a second transient time scale, move to Chapter
2. If the parameters themselves are unknown, Chapter 3 separates calibration
from held-out evaluation. If SOC must be corrected using voltage, Chapter 4
introduces an EKF.

## Recap

Positive current is discharge, so coulomb counting subtracts $I\Delta t/(3600Q)$
from SOC. A one-RC polarization state has an exact ZOH exponential update, and
terminal voltage is OCV minus ohmic and polarization drops. Requested and
applied currents must remain distinct when an SOC boundary is reached. Finally,
the last timestamp is a sample, not an interval: it contributes no charge or
energy after the record ends.

## Exercises

### Exercise 1 — Conceptual: identify each voltage contribution

At one sample, $V_{\mathrm{oc}}=3.80$ V, $R_0=5$ m$\Omega$,
$I=12$ A (discharge), and $v=18$ mV. Which terms are instantaneous and
which term carries memory? What is the direction of each terminal-voltage
change relative to OCV?

### Exercise 2 — Analytical: one irregular interval

Use $Q=2.0$ Ah, $z_k=0.75$, $I_k=4$ A, and
$\Delta t_k=30$ s. Let $R_1=0.010~\Omega$, $C_1=1000$ F, and $v_k=0.020$ V.
Compute $z_{k+1}$, $a_k$, and $v_{k+1}$, rounding SOC to five decimals
and voltage to six decimals.

### Exercise 3 — Code/reproduction: verify a balance

Using repository-root MATLAB paths, load the committed pulse profile, simulate
with `battery_rc_default_parameters()` and `dt_s = 1`, and write two assertions:
one for the voltage balance and one for SOC reconstructed from cumulative applied
charge. Which result fields make the assertions possible?

### Exercise 4 — Interpretation and limits: request versus application

Take $Q=1$ Ah, $z_k=0.10$, $\Delta t_k=3600$ s, and request $I_k^r=1$ A.
Find the applied current and next SOC. Explain why using 1 A in the voltage
equation would be misleading, and name one physical limit absent from this
energy-boundary limiter.
