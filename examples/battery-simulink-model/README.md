# Native Simulink Battery RC Model

This example generates an inspectable Simulink block diagram for the existing
first-order battery equivalent-circuit reference. It reuses the validated input
and parameter pipeline, then independently computes SOC, RC polarization, OCV,
and terminal voltage with native Simulink blocks.

## Engineering Question

Can a generated Simulink diagram reproduce the exact pulse-profile response of
the Base-MATLAB battery RC solver, including a replaceable nonlinear OCV curve?

## Block Structure

The applied current uses the repository's positive-discharge convention and is
zero-order held between supplied timestamps. Gain, sum, integrator, and lookup
blocks implement:

```text
dSOC/dt = -I / (3600 * Q_Ah)
dVrc/dt = I / C1 - Vrc / (R1 * C1)
Vterminal = OCV(SOC) - R0 * I - Vrc
```

The SOC integrator is limited to `[0, 1]`. A native 1-D Lookup Table block uses
linear interpolation and clipped extrapolation for `OCV(SOC)`. The builder
embeds the applied-current profile in the generated model, so the `.slx` file
does not depend on a MAT file or base-workspace initialization.

## Input Preprocessing

`build_battery_rc_simulink_model` calls the existing validated MATLAB solver to
check profile columns, timestamps, parameters, OCV data, and SOC-feasible
interval current. The resulting applied-current trace becomes the Simulink
input. Simulink independently integrates both continuous states and reconstructs
the voltages; it does not duplicate the interval current-limiting algorithm.

This separation keeps one canonical boundary policy while testing whether the
native diagram reproduces the model dynamics and output balance.

## Starter Parameters

| Parameter                     | Value | Unit |
| ----------------------------- | ----: | ---- |
| Capacity                      |    50 | Ah   |
| Initial SOC                   |  0.80 | -    |
| Ohmic resistance `R0`         |     4 | mOhm |
| Polarization resistance `R1`  |     2 | mOhm |
| Polarization capacitance `C1` |  2400 | F    |
| Canonical profile duration    |   600 | s    |
| Canonical output interval     |     1 | s    |

## Requirements

- MATLAB R2026a is the verified release.
- Simulink is required to build and run the block diagram.
- No battery, power-electronics, control, or testing toolbox is required.

## Run

Generate the model in a temporary workspace, simulate the canonical pulse
profile, plot current/SOC/voltage, and open the diagram:

```matlab
run_battery_rc_simulink_model
```

Generate a persistent copy in a directory of your choice:

```matlab
build_battery_rc_simulink_model('generated-models')
```

Run the no-plot regression check:

```matlab
check_battery_rc_simulink_model
```

Expected summary:

```text
Native Simulink battery RC check passed.
Final SOC: 0.767
Voltage range: 3.425 V to 3.877 V
```

The check validates the generated block types, signal connections, zero-order
held input, SOC limits, and lookup method. It compares all five logged outputs
against the exact MATLAB reference for both the canonical profile and a shorter
case with a nonlinear OCV table, then removes the generated models.

## Explicit Limitations

- The current trace is prevalidated and SOC-limited by the MATLAB reference;
  the diagram does not implement current, voltage, thermal, or power limits.
- The model is first order and omits diffusion beyond one RC branch, hysteresis,
  ageing, temperature dependence, and cell-to-cell variation.
- The OCV table and component values are educational placeholders.
- Continuous Simulink states use numerical integration, while the MATLAB
  reference uses exact interval updates.
- The generated diagram is a teaching and regression artifact, not a calibrated
  battery-management or safety model.
