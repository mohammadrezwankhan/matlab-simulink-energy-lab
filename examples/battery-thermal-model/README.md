<!-- markdownlint-disable MD013 -->

# Temperature-Aware Battery Model

This runnable MATLAB example couples a first-order battery equivalent circuit
to a lumped thermal balance. It separates irreversible electrical loss from
SOC-dependent reversible entropic heat, then applies ambient cooling and
temperature-dependent resistance feedback during charge and discharge.

![Temperature-aware battery response showing current, terminal voltage, cell temperature, and separated irreversible, reversible, and total heat generation](../../assets/battery-thermal-response.png)

## Engineering Question

How do electrical losses and reversible electrochemical heat combine during a
pulse-current cycle, and how does temperature feed back into ohmic resistance?

## Model Scope

| Element  | Meaning                                 |               Placeholder Value |
| -------- | --------------------------------------- | ------------------------------: |
| `R0(T)`  | Temperature-dependent ohmic resistance  |               4 mOhm at 25 degC |
| `R1-C1`  | Transient polarization branch           |                  2 mOhm, 2400 F |
| `m * cp` | Lumped thermal capacity                 |                        1050 J/K |
| `hA`     | Lumped conductance to fixed ambient     |                         1.2 W/K |
| `Qirr`   | Irreversible equivalent-circuit loss    |              `I * (I*R0 + Vrc)` |
| `dU/dT`  | SOC-indexed OCV temperature coefficient | Six illustrative samples in V/K |
| `Qrev`   | Signed reversible entropic heat         |              `-I * T_K * dU/dT` |
| `Tamb`   | Fixed ambient temperature               |                         25 degC |

The resistance relation is an inspectable educational approximation:

```text
R0(T) = R0_ref * exp(kR * (Tref - T))
```

Positive current means discharge. With that sign convention, the simplified
heat terms follow the cell energy-balance form introduced by
[Bernardi, Pawlikowski, and Newman](https://www.osti.gov/biblio/5913742):

```text
dU/dT = linear_lookup(SOC)
Qirr = I * (I * R0 + Vrc)
Qrev = -I * (T_C + 273.15) * dU/dT
Qtotal = Qirr + Qrev
(m * cp) * dT/dt = Qtotal - hA * (T - Tamb)
```

`dU/dT` may be positive or negative, so reversible heat may heat or cool the
cell and reverses with current direction. The committed lookup values are
deliberately illustrative. Replace them with measured, chemistry-specific,
SOC- and temperature-qualified data before interpreting the result physically.

## Included MATLAB Files

```text
examples/battery-thermal-model/
  README.md
  battery_thermal_default_parameters.m
  battery_thermal_default_profile.m
  simulate_battery_thermal_model.m
  run_battery_thermal_model.m
  check_battery_thermal_model.m
```

The scripts share the same validated simulator. It accepts native irregular
timestamps or a requested uniform sample time, checks explicit-Euler stability,
and returns every electrical and thermal state plus energy-balance diagnostics.

The [native Simulink counterpart](../battery-thermal-simulink-model/README.md)
generates an inspectable feedback diagram and compares thirteen logged signals with
this discrete reference.

## Requirements

- MATLAB R2026a is the verified release.
- The example uses base MATLAB only.
- No Simulink or additional toolbox is required.

## How To Run

From MATLAB, navigate to this folder and run:

```matlab
run_battery_thermal_model
```

For a lightweight no-plot validation:

```matlab
check_battery_thermal_model
```

Expected output:

```text
Battery thermal check passed.
Peak cell temperature: 36.92 degC
Final cell temperature: 28.96 degC
Peak irreversible heat: 33.31 W
Reversible heat range: -2.31 W to 1.12 W
Peak total heat: 34.29 W
Final SOC: 0.608
```

## Validation Checks

The no-plot script verifies that:

- SOC remains in the physical interval `[0, 1]`;
- the pulse case heats above ambient but remains below 45 degC;
- ohmic resistance decreases as temperature rises;
- irreversible heat remains nonnegative for the defined current profile;
- the strict SOC lookup reproduces the configured entropic coefficient;
- reversible heat follows the declared current sign and exercises heating and
  cooling in the canonical profile;
- a zero entropic-coefficient table recovers irreversible-only heat exactly;
- terminal voltage responds to the applied pulses; and
- irreversible, reversible, total, cooling, electrical, resistance, OCV, and
  terminal-voltage relations close at every sample;
- native irregular timestamps and uniform resampling remain deterministic; and
- integrated net heat matches the change in lumped thermal energy.

## Limitations

- Parameters are illustrative and are not fitted to a specific cell.
- The model has one uniform cell temperature and no spatial gradients.
- Ambient temperature and heat-transfer conductance are fixed.
- The entropic coefficient is linearly interpolated only by SOC; temperature,
  rate, ageing, and hysteresis dependence require measured replacement data.
- Heat capacity and electrical parameters other than `R0` are constant.
- Aging, hysteresis, thermal runaway, contact resistance, and pack-level
  interactions are outside the model scope.
- Results must not be used for cell qualification or safety decisions without
  calibration and validation against measured data.
