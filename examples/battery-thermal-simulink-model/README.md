# Native Simulink Battery Thermal Model

This example generates an inspectable discrete Simulink diagram for the
temperature-aware battery reference. It exposes how current, polarization,
temperature-dependent resistance, irreversible heat, and ambient cooling form
a closed electro-thermal feedback path.

## Engineering Question

Can a generated block diagram reproduce every sample of the validated thermal
battery recurrence while making each electrical and heat-flow balance visible?

## Block Structure

The diagram uses explicit Unit Delay state updates at the configured sample
time. Gain, sum, saturation, product, exponential, and delay blocks implement:

```text
SOC[k+1] = clamp(SOC[k] - dt * I[k] / (3600 * Q_Ah), 0, 1)
Vrc[k+1] = Vrc[k] + dt * (I[k] / C1 - Vrc[k] / (R1 * C1))
R0[k] = R0_ref * exp(kR * (Tref - T[k]))
Qgen[k] = I[k] * (I[k] * R0[k] + Vrc[k])
Qcool[k] = hA * (T[k] - Tamb)
T[k+1] = T[k] + dt * (Qgen[k] - Qcool[k]) / (m * cp)
```

Terminal voltage is `OCV(SOC) - I*R0(T) - Vrc`. Ten logged outputs expose the
current, three states, OCV, resistance, terminal voltage, generated heat,
cooling power, and net heat.

## Shared Reference API

The Base-MATLAB example now provides:

```text
examples/battery-thermal-model/
  battery_thermal_default_parameters.m
  battery_thermal_default_profile.m
  simulate_battery_thermal_model.m
```

The plotting script, no-plot check, and Simulink builder call the same validated
solver. Profile timestamps, parameters, explicit-Euler stability, constitutive
relations, and energy closure therefore have one maintained implementation.

## Starter Parameters

| Parameter                          |   Value | Unit    |
| ---------------------------------- | ------: | ------- |
| Capacity                           |      50 | Ah      |
| Initial SOC                        |    0.80 | -       |
| Reference ohmic resistance         |       4 | mOhm    |
| Polarization branch                | 2, 2400 | mOhm, F |
| Resistance temperature coefficient |   0.025 | 1/degC  |
| Initial and ambient temperature    |      25 | degC    |
| Lumped thermal capacity            |    1050 | J/K     |
| Ambient conductance                |     1.2 | W/K     |
| Canonical sample time              |       1 | s       |
| Canonical duration                 |    1800 | s       |

## Requirements

- MATLAB R2026a is the verified release.
- Simulink is required to build and run the block diagram.
- No battery, control, power-electronics, or testing toolbox is required.

## Run

Generate and open the model, simulate the canonical profile, and plot voltage,
temperature, and heat generation:

```matlab
run_battery_thermal_simulink_model
```

Generate a persistent copy in a directory of your choice:

```matlab
build_battery_thermal_simulink_model('generated-models')
```

Run the no-plot regression check:

```matlab
check_battery_thermal_simulink_model
```

Expected summary:

```text
Native Simulink battery thermal check passed.
Peak cell temperature: 37.32 degC
Final cell temperature: 28.95 degC
```

The check verifies block types, discrete state loops, sample times, SOC limits,
temperature feedback, and heat-flow connections. It compares all ten logged
signals with canonical and custom MATLAB reference cases, checks thermal energy
closure, rejects invalid parameters, and removes generated models.

## Explicit Limitations

- The model is a discrete educational recurrence, not a continuous
  electrochemical or spatial thermal model.
- Current is prescribed; voltage, current, power, and thermal safety limits are
  not implemented.
- OCV and resistance relations are illustrative and require measured-data
  calibration.
- Reversible entropic heat, ageing, hysteresis, self-discharge, thermal
  runaway, and pack gradients are excluded.
- Explicit-Euler sample time must satisfy the checked electrical and thermal
  stability bounds.
- Results must not be used for qualification or safety decisions without
  independent calibration and validation.
