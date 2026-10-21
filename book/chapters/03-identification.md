# Chapter 3 — Identifying Two-RC Parameters from Pulse Data

**Book navigation:** [book contents](../README.md) · [worked solutions](../solutions/03-identification.md) · [Chapter 2: two RC](02-two-rc.md)

**Snapshot identity:** the implementation and benchmark numbers below are bound to the commit recorded in [source-map.md](../source-map.md).

## The identification question

In Chapters 1 and 2, $R_0,R_1,C_1,R_2,C_2$ were known inputs. In practice,
we often have a current record and measured terminal voltage, and need a set of
parameters that explains the response. This is an identification problem, not
just a curve-fitting exercise: the experiment must excite the states, the OCV
contribution must be separated from dynamic voltage drop, and the fitted model
must be tested on data that did not choose its parameters.

The repository's toolbox-free workflow is implemented by
[`fit_battery_2rc_parameters`](../../examples/battery-2rc-model/fit_battery_2rc_parameters.m),
with deterministic records built by
[`build_battery_2rc_fit_scenario`](../../examples/battery-2rc-model/build_battery_2rc_fit_scenario.m)
and evaluated by
[`evaluate_battery_2rc_fit`](../../examples/battery-2rc-model/evaluate_battery_2rc_fit.m).
The accompanying [example README](../../examples/battery-2rc-model/README.md)
and [tutorial](../../docs/two-rc-battery-parameter-identification.md) describe
the same source workflow. The key design is to search the two nonlinear time
constants while solving the three resistances with linear least squares.

### Prerequisites and notation

You should know the two-RC state equations, least-squares notation, and basic
conditioning concepts. The fit input is a table with equal-length columns:

| Column | Meaning |
| --- | --- |
| `time_s` | strictly increasing timestamps |
| `current_A` | applied current, positive for discharge |
| `ocv_V` | independently estimated OCV at each timestamp |
| `terminal_voltage_V` | voltage record to explain |

Use $y_k=V_{\mathrm{oc},k}-V_{t,k}$ for the measured voltage drop. Let
$x_{\tau,k}$ be the unit-resistance polarization basis produced by current
and a candidate time constant $\tau$. It has units of amperes and obeys

$$
x_{\tau,0}=0,
\qquad x_{\tau,k+1}=e^{-\Delta t_k/\tau}x_{\tau,k}
 +(1-e^{-\Delta t_k/\tau})I_k.
$$

The rested-state assumption $x_{\tau,0}=0$ is part of this fitter's contract.

## Why independent OCV is necessary

The voltage drop caused by current is not the same thing as the SOC-dependent
equilibrium voltage. If OCV is wrong by a slowly varying amount, the fitter can
misuse $R_0$ or a slow RC branch to explain that error. The function therefore
requires `ocv_V` as an input rather than trying to estimate OCV and dynamics in
one underconstrained step. “Independent” means justified separately from the
same voltage residual being fit: for example, a rest-based lookup or a
calibrated OCV relation. It does not mean the bundled synthetic OCV is a
physical measurement.

Subtracting terminal voltage from OCV gives

$$
y_k=R_0I_k+R_1x_{\tau_1,k}+R_2x_{\tau_2,k}+\epsilon_k,
$$

where $\epsilon_k$ collects measurement noise and model mismatch. For fixed
$\tau_1,\tau_2$, define

$$
X(\tau_1,\tau_2)=
\begin{bmatrix}I & x_{\tau_1} & x_{\tau_2}\end{bmatrix},
\qquad
r=\begin{bmatrix}R_0\\R_1\\R_2\end{bmatrix}.
$$

Then $y\approx Xr$, and the ordinary least-squares estimate is

$$
\hat r=\arg\min_r\|y-Xr\|_2^2.
$$

The MATLAB backslash operator computes this solve without forming an explicit
inverse. Once $R_i$ and $\tau_i$ are known, capacitances follow from

$$
C_1=\frac{\tau_1}{R_1},\qquad C_2=\frac{\tau_2}{R_2}.
$$

## Search the nonlinear part, solve the linear part

The fitter constructs a logarithmic coarse grid. Its lower bound is

$$
\tau_{\min}=\max(0.1\min_k\Delta t_k,0.05~\mathrm{s}),
$$

and its upper bound is $\tau_{\max}=0.5(t_{N}-t_1)$. The source uses 36
points for each axis. It tests ordered pairs with

$$
\tau_2\ge1.5\tau_1,
$$

which prevents the two columns from being intentionally identical. After the
best coarse pair is found, three refinement passes search 18 logarithmically
spaced points around each current estimate. The search count and bounds are
returned in `fitResult.search`, making the computational contract inspectable.

For every candidate pair, the fitter builds the two bases, forms $X$, solves
$X\hat r=y$, and rejects candidates that are not numerically usable or that
violate simple positivity bounds. Each resistance must exceed $10^{-7}\Omega$
and remain below $0.5\Omega$. It also rejects a candidate when

$$
\operatorname{rcond}(X^TX)<10^{-12}.
$$

This is a screening rule, not a proof of identifiability. The selected design
condition number is returned as `metrics.design_condition_number`; a very large
value means small voltage perturbations can cause large parameter changes.

Strict positivity is pedagogically useful. A negative resistance can reduce
least-squares error on a poorly excited or mismatched record while having no
meaning in this passive ECM. Rejecting it makes a fit fail visibly rather than
quietly returning an unphysical model. It does not ensure that the remaining
positive fit is physically correct.

## A synthetic calibration and a held-out record

The source scenario deliberately creates two records from one parameter set.
The true synthetic parameters are $R_0=0.0042~\Omega$,
$R_1=0.0022~\Omega$, $C_1=900~\mathrm{F}$,
$R_2=0.0038~\Omega$, and $C_2=9000~\mathrm{F}$. Thus the true time
constants are 1.98 s and 34.2 s. The calibration profile includes pulses at
0–35 A and a -20 A segment over 600 s. The validation profile has different
timings and levels, including both charge and discharge. Both synthetic
voltage records receive deterministic sinusoidal perturbations; the validation
record uses a different phase.

Only `scenario.calibration_data` goes into the fitter. The independent
`validation_data` is passed later to `evaluate_battery_2rc_fit`. That separation
answers a more useful question than “can the algorithm fit its own record?”
It tests whether the selected time scales and resistances transfer to a new
current sequence under the same stated OCV and initial-rest assumptions.

The source/check expectation at this snapshot is about 0.401 mV calibration
RMSE, 0.440 mV held-out RMSE, and estimated time constants 2.01 s and 33.88 s.
These are benchmark values for the committed synthetic case, not newly
validated by this manuscript and not evidence of physical-cell accuracy. The
figure below shows the stored calibration/held-out comparison and residuals.

![Existing two-RC calibration and held-out voltage comparison](../../assets/battery-2rc-identification-response.png)

*Figure 3.1 — Stored synthetic identification result. Compare residual structure
as well as the aggregate error; this is not measured-cell validation.*

## One primary workflow: fit, evaluate, diagnose

Run the existing no-plot check from the repository root:

```matlab
addpath('examples/battery-2rc-model');
scenario = build_battery_2rc_fit_scenario();
fitResult = fit_battery_2rc_parameters(...
    scenario.calibration_data, scenario.initial_parameters);
calibration = evaluate_battery_2rc_fit(...
    scenario.calibration_data, fitResult.parameters);
heldout = evaluate_battery_2rc_fit(...
    scenario.validation_data, fitResult.parameters);
fprintf('%.3f mV / %.3f mV\n', ...
    1000*calibration.metrics.rmse_V, 1000*heldout.metrics.rmse_V);
```

Use repository-root paths as shown and the current source APIs. The plotting
entry point [`run_battery_2rc_fit.m`](../../examples/battery-2rc-model/run_battery_2rc_fit.m)
clears workspace variables and closes figures, so preserve unsaved state before
running it. The deterministic check is
[`check_battery_2rc_fit.m`](../../examples/battery-2rc-model/check_battery_2rc_fit.m).
It verifies positivity, bounded recovery, held-out error, conditioning,
repeatability, and malformed-input rejection.

When a fit fails, inspect the record before changing bounds. A flat or nearly
constant current record cannot distinguish $R_0$ from RC response. A record
shorter than roughly four lower-bound time constants is rejected by design. A
single pulse sampled too slowly cannot reveal a fast branch. If calibration
error is small but held-out error is much larger, suspect overfitting, initial
state mismatch, wrong OCV, parameter drift, or a validation profile outside
the experiment's excitation range.

Before fitting a measured table, check the data contract explicitly. Timestamps
must be strictly increasing and use seconds; current must use the same positive-
discharge convention as the simulator; voltage and OCV must be in volts; and
all four columns must be finite and equal in length. Do not silently sort rows:
sorting current and voltage independently can destroy the pulse alignment that
creates the design matrix. If the record contains a known sensor offset, decide
whether to remove it from a documented calibration or to include a bias term in
a deliberately extended model. The current fitter does neither automatically.

The residual should be inspected as a time trace, not reduced immediately to
one RMSE. A sharp residual at current edges suggests an $R_0$ or sample-time
problem; a long residual tail suggests an unresolved time scale or nonzero
initial polarization; and a residual that follows SOC suggests OCV error. A
residual pattern that changes sign between charge and discharge is a reason to
consider hysteresis (Chapter 5), not evidence that a negative resistance is
appropriate. These diagnostics connect numerical fitting back to experiment
design and help prevent an attractive but uninformative least-squares answer.

## Conditioning, identifiability, and limitations

Two time constants are only informative when the current excites both. Long
rests help reveal slow recovery; fine sampling helps reveal fast recovery;
charge and discharge transitions provide sign-rich excitation. Still, a
different pair of time constants may produce a similar voltage waveform over a
limited record. The $R$-$C$ conversion can amplify uncertainty when a
resistance estimate is small, because $C=\tau/R$.

This workflow assumes known OCV, rested initial RC states, fixed temperature,
constant parameters, no hysteresis, no sensor bias, and no capacity fitting.
It does not estimate uncertainty intervals, account for correlated noise, fit
temperature dependence, or jointly select model order. Positive least squares
and a condition-number threshold are guardrails, not a substitute for an
experimental design or physical validation. The records bundled here are
synthetic and illustrative. A cell-specific result needs independently
justified OCV, measured calibration and held-out profiles, temperature control
or modelling, uncertainty reporting, and checks against nonzero initial states.

## Recap

With independent OCV, the two-RC voltage-drop equation is linear in three
resistances once two time constants are fixed. The source searches time
constants on a logarithmic grid, solves resistances by least squares, screens
for positivity and conditioning, converts $\tau/R$ to capacitance, then
evaluates an untouched record. Calibration fit alone is insufficient: held-out
performance, excitation richness, and OCV quality determine whether the model
is informative.

## Exercises

### Exercise 1 — Conceptual: why split the record?

Explain why a low calibration RMSE does not by itself establish a useful
two-RC model. Give two different features of a held-out record that can reveal
weak identifiability or mismatch.

### Exercise 2 — Analytical: fixed-time-constant least squares

Suppose one candidate pair gives the design matrix and drop vector

$$
X=\begin{bmatrix}10&2&1\\0&1&2\\5&1&3\end{bmatrix},
\qquad y=\begin{bmatrix}0.050\\0.014\\0.040\end{bmatrix}\mathrm{V}.
$$

Find the least-squares resistance vector $\hat r$ (it is an exact solution
here), check positivity, and state the capacitance formula for known
$\tau_1,\tau_2$.

### Exercise 3 — Code/reproduction: calibration versus held-out

Write MATLAB commands using `build_battery_2rc_fit_scenario`,
`fit_battery_2rc_parameters`, and `evaluate_battery_2rc_fit` so that only
`calibration_data` is fitted and both records are evaluated afterward. Add an
assertion that the selected time constants are ordered and all fitted
resistances/capacitances are positive.

### Exercise 4 — Interpretation and limits: conditioning

If a selected design matrix has condition number $2.5\times10^6$, while the
source check requires it below $10^4$, what does that tell you? Name two
changes to the experiment that could improve conditioning, and one change that
would not fix wrong OCV.
