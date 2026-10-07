# Chapter 4 Solutions — Correcting SOC with a Two-State EKF

**Back to chapter:** [Chapter 4](../chapters/04-soc-ekf.md) · [book contents](../README.md)

**Snapshot identity:** source and benchmark provenance are recorded in [source-map.md](../source-map.md).

## Exercise 1 — Conceptual solution

The innovation at timestamp $k$ compares the measurement that just arrived
with the voltage predicted from the prior state at that same timestamp:

$$
\nu_k=y_k-h(x_k^-,u_k).
$$

Using a next-state prediction would shift the current interval and compare the
measurement against the wrong time/state convention. The source first corrects
the prior state at the current timestamp and only then propagates the corrected
state through the interval to the next timestamp.

The first Jacobian entry, $dOCV/dSOC$, says how many volts the equilibrium
voltage changes per unit SOC locally. The second entry, (-1), says that a
positive increase in polarization voltage lowers terminal voltage by one volt
per volt of branch state. Together, they describe which state directions can
explain a voltage residual. A small OCV slope makes SOC weakly observable from
voltage at that sample.

## Exercise 2 — Analytical solution

The prior predicted voltage is

$$
\hat y=3.78-0.03-0.020=3.730~\mathrm{V}.
$$

The innovation is

$$
\nu=3.55-3.730=-0.180~\mathrm{V}.
$$

With $H=[0.8,-1]$ and $P^-=\operatorname{diag}(0.0001,0.0001)$,

$$
\begin{aligned}
S&=H P^-H^T+R_v\\
 &=0.8^2(0.0001)+(-1)^2(0.0001)+0.0001\\
 &=0.000264~\mathrm{V}^2.
\end{aligned}
$$

The gain is

$$
K=\frac{P^-H^T}{S}
 =\frac{[0.00008;-0.00010]}{0.000264}
 =\boxed{[0.3030;-0.3788]}.
$$

Applying the correction gives

$$
\begin{aligned}
z^+&=0.60+(0.3030303)(-0.180)=0.5454545,\\
v^+&=0.020+(-0.3787879)(-0.180)=0.0881818~\mathrm{V}.
\end{aligned}
$$

So $x^+\approx\boxed{[0.54545;0.088182]}$. The large voltage discrepancy is
shared between SOC and polarization according to their covariance and the
Jacobian; it is not assigned entirely to SOC.

## Exercise 3 — Code/reproduction solution

One direct check over the stored posterior covariance is:

```matlab
addpath('examples/battery-soc-ekf');
scenario = simulate_battery_soc_ekf_example();
estimate = scenario.estimate;

for k = 1:size(estimate.covariance, 3)
    P = estimate.covariance(:, :, k);
    assert(max(abs(P - P'), [], 'all') < 1e-12);
    assert(min(eig(P)) >= -1e-12);
end
assert(all(estimate.innovation_variance_V2 > 0));
```

The scenario helper returns the filter result in `estimate` and creates its
deterministic voltage record internally. The Joseph update adds the positive
semidefinite measurement-noise term $K R_vK^T$ and preserves the covariance
structure better than a one-sided subtraction. The explicit symmetry check
also matches the source's post-update symmetrization. The no-plot source check
adds malformed-input and irregular-time tests. Since the plotting script can
clear workspace variables and close figures, run the source check only in a
fresh MATLAB session after saving any important state.

## Exercise 4 — Interpretation and limits solution

A (+0.25) A case supplies the estimator with

$$
I_k^{\mathrm{est}}=I_k^{\mathrm{true}}+0.25~\mathrm{A}
$$

at every sample. The estimator therefore integrates too much discharge during
each interval and uses the biased current in its ohmic and polarization voltage
prediction. The plant and measured voltage remain those of the true-current
case. The resulting residuals can cause voltage corrections that partly offset
the propagated SOC error.

Nothing in the two-state state vector represents $b$. There is no third
current-bias state, bias prior, bias likelihood test, or rejection logic. If
the final SOC error happens to improve after voltage correction, that only means
the two available states absorbed some effect of the mismatch for this
experiment. A bias estimate would require an explicit state and a defined
observation/decision procedure; a prescribed sensitivity sweep supplies
neither. The correct statement is that the filter's performance was evaluated
under an unmodelled (+0.25) A input bias.
