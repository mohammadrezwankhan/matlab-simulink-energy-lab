# Closed-Loop Averaged Converter

This base-MATLAB reference adds bounded closed-loop control to an averaged
buck-converter plant. It demonstrates how a voltage reference becomes a current
request and duty-cycle command without introducing switching-device detail or
requiring a control-system toolbox.

## Engineering Question

How does a cascaded voltage and current controller track a DC voltage step while
respecting current-reference and duty-cycle limits, and how do open-loop, PI,
and filtered-PID strategies respond to the same load disturbance?

## Model Structure

The plant uses the continuous-conduction averaged buck equations:

```text
diL/dt = (D * Vin - Vout - RL * iL) / L
dVout/dt = (iL - Vout / Rload) / C
```

The outer PI controller converts voltage error into a bounded inductor-current
reference. A proportional inner current loop converts current error into a duty
command, with plant-voltage and inductor-resistance feedforward. Conditional
integration prevents the outer controller from winding up at its current limits.

## Load-Step Controller Comparison

The companion comparison holds the voltage reference at 400 V and changes the
resistive load from 20 Ohm to 10 Ohm at 40 ms. Every case uses the same averaged
plant, initial state, 10 microsecond integration step, 0 to 60 A current-reference
range, and 0.05 to 0.95 duty-cycle range:

- **Open loop** keeps the initial steady-state duty ratio fixed.
- **PI** uses the existing cascaded structure with a 0.25 A/V proportional gain
  and an 80 A/(V s) integral gain.
- **Filtered PID** adds a 0.001 A s/V derivative term to the PI tuning. The
  error derivative passes through a first-order 0.5 ms filter before it enters
  the current reference, avoiding an unbounded finite-difference derivative.

Both feedback cases use conditional integration: the integrator pauses while
the current reference is saturated unless the voltage error would drive it back
toward the admissible range. This is a transparent educational anti-windup
policy, not a claim of optimal controller synthesis.

## Starter Parameters

| Parameter | Value | Unit |
| --- | ---: | --- |
| Input voltage | 800 | V |
| Inductance | 2 | mH |
| Inductor resistance | 0.1 | Ohm |
| Capacitance | 1 | mF |
| Load resistance | 20 | Ohm |
| Voltage reference | 300 to 400 at 40 ms | V |
| Current-reference limits | 0 to 40 | A |
| Duty-cycle limits | 0.05 to 0.95 | - |
| Simulation step | 10 | microseconds |

## Run

To inspect the voltage, current, and duty-cycle traces:

```matlab
run_closed_loop_converter
```

For a no-plot regression check:

```matlab
check_closed_loop_converter
```

The check verifies finite states, unidirectional current, duty-limit compliance,
final voltage error, overshoot, and two-percent settling time.

To plot open-loop, PI, and filtered-PID load-step responses together:

```matlab
run_converter_controller_comparison
```

For the corresponding no-plot comparison check:

```matlab
check_converter_controller_comparison
```

The reusable summary helper returns one deterministic row for Open loop, PI,
and Filtered PID. Its variable names and table metadata state the engineering
units, and the two compliance columns remain logical values:

```matlab
comparison = simulate_converter_controller_comparison();
summary = build_controller_comparison_table(comparison);
disp(summary);
writetable(summary, 'controller-comparison-metrics.csv');
```

The comparison check reports steady-state error, overshoot, two-percent
settling time, and duty-cycle range for every controller. It also asserts finite
states, nonnegative current, configured current/duty limits, feedback recovery,
bounded overshoot and settling time, table schema, row order, default reproduced
metrics, and logical compliance fields.

With MATLAB R2026a, the checked tuning produces these load-step metrics:

| Controller | Steady-state error | Overshoot | Undershoot | Settling time |
| --- | ---: | ---: | ---: | ---: |
| Open loop | 1.984 V | 3.84% | 6.48% | 20.6 ms |
| PI | -0.000 V | 1.25% | 9.95% | 10.3 ms |
| Filtered PID | -0.015 V | 1.67% | 7.38% | 14.0 ms |

Here, the filtered derivative reduces the PI case's deepest voltage sag, while
the PI case settles faster and has less positive overshoot. The example makes
that tuning tradeoff visible instead of treating one controller as universally
better.

## Explicit Limitations

- The converter is an averaged buck model, not a switching simulation.
- Semiconductor losses, dead time, quantization, delays, and measurement noise
  are excluded.
- Gains are educational starter values, not a robust stability design for real
  hardware.
- Loads are purely resistive. The original example uses a fixed load, and the
  comparison applies one ideal step without source dynamics.
- The derivative filter and gains are illustrative discrete-time choices and
  have not been tested against noise, delay, parameter spread, or sampling
  jitter.
- The explicit Euler step must be reconsidered if plant or controller bandwidth
  changes.
- Hardware limits, protection, sensing, and gain margins require independent
  engineering validation.
