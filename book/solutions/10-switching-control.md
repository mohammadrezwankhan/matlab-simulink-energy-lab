# Worked solutions — Chapter 10

[Chapter 10](../chapters/10-switching-control.md) · [Contents](../README.md)

## 1. Time scales

$T_{PWM}=1/10000=100$ µs and $\delta t=T_{PWM}/100=1$ µs. The 0.18 s
interval contains 1,800 PWM periods and 180,000 plant intervals. The state
time vector contains one additional terminal sample.

$\operatorname{round}(100\cdot0.506)=51$, hence period duty 0.51. This lies
within the permitted 0.05–0.95 range. Over many periods, counts can alternate;
an average across those ratios can be 0.5062 even though each period's ratio
has 0.01 resolution. No finer per-period timer is implied.

## 2. Mode slopes

In the ON mode,

$$
\dot i_L=\frac{800-(0.1+0.04)20-400}{0.002}
=198600\ \mathrm{A/s}.
$$

In the OFF mode,

$$
\dot i_L=\frac{-1-0.1(20)-400}{0.002}
=-201500\ \mathrm{A/s}.
$$

At the stated instant $\dot v=(20-400/20)/0.001=0$ V/s in both modes.
Over a 1 µs interval, forward-Euler intuition would give current changes of
approximately +0.1986 A and −0.2015 A. These are first-order estimates, not
the exact affine-map outputs: current and voltage change inside the interval,
so their derivatives do too. The exact map integrates those coupled linear
changes for the held mode.

## 3. Event energy

The voltage factor is one and current factor is $36/18=2$. Thus
$E_{on}=218$ µJ, $E_{off}=90$ µJ, and the pair is 308 µJ. Repetition at
10 kHz would give $3.08$ W if every pair had those same conditions. Over
0.18 s that artificial constant-condition calculation gives $0.5544$ J.

The canonical trajectory starts at a different current and changes reference
and load. Its event energies use the actual current at each resolved edge.
They must be summed over that record, not replaced by an arbitrary 36 A
constant-current calculation. The linear scaling is the implemented local
estimate, not a general device law.

## 4. Read and challenge

Final average voltage checks regulation under the specified plant, gains,
limits and window. Zero-transition-loss parity checks that removing the
post-processed event energies leaves the electrical states unchanged. Energy
closure checks consistency among the model's source, stored-energy, load and
loss accounting, within the numerical integration convention.

None establishes a junction temperature. That claim would require at least a
sourced thermal impedance/capacitance model, initial and boundary temperatures,
thermal coupling of computed losses, and a comparison appropriate to the
claimed device/conditions. A useful first numerical experiment would apply a
known heat step to such a thermal model and verify its energy balance and
transient response independently. That extension is not implemented by the
current fixed-temperature sensitivity, and this answer is a specification
idea rather than a runnable new example.
