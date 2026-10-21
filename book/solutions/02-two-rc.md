# Chapter 2 Solutions — Two RC Time Scales

**Back to chapter:** [Chapter 2](../chapters/02-two-rc.md) · [book contents](../README.md)

**Snapshot identity:** repository values refer to [source-map.md](../source-map.md).

All calculations use positive current for discharge and the exact
zero-order-held branch update.

## Exercise 1 — Conceptual solution

The order is:

1. $R_0$ appears immediately at the current edge because its drop is
   $R_0I_k$ with no dynamic state.
2. The fast branch follows over its short time constant (\tau_1).
3. The slow branch follows over its longer time constant (\tau_2) and can
   remain visible through a long rest.

A capacitor affects the time constant through $\tau_2=R_2C_2$; it does not
   directly set the steady branch drop. For constant current, the slow branch
   tends to $R_2I$. Thus $R_2$ controls the eventual voltage magnitude,
   while $C_2$ controls how quickly that magnitude is approached (together
   with $R_2$).

## Exercise 2 — Analytical solution

The decay factors are

$$
a_1=e^{-1/1.8}=0.5737534,
\qquad a_2=e^{-1/30}=0.9672161.
$$

With zero initial states, the update reduces to

$$
v_{i,k+1}=R_i(1-a_i)I_k.
$$

Therefore,

$$
v_{1,k+1}=0.0015(1-0.5737534)(10)
 =0.0063937~\mathrm{V}=\boxed{6.394~\mathrm{mV}},
$$

and

$$
v_{2,k+1}=0.0025(1-0.9672161)(10)
 =0.0008196~\mathrm{V}=\boxed{0.820~\mathrm{mV}}.
$$

The fast branch is already about 7.8 times larger after this first second,
even though its steady 10 A drop is only 15 mV versus 25 mV for the slow
branch. That is the distinction between response speed and eventual magnitude.

## Exercise 3 — Code/reproduction solution

Run from the repository root:

```matlab
addpath('examples/battery-2rc-model');
profile = readtable('examples/battery-rc-model/data/pulse_current_profile.csv');
parameters = battery_2rc_default_parameters();
result = simulate_battery_2rc_model(profile, parameters, 1);

expectedTau = [parameters.r1_Ohm*parameters.c1_F, ...
    parameters.r2_Ohm*parameters.c2_F];
assert(max(abs(result.branch_time_constants_s - expectedTau)) < 1e-12);

reconstructed = result.ocv_V - result.current_A*parameters.r0_Ohm - ...
    result.v_rc1_V - result.v_rc2_V;
assert(max(abs(result.terminal_voltage_V - reconstructed)) < 1e-12);
```

The voltage equation must use `current_A`, the applied current, not
`requested_current_A`. The simulator may clip a request at an SOC boundary;
the applied value is the one used for both branch updates and the ohmic drop.
The no-plot source check also compares shared SOC/current/first-branch traces
against the one-RC result and checks deterministic repeatability. The plotting
runner can clear variables and close figures, so use it only in a fresh MATLAB
session and save any important state first.

## Exercise 4 — Interpretation and limits solution

The energy-boundary upper current is

$$
I_{\max}=\frac{z_kQ3600}{\Delta t}
 =\frac{0.10(1)(3600)}{3600}=0.10~\mathrm{A}.
$$

Thus the applied current is $I_k=0.10$ A, even though the request was 1 A.
At the first sample both branch states are rested, so they are zero in the
sample-voltage equation. Consequently,

$$
V_{t,k}=3.70-(0.004)(0.10)-0-0
 =\boxed{3.6996~\mathrm{V}}.
$$

The interval removes exactly 0.10 Ah and reaches SOC zero. A real BMS must
also enforce limits such as maximum allowable current, voltage protection,
temperature, contactor/converter capability, and ageing or fault derating.
The chapter's limiter only protects the nominal SOC bookkeeping over the
requested interval; it is not a complete safety policy.
