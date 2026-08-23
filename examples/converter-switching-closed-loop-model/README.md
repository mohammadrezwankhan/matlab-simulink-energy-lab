# Switching Closed-Loop Buck Converter

This Base-MATLAB benchmark connects a bounded cascaded voltage/current
controller to an event-aligned PWM buck plant. It exposes switching ripple,
freewheel-diode conduction loss, source-backed nominal SiC MOSFET conduction
and transition loss, controller saturation, and reference/load transients in
one deterministic example without requiring Simulink or a power-electronics
toolbox.

## Engineering Question

Can a period-sampled controller regulate an explicitly switched lossy buck
converter through a 300-to-400 V reference step and a 20-to-10 Ohm load step?

## Plant and Switching Model

The high-side switch state `s` is zero or one. Positive inductor current
freewheels through a diode while the switch is off:

```text
diL/dt = (s * Vin - (1 - s) * Vdiode
          - (RL + s * RDSon) * iL - Vout) / L
dVout/dt = (iL - Vout / Rload) / C
```

Each ON or OFF interval is propagated with the exact affine matrix-exponential
solution. PWM edges, reference/load events, and the final time align with the
switching grid. The default case remains in continuous conduction; the
simulator raises an error if that assumption is violated.

## Semiconductor-Loss Evidence

The default high-side switch is the Infineon IMZC120R040M2H only as a
transparent nominal parameter reference. Its official
[revision 1.20 datasheet](https://www.infineon.com/assets/row/public/documents/60/49/infineon-imzc120r040m2h-datasheet-en.pdf)
reports typical `RDS(on) = 40 mOhm` at `VGS = 18 V`, `Tvj = 25 degC`, and
typical `Eon = 109 uJ`, `Eoff = 45 uJ` at `VDD = 800 V`, `ID = 18 A`,
`RG,ext = 2.3 Ohm`, `Lsigma = 12 nH`, and `Tvj = 25 degC`.

At each resolved PWM edge, this benchmark applies the local first-order
estimate

```text
Eevent = Ereference * (Vin / Vreference) * (abs(iL) / Ireference)
```

and sums the turn-on and turn-off events separately. The
[Infineon switching-loss application note](https://www.infineon.com/assets/row/public/documents/24/42/infineon-applicationnote-mosfet-coolmos-how-to-select-the-right-coolmos-applicationnotes-en.pdf)
shows that `Eon` and `Eoff` depend on drain current and that switching power is
the sum of event energies times switching frequency. The
[Texas Instruments synchronous-buck loss report](https://www.ti.com/lit/an/slvaeq9/slvaeq9.pdf)
independently describes switching power as event energy times switching
frequency and separates switching, conduction, gate, capacitance, and diode
loss terms.

The 40 mOhm ON resistance participates directly in the exact affine plant
propagation. Transition energy is an event-level electrical-loss estimate; it
is added to DC-source work and subtracted as device loss without changing the
resolved state trajectory.

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
| Nominal switch ON resistance | 40 | mOhm |
| Reference turn-on / turn-off energy | 109 / 45 | uJ |
| Switching-energy reference point | 800 / 18 | V / A |
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
Final average voltage: 399.62 V
Reference-step overshoot: 5.91%, settling 19.4 ms
Load-step undershoot: 2.08%, settling 1.8 ms
Average duty cycle: 0.506
Diode/inductor loss energy: 2.602 J / 16.845 J
Switch conduction/transition loss energy: 3.354 J / 0.405 J
Turn-on/turn-off transition energy: 0.255 J / 0.150 J
Estimated energy efficiency: 97.046%
```

![Switching closed-loop buck response showing voltage regulation, inductor-current control, quantized duty, separated semiconductor losses, the load step, and final PWM periods](../../assets/converter-switching-closed-loop-response.png)

The check verifies PWM counts, current/duty limits, continuous conduction,
reference and load-step performance, the lossy averaged balance, integrated
energy conservation, exact compatibility with the existing ideal fixed-duty
switched model, zero-transition-loss trajectory parity, doubled-grid loss
convergence, switching-frequency sensitivity, and malformed-input rejection.

## What the Numbers Mean

The final 100-period average is 399.62 V against a 400 V reference. The
measured 0.5062 average duty predicts 399.66 V from the averaged diode, copper,
and switch-resistance balance. The `-0.000143 J` energy residual is
`0.00000712%` of source energy. Source and diode work use exact interval current integrals;
squared conduction and load losses use the resolved PWM grid. The default run
estimates 3.354 J of switch conduction loss and 0.405 J of transition loss,
corresponding to 97.046% electrical energy efficiency over the transient.

For an inspectable fixed-step block-diagram representation of the same
controller, PWM, and exact affine plant maps, see the
[native Simulink companion](../converter-switching-closed-loop-simulink-model/README.md).

These results are deterministic numerical regression evidence for the stated
reduced-order model. They are not hardware validation or controller-design
qualification.

## Explicit Limitations

- The diode is a constant forward-voltage element; reverse recovery and
  discontinuous-conduction state logic are omitted.
- High-side ON resistance is fixed at its nominal 25 degC value. Turn-on and
  turn-off energy use a linear voltage/current scaling around one datasheet
  test point. Temperature, gate resistance and voltage, dead time, nonlinear
  energy curves, output capacitance, reverse recovery, parasitics, EMI,
  electrothermal feedback, and statistical/device variation are excluded.
- The nominal device is a parameter reference, not a selected or qualified
  component. The loss result is not a hardware efficiency, junction
  temperature, lifetime, or safe-operating-area prediction.
- The controller samples without computation delay and uses illustrative,
  manually selected gains. Sensor dynamics, quantization, noise, protection,
  and digital implementation effects are omitted.
- Inductor current is constrained only by the controller reference and the
  continuous-conduction assumption; magnetic saturation is not modeled.
- Parameters are educational starter values, not a device-selection,
  magnetics, protection, stability-margin, or hardware design.
