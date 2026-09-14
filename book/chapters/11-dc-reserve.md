# 11. Managing Stored Energy

[Contents](../README.md) · [Worked solutions](../solutions/11-dc-reserve.md) · [Source map](../source-map.md)

## Requested power is not available power

A converter can receive a 300 kW command when the battery can supply less.
The command does not create energy. For a short interval, the DC-link capacitor
can make up the difference, but its voltage changes as stored energy is spent.
Once an energy bound is reached, the converter request must be reduced or some
other modeled source must contribute.

The [DC-reserve example](../../examples/bess-dc-reserve-model/README.md)
introduces this missing layer between a power request and a battery. Its battery
is deliberately simpler than the cells in earlier chapters: affine OCV,
constant resistance and exact initial SOC. The focus is the accounting and
limiting policy, not the accuracy of a particular pack. Polarization,
temperature, ageing and state-estimation uncertainty are omitted.

We will derive battery terminal power, the reserve-dependent current limits,
and the DC-link energy update. The important result is a distinction among
requested power, battery power and delivered converter power. They are related,
but not identical, signals.

## 11.1 Use one sign convention through the chain

Positive battery current means discharge. Positive converter power leaves the
DC link toward an abstract AC-side load; negative converter power charges the
DC side. The battery's nominal charge capacity is $Q_c=3600Q_{Ah}$ in A·s.
For constant current during an interval,

$$
z_{k+1}=z_k-\frac{I_k\Delta t}{Q_c}.
$$

The source uses $V_{oc}(z)=V_0+k_z z$. Because SOC changes linearly during a
constant-current interval, this affine OCV changes linearly too. Its exact
interval average is

$$
\overline V_{oc}=V_{oc}(z_k)-\frac{k_z I_k\Delta t}{2Q_c}.
$$

The interval-average battery terminal power is therefore

$$
P_{bat,k}=(\overline V_{oc}-R_0I_k)I_k
=V_{oc}(z_k)I_k-R_{eff}I_k^2,
\qquad R_{eff}=R_0+\frac{k_z\Delta t}{2Q_c}.
$$

The extra term in $R_{eff}$ is an accounting consequence of OCV changing over
the interval. It is **not** an additional physical resistor whose heat should
be added to $I^2R_0$. Chemical power uses average OCV; ohmic loss uses the
actual $R_0$. Confusing those terms would double-count part of the energy
change.

Given a feasible power, the code solves the quadratic for the low-current
branch connected to zero current at zero power:

$$
I_k=\frac{V_{oc}(z_k)-\sqrt{V_{oc}(z_k)^2-4R_{eff}P_{bat,k}}}{2R_{eff}}.
$$

For charging, power is negative and this branch yields negative current. The
discriminant must remain real. This algebraic condition is necessary for this
equivalent circuit, but it does not replace explicit current, SOC or hardware
limits. The source checks parameter feasibility before relying on the power
mapping. See [simulate_bess_dc_reserve.m](../../examples/bess-dc-reserve-model/simulate_bess_dc_reserve.m)
for the actual update order.

## 11.2 A reserve is a policy, not a voltage source

The canonical minimum reserve is $z_{min}=0.20$. Discharge availability rises
linearly from zero at this reserve to one at $z=0.24$:

$$
a_d(z)=\operatorname{clip}\left(\frac{z-z_{min}}{w_d},0,1\right),
\qquad w_d=0.04.
$$

The discharge-current limit combines a nominal capability and an interval
charge bound:

$$
I_{d,max}=\min\left(I_{rated,d}a_d,
\frac{\max(0,z-z_{min})Q_c}{\Delta t}\right).
$$

The first term gradually reduces capability near the reserve. The second
prevents a single held interval from consuming more charge than remains above
it. Both are needed to understand the policy: a gradual taper alone and a
hard charge limit are not the same mechanism.

Charging has a corresponding availability factor
$a_c=\operatorname{clip}((z_{max}-z)/w_c,0,1)$ and a limit based on remaining
space below $z_{max}$. The defaults use 500 A maximum discharge, 300 A maximum
charge, upper SOC 0.90 and charge taper width 0.05. These are project starter
values, not a sourced vendor BMS or safe-operating-area specification.

At SOC 0.22, discharge availability is one half and the nominal current limit
becomes 250 A. With the 200 Ah capacity and 0.1 s interval, the remaining-charge
bound is much larger, so the taper term governs. This is a good example of
why a state can remain inside its hard boundary while its useful power is
already strongly reduced.

## 11.3 Control energy, then enforce its feasible interval

For DC-link capacitance $C_{dc}$,

$$
E_{dc}=\frac12 C_{dc}V_{dc}^2,\qquad
E_{dc,k+1}=E_{dc,k}+(P_{bat,k}-P_{conv,k})\Delta t.
$$

The voltage is recovered as $\sqrt{2E_{dc}/C_{dc}}$. Working directly with
energy makes the power balance linear over an interval. It also avoids
pretending that a fixed voltage source exists behind every converter request.

The example first asks the battery to meet the requested converter power and
restore a reference DC energy:

$$
P_{bat,raw}=P_{request}+K_E(E_{ref}-E_{dc}).
$$

$K_E$ has units s⁻¹, so the correction is in watts. The battery request is
clipped to the power range implied by its current limits. Only then does the
code determine how much converter power the capacitor can accommodate. From
$E_{min}\le E_{dc,k+1}\le E_{max}$,

$$
P_{bat}-\frac{E_{max}-E_{dc}}{\Delta t}
\le P_{conv}\le
P_{bat}+\frac{E_{dc}-E_{min}}{\Delta t}.
$$

The converter request is clipped to this interval. It may temporarily exceed
battery power while the capacitor discharges; it may also absorb more charge
than the battery accepts while the capacitor charges. Once headroom is gone,
that temporary difference is unavailable.

With $C_{dc}=0.8$ F, 750 V reference and bounds of 700 and 800 V, initial
energy is 225 kJ. The lower bound is 196 kJ and upper bound 256 kJ. Thus
there are only 29 kJ available for discharge and 31 kJ for additional charge
from the initial condition. A fixed 100 kW deficit would exhaust the discharge
headroom in 0.29 s. The capacitor is a short transient buffer, not a replacement
for reserve energy in the battery.

## 11.4 Inspect three power traces, not just SOC

Run the primary workflow from the repository root:

```matlab
run('examples/bess-dc-reserve-model/check_bess_dc_reserve.m')
run('examples/bess-dc-reserve-model/run_bess_dc_reserve.m')
```

Use a fresh MATLAB session and save existing variables/figures first. The
workflow uses Base MATLAB and does not build a Simulink model. To inspect
returned data without the plotting script:

```matlab
addpath('examples/bess-dc-reserve-model');
parameters = bess_dc_reserve_default_parameters();
result = simulate_bess_dc_reserve(parameters);
metrics = summarize_bess_dc_reserve(result);
disp(metrics);
```

![Stored DC-reserve example with requested and delivered power, SOC, DC voltage and current](../../assets/bess-dc-reserve-response.png)

*Existing companion asset. It illustrates the prescribed profile; it is not
measured site dispatch or a new execution receipt.*

The canonical requests are +250, −120, +300 and 0 kW, beginning at 0, 120,
240 and 360 s. The run ends at 420 s. Source expectations include approximately
10.225 kWh delivered discharge, 8.109 kWh curtailed discharge and 4.000 kWh
accepted charge. The minimum and final SOC are about 0.2042; the reserve is
not exactly reached because the taper has already restricted current.

Trace a region of curtailment on the power plot. Check whether battery power
is limited, whether the DC link has reached its lower bound, and whether the
SOC taper is active. Do not infer causation from the SOC trace alone: at a
different operating point, current capability or capacitor headroom can be the
immediate constraint.

## 11.5 Make an energy ledger

There are two useful closure checks:

$$
E_{chemical}-E_{terminal}-E_{ohmic}\approx0,
$$

$$
E_{dc,0}+\sum_k(P_{bat,k}-P_{conv,k})\Delta t-E_{dc,N}\approx0.
$$

The first compares battery chemical, terminal and internal-loss energy; the
second compares the capacitor's initial energy, net power and final energy.
They test different boundaries. A converter efficiency number should not
appear in this ledger unless converter losses are actually modeled.

Requested discharge energy also partitions into delivered and curtailed
discharge for this policy. Use positive and negative power parts separately
when reporting charge and discharge. Net energy alone would hide the charging
interval, much as net Ah can hide absolute throughput in Chapter 1.

Optional envelope and dynamic-profile runners are available in the example
README. Compare reserve floors within an unchanged request profile. The
dynamic profiles are not energy-normalized, so a larger delivered-energy total
under one profile does not prove that its shape is intrinsically more efficient.
Nor is delivered energy required to increase monotonically with requested
power once curtailment and internal loss matter.

## Exercises

1. **Reserve limit.** At SOC 0.22, use the default reserve, taper width,
   capacity, maximum discharge current and time step. Calculate both current
   bounds, the binding limit, and the next SOC if that current is applied.
2. **Average OCV.** Derive $R_{eff}$ and compute terminal power for the
   250 A interval in Exercise 1. Separate chemical power and ohmic loss;
   explain why the extra effective-resistance term is not extra resistor heat.
3. **Finite headroom.** Calculate the initial DC-link energy and both energy
   headrooms. For a hypothetical constant 100 kW battery-to-converter power
   deficit, estimate the time to the lower limit. What additional dynamics
   would make that estimate insufficient for a real DC bus?
4. **Interpret the run.** Reproduce the metrics and verify the two energy
   residuals returned by the summary. Explain why a higher reserve can reduce
   delivered discharge within the same profile, and why this does not yet
   describe a closed-loop battery-to-grid BESS.

## What to carry forward

Power availability depends on state, policy and the time interval over which
energy is transferred. The AC supervisor in Chapter 12 accepts DC-side
availability and voltage as boundary inputs. The two examples are not connected
in this repository. Treating that interface explicitly is the final modeling
exercise, not a claim that the integration has already been performed.
