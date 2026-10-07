# Solutions — Chapter 6

[Chapter](../chapters/06-electrothermal.md) · [Chapter index](../README.md) · [Source map](../source-map.md)

## Exercise 1 — One-step hand calculation

At 25 °C the default reference temperature is also 25 °C, so the exponential
resistance relation gives

$$
R_0=0.004\exp(0.025(25-25))=0.004\,\Omega.
$$

The polarization voltage is initially zero. The model-specific irreversible
proxy is therefore

$$
Q_{irr}=I(IR_0+V_{rc})
 =75\,[75(0.004)+0]
 =75(0.3)=22.5\,\mathrm{W}.
$$

At $z=0.8$, the lookup coefficient is $-0.05\,\mathrm{mV/K}$, or
$-0.00005\,\mathrm{V/K}$. Convert the cell temperature before using it in
the product:

$$
T_K=25+273.15=298.15\,\mathrm{K},
$$

$$
Q_{rev}=-75(298.15)(-0.00005)=1.1180625\,\mathrm{W}.
$$

There is no cooling at the initial ambient temperature, so

$$
Q_{net}=22.5+1.1180625-1.2(25-25)=23.6180625\,\mathrm{W}.
$$

The thermal capacity is $mc_p=1.05\times1000=1050\,\mathrm{J/K}$. Forward
Euler gives

$$
T_1=25+\frac{23.6180625\times1}{1050}
  =25.0224933929\,^{\circ}\mathrm{C}.
$$

For a 50-Ah cell, the nominal charge is
$Q_{nom}=50\times3600=180000\,\mathrm{C}$. Thus

$$
z_1=0.8-\frac{75\times1}{180000}=0.7995833333.
$$

Finally, the polarization derivative at the first sample is $75/2400$ V/s,
so

$$
V_{rc,1}=0+1\left(\frac{75}{2400}-0\right)=0.03125\,\mathrm{V}.
$$

These match the source/check expectations: $22.5$ W, $1.1180625$ W,
$25.0224933929\,^{\circ}\mathrm{C}$, $0.7995833333$, and $0.03125$ V.

## Exercise 2 — Stability and accuracy

Ignore input forcing for the stability calculation. The polarization state has
homogeneous dynamics

$$
\frac{dV_{rc}}{dt}=-\frac{1}{R_1C_1}V_{rc}.
$$

Forward Euler maps one sample to

$$
V_{rc,n+1}=\left(1-\frac{\Delta t}{R_1C_1}\right)V_{rc,n}.
$$

For absolute stability, the multiplier must satisfy an absolute-value bound;
monotone nonnegative decay is a stricter requirement. The absolute-stability
inequality is

$$
|1-\frac{\Delta t}{R_1C_1}|<1
\quad\Longrightarrow\quad
0<\Delta t<2R_1C_1.
$$

The source's strict guard uses this absolute-stability limit. At equality, the
multiplier is $-1$, so the mode does not decay. For
$R_1C_1<\Delta t<2R_1C_1$, the multiplier is negative but has magnitude below
one: the state alternates sign while decaying. If monotone nonnegative decay is
required, use $0<\Delta t\leq R_1C_1$.

For the thermal balance with no forcing, $T-T_{amb}$ obeys

$$
\frac{d(T-T_{amb})}{dt}=-\frac{hA}{mc_p}(T-T_{amb}),
$$

so the same Euler argument gives

$$
\Delta t<\frac{2mc_p}{hA},
$$

when $hA>0$. The default values produce

$$
2R_1C_1=2(0.002\,\Omega)(2400\,\mathrm{F})=9.6\,\mathrm{s},
$$

and

$$
\frac{2mc_p}{hA}=\frac{2(1050\,\mathrm{J/K})}{1.2\,\mathrm{W/K}}
 =1750\,\mathrm{s}.
$$

The electrical branch therefore sets the smaller limit. A one-second step is
inside both bounds for this parameter set. Stability only constrains numerical
growth of the homogeneous modes. Accuracy also depends on input bandwidth,
the size of current transitions, and the desired resolution of the temperature
trace. A step can be stable but still smear a short pulse or misrepresent a
rapid change in an irregular profile. Spatial effects are absent altogether in
this lumped model.

## Exercise 3 — Reproduce and perturb the source

Run the existing check from the repository root:

```matlab
run(fullfile('examples', 'battery-thermal-model', ...
    'check_battery_thermal_model.m'))
```

The script constructs the default profile and parameters, calls
`simulate_battery_thermal_model(profile, parameters, 1)`, and checks finite
states, bounds, constitutive relations, deterministic repetition, and the
integrated thermal energy balance. It also checks the expected sign pattern by
requiring active reversible heat to include both negative and positive values.

For the perturbation, use the exact one-second profile from the chapter and
replace every lookup coefficient by zero:

```matlab
modelDirectory = fullfile('examples', 'battery-thermal-model');
addpath(modelDirectory);
oneStepProfile = table([0; 1], [75; 75], ...
    'VariableNames', {'time_s', 'current_A'});
oneStepParameters = battery_thermal_default_parameters();
oneStepParameters.entropic_coefficient_V_per_K(:) = 0;
oneStep = simulate_battery_thermal_model( ...
    oneStepProfile, oneStepParameters, 1);
```

The first-sample coefficient is now $0\,\mathrm{V/K}$, so

$$
Q_{rev,0}=-I_0T_{K,0}(0)=0\,\mathrm{W}.
$$

Since `total_heat_generation_W` is computed as the sum of the irreversible and
reversible terms, its first sample is exactly

$$
Q_{total,0}=Q_{irr,0}+0=22.5\,\mathrm{W}.
$$

The check's explicit source assertion is
`all(zeroEntropicResult.reversible_heat_W == 0)` together with equality of
`zeroEntropicResult.total_heat_generation_W` and
`zeroEntropicResult.heat_generation_W`. This tests the implementation's
zero-entropic limit, not a measured battery property.

## Exercise 4 — Critical interpretation

Take a state with $V_{rc}=0.10\,\mathrm{V}$, $I=-1\,\mathrm{A}$, and
$R_0=0.004\,\Omega$. The ohmic-plus-polarization voltage in the proxy is

$$
IR_0+V_{rc}=(-1)(0.004)+0.10=0.096\,\mathrm{V}.
$$

Consequently,

$$
Q_{irr}=(-1)(0.096)=-0.096\,\mathrm{W}.
$$

The negative result is mathematically consistent with the expression: a
negative current multiplies a still-positive polarization contribution. It is
not evidence that a real cell's irreversible dissipation is negative. The
expression is explicitly a model-specific equivalent-circuit proxy and is only
asserted nonnegative by the canonical check for its defined profile. A model
intended to enforce nonnegative physical dissipation would need a different
energy accounting, careful state definitions, and parameter/experiment review.

SOC clipping is a separate issue. Suppose $z_n=0.0001$, $I=75\,\mathrm{A}$,
$\Delta t=1\,\mathrm{s}$, and $Q_{nom}=180000\,\mathrm{C}$. The requested
update is

$$
z^*_{n+1}=0.0001-\frac{75}{180000}=-0.0003166667.
$$

The source stores `min(max(z^*,0),1)=0`, but it still used the full 75 A in the
input and did not calculate a curtailed current or a charge correction. The
clipped state is bounded, while the requested-current charge balance is not
conserved at the boundary. A physical controller must limit current before the
state update and report that limitation explicitly.
