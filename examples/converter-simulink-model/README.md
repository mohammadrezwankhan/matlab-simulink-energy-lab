# Native Simulink Averaged Buck Converter

This example generates a genuine Simulink block diagram from readable MATLAB
source. The diagram exposes the two continuous states, electrical balances,
and parameter gains instead of treating the model as an opaque binary file.

## Engineering Question

Can a programmatically generated Simulink model reproduce the exact transient
and lossy steady state of the averaged buck-converter equations?

## Block Structure

The input-voltage and duty-cycle constants form the averaged switch-node
voltage `D * Vin`. Sum, gain, and integrator blocks then implement:

```text
diL/dt = (D * Vin - Vout - RL * iL) / L
dVout/dt = (iL - Vout / Rload) / C
```

The builder uses `new_system`, `add_block`, `add_line`, `set_param`, and
`save_system` to create `average_buck_simulink_model.slx`. The MATLAB builder is
the source of truth, so the generated binary does not need to be committed.

## Starter Parameters

| Parameter           | Value | Unit |
| ------------------- | ----: | ---- |
| Input voltage       |   800 | V    |
| Duty cycle          |  0.45 | -    |
| Inductance          |     2 | mH   |
| Inductor resistance |   0.1 | Ohm  |
| Capacitance         |     1 | mF   |
| Load resistance     |    20 | Ohm  |
| Simulation duration |   0.3 | s    |
| Maximum solver step |   0.1 | ms   |

The 0.1 Ohm winding resistance makes this dynamic reference intentionally more
realistic than the ideal algebraic scaffold. Its expected steady state is:

```text
Vout = D * Vin / (1 + RL / Rload) = 358.209 V
iL   = Vout / Rload               = 17.910 A
```

## Requirements

- MATLAB R2026a is the verified release.
- Simulink is required to build and run the block diagram.
- No power-electronics, control, or testing toolbox is required.

## Run

Generate the model in a temporary workspace, simulate startup, plot both
states, and open the block diagram:

```matlab
run_average_buck_simulink_model
```

Generate a persistent copy in a directory of your choice:

```matlab
build_average_buck_simulink_model('generated-models')
```

Run the no-plot regression check:

```matlab
check_average_buck_simulink_model
```

Expected check summary:

```text
Native Simulink averaged buck check passed.
Final output voltage: 358.209 V
Final inductor current: 17.910 A
Maximum exact-state error: below 1e-4 V and 1e-5 A
```

The check generates an `.slx` file in a unique temporary directory, confirms
the required block types and signal connections, compiles the diagram,
simulates it, and compares every logged sample with the independent matrix
exponential solution. It also verifies parameter rejection and removes the
temporary model afterward.

## Explicit Limitations

- This is an averaged continuous-time model. PWM ripple, switching loss, dead
  time, semiconductor drops, and discontinuous conduction are excluded.
- Duty cycle, source voltage, and load are constant during a simulation.
- The winding resistance is the only modeled loss; capacitor ESR and source
  impedance are omitted.
- Parameters are educational starter values and are not calibrated to hardware.
- The generated model is a reproducible teaching artifact, not a converter
  design or safety-validation model.
