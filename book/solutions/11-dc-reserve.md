# Worked solutions — Chapter 11

[Chapter 11](../chapters/11-dc-reserve.md) · [Contents](../README.md)

## 1. Reserve limit

$Q_c=200(3600)=720000$ A·s. At $z=0.22$, availability is
$(0.22-0.20)/0.04=0.5$, so the taper limit is 250 A. The interval-charge
bound is $(0.02)(720000)/0.1=144000$ A. Their minimum is 250 A.

The next SOC is $0.22-250(0.1)/720000=0.2199652778$. It stays above the
reserve. The 144000 A algebraic charge bound is not a physical current
capability; the separate rated/taper limit is essential.

## 2. Average OCV

SOC changes linearly with time under held current. Substitution into
$V_{oc}=700+100z$ and averaging the endpoints gives
$\overline V_{oc}=722-100(250)(0.1)/(2\cdot720000)
=721.9982638889$ V.

$R_{eff}=0.08+100(0.1)/(2\cdot720000)=0.0800069444444$ Ω, hence

$$
P_{terminal}=722(250)-0.0800069444444(250)^2
=175499.565972\ \mathrm{W}.
$$

Chemical power is $721.9982638889(250)=180499.565972$ W. Ohmic loss is
$0.08(250)^2=5000$ W. Their difference matches terminal power. The extra
term in $R_{eff}$ accounts for the average OCV decreasing as charge is
removed; counting it again as resistor heat would corrupt this ledger.

## 3. Finite headroom

$E_0=0.5(0.8)(750)^2=225000$ J,
$E_{min}=196000$ J, and $E_{max}=256000$ J. Initial discharge headroom is
29000 J; charging headroom is 31000 J. With an unchanged 100000 W deficit,
$t=29000/100000=0.29$ s. This is a constant-power thought experiment, not
the complete canonical trajectory.

A physical bus can involve ESR/ESL, converter dynamics, ripple, voltage-
dependent controls, measurement delay and protection. The ideal energy-state
model omits those effects. It also assumes a usable capacitance and fixed
voltage limits rather than deriving component ratings.

## 4. Interpret the run

The summary exposes `battery_energy_residual_J` and
`dc_link_energy_residual_J`. They should be near zero under the source's
numerical tolerances. Record their actual values, units and revision; do not
replace them with a displayed zero or a guessed tolerance. The existing check
also verifies the bounds and energy relationships independently.

A higher reserve leaves less charge available for the same request and causes
tapering earlier. This can reduce deliverable discharge, but cross-profile
comparisons require controlling requested energy, timing and charging
opportunities. The AC supervisor does not receive a live computed current/SOC
trajectory from this model. A future coupling would need a specified power
boundary, losses, per-unit conversion, synchronization and feedback order.
The current examples explain those issues separately; they do not establish
the coupled system's stability or performance.
