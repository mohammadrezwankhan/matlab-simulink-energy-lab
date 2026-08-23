<!-- markdownlint-disable MD013 -->

# Validation Results

This page keeps the complete expected output for the repository regression
command in one place. The README contains only a concise evidence summary so
the runnable path stays easy to scan.

## Reproduce the check

From the repository root, run:

```bash
matlab -batch "addpath('examples'); run_all_checks"
```

The verified environment is MATLAB R2026a. Simulink is required for the native
block-diagram checks. The latest signed release is
[`v0.10.0`](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab/releases/tag/v0.10.0);
the output below records the current main branch.

## Expected output

```text
Battery RC check passed. Final SOC: 0.767
Voltage range: 3.425 V to 3.877 V
Native Simulink battery RC check passed.
Final SOC: 0.767
Voltage range: 3.425 V to 3.877 V
Battery 2RC check passed. Final SOC: 0.767
Voltage range: 3.325 V to 3.925 V
Peak polarization: fast 0.075 V, slow 0.125 V
Battery 2RC identification check passed.
Calibration RMSE: 0.401 mV
Held-out RMSE: 0.440 mV
Estimated time constants: 2.01 s and 33.88 s
Native Simulink battery 2RC check passed.
Final SOC: 0.767
Voltage range: 3.325 V to 3.925 V
Battery SOC EKF check passed.
Initial prior SOC error: -0.200
First posterior SOC error: -0.142
Final SOC error: +0.0001
SOC RMSE: 0.0066
Two-percent settling time: 18 s
Posterior voltage RMSE: 1.581 mV
Battery OCV hysteresis check passed.
Final SOC: 0.600
Hysteresis state range: -0.777 to 0.676
Same-SOC minor-loop voltage gap: 8.13 mV
Battery SOC hysteresis EKF check passed.
SOC RMSE: hysteresis 0.0023, baseline 0.0203
Final SOC error: hysteresis +0.0005, baseline +0.0285
Hysteresis-state RMSE: 0.0482
Voltage RMSE: hysteresis 0.589 mV, baseline 3.672 mV
Battery thermal check passed.
Peak cell temperature: 36.92 degC
Final cell temperature: 28.96 degC
Peak irreversible heat: 33.31 W
Reversible heat range: -2.31 W to 1.12 W
Peak total heat: 34.29 W
Final SOC: 0.608
Battery cooling-sensitivity check passed.
hA (W/K)  Peak (degC)  Final (degC)  Time > 35.0 degC (s)  Degree-hours
     0.0        42.73         42.73                1399.6        2.5049
     0.6        38.89         33.25                1019.7        0.5032
     1.2        36.92         28.96                 305.6        0.0815
     2.4        34.05         26.02                   0.0        0.0000
     4.8        30.78         25.12                   0.0        0.0000
Battery module cooling-network check passed.
Peak cell temperature: 39.87 degC (cell 4 at 1320 s)
Peak cell-temperature spread: 5.10 degC
Peak coolant outlet temperature: 31.27 degC
Peak cell temperature at 3x flow: 38.01 degC
Pouch-cell thermal-gradient check passed.
Peak node temperature: 43.83 degC at 5.60 mm and 1800 s
Peak through-thickness node spread: 3.09 degC
Symmetric steady center error: 0.003 degC
Medium-to-fine grid center difference: 0.0024 degC
Native Simulink battery thermal check passed.
Peak cell temperature: 36.92 degC
Final cell temperature: 28.96 degC
Reversible heat range: -2.31 W to 1.12 W
Converter parameter check passed.
Output voltage: 360.0 V
Load current: 18.0 A
Closed-loop converter check passed.
Final average voltage: 399.49 V
Peak voltage after step: 421.90 V
Two-percent settling time: 38.6 ms
Controller comparison check passed.
Controller      Steady error (V)  Overshoot (%)  Settling (ms)  Duty range
Open loop                  1.984           3.84           20.6  0.502 to 0.502
PI                        -0.000           1.25           10.3  0.464 to 0.510
Filtered PID              -0.015           1.67           14.0  0.471 to 0.526
Switching buck converter check passed.
Average output voltage: 358.209 V
Average inductor current: 17.910 A
Current ripple: 9.901 A peak-to-peak
Voltage ripple: 0.124 V peak-to-peak
Measured duty cycle: 0.450
Switching closed-loop buck check passed.
Final average voltage: 399.92 V
Reference-step overshoot: 5.97%, settling 19.1 ms
Load-step undershoot: 2.19%, settling 2.1 ms
Average duty cycle: 0.505
Diode/inductor loss energy: 2.606 J / 16.843 J
Native Simulink averaged buck check passed.
Final output voltage: 358.209 V
Final inductor current: 17.910 A
BESS DC reserve check passed.
SOC: minimum 0.2042, final 0.2042
DC-link voltage: 700.00 V to 750.00 V
Delivered/curtailed discharge energy: 10.225 / 8.109 kWh
Accepted charge energy: 4.000 kWh
Reserve-limited operation: 219.9 s
Peak discharge/charge current: 432.9 / 163.5 A
All 31 focused BESS controller tests passed.
All 21 MATLAB and Simulink checks passed.
```

## Interpretation and limits

- These outputs are deterministic regression evidence for reduced-order,
  educational engineering models. They are not physical-cell, hardware, or
  grid-code qualification results.
- The two-RC identification benchmark uses transparent synthetic voltage
  records with deterministic sensor-like perturbations. Its held-out RMSE is
  not validation against measured physical-cell data.
- Recalibrate parameters and revalidate expected outputs before applying any
  model to real cells, converters, or control designs. See the repository's
  [Scope and Limitations](../README.md#scope-and-limitations).

For the focused BESS scenarios, see the detailed
[Unified BESS validation report](../examples/bess-unified-control/validation/validation-report.md),
which records the eight mandatory scenarios, 31 focused results, environment,
and publication evidence.
