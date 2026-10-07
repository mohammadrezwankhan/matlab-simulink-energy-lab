# 8. A Six-Cell Serial-Coolant Network

[Chapter index](../README.md) · [Solutions](../solutions/08-module-cooling.md) · [Source map](../source-map.md)

## The question

Even if every cell starts at the same temperature, a serial coolant path does
not present the same boundary condition to every cell. Upstream cells see cold
coolant; downstream cells see coolant that has already absorbed heat. Add a
nonuniform cell heat load and cell-to-cell conduction, and the hottest cell is
not obvious from the heat fractions alone. The motivating question is: **how do
we combine a quasi-steady coolant calculation with explicit thermal masses while
keeping local and module energy balances auditable?**

This chapter uses six lumped cell temperatures connected to a one-dimensional
coolant channel. It is a deliberately inspectable network. Coolant inventory,
transport delay, pressure drop, pumping power, and manifold maldistribution are
outside the model, so the result is a teaching calculation and not a cooling
system design.

## Prerequisite recap

For a lumped cell, $C_i\,dT_i/dt=Q_i$ with $C_i=m_i c_{p,i}$. For a stream,
the heat-capacity rate is $\dot C=\dot m c_{p,c}$ in W/K. A simple
heat-exchanger effectiveness relation maps a cell-to-coolant conductance to the
heat exchanged in one segment. Here that coolant relation is evaluated
quasi-steadily at each simulation sample, while cell temperatures advance with
forward Euler over the interval.

The coolant flow direction is explicit: segment 1 receives the supply, and its
outlet is segment 2's inlet. Cell-to-cell conduction is bidirectional and
conservative. A flow sign is also explicit: positive cell-to-coolant heat warms
the coolant. If a cell is colder than its local coolant, the same equation
allows a negative value, meaning the coolant heats the cell.

## Notation and units

| Symbol | Meaning | Units |
| --- | --- | --- |
| $i$ | Cell/segment index, 1 through 6 | 1 |
| $T_i$ | Lumped cell temperature | °C |
| $C_i=m_i c_{p,i}$ | Cell thermal capacity | J/K |
| $f_i$ | Fraction of module heat assigned to cell $i$ | 1 |
| $Q_M$ | Applied module heat generation | W |
| $UA_i$ | Cell-to-coolant conductance | W/K |
| $\dot m,c_{p,c}$ | Coolant mass flow and heat capacity | kg/s, J/(kg K) |
| $\dot C=\dot m c_{p,c}$ | Coolant capacity rate | W/K |
| $\epsilon_i$ | Segment heat-exchanger effectiveness | 1 |
| $G_{cc,i}$ | Conductance between cells $i$ and $i+1$ | W/K |
| $T_{in,i},T_{out,i}$ | Segment inlet and outlet coolant temperatures | °C |

The default six-cell source uses $m_i=1.05\,\mathrm{kg}$, $c_{p,i}=1000\,
\mathrm{J/(kg\,K)}$, so each $C_i=1050\,\mathrm{J/K}$. Heat fractions are
$[0.14,0.16,0.19,0.20,0.17,0.14]$, summing to one. The $UA$ values are
$[1.7,1.8,1.9,1.9,1.8,1.7]\,\mathrm{W/K}$, cell-to-cell conductances are
$0.25\,\mathrm{W/K}$, and the coolant uses $\dot m=0.004\,\mathrm{kg/s}$
and $c_{p,c}=4180\,\mathrm{J/(kg\,K)}$.

## Derive the serial coolant relation

The coolant capacity rate is

$$
\dot C=\dot m c_{p,c}.
$$

To derive the segment relation, hold the cell temperature $T_i$ constant while
the coolant passes through the segment. A differential conductance $d(UA)$
transfers $(T_i-T_f)d(UA)$ into a stream whose temperature changes by $dT_f$:

$$
\dot C\,dT_f=(T_i-T_f)\,d(UA).
$$

Separate variables and integrate from inlet to outlet. The temperature
difference from the cell decays exponentially:

$$
T_{out,i}-T_i=(T_{in,i}-T_i)\exp(-UA_i/\dot C).
$$

Thus the fraction of the inlet-to-cell temperature difference removed in one
segment is its effectiveness. The source defines this as

$$
\epsilon_i=1-\exp\left(-\frac{UA_i}{\dot C}\right).
$$

It then uses the effective conductance $H_i=\epsilon_i\dot C$ to calculate
heat from the cell into that segment:

$$
Q_{cool,i}=H_i(T_i-T_{in,i}).
$$

The outlet follows from the stream energy balance,

$$
T_{out,i}=T_{in,i}+\frac{Q_{cool,i}}{\dot C}.
$$

The implementation passes $T_{out,i}$ forward as $T_{in,i+1}$. Because
$0<\epsilon_i<1$ for positive finite $UA_i$ and $\dot C$, the outlet is a
weighted move toward the cell temperature and does not overshoot it. The
effective $H_i$ is lower than the configured $UA_i$, which captures finite
stream capacity without introducing a dynamic coolant state.

## Derive the cell balances

The prescribed cell source is

$$
Q_{gen,i}=f_iQ_M,
\qquad \sum_i f_i=1.
$$

Define the interface flow $F_i=G_{cc,i}(T_i-T_{i+1})$ as positive from cell
$i$ to cell $i+1$. Its contribution is subtracted from cell $i$ and added
to cell $i+1$. The net cell-to-cell conduction for an interior cell is

$$
Q_{cond,i}=G_{cc,i-1}(T_{i-1}-T_i)+G_{cc,i}(T_{i+1}-T_i).
$$

At the two ends only one neighbor exists. The complete balance is

$$
C_i\frac{dT_i}{dt}=Q_{gen,i}-Q_{cool,i}+Q_{cond,i}.
$$

Forward Euler over $\Delta t_n$ gives

$$
T_{i,n+1}=T_{i,n}+\frac{\Delta t_n}{C_i}
\left(Q_{gen,i,n}-Q_{cool,i,n}+Q_{cond,i,n}\right).
$$

Summing over all cells cancels each $F_i$, leaving

$$
\sum_i C_i\frac{dT_i}{dt}=Q_M-\sum_iQ_{cool,i}.
$$

That is the module balance the source reports as
`energy_balance_error_J`. The per-cell field
`cell_energy_balance_error_J` is useful when a local sign or indexing error
exists even though a module sum might look plausible.

## Stability and source discretization

The explicit update has a conservative conductance bound. For each cell, the
source computes an adjacent-conduction outflow sum and adds the configured
cell-to-coolant $UA_i$, then rejects any interval satisfying

$$
\Delta t\geq\min_i\frac{C_i}{UA_i+G_{adj,i}}.
$$

The code uses configured $UA_i$, not the smaller effective $H_i$, making the
bound conservative for finite-flow exchange. This is a stability guard, not an
accuracy or convergence guarantee. A shorter step may be necessary to resolve
a heat-load transition or to compare two nearby peak temperatures.

The authoritative implementation is
`examples/battery-module-cooling-network/simulate_battery_module_cooling_network.m`.
Its public setup functions are `battery_module_cooling_default_parameters` and
`battery_module_cooling_default_profile`. The profile table contains
`time_s`, `module_heat_generation_W`, and
`coolant_inlet_temp_C`. Native timestamps are preserved when `dt_s` is
omitted; otherwise previous-value interpolation builds a uniform grid. Parameter
vectors are normalized to row vectors internally, so row and column inputs
produce the same result.

Run the existing scripts from the repository root:

```matlab
run(fullfile('examples', 'battery-module-cooling-network', ...
    'run_battery_module_cooling_network.m'))
run(fullfile('examples', 'battery-module-cooling-network', ...
    'check_battery_module_cooling_network.m'))
```

The plot script begins with `clear; clc; close all;`; the no-plot check begins
with `clearvars; clc;`. These demo/check scripts clear variables and close
figures, so protect unrelated work in a shared MATLAB session. They add the
model directory to the path and use the same cleanup pattern as the other
examples.

## First one-second step: a hand-checkable result

To isolate the first step, use a two-row 180-W profile with every cell and the
coolant initially at 25 °C. At the first sample, cell-to-coolant differences are
zero, so $Q_{cool,i}=0$, and all cell-to-cell differences are zero. Only
weighted generation changes temperature:

$$
\Delta T_i=\frac{f_iQ_M\Delta t}{C_i}
          =\frac{f_i(180)(1)}{1050}.
$$

The heat vector is $[25.2,28.8,34.2,36.0,30.6,25.2]\,\mathrm{W}$, and the
temperature increments are approximately
$[0.024,0.0274285714,0.0325714286,0.0342857143,0.0291428571,0.024]\,\mathrm{K}$.
The next cell temperatures are 25 °C plus those increments. This is a
source/check expectation for this custom first-step setup and makes the phrase
“weighted heat divided by 1050” numerically explicit.

The direct reproduction is:

```matlab
modelDirectory = fullfile('examples', 'battery-module-cooling-network');
addpath(modelDirectory);
oneStepProfile = table([0; 1], [180; 180], [25; 25], ...
    'VariableNames', {'time_s', 'module_heat_generation_W', ...
    'coolant_inlet_temp_C'});
parameters = battery_module_cooling_default_parameters();
result = simulate_battery_module_cooling_network( ...
    oneStepProfile, parameters, 1);
disp(result.cell_temp_C(2, :));
```

![Existing six-cell module cooling response figure.](../../assets/battery-module-cooling-network-response.png)

*Figure 8.1 — Existing result figure from the serial-coolant example, showing
module heat, individual cell temperatures, coolant warming, and temperature
spread. It is an illustrative numerical result, not a pumping, flow, or
hardware-validation claim.*

## Interpret the canonical response

The default profile applies 180 W from 60–660 s, 30 W from 660–900 s, and
140 W from 900–1320 s. The existing check's source/check expectations are a
39.87 °C peak at cell 4 and 1320 s, a 5.10 °C peak spread, a 31.27 °C peak
coolant outlet, and a 38.01 °C peak for three-times the coolant flow. Cell 4's
large heat fraction and its central position compete with downstream coolant
warming; the resulting hottest index is a network outcome, not simply the
largest $f_i$.

Increasing flow raises $\dot C$. Each effectiveness changes, and the stream
has more heat capacity per kelvin, so the canonical high-flow case removes heat
more effectively and warms less at the outlet. The check expects lower peak
cell temperature, lower cell-temperature spread, and lower outlet warming. This
monotonic comparison is a property of the stated case, not a universal claim
for every possible parameter set or flow regime.

Inspect three closures when interpreting a run. First,
`coolant_capacity_rate_W_per_K * (outlet - inlet)` must equal each
`cell_to_coolant_heat_W`. Second, every segment outlet must equal the next
segment inlet. Third, the sum of `cell_conduction_net_heat_W` across cells must
be zero. If these pass but a peak still seems surprising, examine the heat
fractions, $UA$ distribution, and coolant ordering before changing the time
step.

## Limitations

Each cell is a single thermal mass; through-plane and in-plane gradients, tabs,
collectors, and contact resistances are absent. The coolant is quasi-steady at
each sample, with no fluid inventory or transport delay. Pressure drop, pump
power, boiling, flow maldistribution, and manifold effects are not represented.
The heat fractions, $UA$ values, and cell-to-cell conductance are constant
illustrative values, not measurements. Heat is prescribed rather than coupled
to current or an electrochemical model. The explicit time-step guard does not
make the network physically validated. Replace the placeholders and compare
against temperature and coolant heat-flux measurements before design or safety
use.

## Exercises

### Exercise 1 — Hand-check the first step

Using the custom 180-W, one-second setup with all initial temperatures at 25 °C,
calculate the heat generated by cells 1–6 and each temperature increment. Which
cell has the largest increment, and why is its coolant heat zero at this first
sample?

### Exercise 2 — Derive the module balance

Starting from the six cell equations, sum the balances and show that all
cell-to-cell conduction terms cancel. Derive the discrete energy-balance
quantity that should be close to zero in `energy_balance_error_J`, including its
units.

### Exercise 3 — Reproduce the flow sensitivity

Run `check_battery_module_cooling_network`, then create a second parameter
structure with `coolant_mass_flow_kg_per_s` multiplied by three. Which result
fields should be lower in the high-flow case, and which local relation verifies
that the coolant path is contiguous?

### Exercise 4 — Critical interpretation of quasi-steady cooling

Explain why the serial model can report a downstream coolant inlet warmer than
the supply without having a coolant state derivative. Identify two situations
where omitting transport delay or pumping power could make a design conclusion
misleading, and state what additional evidence would be needed.
