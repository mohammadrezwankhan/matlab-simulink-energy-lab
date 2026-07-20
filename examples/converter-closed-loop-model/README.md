# Closed-Loop Averaged Converter

This base-MATLAB reference adds bounded closed-loop control to an averaged
buck-converter plant. It demonstrates how a voltage reference becomes a current
request and duty-cycle command without introducing switching-device detail or
requiring a control-system toolbox.

## Engineering Question

How does a cascaded voltage and current controller track a DC voltage step while
respecting current-reference and duty-cycle limits?

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

## Explicit Limitations

- The converter is an averaged buck model, not a switching simulation.
- Semiconductor losses, dead time, quantization, delays, and measurement noise
  are excluded.
- Gains are educational starter values, not a robust stability design for real
  hardware.
- The load is fixed and resistive; source and load disturbances are not applied.
- The explicit Euler step must be reconsidered if plant or controller bandwidth
  changes.
- Hardware limits, protection, sensing, and gain margins require independent
  engineering validation.
