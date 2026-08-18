<!-- markdownlint-disable MD013 -->

# A Reproducible Two-RC Battery Parameter-Identification Workflow in MATLAB

An equivalent-circuit model is useful when its assumptions, fitted parameters,
and validation record can all be inspected. This tutorial walks through the
toolbox-free two-RC workflow in MATLAB Simulink Energy Lab: fit the model on
one pulse record, then test it on a separate pulse record that was not used to
choose the parameters.

> The included records are deterministic synthetic benchmarks. They demonstrate
> the workflow; they do **not** establish accuracy for a physical cell.

![Two-RC parameter-identification validation: calibration and held-out voltage traces with millivolt residuals](../assets/battery-2rc-identification-response.png)

## What the model represents

The terminal voltage is described by an OCV lookup, an instantaneous ohmic
drop, and two polarization branches:

```text
Vt = OCV - I*R0 - Vrc1 - Vrc2
```

For a zero-order-held current over one interval, each RC state is updated
exactly rather than by a coarse Euler approximation:

```text
Vrc_k,next = exp(-dt / tau_k) * Vrc_k
             + Rk * (1 - exp(-dt / tau_k)) * I

tau_k = Rk*Ck
```

The fast and slow branches represent different terminal-voltage relaxation
time scales. They are a compact engineering approximation, not a substitute
for an electrochemical or cell-specific model.

## Run the complete example

From the repository root, run the deterministic no-plot check:

```matlab
run('examples/battery-2rc-model/check_battery_2rc_fit.m')
```

Or open the plotted workflow:

```matlab
run('examples/battery-2rc-model/run_battery_2rc_fit.m')
```

The current reference benchmark reports:

| Record | RMSE |
| --- | ---: |
| Calibration pulse profile | 0.401 mV |
| Independent held-out pulse profile | 0.440 mV |

The fitted fast and slow time constants are 2.01 s and 33.88 s. The regression
check also requires positive fitted parameters, ordered time constants, a
well-conditioned resistance solve, deterministic results, and held-out error
below 1.5 mV.

## Why a held-out profile matters

A small residual on the same pulse record used for fitting can result from a
model following quirks of that record rather than its underlying dynamics.
Using a second record creates a clear separation:

1. Build a calibration table containing `time_s`, `current_A`, `ocv_V`, and
   `terminal_voltage_V`.
2. Fit only the calibration table with `fit_battery_2rc_parameters`.
3. Pass the fitted parameters and a separate pulse table to
   `evaluate_battery_2rc_fit`.
4. Compare the held-out error with the pre-fit baseline and inspect the
   residuals.

The repository's check requires fitting to reduce held-out RMSE by at least
half relative to its deliberately imperfect initial parameter set. That is a
stronger teaching signal than reporting only a calibration fit.

## How the fitter stays toolbox-free

For a candidate pair of time constants, the branch responses are calculated
with unit resistance. The voltage drop is then linear in the three resistances:

```text
OCV - Vt = R0*I + R1*x1(tau1) + R2*x2(tau2)
```

The implementation searches ordered logarithmic time-constant candidates,
solves the three-resistance least-squares subproblem, rejects nonpositive or
ill-conditioned candidates, and refines around the best pair. Capacitances are
recovered from `C = tau / R`.

This structure makes the nonlinear part of the problem visible while keeping
the example runnable with base MATLAB.

## Before using measured cell data

Replace the synthetic records and illustrative parameters before drawing
cell-specific conclusions. In particular:

- estimate OCV independently instead of allowing the voltage fit to hide OCV
  error;
- use pulses that excite both expected time scales and a sampling interval
  appropriate to the fastest dynamics;
- keep a physically separate validation profile;
- check current sign, timestamp monotonicity, temperature, initial RC states,
  sensor bias, and hysteresis; and
- report parameter uncertainty and limitations alongside fit quality.

The model deliberately excludes joint OCV/capacity estimation, temperature
dependence, ageing, hysteresis, current bias, and cell-to-cell variation.

## Explore the runnable source

- [Two-RC model README](../examples/battery-2rc-model/README.md) — model
  scope, result fields, validation coverage, and limitations.
- [Fitting function](../examples/battery-2rc-model/fit_battery_2rc_parameters.m)
  — inspect the candidate search and constrained parameter selection.
- [Held-out evaluation](../examples/battery-2rc-model/evaluate_battery_2rc_fit.m)
  — compute voltage predictions and error metrics for any compatible record.
- [Native Simulink counterpart](../examples/battery-2rc-simulink-model/README.md)
  — generate and validate the two-branch block diagram against the exact
  MATLAB reference.

If this workflow saves setup time or helps teach validation, consider starring
the [repository](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab)
to help other energy-engineering learners find it.
