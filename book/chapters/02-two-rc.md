# Chapter 2 — Two RC Time Scales

**Book navigation:** [book contents](../README.md) · [worked solutions](../solutions/02-two-rc.md) · [Chapter 1: one RC](01-one-rc.md)

**Snapshot identity:** code and numerical expectations are tied to the repository snapshot in [source-map.md](../source-map.md).

## Why one transient may not be enough

Look at a current pulse followed by rest. A battery voltage often jumps at the
edge, moves quickly over the next few seconds, and then continues drifting over
many tens of seconds. A single $R-C$ branch can compromise between those
shapes, but the compromise hides an important distinction: a fast polarization
process and a slow recovery process. A two-RC equivalent-circuit model makes
that distinction explicit while preserving the simple SOC and voltage balance
from Chapter 1.

The repository implementation is
[`simulate_battery_2rc_model`](../../examples/battery-2rc-model/simulate_battery_2rc_model.m),
and its defaults are supplied by
[`battery_2rc_default_parameters`](../../examples/battery-2rc-model/battery_2rc_default_parameters.m).
The two-branch simulator delegates profile validation, OCV interpolation, SOC
integration, and SOC-boundary current limiting to the established one-RC
simulator, then propagates the additional slow branch and recomputes voltage.
That reuse is an engineering choice: one definition of current limiting and
time-grid behavior is easier to review than two nearly identical state loops.

### Prerequisites and notation

This chapter assumes Chapter 1, first-order linear systems, and basic MATLAB
tables. Let $v_{1,k}$ and $v_{2,k}$ denote the fast and slow polarization
voltages. The symbols are:

| Symbol | Meaning | Units |
| --- | --- | --- |
| $Q,z_k,I_k,\Delta t_k$ | capacity, SOC, applied current, interval | Ah, 1, A, s |
| $R_0$ | instantaneous series resistance | $\Omega$ |
| $R_i,C_i$ | branch $i$'s resistance and capacitance | $\Omega$, F |
| $\tau_i=R_iC_i$ | branch $i$'s time constant | s |
| $a_{i,k}=e^{-\Delta t_k/\tau_i}$ | branch decay factor | 1 |
| $V_{\mathrm{oc}}(z)$ | SOC-dependent OCV | V |
| $V_t$ | terminal voltage | V |

The sign convention remains positive current for discharge. Both polarization
voltages are positive on a positive pulse when they start at rest, so both lower
terminal voltage.

## Deriving two exact branch updates

Each branch obeys the same first-order equation as the branch in Chapter 1:

$$
\tau_i\dot v_i(t)+v_i(t)=R_iI(t),
\qquad \tau_i=R_iC_i,\qquad i\in\{1,2\}.
$$

Topologically, each $R_i$-$C_i$ pair is a parallel polarization branch, and
the branch voltage is placed in series with the ideal OCV source and $R_0$ in
the terminal path. The parallel branch is why both elements see the same
polarization voltage while their combined dynamic response has time constant
$R_iC_i$. Calling the pair a “series RC” would describe a different circuit
and would not lead to the state equation used here.

The input current is held at $I_k$ over $[t_k,t_{k+1})$. Solving the
constant-input equation gives

$$
v_{i,k+1}=a_{i,k}v_{i,k}+R_i(1-a_{i,k})I_k,
\qquad a_{i,k}=e^{-\Delta t_k/\tau_i}.
$$

The two states are independent conditional on current. They are coupled to
the rest of the model only through the shared applied current and the terminal
voltage sum. The complete voltage equation is

$$
V_{t,k}=V_{\mathrm{oc}}(z_k)-R_0I_k-v_{1,k}-v_{2,k}.
$$

The SOC update is unchanged:

$$
z_{k+1}=\operatorname{clip}_{[0,1]}\left(z_k-
\frac{I_k\Delta t_k}{3600Q}\right).
$$

The word “exact” has a narrow meaning here: the update is exact for a
zero-order-held current and fixed parameters during each interval. It does not
mean exact physical-cell behaviour. A coarse interval can still erase detail
about a changing current if the profile did not sample that change.

## Interpreting fast and slow branches

The branch time constants determine how quickly each state moves. For the
defaults, $R_1=0.0015~\Omega$, $C_1=1200~\mathrm{F}$,
$R_2=0.0025~\Omega$, and $C_2=12000~\mathrm{F}$. Therefore

$$
\tau_1=0.0015(1200)=1.8~\mathrm{s},\qquad
\tau_2=0.0025(12000)=30~\mathrm{s}.
$$

At steady 20 A discharge, the branches approach 30 mV and 50 mV,
respectively. A branch with the larger resistance does not necessarily move
faster; speed is controlled by the product $RC$. Conversely, a large
capacitance does not mean a large voltage drop by itself. It contributes to
the time constant together with resistance.

Consider a 1-second interval from zero polarization under 10 A. The fast
branch has $a_1=e^{-1/1.8}\approx0.57375$, so

$$
v_{1,1}=0.0015(1-0.57375)(10)\approx6.394~\mathrm{mV}.
$$

The slow branch has $a_2=e^{-1/30}\approx0.96722$, giving

$$
v_{2,1}=0.0025(1-0.96722)(10)\approx0.820~\mathrm{mV}.
$$

The fast branch accounts for most of the first-second transient. If current
then goes to zero, both branches decay, but the slow branch remains visible
longer. After 30 seconds of rest, its magnitude is divided by $e$, while
the fast branch has undergone roughly 16.7 time constants and is nearly gone.

This separation is useful for teaching pulse interpretation: the immediate
edge is mostly $R_0$, early recovery is associated with the fast branch, and
late recovery is associated with the slow branch. It is not a unique physical
decomposition. Different combinations of parameters can produce similar
voltage traces, especially when the profile does not contain both short and
long rest windows.

## Initial conditions and rest

The example starts both RC states at zero. “Rested state” means the model's
polarization voltages have been allowed to relax to zero under zero current;
it does not mean SOC is known exactly or the cell has reached every
electrochemical equilibrium. If the real cell begins immediately after a
previous pulse, setting $v_1=v_2=0$ creates an initial-condition mismatch.
The simulator API does not expose nonzero branch initial states, so a workflow
that needs them should extend the source deliberately and add checks for the
new contract rather than silently editing returned arrays.

At zero current, each update becomes

$$
v_{i,k+1}=e^{-\Delta t_k/\tau_i}v_{i,k}.
$$

After sufficiently long rest, both approach zero and terminal voltage tends
toward OCV. During a charge pulse $I_k<0$, the steady branch voltages are
negative and the terms (-v_{i,k}) can raise terminal voltage above OCV. This
sign symmetry follows the compact model, but real batteries can show charge/
discharge asymmetry, hysteresis, and rate dependence that require other states.

## The shared SOC-boundary limiter

The two-RC model uses exactly the one-RC model's requested/applied distinction.
At the start of each interval, requested current is clipped using SOC and
capacity:

$$
-\frac{(1-z_k)Q3600}{\Delta t_k}\le I_k\le
\frac{z_kQ3600}{\Delta t_k}.
$$

That applied $I_k$ feeds coulomb counting and both exponential branch
updates. Consequently, when a low-SOC cell cannot sustain a requested pulse,
neither the SOC nor polarization states pretend that the full request occurred.
The output fields retain `requested_current_A`, `current_A`, and
`current_limited`, so a user can distinguish command shaping from model
response. The limiter still says nothing about maximum C-rate, temperature,
converter saturation, overvoltage, or cell safety.

There are $N-1$ intervals for $N$ timestamps. The final timestamp has no
following duration. It may carry a current value for signal completeness, but
it contributes neither charge nor branch update after the record ends. The
result's `interval_s` and cumulative charge fields make this boundary explicit.

## One primary workflow: compare branches on the committed pulse

From the repository root, use the existing runner or the reusable function:

```matlab
addpath('examples/battery-2rc-model');
profile = readtable('examples/battery-rc-model/data/pulse_current_profile.csv');
parameters = battery_2rc_default_parameters();
result = simulate_battery_2rc_model(profile, parameters, 1);
fprintf('tau = %.1f and %.1f s\n', result.branch_time_constants_s);
```

The source example's plotting entry point is
[`run_battery_2rc_model.m`](../../examples/battery-2rc-model/run_battery_2rc_model.m),
and its no-plot check is
[`check_battery_2rc_model.m`](../../examples/battery-2rc-model/check_battery_2rc_model.m).
The plotting script clears workspace variables and closes figures; save
important state before invoking it. The existing figure
[`battery-2rc-identification-response.png`](../../assets/battery-2rc-identification-response.png)
belongs to the identification workflow, while a two-branch pulse figure may
be generated by the runner; no figure in this chapter is newly fabricated.

At this snapshot, the source/check expectation for the canonical profile is
final SOC near 0.767, with peak fast and slow polarization reported around
0.075 V and 0.125 V. Treat those as reproducibility expectations, not newly
validated results or physical-cell estimates. The most instructive local
checks are equality of one-RC and two-RC SOC/current/first-branch traces,
voltage reconstruction from the four terms, exact constant-current updates,
and faster relaxation of branch 1.

## Limitations and model selection

Two branches improve shape flexibility, not truth by decree. The model still
assumes fixed parameters, a fixed OCV curve, constant temperature, nominal
capacity, zero initial branch states, and no hysteresis, ageing, self-discharge,
cell variation, or sensor error. Parameter trade-offs are common: a larger
$R_0$ can resemble a short fast branch if the sampling interval is too coarse;
a slow branch can absorb OCV drift if the OCV input is wrong. Chapter 3
therefore fits time constants and resistances with a pulse-rich calibration
record and tests the result on an independent record.

If the question is only “how does a pulse create an immediate and one-scale
recovery?”, Chapter 1 is easier to audit. If late recovery matters, two branches
are a useful next model. If the question is SOC estimation under noisy voltage,
Chapter 4 adds an EKF while retaining the one-RC state pipeline. Hysteresis is
addressed in Chapter 5 rather than hidden inside either branch.

## Recap

Two independent RC states produce two exact ZOH updates and a terminal voltage
$V_t=V_{oc}-R_0I-v_1-v_2$. The approved defaults give 1.8 s and 30 s time
constants, separating fast and slow recovery. The SOC update, requested/applied
current logic, irregular time support, and terminal-timestamp convention are
shared with the one-RC model. Extra flexibility is useful only when the current
profile and experiment contain enough information to distinguish both scales.

## Exercises

### Exercise 1 — Conceptual: what does each time scale explain?

Rank $R_0$, the fast branch, and the slow branch by when their voltage effect
appears after a discharge step. Explain why a large $C_2$ does not by itself
mean a large slow voltage drop.

### Exercise 2 — Analytical: two exact updates

Start at $v_{1,k}=v_{2,k}=0$. Use $I_k=10$ A for
$\Delta t=1$ s, $R_1=0.0015~\Omega$, $\tau_1=1.8$ s,
$R_2=0.0025~\Omega$, and $\tau_2=30$ s. Compute $a_1,a_2,v_{1,k+1}$,
and $v_{2,k+1}$, reporting branch voltages in mV to three decimals.

### Exercise 3 — Code/reproduction: prove branch and voltage consistency

Using the existing two-RC simulator and the committed pulse profile, write
assertions that (a) `branch_time_constants_s` equals
`[r1_Ohm*c1_F, r2_Ohm*c2_F]`, and (b) terminal voltage equals OCV minus the
ohmic and two branch drops. State which current signal must be used.

### Exercise 4 — Interpretation and limits: a profile that reaches empty

Let $Q=1$ Ah, $z_k=0.10$, $\Delta t=3600$ s, and request 1 A discharge.
The two-RC model has $R_0=0.004~\Omega$, $R_1=0.0015~\Omega$,
$C_1=1200$ F, $R_2=0.0025~\Omega$, $C_2=12000$ F, and OCV 3.70 V.
Find the applied current and the first-sample terminal voltage if both branch
states are rested. Why should a real BMS add another limit?
