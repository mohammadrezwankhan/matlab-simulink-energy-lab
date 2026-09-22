# Chapter 5 Solutions — OCV Hysteresis and a Three-State EKF

**Back to chapter:** [Chapter 5](../chapters/05-hysteresis.md) · [book contents](../README.md)

**Snapshot identity:** see [source-map.md](../source-map.md) for snapshot and benchmark provenance.

## Exercise 1 — Conceptual solution

At rest, $I=0$. The dynamic RC state obeys

$$
v_{k+1}=e^{-\Delta t/(R_1C_1)}v_k,
$$

so it decays toward zero. The hysteresis state is explicitly held:

$$
h_{k+1}=h_k.
$$

This difference is experimentally useful. During a long rest, the transient
polarization fades while the history-dependent equilibrium offset remains.
Measuring voltage at the beginning and end of rest can therefore reveal which
part of a voltage excursion is dynamic and which part persists as hysteresis.
The separation is only as good as the chosen model and the experiment; other
slow physical effects could also remain during rest.

## Exercise 2 — Analytical solution

The fractional throughput is

$$
\delta=\frac{|30|(600)}{3600(50)}
 =\frac{18000}{180000}=0.1.
$$

For discharge, the target is $h_{\mathrm{target}}=-1$. The decay factor is

$$
\rho=e^{-\gamma\delta}=e^{-15(0.1)}=e^{-1.5}=0.2231302.
$$

Starting with $h_k=0$,

$$
h_{k+1}=-1+(0-(-1))(0.2231302)
 =-0.7768698\approx\boxed{-0.7769}.
$$

The hysteresis voltage is

$$
V_{\mathrm{hys},k+1}=Mh_{k+1}
 =(0.025)(-0.7768698)=-0.0194217~\mathrm{V}
 \approx\boxed{-19.42~\mathrm{mV}}.
$$

The negative sign is consistent with discharge driving the source's normalized
hysteresis state toward (-1). It is an equilibrium contribution and must be
kept distinct from the dynamic RC drop.

## Exercise 3 — Code/reproduction solution

One robust way to find rest intervals is to compare each zero-current sample
with its predecessor and use the known profile timestamps:

```matlab
addpath('examples/battery-ocv-hysteresis');
parameters = battery_hysteresis_default_parameters();
profile = battery_hysteresis_default_profile();
result = simulate_battery_ocv_hysteresis(profile, parameters);

assert(all(abs(result.hysteresis_state) <= 1 + 1e-14));
restSamples = find(profile.current_A(1:end-1) == 0);
for k = restSamples'
    assert(result.hysteresis_state(k+1) == ...
        result.hysteresis_state(k));
end
```

The check uses `profile.current_A(k)` because the current at timestamp $k$ is
held over the interval to $k+1$. In this committed profile, the zero-current
rest intervals are 0–300 s, 900–1200 s, 1500–1800 s, 2100–2400 s, and
3000–3300 s (the exact list is derived by the code rather than hard-coded).
The equality is exact in the source branch because the rest path assigns the
previous state directly. The no-plot source check also verifies charge balance,
minor-loop behavior, irregular time, deterministic repeatability, and malformed
parameters. The plotting runner clears variables and closes figures, so save
unsaved workspace or figure state before running it, and use source runners only
in a fresh MATLAB session.

## Exercise 4 — Interpretation and limits solution

The three-state filter has an additional state $h$ and a corresponding
measurement sensitivity $M$:

$$
V_t=V_{\mathrm{mean}}(z)+Mh-R_0I-v,
\qquad H=[dV_{\mathrm{mean}}/dz,-1,M].
$$

When the plant voltage retains a charge/discharge history offset, the EKF can
attribute part of that offset to $h$, rather than forcing the two-state
baseline to move SOC or $v$ to explain it. This is why SOC and voltage RMSE
can improve in the controlled reversal-rich synthetic benchmark.

That result is not a cell-specific BMS estimator for at least two reasons.
First, the plant and estimator share the same illustrative mean-OCV curve,
$M$, $\gamma$, electrical parameters, and capacity; real parameter
mismatch and temperature can change the result. Second, the one-state
hysteresis law omits nested loops, ageing, instantaneous hysteresis, sensor
bias, and cell variation, and the bundled voltage/noise record is synthetic.
A real claim needs measured reversal data, independent mean-OCV evidence,
calibration/held-out tests, uncertainty and fault analysis, and safety-specific
validation.
