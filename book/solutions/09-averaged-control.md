# Worked solutions — Chapter 9

[Chapter 9](../chapters/09-averaged-control.md) · [Contents](../README.md)

## 1. Equilibrium

Initially, $i_L=400/20=20$ A. The winding drop is $0.1(20)=2$ V, so
$D_0=(400+2)/800=0.5025$. At the new load with this duty,

$$
v=D_0V_{in}-R_Lv/R
\quad\Rightarrow\quad
v=402/1.01=398.019802\ \mathrm{V}.
$$

The asymptotic voltage error is 1.980198 V. The source's approximately 1.984 V
uses a finite final averaging window, so it need not equal the infinite-time
equilibrium to every digit. At 400 V and 10 Ω, the required current is 40 A and
the required duty is $(400+4)/800=0.505$.

A 2% band around 400 V is [392,408] V. The open-loop equilibrium lies within
that band despite its nonzero error. Settling into a specified band is not the
same as exact reference tracking.

## 2. The first interval

At the instant of the load change,

$$
\dot i_L=(0.5025\cdot800-400-0.1\cdot20)/0.002=0\ \mathrm{A/s},
$$

$$
\dot v=(20-400/10)/0.001=-20000\ \mathrm{V/s}.
$$

Therefore $i_{L,next}=20$ A and $v_{next}=400-20000(10^{-5})=399.8$ V.
The capacitor initially supplies the 20 A deficit. The inductor does not
instantaneously acquire the new equilibrium current, and the controller needs
a sampled error before its feedback terms respond.

## 3. Read the experiment

Among the two feedback cases, filtered PID has the smaller expected sag,
7.38% versus PI's 9.95%. PI has the shorter expected settling time, 10.3 ms
versus 14.0 ms, and smaller positive overshoot. Record actual values rather
than copying this rounded source table into an execution log.

The comparison holds reference voltage at 400 V, steps load at 40 ms, and
allows a 60 A current reference. The other runner changes the voltage reference
from 300 to 400 V with a fixed 20 Ω load and a 40 A reference limit. Different
initial conditions, disturbance and limits change the question. Comparing their
overshoots as if they were the same experiment would confound controller and
scenario effects.

## 4. Constraints and derivative action

The 65 A raw request is above the 60 A limit. With positive error, more integral
action would push farther into saturation, so the source pauses integration.
With negative error, it allows integration to reduce the stored demand. It is
the error's recovery direction, not just the presence of clipping, that matters.

The derivative filter weight is

$$
a=\frac{0.0005}{0.0005+0.00001}=0.9803921569,
\qquad 1-a=0.0196078431.
$$

Measurement noise, computational delay or a different load class could change
the observed ranking. For example, derivative action can react strongly to
measurement changes not caused by the plant. The filter reduces this response
but the deterministic source experiment contains no noise study, so no robust
ranking follows from it.
