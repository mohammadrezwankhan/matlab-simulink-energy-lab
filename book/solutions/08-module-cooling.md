# Solutions — Chapter 8

[Chapter](../chapters/08-module-cooling.md) · [Chapter index](../README.md) · [Source map](../source-map.md)

## Exercise 1 — Hand-check the first step

At the first sample every cell is at 25 °C and the coolant supply is 25 °C.
Because all cell temperatures are equal, every cell-to-cell difference is zero.
Because each segment inlet is also 25 °C, each cell-to-coolant difference is
zero. Therefore $Q_{cool,i}=0$ and $Q_{cond,i}=0$ for this first update.

The module heat is 180 W and the fractions are
$[0.14,0.16,0.19,0.20,0.17,0.14]$. The generated heat vector is

$$
Q_{gen}=180f
 =[25.2,\ 28.8,\ 34.2,\ 36.0,\ 30.6,\ 25.2]\,\mathrm{W}.
$$

Every cell has

$$
C_i=m_ic_{p,i}=1.05(1000)=1050\,\mathrm{J/K}.
$$

With $\Delta t=1\,\mathrm{s}$,

$$
\Delta T_i=\frac{Q_{gen,i}\Delta t}{C_i}
=\frac{Q_{gen,i}}{1050}.
$$

The increments are

$$
[0.024,\ 0.0274285714,\ 0.0325714286,\ 0.0342857143,\
0.0291428571,\ 0.024]\,\mathrm{K}.
$$

Thus the next temperatures are approximately
$[25.024,25.0274285714,25.0325714286,25.0342857143,25.0291428571,25.024]$
°C. Cell 4 has the largest increment because it has the largest heat fraction,
0.20. The zero coolant heat is not an assertion that cooling is absent in
general; it follows only from the equal initial cell and coolant temperatures
at this first sample.

## Exercise 2 — Derive the module balance

For each cell,

$$
C_i\frac{dT_i}{dt}=Q_{gen,i}-Q_{cool,i}+Q_{cond,i}.
$$

For six cells, write the conduction terms using interface flows
$F_i=G_{cc,i}(T_i-T_{i+1})$:

$$
Q_{cond}=[-F_1,\ F_1-F_2,\ F_2-F_3,\ F_3-F_4,\ F_4-F_5,\ F_5].
$$

Summing gives

$$
\sum_{i=1}^{6}Q_{cond,i}
=-F_1+(F_1-F_2)+(F_2-F_3)+(F_3-F_4)
+(F_4-F_5)+F_5=0.
$$

The generated terms sum because the fractions sum to one:
$\sum_iQ_{gen,i}=Q_M$. Therefore

$$
\sum_iC_i\frac{dT_i}{dt}
=Q_M-\sum_iQ_{cool,i}.
$$

For the explicit source implementation, the integrated module net heat is

$$
E_{in}=\sum_{n=1}^{N_t-1}
\left(Q_{M,n}-\sum_iQ_{cool,i,n}\right)\Delta t_n.
$$

The stored thermal energy change is

$$
\Delta E=\sum_i C_i(T_{i,end}-T_{i,start}).
$$

The field called `energy_balance_error_J` is

$$
\mathrm{error}_E=\Delta E-E_{in},
$$

with units J. It should be close to zero for the discrete calculation. The
per-cell field `cell_energy_balance_error_J` applies the same subtraction to
each cell and can reveal a local indexing error that is hidden by cancellation
in the module sum.

## Exercise 3 — Reproduce the flow sensitivity

Run the existing check:

```matlab
run(fullfile('examples', 'battery-module-cooling-network', ...
    'check_battery_module_cooling_network.m'))
```

The check itself includes a high-flow case. This block is independently
runnable from the repository root, including its own model-folder path:

```matlab
modelDirectory = fullfile('examples', 'battery-module-cooling-network');
addpath(modelDirectory);
parameters = battery_module_cooling_default_parameters();
profile = battery_module_cooling_default_profile();
baseResult = simulate_battery_module_cooling_network( ...
    profile, parameters, 1);
highFlowParameters = parameters;
highFlowParameters.coolant_mass_flow_kg_per_s = ...
    3 * parameters.coolant_mass_flow_kg_per_s;
highFlowResult = simulate_battery_module_cooling_network( ...
    profile, highFlowParameters, 1);
```

For the canonical profile, the source check requires

$$
\max(T_{cell,high})<\max(T_{cell,base}),
$$

and the corresponding peak cell-temperature spread and peak coolant outlet
temperature to be lower as well. The reported source/check expectation is
38.01 °C for high-flow peak temperature versus 39.87 °C at base flow; these
numbers belong to the configured illustrative case.

The local coolant closure is

$$
\dot C(T_{out,i}-T_{in,i})=Q_{cool,i}.
$$

In the result, the check evaluates this with
`result.coolant_capacity_rate_W_per_K` and the inlet/outlet arrays, requiring a
maximum absolute mismatch below $10^{-12}\,\mathrm{W}$. Contiguity is checked
separately: segment 1 inlet equals `coolant_supply_temp_C`, and columns 2–6 of
`coolant_segment_inlet_temp_C` equal columns 1–5 of
`coolant_segment_outlet_temp_C`. These two tests distinguish heat bookkeeping
from correct serial ordering.

## Exercise 4 — Critical interpretation of quasi-steady cooling

At each sample, the source starts from the supplied coolant temperature and
walks through all six cells algebraically. It calculates segment 1's outlet,
assigns it as segment 2's inlet, and continues. The coolant temperatures are
therefore stored outputs of a quasi-steady calculation, not dynamic states with
a derivative or a fluid heat capacity inventory. A warmer downstream inlet is
simply the accumulated heat gain from upstream segments at that sample.

Omitting transport delay can be misleading when the coolant residence time is
comparable to the cell thermal time or to a fast load transition. A controller
could then react to an outlet temperature that would not yet have reached the
measurement location, or a downstream cell could receive a transient inlet that
the algebraic model never represents. Omitting pumping power is misleading when
comparing flow rates: a higher flow may lower cell temperatures while requiring
substantially more electrical power or pressure head. Manifold maldistribution
can also make the nominal flow differ by segment.

Evidence needed for a design conclusion includes measured or otherwise
defensible mass-flow distribution and pressure-drop/pump-power curves, fluid
residence-time or transport measurements, and temperature/heat-flux data under
step and sustained loads. A model extension should add a fluid control-volume
state or an explicit delay and account for pump power before claiming a
system-level benefit. The current source/check only establishes numerical
closure and behavior for its stated assumptions.
