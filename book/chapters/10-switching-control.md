# 10. From Averaging to Switching

[Contents](../README.md) · [Worked solutions](../solutions/10-switching-control.md) · [Source map](../source-map.md)

## A duty ratio is not a switch position

The previous chapter applied $DV_{in}$ continuously to an averaged plant.
A real switching command is instead ON or OFF. Its average may be close to
$D$, but the inductor experiences alternating voltage slopes, the capacitor
filters a rippling current, and the controller sees the plant only at its
sample times. If these distinctions matter to a question, the averaged model
does not answer it merely because its voltage trace is smooth.

The [switching closed-loop example](../../examples/converter-switching-closed-loop-model/README.md)
keeps the plant small enough to inspect. A high-side resistive switch feeds an
inductor; a constant-drop diode carries positive current during OFF intervals.
The controller updates at each PWM boundary. Exact affine state maps propagate
the electrical states over the fixed subintervals. Loss accounting is explicit
about which terms affect the state trajectory and which are post-processed.

The purpose is to learn how sampling, switch states and model boundaries fit
together—not to select a qualified semiconductor or predict a hardware
efficiency from a short simulation.

## 10.1 Derive the two electrical modes

Let $s=1$ when the high-side switch is ON and $s=0$ when it is OFF. The
positive-current continuous-conduction equations are

$$
L\dot i_L=sV_{in}-(1-s)V_D-(R_L+sR_{DS})i_L-v,
\qquad C\dot v=i_L-v/R.
$$

The ON mode includes source voltage and switch resistance. The OFF mode
removes the source and adds a negative diode-drop contribution. This sign
makes physical sense: a conducting freewheel diode does not become an
additional positive supply. Both modes retain winding resistance, capacitor
current balance and the load.

If current would become negative, the code rejects the case when continuous
conduction is enforced. It does not silently introduce a discontinuous-conduction
mode. That choice is part of the model contract, not a limitation to evade by
disabling the check without deriving the missing mode.

For a fixed mode and load, define $x=[i_L,v]^T$:

$$
\dot x=A_sx+b_s,\qquad
A_s=\begin{bmatrix}
-(R_L+sR_{DS})/L&-1/L\\
1/C&-1/(RC)
\end{bmatrix},
\quad
b_s=\begin{bmatrix}(sV_{in}-(1-s)V_D)/L\\0\end{bmatrix}.
$$

These matrices change when the load changes, even if the switch state does
not. Event alignment therefore includes load and reference changes as well as
PWM edges. The source precomputes maps for both loads and both switch states.

## 10.2 Integrate a held mode exactly

For fixed $A$ and $b$ over a subinterval $\delta t$, variation of constants gives

$$
x_{k+1}=\Phi x_k+\Gamma,
\qquad \Phi=e^{A\delta t},\quad
\Gamma=\int_0^{\delta t}e^{A\tau}b\,d\tau.
$$

When $A$ is nonsingular, $A\Gamma=(\Phi-I)b$. The implementation uses a
linear solve, not an explicit matrix inverse, to obtain this increment. Its
supported positive component values and resistive loads give nonsingular mode
matrices. The integral expression is the more general derivation: it remains
meaningful for a singular matrix. An augmented matrix exponential is another
way to compute it in a more general model.

Read [switching_closed_loop_buck_interval_maps.m](../../examples/converter-switching-closed-loop-model/switching_closed_loop_buck_interval_maps.m)
to connect each matrix entry with an electrical term. “Exact” here describes
the solution of these held affine equations. The switch model, diode model,
sampled control and parasitic omissions remain approximations. Some energy
integrals also use the resolved grid rather than exact continuous-time squared
state integrals, so an exact state map does not imply zero numerical energy
residual under every accounting method.

## 10.3 Resolve the three time scales

The default switching frequency is 10 kHz, giving $T_{PWM}=100$ µs. Each PWM
period contains 100 subintervals, so $\delta t=1$ µs. The controller updates
once per period, not once per subinterval. Its duty command determines an
integer count of ON subintervals; the command is bounded and quantized.

A desired duty near 0.506 becomes 51 ON intervals out of 100, or 0.51, for
a period using nearest-integer quantization. A trajectory's average duty need
not be a multiple of 0.01, because successive periods can choose different
integer counts. Confusing the per-period command with its average can make a
correct result look inconsistent.

The canonical 0.18 s run contains 1,800 controller periods and 180,000 plant
subintervals. That resolution is a declared numerical setup, not a measurement
of a real controller's timer. Computational delay, sensor quantization and
sampling jitter are absent. Duty quantization is present and should not be
conflated with the omitted sensor effects.

The reference changes from 300 to 400 V at 40 ms. The load changes from 20
to 10 Ω at 100 ms. All three kinds of event—PWM, reference and load—lie on
the declared grid. If an extension moves an event off the grid, its timing
policy must be specified rather than hidden by array indexing.

## 10.4 Keep feedback and switch detail separate

The outer PI loop creates a bounded current reference, while the inner current
loop uses voltage and loss-related feedforward to create duty. Integral action
is conditional on whether the current request is free or recovering from a
limit. The maximum reference is 60 A and duty remains between 0.05 and 0.95.
The gains are starter values, not the result of a robustness or hardware
qualification study.

Averaging the switched inductor balance near steady state gives a useful
sanity check:

$$
D V_{in}-(1-D)V_D-(R_L+DR_{DS})I-v\approx0.
$$

Using $I\approx v/R$ yields

$$
v\approx\frac{DV_{in}-(1-D)V_D}{1+(R_L+DR_{DS})/R}.
$$

This expression explains why duty slightly above one half can be needed for
roughly 400 V from an 800 V input. It is a balance check, not a substitute for
the transient simulation. Ripple and current/duty correlations mean that
products of separate averages are generally approximations to averages of
products.

## 10.5 Account for losses without inventing a thermal model

The electrical trajectory includes winding resistance, diode drop and switch
ON resistance. Copper and switch-conduction losses depend on squared current;
diode loss depends on positive conducting current. The example separately sums
turn-on and turn-off event-energy estimates. Its reference parameters and
source links are documented in the example README.

For a local illustrative scaling, the event estimate is

$$
E_{event}=E_{ref}\frac{V_{in}}{V_{ref}}\frac{|i_{edge}|}{I_{ref}}.
$$

At the reference voltage and current, the factor is one. Doubling edge current
doubles this particular estimate; it does not establish that every real device
has a globally linear switching-energy surface. Temperature, gate drive and
parasitic conditions can matter outside this simple relation.

Transition energy is added to source work and counted as device loss without
altering the resolved electrical state trajectory. A study that removes those
post-processed energies should therefore preserve the voltage/current trace
while changing energy totals. That is an important interpretation check. In
contrast, changing ON resistance changes the plant matrices and can affect
both trajectory and losses.

The optional temperature sensitivity *prescribes* a fixed junction temperature
inside documented 25–175 °C anchors. It does not integrate a thermal network.
Do not draw a time-varying junction-temperature curve from the loss output
without introducing and validating additional thermal states and boundaries.

## 10.6 Run and interpret the evidence

From a fresh MATLAB session at the repository root:

```matlab
run('examples/converter-switching-closed-loop-model/check_switching_closed_loop_buck.m')
run('examples/converter-switching-closed-loop-model/run_switching_closed_loop_buck.m')
```

Save variables and figures first; existing scripts may clear them. The primary
workflow uses Base MATLAB. The optional
[native Simulink companion](../../examples/converter-switching-closed-loop-simulink-model/README.md)
requires Simulink and has its own builder/output-file precautions.

![Stored switching-buck example showing voltage regulation, current, duty and separated losses](../../assets/converter-switching-closed-loop-response.png)

*Existing companion figure. Reproduce the runner for a new execution; the stored
image is not a fresh physical measurement or a new manuscript validation run.*

The source's canonical check expects about 399.62 V final average, 5.91%
reference-step overshoot and 2.08% load-step undershoot. It reports about
3.354 J switch-conduction loss and 0.405 J transition loss over this transient.
The stated 97.046% is an estimated *energy* efficiency for this model and
window, not a device data-sheet efficiency or hardware measurement.

The check also exercises zero-transition-loss trajectory parity, grid
refinement and energy closure. Those checks answer specific implementation
questions. They do not include magnetic saturation, protection, dead time,
reverse recovery, EMI or a robust digital-controller design. Adding switching
detail has improved the questions we can ask, not removed the need to state
what is missing.

## Exercises

1. **Time scales.** Calculate the PWM period, plant subinterval and counts in
   the default run. Quantize a requested duty of 0.506 to the nearest allowed
   integer count. Why may average duty still be reported as 0.5062?
2. **Mode slopes.** At $i_L=20$ A and $v=400$ V with a 20 Ω load, calculate
   the ON and OFF derivatives using the default $L=2$ mH, $C=1$ mF,
   $R_L=0.1$ Ω, $R_{DS}=0.04$ Ω and $V_D=1$ V. Explain why exact maps
   are still needed even though these initial derivatives are easy to compute.
3. **Event energy.** At 800 V and 36 A, use reference energies 109 µJ ON
   and 45 µJ OFF at 18 A. Calculate one ON/OFF pair and its average power
   if repeated at 10 kHz. Explain why multiplying that power by 0.18 s is
   not the canonical transient loss result.
4. **Read and challenge.** Run the canonical check and explain separately
   what its final voltage, transition-loss parity and energy closure support.
   Propose one experiment that would be required before claiming a
   junction-temperature prediction. Do not modify the canonical parameters.

## What to carry forward

Switching introduces mode-dependent state equations, distinct control and plant
time grids, and an energy ledger. It does not create an unlimited power source.
Chapter 11 asks what happens when the battery and DC-link energy can no longer
support the converter's request, even if a controller would like them to.
