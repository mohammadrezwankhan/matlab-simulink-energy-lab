# Battery OCV Hysteresis Model

## Engineering Question

How can a small equivalent-circuit model preserve charge/discharge history so
that the predicted equilibrium voltage is not a single-valued function of SOC?

This example adds a normalized dynamic hysteresis state to a first-order
battery RC model. A reversal-rich profile demonstrates a minor loop: the model
returns to the same SOC twice but predicts different equilibrium voltages
because the intervening charge/discharge history differs.

## Model

The current convention is positive for discharge. SOC and RC polarization use
the same exact interval updates as the other battery examples. The normalized
hysteresis state `h` follows

```text
target = -sign(current)
h_next = target + (h - target) *
         exp(-gamma * abs(current) * dt / (3600 * capacity))
```

when current is nonzero, and holds its value during rest. The output equations
are

```text
hysteresis voltage = M * h
equilibrium voltage = mean OCV(SOC) + M * h
terminal voltage = equilibrium voltage - current * R0 - Vrc
```

This is a deliberately compact, dynamic-only form of the one-state hysteresis
model described by Gregory L. Plett in
[Part 2: Modeling and identification](https://doi.org/10.1016/j.jpowsour.2004.02.032).
The paper's broader model also discusses additional effects and identification.

## Files

- `battery_hysteresis_default_parameters.m`: illustrative electrical,
  mean-OCV, and hysteresis parameters.
- `battery_hysteresis_default_profile.m`: native irregular reversal profile.
- `simulate_battery_ocv_hysteresis.m`: validated exact interval simulator.
- `check_battery_ocv_hysteresis.m`: no-plot physical and numerical checks.
- `run_battery_ocv_hysteresis.m`: four-panel interpretation plot.

## Run

From this folder:

```matlab
check_battery_ocv_hysteresis
run_battery_ocv_hysteresis
```

Expected no-plot summary:

```text
Battery OCV hysteresis check passed.
Final SOC: 0.600
Hysteresis state range: -0.777 to 0.676
Same-SOC minor-loop voltage gap: 8.13 mV
```

## What the Check Proves

- SOC closes against net applied-current ampere-hours.
- The RC and hysteresis states use exact zero-order-hold interval updates.
- The normalized hysteresis state remains inside `[-1, 1]`.
- Rest intervals preserve hysteresis memory exactly.
- Reversal history creates a deterministic same-SOC minor-loop voltage gap.
- Native irregular and resampled profiles agree at shared timestamps.
- SOC current limiting also limits hysteresis-state progression.
- Zero hysteresis magnitude and zero hysteresis rate reduce to explicit,
  independently checked limiting cases.
- Invalid timestamps, OCV curves, and hysteresis states are rejected.

## Assumptions and Limitations

- Parameters are illustrative and are not fitted to a physical cell.
- Coulombic efficiency is one and capacity is constant.
- The mean OCV curve, maximum hysteresis voltage, and rate parameter do not
  depend on temperature, SOC, current direction, ageing, or chemistry.
- The dynamic-only state omits the instantaneous hysteresis term used in some
  enhanced self-correcting models.
- The model cannot reproduce arbitrary nested loops, path-dependent
  rate effects, diffusion, or relaxation of OCV during rest.
- A measured major-loop and reversal-pulse dataset is required before using
  the model for cell-specific SOC estimation or control.

## Extension Ideas

- Fit separate charge and discharge rate parameters from measured reversals.
- Make hysteresis magnitude and rate functions of SOC and temperature.
- Add the hysteresis state to the repository's SOC EKF.
- Compare the single-state response with Preisach or
  Prandtl-Ishlinskii operators on held-out minor loops.
