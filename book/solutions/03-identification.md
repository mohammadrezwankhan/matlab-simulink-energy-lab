# Chapter 3 Solutions — Identifying Two-RC Parameters

**Back to chapter:** [Chapter 3](../chapters/03-identification.md) · [book contents](../README.md)

**Snapshot identity:** see [source-map.md](../source-map.md) for the source snapshot and benchmark provenance.

## Exercise 1 — Conceptual solution

A low calibration RMSE only says that the selected parameters reproduce the
record used to select them. A flexible two-branch model can absorb noise,
wrong initial conditions, OCV error, or accidental features of that one current
sequence. It does not show that the parameters represent the cell's response
outside the calibration record.

A held-out record can reveal weak identifiability through a different pulse
duration or rest duration. For example, a model may fit a record containing
only short pulses but fail to predict late slow recovery. A different current
amplitude or charge/discharge order can also expose wrong resistance sharing,
sign conventions, hysteresis, or OCV mismatch. Thus calibration and validation
should be separated before the fit is run, and held-out error should be
reported alongside conditioning and parameter values.

## Exercise 2 — Analytical solution

The stated matrix has full column rank. The candidate resistance vector

$$
r=\begin{bmatrix}0.004\\0.002\\0.006\end{bmatrix}\Omega
$$

reconstructs every row:

$$
\begin{aligned}
10(0.004)+2(0.002)+1(0.006)&=0.050,\\
0(0.004)+1(0.002)+2(0.006)&=0.014,\\
5(0.004)+1(0.002)+3(0.006)&=0.040.
\end{aligned}
$$

Therefore the least-squares result is

$$
\boxed{\hat R_0=0.004~\Omega,\quad
\hat R_1=0.002~\Omega,\quad
\hat R_2=0.006~\Omega}.
$$

All three values are strictly positive, so they pass a positivity screen such
as the source fitter's. For known time constants, capacitances are recovered
from

$$
\boxed{C_1=\tau_1/\hat R_1,\qquad C_2=\tau_2/\hat R_2}.
$$

For example, if $\tau_1=2$ s and $\tau_2=30$ s, these estimates would give
$C_1=1000$ F and $C_2=5000$ F. The matrix solve itself estimates only
resistances; time constants come from the outer search.

## Exercise 3 — Code/reproduction solution

The following sequence keeps the calibration/held-out boundary explicit:

```matlab
addpath('examples/battery-2rc-model');
scenario = build_battery_2rc_fit_scenario();

fitResult = fit_battery_2rc_parameters(...
    scenario.calibration_data, scenario.initial_parameters);
calibration = evaluate_battery_2rc_fit(...
    scenario.calibration_data, fitResult.parameters);
heldout = evaluate_battery_2rc_fit(...
    scenario.validation_data, fitResult.parameters);

assert(fitResult.estimated_time_constants_s(1) < ...
    fitResult.estimated_time_constants_s(2));
fitted = fitResult.parameters;
assert(fitted.r0_Ohm > 0 && fitted.r1_Ohm > 0 && ...
    fitted.r2_Ohm > 0 && fitted.c1_F > 0 && fitted.c2_F > 0);
assert(isfinite(calibration.metrics.rmse_V) && ...
    isfinite(heldout.metrics.rmse_V));
```

Only the first call to `fit_battery_2rc_parameters` receives calibration data.
The validation data is not used until after the parameters are fixed. The
source check additionally expects the held-out error below 1.5 mV and checks
that the selected design is well conditioned. Those values are source/check
expectations for the deterministic synthetic record. The plotting script
clears workspace variables and closes figures; use every source runner only in
a fresh MATLAB session and save any important state first.

## Exercise 4 — Interpretation and limits solution

A condition number of (2.5\times10^6) is 250 times larger than the source
screen's (10^4) ceiling. The columns of the design matrix are effectively
too similar, or the problem is badly scaled, so small voltage noise or OCV
error can produce large changes in fitted resistances. The fit may still return
finite positive values, but those values should not be treated as stable
physical estimates.

Two experimental changes that can help are:

1. add fine-sampled short pulses to distinguish $R_0$ and the fast branch;
2. add long rests or longer pulses so the slow branch evolves measurably.

Using varied charge and discharge levels also improves excitation, provided the
sign convention and OCV are controlled. Rescaling columns for numerical
conditioning can help arithmetic, but it cannot correct an incorrect OCV
curve. A wrong OCV changes the drop vector $y=OCV-V_t$, so the experiment
needs an independently justified OCV estimate or a model that explicitly
estimates OCV and its uncertainty.
