# Native Simulink Battery 2RC Model

This example generates an inspectable Simulink block diagram for the existing
two-RC battery reference. It independently integrates fast and slow
polarization states while reusing the validated current, parameter, SOC, and
OCV preprocessing pipeline.

## Engineering Question

Can a generated Simulink diagram preserve both battery recovery time scales
and reproduce the exact two-RC MATLAB reference over pulse-current profiles?

## Block Structure

The model uses the repository's positive-discharge convention. A zero-order
held current source drives native gain, sum, integrator, and lookup blocks:

```text
dSOC/dt  = -I / (3600 * Q_Ah)
dVrc1/dt = I / C1 - Vrc1 / (R1 * C1)
dVrc2/dt = I / C2 - Vrc2 / (R2 * C2)
Vterminal = OCV(SOC) - R0 * I - Vrc1 - Vrc2
```

The generated diagram exposes current, SOC, OCV, both branch voltages, total
polarization, and terminal voltage as logged outputs. Its SOC integrator is
limited to `[0, 1]`, and the OCV lookup uses linear interpolation with clipped
extrapolation.

## Input Preprocessing

`build_battery_2rc_simulink_model` calls the exact MATLAB two-RC solver first.
That call validates the profile, timestamps, parameters, OCV data, optional
uniform resampling, and SOC-feasible interval current. The resulting applied
current is embedded directly in the generated `.slx` file.

Simulink then independently integrates SOC and both RC states and reconstructs
all voltage outputs. Keeping the boundary-current policy in one validated
location avoids two subtly different limiters while still testing the native
dynamic diagram.

## Starter Parameters

| Parameter                  | Value | Unit |
| -------------------------- | ----: | ---- |
| Capacity                   |    50 | Ah   |
| Initial SOC                |  0.80 | -    |
| Ohmic resistance `R0`      |     4 | mOhm |
| Fast resistance `R1`       |   1.5 | mOhm |
| Fast capacitance `C1`      |  1200 | F    |
| Fast time constant         |   1.8 | s    |
| Slow resistance `R2`       |   2.5 | mOhm |
| Slow capacitance `C2`      | 12000 | F    |
| Slow time constant         |    30 | s    |
| Canonical profile duration |   600 | s    |
| Canonical output interval  |     1 | s    |

## Requirements

- MATLAB R2026a is the verified release.
- Simulink is required to build and run the block diagram.
- No battery, power-electronics, control, or testing toolbox is required.

## Run

Generate the model in a temporary workspace, simulate the canonical pulse
profile, plot both branch states, and open the diagram:

```matlab
run_battery_2rc_simulink_model
```

Generate a persistent copy in a directory of your choice:

```matlab
build_battery_2rc_simulink_model('generated-models')
```

Run the no-plot regression check:

```matlab
check_battery_2rc_simulink_model
```

Expected summary:

```text
Native Simulink battery 2RC check passed.
Final SOC: 0.767
Voltage range: 3.325 V to 3.925 V
```

The check verifies every state-path block, key connection, branch gain,
zero-order-held input, SOC bound, and lookup method. It compares all seven
logged signals with the exact MATLAB solver for both the canonical case and a
custom case with different branch time constants and a nonlinear OCV table.
Generated models are removed after validation.

## Explicit Limitations

- The current trace is prevalidated and SOC-limited by the MATLAB reference;
  the diagram does not implement current, voltage, thermal, or power limits.
- Both RC branches start from a rested zero-polarization state.
- Parameters and OCV data are educational placeholders, not a fitted cell.
- Continuous Simulink states use numerical integration, while the MATLAB
  reference uses exact interval updates.
- OCV hysteresis, ageing, thermal feedback, self-discharge, and cell variation
  are excluded.
- A second branch adds response flexibility but does not prove parameter
  identifiability or predictive accuracy without held-out measured data.
