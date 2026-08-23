# Native Simulink Switching Closed-Loop Buck

This example generates a genuine fixed-step Simulink block diagram for the
repository's event-aligned switching closed-loop buck. The generated model
uses native blocks for the period-sampled cascaded controller, integer-step
PWM, anti-windup decision, and four exact affine plant-update branches.

## Engineering Question

Can an inspectable generated Simulink diagram reproduce the Base MATLAB
controller, PWM sequence, and exact ON/OFF plant states without changing the
underlying model?

## Architecture

The model runs on the same fixed interval grid as the MATLAB reference:

```text
dt = 1 / (switching frequency * PWM steps per period)
```

Zero-order holds sample current and voltage once per PWM period. Native sum,
gain, saturation, comparison, logic, delay, rounding, and PWM-counter blocks
implement the controller and anti-windup rules. One vector delay owns the plant
state, and a native assertion enforces continuous conduction. Four visible
branches compute `A*x + b` for ON/OFF operation before and after the load step;
a multiport switch selects the active exact map.

The `.slx` file is generated into a temporary directory and is not committed.
The MATLAB builder remains the reviewable source of the diagram.

## Run

```matlab
run_switching_closed_loop_buck_simulink_model
```

For the no-plot topology and parity check:

```matlab
check_switching_closed_loop_buck_simulink_model
```

Expected output:

```text
Native Simulink switching closed-loop buck check passed.
Maximum MATLAB parity error: 0.000e+00 A, 0.000e+00 V
Matched PWM intervals / controller periods: 180000 / 1800
```

## Evidence Boundary

The check establishes implementation consistency between two representations
of the same reduced-order equations. A perturbed grid and near-boundary event
case also verifies shared event indexing. This is not independent physical
validation because both representations use the same affine-map helper.
Semiconductor transition energy remains post-processed by the existing MATLAB
reference because it is bookkeeping-only and does not alter the electrical
trajectory.

The model assumes continuous conduction and omits dead time, reverse recovery,
nonlinear device curves, parasitics, EMI, temperature, magnetic saturation,
sensor dynamics, computation delay, protection, and hardware effects. It is
not evidence for device selection, efficiency qualification, controller-design
qualification, safe operating area, lifetime, or grid-code compliance.
