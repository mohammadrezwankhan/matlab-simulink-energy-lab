# Chapter 1 Solutions — The One-RC Battery Pulse Model

**Back to chapter:** [Chapter 1](../chapters/01-one-rc.md) · [book contents](../README.md)

**Snapshot identity:** use the source record in [source-map.md](../source-map.md) when reproducing repository values.

The numerical answers below use the stated sign convention (positive current
means discharge) and round only at the end.

## Exercise 1 — Conceptual solution

The model is

$$
V_t=V_{\mathrm{oc}}-R_0I-v.
$$

The $R_0I$ term is instantaneous: it changes as soon as the applied current
changes. The $v$ term carries memory because its value comes from the prior
RC state and relaxes with time constant $R_1C_1$. Here,

$$
R_0I=(0.005)(12)=0.060~\mathrm{V},\qquad v=0.018~\mathrm{V}.
$$

Thus the terminal voltage is

$$
V_t=3.80-0.060-0.018=3.722~\mathrm{V}.
$$

Both contributions lower the voltage below OCV. The 60 mV drop is the
instantaneous ohmic component; the 18 mV drop is the transient polarization
component. If the current were switched to zero, the ohmic term would vanish
immediately, while the 18 mV state would decay rather than disappear
instantaneously.

## Exercise 2 — Analytical solution

First compute the charge removed during the interval:

$$
\Delta q=\frac{4(30)}{3600}=0.0333333~\mathrm{Ah}.
$$

The SOC update is

$$
z_{k+1}=0.75-\frac{0.0333333}{2.0}=0.7333333\approx\boxed{0.73333}.
$$

The time constant is $R_1C_1=(0.010)(1000)=10$ s. Therefore

$$
a_k=e^{-30/10}=e^{-3}=0.0497871\approx\boxed{0.049787}.
$$

The held-current steady branch voltage is $R_1I=0.010(4)=0.040$ V. The
exact update is

$$
\begin{aligned}
v_{k+1}&=a_kv_k+R_1(1-a_k)I\\
&=(0.0497871)(0.020)+(0.010)(1-0.0497871)(4)\\
&=0.000995742+0.038008516\\
&=\boxed{0.039004~\mathrm{V}}.
\end{aligned}
$$

The result is close to the 40 mV steady value because three time constants
have elapsed. It is not exactly 40 mV because the initial branch voltage was
only 20 mV rather than the same-current steady state.

## Exercise 3 — Code/reproduction solution

Run from the repository root. The first path addition makes the simulator and
the duty-cycle utility available without changing the source files:

```matlab
addpath('examples/battery-rc-model');
profile = readtable('examples/battery-rc-model/data/pulse_current_profile.csv');
parameters = battery_rc_default_parameters();
result = simulate_battery_rc_model(profile, parameters, 1);

reconstructed = result.ocv_V - result.current_A*parameters.r0_Ohm - ...
    result.v_rc_V;
assert(max(abs(result.terminal_voltage_V - reconstructed)) < 1e-12);

socFromCharge = parameters.initial_soc - ...
    result.cumulative_net_discharge_Ah/parameters.capacity_Ah;
assert(max(abs(result.soc - socFromCharge)) < 1e-12);
```

The voltage assertion uses `ocv_V`, the applied `current_A`, `v_rc_V`,
`terminal_voltage_V`, and the parameter `r0_Ohm`. The SOC assertion uses
`cumulative_net_discharge_Ah`, `capacity_Ah`, `initial_soc`, and `soc`.
`requested_current_A` is intentionally not used in the balance: if limiting
occurs, the applied current is the current that actually updates the model.
The no-plot check
[`check_battery_rc_model.m`](../../examples/battery-rc-model/check_battery_rc_model.m)
performs this class of checks as part of a larger deterministic suite.
Run scripts only in a fresh MATLAB session because they can clear workspace
variables and close figures; save any important state first.

## Exercise 4 — Interpretation and limits solution

The maximum feasible discharge current is

$$
I_{\max}=\frac{z_kQ3600}{\Delta t_k}
 =\frac{(0.10)(1)(3600)}{3600}=0.10~\mathrm{A}.
$$

The request is 1 A, so the applied current is

$$
\boxed{I_k=0.10~\mathrm{A}}.
$$

The interval removes

$$
\Delta q=\frac{(0.10)(3600)}{3600}=0.10~\mathrm{Ah},
$$

and consequently

$$
z_{k+1}=0.10-\frac{0.10}{1}=\boxed{0}.
$$

Using the requested 1 A in the voltage equation would apply a 10 mV ohmic
drop if $R_0=10$ m$\Omega$, while the SOC state says only 0.10 A can be
delivered over that one-hour interval. It would combine an energy-feasible
state trajectory with an energy-infeasible voltage/current pair. The limiter
does not represent, for example, a maximum-temperature limit. It also omits
instantaneous current, voltage, converter, fuse, and cell-safety limits; those
must be modelled separately when the engineering question requires them.
