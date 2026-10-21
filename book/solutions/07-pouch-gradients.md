# Solutions — Chapter 7

[Chapter](../chapters/07-pouch-gradients.md) · [Chapter index](../README.md) · [Source map](../source-map.md)

## Exercise 1 — Assemble one default control volume

The face area is the product of the default width and height:

$$
A=0.15\,\mathrm{m}\times0.10\,\mathrm{m}=0.015\,\mathrm{m^2}.
$$

With $N=15$ and $L=0.008\,\mathrm{m}$,

$$
\Delta x=\frac{L}{N}=\frac{0.008}{15}
 =0.0005333333\,\mathrm{m}=0.5333333\,\mathrm{mm}.
$$

The volume of one CV is $A\Delta x=0.000008\,\mathrm{m^3}$. Its thermal
capacity is

$$
C_{node}=\rho c_pA\Delta x
 =2200(900)(0.000008)
 =15.84\,\mathrm{J/K}.
$$

The conductance from one node center to the next is

$$
G_z=\frac{k_zA}{\Delta x}
 =\frac{0.45(0.015)}{0.0005333333}
 =12.65625\,\mathrm{W/K}.
$$

Uniform whole-cell heat is split equally, so for $Q_{cell}=12\,\mathrm{W}$,

$$
Q_{node}=\frac{12}{15}=0.8\,\mathrm{W}.
$$

The sum is $15(0.8)=12\,\mathrm{W}$. This allocation is a conservation
requirement: if node sources summed to another value, the finite-volume model
would be simulating a different whole-cell input than the profile declares.
Conduction can redistribute that heat and boundaries can remove it, but neither
operation changes the prescribed source allocation.

## Exercise 2 — Symmetric analytic comparison

For a uniform source, the steady slab satisfies

$$
k_z\frac{d^2T}{dx^2}+q'''=0,
\qquad
q'''=\frac{Q_{cell}}{AL}.
$$

The geometry gives $AL=0.015(0.008)=0.00012\,\mathrm{m^3}$, hence

$$
q'''=\frac{8}{0.00012}=66666.6667\,\mathrm{W/m^3}.
$$

At the mid-plane, symmetry requires $dT/dx=0$. Integrating toward a face and
using the convection condition gives

$$
T_{center}-T_\infty
=\frac{q'''L}{2h}+\frac{q'''L^2}{8k_z}.
$$

Substitution gives the convection contribution

$$
\frac{66666.6667(0.008)}{2(20)}
=13.3333333\,\mathrm{K},
$$

and the conduction contribution

$$
\frac{66666.6667(0.008)^2}{8(0.45)}
=1.1851852\,\mathrm{K}.
$$

Therefore

$$
T_{center}=25+13.3333333+1.1851852
=39.5185185\,^{\circ}\mathrm{C}.
$$

The first term is the temperature rise required to push the total heat through
both convection films. The second is the additional center-to-face rise inside
the conducting slab. Since a temperature difference has the same numerical
size in kelvin and Celsius, adding these rises to 25 °C is valid. The source
check compares a long explicit run to this number with a 0.12 °C tolerance.
That tolerance is a check expectation for this case, not evidence that the
placeholder material properties represent hardware.

## Exercise 3 — Reproduce the grid check

The existing no-plot check is run from the repository root with:

```matlab
run(fullfile('examples', 'pouch-cell-thermal-gradient', ...
    'check_pouch_cell_thermal_model.m'))
```

The check creates symmetric parameters with $h_l=h_r=20\,\mathrm{W/(m^2K)}$
and a constant 8-W profile. Its refinement loop uses node counts
$[7,15,31]$ and time steps $[0.5,0.25,0.05]\,\mathrm{s}$. The same logic can
be written explicitly:

```matlab
modelDirectory = fullfile('examples', 'pouch-cell-thermal-gradient');
addpath(modelDirectory);
base = pouch_cell_thermal_default_parameters();
base.left_heat_transfer_coefficient_W_per_m2K = 20;
base.right_heat_transfer_coefficient_W_per_m2K = 20;
profile = table([0; 600], [8; 8], [25; 25], [25; 25], ...
    'VariableNames', {'time_s', 'cell_heat_generation_W', ...
    'left_fluid_temperature_C', 'right_fluid_temperature_C'});
nodeCounts = [7, 15, 31];
steps = [0.5, 0.25, 0.05];
centers = zeros(size(nodeCounts));
for k = 1:numel(nodeCounts)
    p = base;
    p.node_count = nodeCounts(k);
    r = simulate_pouch_cell_thermal_model(profile, p, steps(k));
    centers(k) = r.center_temperature_C(end);
end
coarseFine = abs(centers(1) - centers(3));
mediumFine = abs(centers(2) - centers(3));
```

The conservation fields are `node_energy_balance_error_J` for each CV and
`energy_balance_error_J` for the complete slab. The source also checks that
`sum(result.node_heat_generation_W, 2)` equals the prescribed
`cell_heat_generation_W`, that interface conduction cancels, and that inferred
surface temperatures close the convection equations. The refinement decision is
the pair of strict inequalities

$$
|T_{center,15}-T_{center,31}|
 <|T_{center,7}-T_{center,31}|,
\qquad
|T_{center,15}-T_{center,31}|<0.05\,^{\circ}\mathrm{C}.
$$

The actual script computes those values and asserts them; the expected printed
summary is a source/check expectation, not a value to generalize to other grids.

## Exercise 4 — Critical interpretation of the hot spot

For a fixed node temperature and fluid temperature, a smaller $h$ increases
the convection resistance $1/(hA)$. The default right face has the smaller
coefficient, so it removes less heat. Heat conducted through the slab toward
that face accumulates more readily, shifting the hottest node rightward. The
source check makes this a reproducible numerical observation by asserting
`result.peak_position_m > parameters.thickness_m / 2`.

Replacing the series boundary conductance with $hA$ would remove the
half-control-volume conduction resistance $\Delta x/(2k_z)$:

$$
G_{boundary}=\frac{A}{\Delta x/(2k_z)+1/h}
\neq hA.
$$

That changes both the boundary heat flow and the inferred surface temperature,
especially for a coarse grid or a low-conductivity material. It is a different
discretization, not a harmless algebraic rewrite. Two hardware effects that
could weaken or reverse the simple rightward conclusion are nonuniform heat
generation (for example, tabs or current collectors producing a local source)
and strong in-plane/edge cooling. Temperature-dependent or contact-dependent
conductivity and nonuniform compression could also move the hot spot. The
one-dimensional model intentionally cannot decide among those effects.
