# Switching Closed-Loop Buck Converter

This Base-MATLAB benchmark connects a bounded cascaded voltage/current
controller to an event-aligned PWM buck plant. It exposes switching ripple,
freewheel-diode conduction loss, controller saturation, and reference/load
transients in one deterministic example without requiring Simulink or a
power-electronics toolbox.

## Engineering Question

Can a period-sampled controller regulate an explicitly switched lossy buck
converter through a 300-to-400 V reference step and a 20-to-10 Ohm load step?

## Plant and Switching Model

The high-side switch state `s` is zero or one. Positive inductor current
freewheels through a diode while the switch is off:

```text
diL/dt = (s * Vin - (1 - s) * Vdiode - RL * iL - Vout) / L
dVout/dt = (iL - Vout / Rload) / C
```

Each ON or OFF interval is propagated with the exact affine matrix-exponential
solution. PWM edges, reference/load events, and the final time align with the
switching grid. The default case remains in continuous conduction; the
simulator raises an error if that assumption is violated.

## Controller

At each 10 kHz PWM-period boundary, an outer PI voltage loop produces a bounded
current reference. A proportional current loop plus voltage, copper-drop, and
diode-drop feedforward produces the duty command. Anti-windup conditionally
integrates only when the current reference is free or recovering from a limit.
The duty command is bounded and quantized to an integer number of ON intervals.

## Starter Parameters

| Parameter | Value | Unit |
| --- | ---: | --- |
| Input voltage | 800 | V |
| Reference step | 300 to 400 at 0.04 | V, s |
| Load step | 20 to 10 at 0.10 | Ohm, s |
| Switching frequency | 10 | kHz |
| Inductance / resistance | 2 / 0.1 | mH / Ohm |
| Capacitance | 1 | mF |
| Diode forward voltage | 1 | V |
| Voltage PI gains | 0.24 / 35 | A/V / A/(V s) |
| Current-loop proportional gain | 3 | Ohm |
| Current-reference limit | 0 to 60 | A |
| Duty limit | 0.05 to 0.95 | - |
| PWM-grid resolution | 100 | steps/period |

## Run

To plot the reference and load transients, current loop, duty command, and
final five PWM periods:

```matlab
run_switching_closed_loop_buck
```

For the no-plot regression check:

```matlab
check_switching_closed_loop_buck
```

Expected check output:

```text
Switching closed-loop buck check passed.
Final average voltage: 399.92 V
Reference-step overshoot: 5.97%, settling 19.1 ms
Load-step undershoot: 2.19%, settling 2.1 ms
Average duty cycle: 0.505
Diode/inductor loss energy: 2.606 J / 16.843 J
```

![Switching closed-loop buck response showing voltage regulation, inductor-current control, quantized duty, the load step, and final PWM periods](../../assets/converter-switching-closed-loop-response.png)

The check verifies PWM counts, current/duty limits, continuous conduction,
reference and load-step performance, the lossy averaged balance, integrated
energy conservation, exact compatibility with the existing ideal fixed-duty
switched model, doubled-grid convergence, and malformed-input rejection.

## What the Numbers Mean

The final 100-period average is 399.92 V against a 400 V reference. The
measured 0.5055 average duty predicts 399.91 V from the lossy diode averaged
balance. The 0.0185 J energy residual is 0.00093% of source energy. Source and
diode work use exact interval current integrals; squared conduction and load
losses use the resolved PWM grid.

These results are deterministic numerical regression evidence for the stated
reduced-order model. They are not hardware validation or controller-design
qualification.

## Explicit Limitations

- The diode is a constant forward-voltage element; reverse recovery and
  discontinuous-conduction state logic are omitted.
- The high-side switch is ideal. Dead time, semiconductor capacitance,
  switching energy, gate drive, parasitics, EMI, and thermal behavior are
  excluded.
- The controller samples without computation delay and uses illustrative,
  manually selected gains. Sensor dynamics, quantization, noise, protection,
  and digital implementation effects are omitted.
- Inductor current is constrained only by the controller reference and the
  continuous-conduction assumption; magnetic saturation is not modeled.
- Parameters are educational starter values, not a device, magnetics,
  protection, stability-margin, or hardware design.
