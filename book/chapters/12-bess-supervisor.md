# 12. Following and Forming the Grid

[Contents](../README.md) · [Worked solutions](../solutions/12-bess-supervisor.md) · [Source map](../source-map.md)

## The final problem is also a sequence problem

A storage controller can regulate a power request while a strong grid supplies
the voltage and frequency reference. If that grid disappears, continuing the
same logic is not enough: something must establish the island's voltage and
frequency, respect current limits, and decide whether reconnection is ready.
When the grid returns, closing a breaker merely because voltage magnitudes
match ignores frequency and phase.

The [unified BESS example](../../examples/bess-unified-control/README.md)
combines a reduced-order plant with grid-following, grid-forming and supervisory
logic. It is a transparent project translation of selected control concepts,
not an exact reproduction of every mode or numerical result in its source
publication. The [source ledger](../../examples/bess-unified-control/requirements/source-ledger.csv)
distinguishes published concepts from project assumptions. Virtual synchronous
generator inertia, hardware protection qualification and grid-code certification
are not implemented by this example.

This chapter asks you to reason about both equations and event order. A mode
label alone does not prove that the controller switched at the correct time.

## 12.1 Establish the bases before interpreting power

The default three-phase apparent-power base is 10 MVA, line-to-line RMS
voltage base 690 V, and nominal frequency 50 Hz. The phase-voltage, line-current
and impedance bases follow from balanced three-phase power:

$$
V_{\phi,b}=V_{LL,b}/\sqrt3,\qquad
I_b=\frac{S_b}{\sqrt3 V_{LL,b}},\qquad
Z_b=\frac{V_{LL,b}^2}{S_b}.
$$

Positive active power means discharge/injection into the point of common
coupling (PCC). A command of 0.5 p.u. represents 5 MW on this base; it does
not imply that the separate Chapter 11 battery is sized to supply it. Base
definitions make normalized equations portable, but they do not create a
physically consistent integration automatically.

The amplitude-invariant Clarke transform maps three phases to a stationary
two-axis representation:

$$
v_\alpha=\frac23(v_a-\tfrac12v_b-\tfrac12v_c),\qquad
v_\beta=\frac23\frac{\sqrt3}{2}(v_b-v_c).
$$

Rotation by $\theta$ gives
$v_d=v_\alpha\cos\theta+v_\beta\sin\theta$ and
$v_q=-v_\alpha\sin\theta+v_\beta\cos\theta$. The sign of the second
equation determines the reactive-power convention; mixing it with another
Park convention changes signs even when the plotted magnitudes look plausible.

For the example's normalized peak-form α/β quantities,

$$
P_{pu}=\tfrac12(v_\alpha i_\alpha+v_\beta i_\beta),\qquad
Q_{pu}=\tfrac12(v_\beta i_\alpha-v_\alpha i_\beta).
$$

Why one half rather than the familiar three halves? In physical amplitude-
invariant coordinates, balanced three-phase power has a $3/2$ factor. Dividing
by $S_b=3V_{\phi,b}I_b$ while normalizing α/β voltage and current by those RMS
bases leaves $1/2$. The code's definitions and balanced-vector checks matter
more than memorizing a coefficient without its bases.

## 12.2 Follow the grid or establish an island reference

Grid-following control treats the available grid as the reference and requests
active/reactive power. The example optionally adds support terms:

$$
P^*=P_{ref}+K_f(f_{ref}-f),\qquad
Q^*=Q_{ref}+K_v(V_{ref}-V).
$$

A low frequency can therefore increase active-power demand under the chosen
sign convention. It still cannot exceed current or DC-side availability.
The support gains are illustrative project values, not universal grid-service
settings.

In grid-forming operation, the project uses droop with bounded secondary
restoration:

$$
f^*=f_{ref}-m_p(P-P_{ref})+\xi_f,\qquad
V^*=V_{ref}-n_q(Q-Q_{ref})+\xi_v.
$$

The restoration states integrate frequency and voltage errors subject to
bounds. Droop creates a relation between power imbalance and formed reference;
restoration changes the long-term offset. Their interaction with a network
requires more analysis than this reduced-order demonstration supplies.

The plant is not an electromagnetic network solver. Its voltage, frequency
and current channels use project-defined reduced dynamics. For example, a held
current target has the exact first-order update

$$
i_{d,k+1}=i_{d,k}+(1-e^{-T_s/\tau_i})(i_d^*-i_{d,k}),
$$

with an analogous q-axis update and hard current-circle projection. The target
uses $i_d^*=P^*/\max(V,0.05)$ and $i_q^*=-Q^*/\max(V,0.05)$. The numerical
voltage floor avoids division by a small quantity; it is not a physical claim
that power remains available at zero voltage.

## 12.3 Feasibility precedes the mode's ambition

The command limiter first clips P and Q to their configured component limits
and clips P symmetrically to $[-P_{avail},+P_{avail}]$, where $P_{avail}\ge0$
is the DC-availability magnitude. It then applies the
apparent-power/current boundary

$$
\sqrt{P^2+Q^2}\le I_{max}\max(V,0.05).
$$

When the requested vector lies outside the circle, the source scales P and Q
together. This preserves their direction after the component clips, rather
than giving one component absolute priority. At $V=0.8$ p.u., unit current
limit permits only 0.8 p.u. apparent power under this relation.

Read [bess_limit_pq.m](../../examples/bess-unified-control/src/bess_limit_pq.m)
before assuming that “saturation” means only one thing. Saturation can come
from active power, reactive power, DC availability or the circle. Commands are
also slew-limited, and plant current is projected to its hard circle. These
layers help the example remain bounded; they do not replace a hardware
overcurrent protection design.

## 12.4 Name the supervisor states

The state codes are stable public labels in
[bess_state_codes.m](../../examples/bess-unified-control/src/bess_state_codes.m):

| Code | State | Role in the teaching model |
| --- | --- | --- |
| 1 | `GRID_FOLLOWING` | Operate against an available grid reference |
| 2 | `PREPARE_ISLAND` | Manage the transition away from grid-following |
| 3 | `GRID_FORMING` | Establish the forming branch |
| 4 | `ISLANDED_SUPPORT` | Support the isolated load |
| 5 | `SYNCHRONIZING` | Reduce grid/PCC mismatches before reconnection |
| 6 | `PREPARE_RECONNECT` | Require readiness through a further preparation interval |
| 7 | `RECOVERY` | Manage bounded return after a fault or invalid condition |
| 8 | `FAULT_SAFE` | Apply the example's fault-safe command policy |

These are not simply eight labels placed on a continuous waveform. Each
transition has guards and timing. A trace that eventually reaches the right
state can still be wrong if it accumulated hold time before initialization or
closed a breaker one sample early.

![Existing supervisor state diagram](../../examples/bess-unified-control/docs/supervisor-states.svg)

*Structural illustration. Transition timing must be read from current source
and its sample contract, not inferred from an older diagram or stored plot.*

For reconnection, readiness includes a present grid, valid measurements, a
grid-following request, voltage mismatch within 0.05 p.u., frequency mismatch
within 0.1 Hz and wrapped phase mismatch within 5°. The wrapped phase is
$\operatorname{atan2}(\sin\Delta\theta,\cos\Delta\theta)$, which avoids
treating angles just across ±π as nearly a full revolution apart.

Those thresholds and hold times are project assumptions. A real grid
interconnection requires its own applicable requirements, sensing, protection
and equipment validation; this book does not supply that engineering authority.

## 12.5 Time labels are part of the model

The current runner records plant state at $t_k$ before the selected command
drives the following interval. Command $c_k$ is held over
$[t_k,t_{k+1})$. An $N$-sample record therefore contains $N-1$ dynamic updates,
not $N$. At the first sample, elapsed controller time is zero, so there is no
unearned timer, restoration or slew credit.

At later boundaries, an exogenous event such as grid loss can open the breaker
without another dynamic state advance. This is a zero-duration boundary action,
not a reason to label the previous interval's state as a future state. The
configured sample period, 5 ms by default, drives updates; timestamp roundoff
within the documented tolerance is accepted, while skipped or irregular
reference grids are rejected.

Synchronization hold accumulates only when readiness is true at both sampled
boundaries of an interval. It proves a sampled guard, not continuous readiness
between those boundaries. If readiness first becomes true at 1.000 s, a
0.100 s hold cannot be earned at that same sample. Under uninterrupted sampled
readiness, twenty subsequent 5 ms intervals reach 1.100 s. Additional
preparation logic still matters before breaker closure.

The Simulink wrapper validates its actual logged clock before assigning scenario
labels. It rejects missing, repeated, reversed, nonfinite or misaligned samples
rather than interpolating them into apparent agreement. See the exact
[sample-timing contract](../../examples/bess-unified-control/docs/sample-timing.md).
Historical plots and run counts are not silently reinterpreted under that
contract.

## 12.6 Reproduce transitions before interpreting them

From the repository root:

```matlab
addpath('examples/bess-unified-control');
result = run_bess_unified_control('C');
```

This runs the MATLAB reference grid-loss scenario and plots power, voltage,
frequency and state code. Use a fresh session and separate figures for work
you want to preserve. Scenario C removes the grid at 2 s. Run `'E'` separately
for grid return and reconnection; it is a separate prescribed experiment,
not an automatic continuation of C. Scenario `'F'` explores infeasible
power requests and recovery from saturation.

For the full focused MATLAB/Simulink validation route:

```matlab
run('examples/bess-unified-control/check_bess_unified_control.m')
```

The complete check requires Simulink and can build temporary/generated models.
Observe the repository's loaded-model and output-directory precautions. The
[source map](../source-map.md) records the prior 77-test, eight-scenario run
at the model snapshot; it is not a new validation of the manuscript text.

Inspect transition times as well as the final state. Compare requested power
with limited commands and measured plant response. A command can change at a
boundary while the state responds over subsequent intervals. Confusing these
traces would undo the sample-time distinction that makes the experiment
reviewable.

## Exercises

1. **Bases and conventions.** Calculate $V_{\phi,b}$, $I_b$ and $Z_b$ for
   10 MVA and 690 V. Explain the one-half coefficient in the normalized
   α/β power relation and convert 0.5 p.u. active power to watts.
2. **Current circle.** Request $(P,Q)=(0.8,0.6)$ p.u. at $V=0.8$ p.u.,
   unit current limit and full DC availability. The component limits do not
   bind. Calculate the scale and limited P/Q. What changes if availability
   first clips P to 0.5 p.u.?
3. **A timer is not a sample count.** Readiness first becomes true at
   1.000 s on the 5 ms grid. Calculate the earliest completion of a 0.100 s
   hold with uninterrupted readiness at both boundaries. Explain why that
   does not by itself prove immediate breaker closure or continuous readiness.
   Run C and E separately and record their state sequences.
4. **Capstone interface.** Specify, without implementing it, an interface
   between Chapter 11 and this supervisor. Include power/voltage bases,
   signs, sample rates, command-versus-delivery semantics, energy balance,
   failure behavior and at least two acceptance experiments. Explain why
   directly feeding an asymmetric battery capability into a symmetric
   availability magnitude can lose information.

## What the complete course has established

You have moved from a charge balance to a supervisory control sequence while
keeping states, units, evidence and omissions explicit. The next engineering
step is not automatically a larger diagram. It may be measured parameters,
an uncertainty study, a different plant or a carefully tested interface. A
useful model is one whose conclusions you can defend at its stated boundary.
