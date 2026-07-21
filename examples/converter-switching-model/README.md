# Switching Buck Converter

This Base-MATLAB reference resolves ideal pulse-width modulation and the
resulting inductor-current and output-voltage ripple for a synchronous buck
converter. It complements the algebraic and closed-loop averaged examples
without requiring Simulink or a power-electronics toolbox.

## Engineering Question

How closely do the steady average and ripple of a switched buck converter match
the corresponding averaged continuous-conduction estimates?

## Model Structure

The ideal complementary switch state `s` is either zero or one. During each
event-aligned PWM interval, the model propagates the linear state exactly:

```text
diL/dt = (s * Vin - Vout - RL * iL) / L
dVout/dt = (iL - Vout / Rload) / C
```

The simulator precomputes the matrix exponential and input increment for one
time step, then applies the ON or OFF transition. The duty edge and final time
must align with the discrete PWM grid, preventing an interval from silently
straddling a switching event.

## Starter Parameters

| Parameter | Value | Unit |
| --- | ---: | --- |
| Input voltage | 800 | V |
| Duty cycle | 0.45 | - |
| Switching frequency | 10 | kHz |
| Inductance | 2 | mH |
| Inductor resistance | 0.1 | Ohm |
| Capacitance | 1 | mF |
| Load resistance | 20 | Ohm |
| Simulation duration | 0.3 | s |
| Steps per switching period | 100 | - |

## Run

To inspect startup and the final three PWM periods:

```matlab
run_switching_buck_converter
```

For the no-plot regression check:

```matlab
check_switching_buck_converter
```

Expected check output:

```text
Switching buck converter check passed.
Average output voltage: 358.209 V
Average inductor current: 17.910 A
Current ripple: 9.901 A peak-to-peak
Voltage ripple: 0.124 V peak-to-peak
Measured duty cycle: 0.450
```

The check verifies PWM step counts, finite states, average voltage/current,
current and voltage ripple, settled volt-second and charge balance, final state
drift, doubled-grid convergence, and invalid parameter handling.

## Averaged Comparison

Including the 0.1 Ohm inductor resistance, the steady averaged solution is:

```text
Vout = D * Vin / (1 + RL / Rload)
Iout = Vout / Rload
```

The switched result is compared with that lossy average and with the familiar
continuous-conduction triangular ripple estimates. These comparisons are
regression checks for the stated assumptions, not validation against hardware.

## Explicit Limitations

- The switches are ideal and complementary; dead time, diode drops, output
  capacitance, reverse recovery, switching energy, and gate-drive behavior are
  excluded.
- Fixed-duty open-loop PWM is used. The closed-loop example remains an averaged
  model and is not coupled to this switching plant.
- A synchronous topology permits bidirectional inductor current; diode-emulated
  discontinuous-conduction behavior is not modeled.
- The source and resistive load are fixed, and capacitor ESR is omitted.
- Parameters are educational starter values, not a device, magnetic, thermal,
  EMI, protection, or controller design.
