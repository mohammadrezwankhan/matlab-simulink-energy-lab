# Worked solutions — Chapter 12

[Chapter 12](../chapters/12-bess-supervisor.md) · [Contents](../README.md)

## 1. Bases and conventions

$V_{\phi,b}=690/\sqrt3=398.371686$ V RMS,
$I_b=10^7/(\sqrt3\cdot690)=8367.395206$ A RMS, and
$Z_b=690^2/10^7=0.04761$ Ω. Active power 0.5 p.u. is $5\times10^6$ W.
This base is not the rating of the separate illustrative Chapter 11 battery.

Physical amplitude-invariant α/β power has coefficient $3/2$. Normalize
voltage/current by phase RMS voltage and RMS current bases; their product is
$S_b/3$. Dividing physical power by $S_b$ therefore leaves $(3/2)/3=1/2$.
Using a peak base or a power-invariant transform would change the intermediate
formula, so coefficients must travel with their definitions.

## 2. Current circle

The first requested magnitude is $\sqrt{0.8^2+0.6^2}=1$. Its allowed
magnitude is $1(0.8)=0.8$, hence scale 0.8 and limited powers
$(0.64,0.48)$ p.u. The requested P/Q direction is preserved by circle scaling.

If DC availability first clips P to 0.5, the remaining vector magnitude is
$\sqrt{0.5^2+0.6^2}=\sqrt{0.61}=0.781025$. It is already below 0.8, so
the circle scale is one and the output is $(0.5,0.6)$. Saturation is still
true because the original P request was clipped. A circle scale of one does
not imply that every requested component was feasible.

## 3. A timer is not a sample count

At 1.000 s there is not yet an interval with readiness true at both sampled
boundaries. Twenty 5 ms intervals complete at 1.100 s. There are twenty-one
ready boundary samples including the initial one. Giving the initial sample
one step of credit would finish one sample too early.

Completion of this hold does not remove `PREPARE_RECONNECT` or other guards.
The code also distinguishes boundary actions from dynamic evolution. Nor can
samples establish what happened between them: continuous readiness requires
additional assumptions or evidence.

For C, expect a grid-following-to-islanding/forming/support progression after
the grid-loss event, and inspect actual timing. For E, expect islanded operation,
synchronization, preparation and grid-following reconnection after grid return.
Record actual state codes and times from the current run; the two scenarios
are independently initialized, so concatenating their arrays would not form
one continuous experiment.

## 4. Capstone interface

A defensible specification must name the DC/AC power boundary and losses:
is positive requested power terminal DC power, converter input power or PCC
active power? Define which signal is a request and which is delivered power,
and account for conversion losses before using both in the same energy ledger.

Convert DC voltage using a declared nominal DC base; do not divide it by the
690 V line-to-line AC base merely because both have voltage units. Select a
compatible apparent-power base and a consistent per-unit availability
definition. The current examples use 0.1 s DC updates and 0.005 s AC updates;
a coupling needs explicit rate conversion, sample/hold order, aggregation of
twenty AC intervals, and an energy-consistent interface without algebraic
look-ahead.

The AC limiter accepts one nonnegative availability magnitude and clips active
power symmetrically to ±that value. The DC model has different charge/discharge
limits and SOC boundaries. A single magnitude can discard that asymmetry;
the interface must specify a conservative policy or a separately reviewed
change supporting two-sided limits. It must also define stale data, invalid
voltage, unavailable power and recovery behavior.

Two acceptance experiments are (1) a constant feasible discharge with matching
integrated DC/AC/loss energy and no reserve violation, and (2) reserve depletion
during islanding, requiring consistent curtailment, bounded current/voltage
and no energy creation. A third useful case is charge saturation during grid
return. Separate analytic energy checks, timing assertions and fault cases
would be needed before calling the integration validated. These are proposed
requirements, not code or completed evidence in this repository.
