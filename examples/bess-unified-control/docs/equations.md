<!-- markdownlint-disable MD049 -->

# Equations, Frames, and Conventions

## Per-unit bases

For three-phase rated apparent power \(S_b\), line-to-line RMS voltage
\(V_{LL,b}\), and nominal frequency \(f_b\):

\[
V_{\phi,b} = \frac{V_{LL,b}}{\sqrt{3}}, \qquad
I_b = \frac{S_b}{\sqrt{3}V_{LL,b}}, \qquad
Z_b = \frac{V_{LL,b}^2}{S_b}.
\]

Defaults are 10 MVA, 690 V, and 50 Hz. Positive P means BESS discharge into
the PCC; negative P means charging.

## Clarke and Park transforms

The amplitude-invariant Clarke transform is

\[
\begin{aligned}
v_\alpha &= \frac{2}{3}(v_a-\tfrac12v_b-\tfrac12v_c),\\
v_\beta &= \frac{2}{3}\frac{\sqrt3}{2}(v_b-v_c),\\
v_0 &= \frac{v_a+v_b+v_c}{3}.
\end{aligned}
\]

The rotating transformation at angle \(\theta\) is

\[
v_d=v_\alpha\cos\theta+v_\beta\sin\theta,\qquad
v_q=-v_\alpha\sin\theta+v_\beta\cos\theta.
\]

For the normalized peak-form alpha/beta vectors used by the example:

\[
P=\tfrac12(v_\alpha i_\alpha+v_\beta i_\beta),\qquad
Q=\tfrac12(v_\beta i_\alpha-v_\alpha i_\beta).
\]

Independent analytic tests create balanced ABC vectors at a known phase and
power angle, then verify all four equations without calling the controller.

## Grid-following branch

The source-backed concept is P/Q regulation synchronized to the utility grid.
The reduced-order command adds optional support terms:

\[
P^*=P_{ref}+K_f(f_{ref}-f), \qquad
Q^*=Q_{ref}+K_v(V_{ref}-V).
\]

The support gains and all inner-loop dynamics are `PROJECT_ASSUMPTION`
starters because the source does not publish a complete reusable controller.

## Grid-forming branch

The source-backed relation is real-power/frequency and reactive-power/voltage
formation. The project implementation uses droop with bounded secondary
restoration:

\[
f^*=f_{ref}-m_p(P-P_{ref})+\xi_f,
\qquad
\dot{\xi}_f=K_{if}(f_{ref}-f),
\]

\[
V^*=V_{ref}-n_q(Q-Q_{ref})+\xi_v,
\qquad
\dot{\xi}_v=K_{iv}(V_{ref}-V).
\]

The restoration states are bounded to prevent runaway. During
`SYNCHRONIZING`, phase error generates a bounded frequency correction and
voltage mismatch generates a bounded voltage correction.

## Limits and anti-windup

Requested active power is clipped by the active-power and DC-availability
limits; Q is clipped by the reactive-power limit. With PCC voltage \(V\), the
apparent-power/current boundary is

\[
\sqrt{P^2+Q^2} \le I_{max}\max(V,0.05).
\]

If necessary, P and Q are scaled together to the circle. Commands are then
slew limited. Restoration integrators are bounded, so infeasible commands do
not accumulate unbounded internal state. Scenario F asserts saturation,
current compliance, finite signals, and recovery after feasibility returns.

## Averaged dq current/filter equivalent

With voltage-oriented d/q axes, the commanded current targets are

\[
i_d^*=\frac{P^*}{\max(V,0.05)},\qquad
i_q^*=-\frac{Q^*}{\max(V,0.05)}.
\]

Each current state follows its target through the reduced current-control and
filter equivalent

\[
i_{d/q,k+1}=i_{d/q,k}+
\left(1-e^{-T_s/\tau_i}\right)(i_{d/q}^*-i_{d/q,k}),
\]

followed by the hard current-circle projection. Power is then calculated from
the dynamic states:

\[
P=V i_d,\qquad Q=-V i_q.
\]

Voltage and frequency each use the same exact first-order discrete form toward
their grid-anchored or forming command targets. These equations are a
project-defined validation abstraction, not a claimed paper plant. Phase is
grid-anchored with the breaker closed and integrated from the formed frequency
while islanded.

## Synchronization

The wrapped phase error is

\[
\Delta\theta=\operatorname{atan2}
(\sin(\theta_g-\theta_{pcc}),\cos(\theta_g-\theta_{pcc})).
\]

Reconnection readiness requires
\(|\Delta V|\le0.05\) p.u., \(|\Delta f|\le0.1\) Hz,
\(|\Delta\theta|\le5^\circ\), valid measurements, a present grid, and a
grid-following request. The conditions must remain true through the configured
hold and preparation intervals before the breaker can close.
