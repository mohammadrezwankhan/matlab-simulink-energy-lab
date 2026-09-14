# 9. Regulating Converter Voltage

[Contents](../README.md) · [Worked solutions](../solutions/09-averaged-control.md) · [Source map](../source-map.md)

## The load changes before the controller can respond

Imagine a converter supplying a 400 V DC bus. A second resistive load is
connected. At that instant, load current can change, but inductor current and
capacitor voltage cannot jump in this model. The capacitor supplies the initial
current deficit and its voltage falls. A useful controller must observe that
fall, request more inductor current, and change duty without demanding an
impossible current or duty ratio.

This chapter compares a fixed duty, a PI controller, and a filtered-PID
controller on the same averaged buck plant. The question is not which acronym
is best. It is how a particular controller changes the depth and duration of a
disturbance, and what constraints shape that change. The companion example is
[converter-closed-loop-model](../../examples/converter-closed-loop-model/README.md).

You need Kirchhoff's laws and the meaning of a derivative. Chapter 10 will add
explicit switching. Here, duty is a continuous fraction representing the
period-averaged switch action; PWM ripple is intentionally absent.

## 9.1 Start with two stored-energy states

Let $i_L$ be inductor current and $v$ output voltage. An inductor stores
$Li_L^2/2$ joules; a capacitor stores $Cv^2/2$ joules. These two states explain
why output voltage cannot follow a disturbance instantaneously. With input
$V_{in}$, duty $D$, inductor resistance $R_L$, and resistive load $R$, the
inductor voltage balance is

$$
L\frac{di_L}{dt}=DV_{in}-v-R_Li_L.
$$

At the output node, the load consumes $v/R$ amperes. The remainder charges the
capacitor:

$$
C\frac{dv}{dt}=i_L-\frac{v}{R}.
$$

Do a unit check before proceeding. The inductor equation has volts on both
sides because H·A/s is V. The capacitor equation has amperes on both sides
because F·V/s is A. A gain or parameter error cannot be repaired by choosing
a visually pleasing axis range.

At equilibrium, both derivatives vanish:

$$
i_L=\frac{v}{R},\qquad D=\frac{v+R_Lv/R}{V_{in}}.
$$

Thus the familiar ideal result $v=DV_{in}$ omits the copper drop. The
comparison starts at 400 V, 20 Ω, 800 V input, and 0.1 Ω winding resistance.
The equilibrium current is 20 A and the fixed duty is $402/800=0.5025$.
After the load falls to 10 Ω, the same duty cannot maintain exactly 400 V:

$$
v_{new}=\frac{0.5025(800)}{1+0.1/10}=398.0198\ \mathrm{V}.
$$

That predicted steady-state error is a useful baseline. Feedback should be
judged against it, not against an unexamined assumption of perfect open-loop
regulation.

## 9.2 Convert voltage error into a current request

Define voltage error $e_k=v^*-v_k$. The outer controller produces a current
request rather than duty directly:

$$
i^*_{raw,k}=i_{nom}+K_pe_k+\xi_k+K_d\dot e_{f,k}.
$$

Here $i_{nom}=20$ A is the initial nominal current and $\xi$ is integral action
in amperes. In the PI case, $K_d=0$. In the comparison, $K_p=0.25$ A/V and
$K_i=80$ A/(V·s); the filtered-PID case adds $K_d=0.001$ A·s/V. The requested
current is clipped to 0–60 A. These comparison limits differ from the separate
single-reference-step runner's 0–40 A range; do not combine their parameter
tables.

Without limits, integral action updates as

$$
\xi_{k+1}=\xi_k+K_ie_k\Delta t.
$$

The gain's units matter: multiplying A/(V·s) by V and s produces A. A positive
voltage error accumulates a larger current demand. At a sustained equilibrium,
integral action can supply the extra 20 A needed by the new load while voltage
error becomes small.

The source implements conditional integration. It updates the integral when
the raw current request lies strictly inside the allowed range, or when error
would recover from saturation. If the request is at the upper limit and error
is positive, accumulating more integral action would store demand the plant
cannot currently realize. Integration pauses. If the error becomes negative,
integration is allowed to reduce that demand. The rule is visible in
[simulate_converter_controller_comparison.m](../../examples/converter-closed-loop-model/simulate_converter_controller_comparison.m).

This is an educational anti-windup policy tied to the current-reference limit.
It is not a general proof that every actuator saturation, delay or parameter
combination is safe. In particular, duty is limited separately; the outer
integrator does not infer every possible physical reason that a current
request may be unavailable.

## 9.3 Why filter the derivative?

A raw finite difference is $(e_k-e_{k-1})/\Delta t$. A small error jump divided
by a very small interval can be large. The comparison uses the recurrence

$$
\dot e_{f,k}=a\dot e_{f,k-1}+(1-a)\frac{e_k-e_{k-1}}{\Delta t},
\qquad a=\frac{\tau_f}{\tau_f+\Delta t}.
$$

With $\tau_f=0.5$ ms and $\Delta t=10$ µs, $a=0.980392$. Only about 1.96%
of a new raw derivative enters at each update. The filter reduces abrupt
derivative demand, but it also changes the timing of the controller response.
This deterministic example contains no sensor-noise model, so the filter's
presence is not evidence that the tuning has been validated under noise.

The proportional, integral and derivative terms answer different questions:
how large is the error, how long has it persisted, and how is it changing?
Their units and update order must be checked before comparing their sizes.
Adding a derivative term can reduce a transient sag while worsening settling
or overshoot. There is no requirement that all metrics improve together.

## 9.4 The inner loop requests duty

The inner proportional current loop uses the bounded request:

$$
D_{raw,k}=\frac{v_k+R_Li_{L,k}+K_c(i^*_k-i_{L,k})}{V_{in}},
\qquad D_k=\operatorname{clip}(D_{raw,k},0.05,0.95).
$$

The feedforward terms approximately cancel the measured output voltage and
copper drop in the inductor equation. Without clipping or variation during
the interval, substituting this command gives
$L\dot i_L=K_c(i^*-i_L)$. This explains the role of $K_c=3$ Ω: it turns
a current error into the extra inductor voltage needed to change current.
The simplified substitution helps interpret the loop; it does not eliminate
the outer-loop dynamics or prove a global closed-loop stability margin.

The code computes the current request using the old integral state, decides
whether to update that state, computes duty, and advances the plant. Reordering
those operations creates a different sampled controller. The explicit Euler
plant updates are

$$
i_{L,k+1}=i_{L,k}+\frac{\Delta t}{L}(D_kV_{in}-v_k-R_Li_{L,k}),
$$

$$
v_{k+1}=v_k+\frac{\Delta t}{C}(i_{L,k}-v_k/R_k).
$$

Both right-hand sides use interval-start states. The 10 µs step belongs to this
particular model and tuning. If inductance, capacitance or bandwidth changes,
reconsider discretization instead of assuming that an old successful check
validates the new case.

## 9.5 Run a fair comparison

From the repository root, in a fresh MATLAB session:

```matlab
run('examples/converter-closed-loop-model/check_converter_controller_comparison.m')
run('examples/converter-closed-loop-model/run_converter_controller_comparison.m')
```

Save existing work first: existing scripts may clear variables and close
figures. These are Base MATLAB commands; Control System Toolbox and Simulink
are not required for this primary workflow. The runner produces the appropriate
three-panel voltage/current/duty comparison. There is no need to substitute a
stored switching-converter image for this different plant.

For a programmatic table without the plotting script:

```matlab
addpath('examples/converter-closed-loop-model');
comparison = simulate_converter_controller_comparison();
summary = build_controller_comparison_table(comparison);
disp(summary);
```

The source reference reports approximately:

| Controller | Final-window error | Positive overshoot | Undershoot | 2% settling |
| --- | ---: | ---: | ---: | ---: |
| Open loop | 1.984 V | 3.84% | 6.48% | 20.6 ms |
| PI | approximately 0 V | 1.25% | 9.95% | 10.3 ms |
| Filtered PID | −0.015 V | 1.67% | 7.38% | 14.0 ms |

These are deterministic source expectations, not hardware specifications.
Read the metric definitions: the final error averages the last 10 ms; settling
uses the last out-of-band sample after the disturbance. A nonzero steady error
can still fit within the ±8 V settling band. Conversely, a small final error
does not establish that the transient was acceptable.

The PI case settles fastest here but has the deepest sag. Filtered PID trades
some settling time and positive overshoot for a smaller sag. That is a reason
to state a design objective before choosing a winner. The current limits in
this example constrain the *reference*; they do not model magnetic saturation,
protection trips, or a physical semiconductor safe-operating area.

## Exercises

1. **Equilibrium.** Derive the fixed-duty voltage after the 20→10 Ω step.
   Calculate the pre-step duty and the duty required to maintain 400 V afterward.
   Explain why a 1.98 V error still permits a 2% settling-time result.
2. **The first interval.** Just after the load change, take $i_L=20$ A,
   $v=400$ V, $D=0.5025$, $L=2$ mH, $C=1$ mF and $\Delta t=10$ µs.
   Calculate both Euler updates before feedback has changed duty.
3. **Read the experiment.** Run the programmatic table above. Identify which
   controller best satisfies “smallest sag” among the feedback cases and which
   satisfies “fastest settling.” Explain why this is not an apples-to-apples
   comparison with the separate 300→400 V reference-step runner.
4. **Constraints and derivative action.** With raw current request 65 A,
   positive voltage error and a 60 A upper limit, should the integral increase?
   What if the error is negative? Calculate the filter weight for the default
   step and discuss one omitted effect that could change the ranking.

## What to carry forward

The averaged plant turns a duty fraction into stored-energy dynamics. Feedback
changes that fraction through bounded current demand, and sampling makes the
order of operations part of the model. Chapter 10 retains these ideas while
replacing averaged switch action with explicit ON/OFF intervals. The added
detail will expose ripple and loss accounting, not magically certify a design.
