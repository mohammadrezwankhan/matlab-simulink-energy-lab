# 7. Through-Thickness Gradients in a Pouch Cell

[Chapter index](../README.md) · [Solutions](../solutions/07-pouch-gradients.md) · [Source map](../source-map.md)

## The question

A pouch cell is broad and thin, so a single temperature can hide the very
gradient that controls a thermal design decision. If one broad face is cooled
more strongly than the other, which side hosts the hot spot? How does a
finite-volume discretization expose that answer while conserving the prescribed
heat? This chapter builds an answer with a one-dimensional, cell-centered slab.

The model is deliberately narrow: heat is generated uniformly through the
volume, conduction is only through thickness, and each broad face exchanges heat
with its own fluid. It is an excellent bridge between a lumped thermal balance
and a spatial PDE, but its output is an educational numerical result rather than
a physical qualification claim.

## Prerequisite recap

From a lumped thermal model, recall $C\,dT/dt=Q$. A finite-volume model keeps
that same energy balance for each control volume (CV), but adds heat flows
through neighboring faces. Fourier conduction gives a conductance $G$ in
W/K, so a temperature difference multiplied by $G$ is a heat flow in W.
Forward Euler evaluates those flows from the current sample and advances every
node together.

Two bookkeeping habits are essential. First, internal interface heat is equal
and opposite for its two neighboring CVs; it must disappear when all CV
balances are summed. Second, the boundary relation contains a half-CV
conduction resistance in series with convection. A boundary is therefore not
simply $hA(T_{node}-T_{fluid})$ when the stored temperature is at the CV
center.

## Geometry, notation, and units

| Symbol | Meaning | Units |
| --- | --- | --- |
| $L$ | Pouch through-thickness | m |
| $A$ | Broad-face area $=WH$ | m² |
| $N$ | Number of equal cell-centered CVs | 1 |
| $\Delta x=L/N$ | CV thickness | m |
| $x_i=(i-\tfrac12)\Delta x$ | Center of node $i$ | m |
| $\rho,c_p$ | Effective density and heat capacity | kg/m³, J/(kg K) |
| $k_z$ | Through-plane conductivity | W/(m K) |
| $Q_{cell}$ | Prescribed whole-cell heat | W |
| $q'''=Q_{cell}/(AL)$ | Volumetric heat source | W/m³ |
| $h_l,h_r$ | Left/right face transfer coefficients | W/(m² K) |
| $C_{node}$ | CV thermal capacity | J/K |
| $G_z$ | Internal face conductance | W/K |

The default source parameters are $N=15$, $L=0.008\,\mathrm{m}$, width
$0.15\,\mathrm{m}$, height $0.10\,\mathrm{m}$, $\rho=2200\,\mathrm{kg/m^3}$,
$c_p=900\,\mathrm{J/(kg\,K)}$, and $k_z=0.45\,\mathrm{W/(m\,K)}$. The area
is $A=0.015\,\mathrm{m^2}$, and the default boundary coefficients are
$h_l=35$ and $h_r=12\,\mathrm{W/(m^2 K)}$. Temperatures are stored in °C
because all driving differences are differences, but the finite-volume
conduction equations are otherwise unit-consistent in SI.

## Build the finite-volume balance

Every CV has volume $A\Delta x$, so

$$
C_{node}=\rho c_p A\Delta x.
$$

With equal spacing, the conductance between adjacent node centers is

$$
G_z=\frac{k_zA}{\Delta x}.
$$

Let the interface flow $F_i=G_z(T_i-T_{i+1})$ be positive from node $i$
to node $i+1$. The internal conduction contribution to node $i$ is
$F_{i-1}-F_i$, using only the interfaces that exist. Thus an interior node
has

$$
C_{node}\frac{dT_i}{dt}=\frac{Q_{cell}}{N}
 +G_z(T_{i-1}-T_i)+G_z(T_{i+1}-T_i).
$$

The signs make the cancellation visible: $F_i$ is subtracted from the left
node and added to the right node. At the left and right boundary, the source
combines the half-CV conduction resistance $\Delta x/(2k_z)$ with the
convection resistance $1/h$:

$$
G_{b}=\frac{A}{\Delta x/(2k_z)+1/h},
\qquad
Q_b=G_b(T_{node}-T_{fluid}).
$$

Positive $Q_b$ means heat leaves the cell. The inferred surface temperature is

$$
T_{surface}=T_{fluid}+\frac{Q_b}{hA},
$$

which is a useful diagnostic: the same $Q_b$ must satisfy both the effective
series conductance and the convection relation.

The complete node update for an interval $\Delta t_n$ is

$$
T_{i,n+1}=T_{i,n}+\frac{\Delta t_n}{C_{node}}
\left(\frac{Q_{cell,n}}{N}+Q_{cond,i,n}-Q_{b,i,n}\right).
$$

The source evaluates `calculate_heat_flows` internally, stores every interface
flow, and forms `node_conduction_net_heat_W` with equal-and-opposite updates. The
public result includes node temperatures, center and volume-average
temperatures, inferred surfaces, boundary removal, heat-flow arrays, hot-spot
position, and node and whole-cell balance errors.

## A continuous comparison

For a symmetric slab with equal $h$ on both faces, common fluid temperature
$T_\infty$, and uniform $q'''$, the steady one-dimensional equation is

$$
k_z\frac{d^2T}{dx^2}+q'''=0.
$$

Symmetry gives zero gradient at the center. Integrating to a face and applying
the convection condition gives the center rise

$$
T_{center}-T_\infty
=\frac{q'''L}{2h}+\frac{q'''L^2}{8k_z}.
$$

The first term is the face-to-fluid convection rise and the second is the
center-to-face conduction rise. The expression is independent of the grid and
is therefore a useful check on a long finite-volume run. It is not a substitute
for a transient or asymmetric solution.

For the source check, $Q_{cell}=8\,\mathrm{W}$, $h_l=h_r=20\,\mathrm{W/(m^2K)}$,
and $T_\infty=25\,^{\circ}\mathrm{C}$. With $AL=0.015(0.008)=0.00012\,\mathrm{m^3}$,
$q'''=66666.6667\,\mathrm{W/m^3}$, and the analytic expression predicts

$$
T_{center}=25+\frac{66666.6667(0.008)}{2(20)}
+\frac{66666.6667(0.008)^2}{8(0.45)}
=39.5185185\,^{\circ}\mathrm{C}.
$$

The existing check allows 0.12 °C difference after a long transient. This is a
source/check expectation for one configured grid and step, not generic physical
validation.

## Explicit-Euler stability

For a node with total outward conductance $G_{out}$, the homogeneous part has
a time constant $C_{node}/G_{out}$. The source uses a conservative monotonic
bound,

$$
\Delta t<\min_i\frac{C_{node}}{G_{out,i}},
$$

where $G_{out}=2G_z$ for an interior node, $G_z+G_{b,l}$ for the left
boundary, and $G_z+G_{b,r}$ for the right boundary. The inequality is strict;
the implementation rejects `interval_s >= stabilityLimit_s`. It is a sufficient
bound for the explicit finite-volume update. A smaller step may still be needed
to resolve a switching heat profile or a desired accuracy in the hot spot.

## Source discretization and reproducible workflow

The authoritative public functions are
`pouch_cell_thermal_default_parameters`,
`pouch_cell_thermal_default_profile`, and
`simulate_pouch_cell_thermal_model(profile, parameters, dt_s)` in
`examples/pouch-cell-thermal-gradient`. The profile table has
`time_s`, `cell_heat_generation_W`, `left_fluid_temperature_C`, and
`right_fluid_temperature_C`. Omitting `dt_s` preserves native irregular
timestamps. A supplied positive step makes a uniform grid using previous-value
interpolation for all inputs, and the final profile time must be an integer
multiple of that step.

Run from the repository root:

```matlab
run(fullfile('examples', 'pouch-cell-thermal-gradient', ...
    'run_pouch_cell_thermal_model.m'))
run(fullfile('examples', 'pouch-cell-thermal-gradient', ...
    'check_pouch_cell_thermal_model.m'))
```

The plot script starts with `clear; clc; close all;`; the no-plot check starts
with `clearvars; clc;`. Those demo/check scripts clear variables and close
figures, so save unrelated session state first. Both scripts add their model
directory and restore the previous MATLAB path. A direct analytic comparison
can be reproduced with:

```matlab
modelDirectory = fullfile('examples', 'pouch-cell-thermal-gradient');
addpath(modelDirectory);
parameters = pouch_cell_thermal_default_parameters();
parameters.left_heat_transfer_coefficient_W_per_m2K = 20;
parameters.right_heat_transfer_coefficient_W_per_m2K = 20;
profile = table([0; 3600], [8; 8], [25; 25], [25; 25], ...
    'VariableNames', {'time_s', 'cell_heat_generation_W', ...
    'left_fluid_temperature_C', 'right_fluid_temperature_C'});
result = simulate_pouch_cell_thermal_model(profile, parameters, 0.5);
disp(result.center_temperature_C(end));
```

![Existing pouch-cell thermal-gradient response figure.](../../assets/pouch-cell-thermal-gradient-response.png)

*Figure 7.1 — Existing result figure from the pouch-cell example, showing heat
input, surface/center temperatures, through-thickness profiles, and boundary
heat removal. It visualizes the configured numerical result; it does not certify
the placeholder properties.*

## Interpreting asymmetry and conservation

In the default profile, the right coefficient is weaker than the left. For an
equal fluid temperature, the right boundary removes less heat for a comparable
surface-to-fluid difference. The temperature maximum shifts toward the more
weakly cooled right side; heat still leaves through both boundaries. The
`peak_position_m` result reports this directly instead of requiring a visual
guess from a plot. A temperature spread of zero in the zero-heat, isothermal
case is a stronger sanity check than merely seeing a smooth curve.

Sum the node balances to audit the implementation. Internal interfaces cancel,
so

$$
\sum_i C_{node}\frac{dT_i}{dt}
=Q_{cell}-Q_{boundary,left}-Q_{boundary,right}.
$$

The result's `energy_balance_error_J` compares the integrated right side with
the change in total node thermal energy. `node_energy_balance_error_J` provides
the same audit per node. If those errors are not near roundoff, inspect flow
orientation, the first-versus-last sample convention, and interval lengths.

## Limitations

The slab resolves only through thickness. It omits in-plane gradients, tabs,
edges, collectors, layer-by-layer anisotropy, contact interfaces, and spatially
varying heat generation. The effective density, heat capacity, conductivity,
and convection coefficients are constant placeholders. Fluid temperatures are
inputs rather than a flow network. The explicit solver's stability rejection is
not a convergence proof; perform both temporal and spatial refinement for a new
case. Phase change, gas generation, thermal runaway, and safety controls are
outside scope. Calibrate against spatial temperature and heat-flux measurements
before using the model for design or safety decisions.

## Exercises

### Exercise 1 — Assemble one default control volume

Using $N=15$ and the default geometry/properties, calculate $\Delta x$,
$A$, $C_{node}$, $G_z$, and the heat assigned to one node when
$Q_{cell}=12\,\mathrm{W}$. Give units and explain why the sum of all node
sources must equal 12 W.

### Exercise 2 — Symmetric analytic comparison

For the source/check case $Q_{cell}=8\,\mathrm{W}$, $h_l=h_r=20\,\mathrm{W/(m^2K)}$,
and $T_\infty=25\,^{\circ}\mathrm{C}$, derive and evaluate the continuous
slab center temperature. Explain the physical meaning of its two terms.

### Exercise 3 — Reproduce the grid check

Run `check_pouch_cell_thermal_model`. Then reproduce its symmetric cases for
$N=7,15,31$ and time steps $0.5,0.25,0.05\,\mathrm{s}$. Which result fields
show conservation, and what inequality does the check use to decide that the
medium grid is closer to the fine grid?

### Exercise 4 — Critical interpretation of the hot spot

The default right face has $h_r=12$ while the left has $h_l=35\,
\mathrm{W/(m^2K)}$. Explain why the hot spot shifts rightward, why replacing
the boundary conductance with $hA$ would change the model, and name two
physical effects that could reverse or weaken this conclusion in hardware.
