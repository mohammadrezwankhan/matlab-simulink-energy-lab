<!-- markdownlint-disable MD013 MD060 -->

# Battery RC Model Example

This runnable example implements a simple first-order battery equivalent-circuit model in MATLAB.

![First-order battery RC model response showing discharge and charge current pulses, state-of-charge change, and terminal-voltage transients](../../assets/battery-rc-response.png)

## Engineering Question

How can a first-order RC equivalent circuit help explain terminal-voltage response during charge and discharge pulses?

## Model Scope

| Element | Meaning |
|---|---|
| `OCV(SOC)` | Open-circuit voltage interpolated from a replaceable SOC/voltage lookup table |
| `R0` | Ohmic resistance |
| `R1-C1` | Transient polarization branch propagated exactly over each zero-order-held current interval |
| `I` | Applied current profile |
| `Vt` | Terminal voltage |

## Included MATLAB Files

```text
examples/battery-rc-model/
  README.md
  battery_rc_default_parameters.m
  simulate_battery_rc_model.m
  run_battery_rc_model.m
  check_battery_rc_model.m
  data/pulse_current_profile.csv
```

## How To Run

Open MATLAB, navigate to this folder, and run:

```matlab
run_battery_rc_model
```

The script loads the committed pulse profile, calls the shared simulator, and
plots current, SOC, and terminal voltage.

Pass a positive scalar third argument to resample onto a uniform grid, as the
starter scripts do with `dt_s = 1`. Omit that argument to preserve measured or
irregular profile timestamps:

```matlab
parameters = battery_rc_default_parameters();
nativeResult = simulate_battery_rc_model(profile, parameters);
```

The current at each timestamp is held through the following interval. SOC is
integrated over that interval, and the first-order RC state uses its analytic
exponential update. This stays stable for coarse intervals without imposing an
explicit-Euler step-size limit. `result.interval_s` records every interval;
`result.dt_s` is populated only when the resulting grid is uniform.

For a lightweight no-plot check using the included sample pulse-current data, run:

```matlab
check_battery_rc_model
```

Expected starter output:

```text
Battery RC check passed. Final SOC: 0.767
Voltage range: 3.425 V to 3.877 V
```

## Expected Output Notes

Both starter entry points call `simulate_battery_rc_model` with
`battery_rc_default_parameters` and the same committed profile, so they should
produce the same headline values:

| Entry Point | Purpose | Expected Text |
|---|---|---|
| `run_battery_rc_model` | Plotting script for visual inspection of current, SOC, and terminal voltage. | `Final SOC: 0.767` and `Voltage range: 3.425 V to 3.877 V` |
| `check_battery_rc_model` | No-plot script for quick validation and future automation. | `Battery RC check passed. Final SOC: 0.767` and `Voltage range: 3.425 V to 3.877 V` |

Small differences may appear if model parameters, sample data, or MATLAB interpolation behavior are changed. Update this note whenever the starter assumptions change intentionally.

## OCV Lookup Table

`battery_rc_default_parameters` defines paired `ocv_soc_breakpoints` and
`ocv_lookup_V` vectors covering the full SOC interval from zero to one. The
simulator linearly interpolates those values at every time step and returns the
trace as `result.ocv_V`. The default table samples the previous educational
linear relationship, preserving the starter response while making the hidden
assumption explicit and replaceable.

To study a specific cell, replace both vectors with measured or
datasheet-derived values. Breakpoints must be strictly increasing from zero to
one; OCV values must be positive and nondecreasing. The simulator rejects a
malformed curve instead of extrapolating beyond the supplied data.

## Validation Notes

- State units for every parameter.
- Compare simulated terminal voltage with a known pulse response.
- Report assumptions around temperature and SOC range.
- Treat the included OCV-SOC lookup as a placeholder until replaced with
  measured or datasheet-derived values.
- Keep plotting, checks, and extensions on the shared simulator rather than
  copying the state-update loop.
- The simulator rejects malformed timestamps, incomplete parameters, invalid
  OCV lookup tables, and requested uniform grids that do not end exactly at the
  profile end time.
