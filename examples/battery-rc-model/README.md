# Battery RC Model Example

This starter example outlines a simple battery equivalent-circuit model for future MATLAB/Simulink implementation.

## Engineering Question

How can a first-order RC equivalent circuit help explain terminal-voltage response during charge and discharge pulses?

## Model Scope

| Element | Meaning |
|---|---|
| `OCV(SOC)` | Open-circuit voltage as a function of state of charge |
| `R0` | Ohmic resistance |
| `R1-C1` | Transient polarization branch |
| `I` | Applied current profile |
| `Vt` | Terminal voltage |

## Planned MATLAB Files

```text
examples/battery-rc-model/
  README.md
  run_battery_rc_model.m
  check_battery_rc_model.m
  data/pulse_current_profile.csv
```

## How To Run

Open MATLAB, navigate to this folder, and run:

```matlab
run_battery_rc_model
```

The script creates a simple current profile, estimates SOC, calculates a placeholder first-order RC voltage response, and plots current, SOC, and terminal voltage.

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

Both starter entry points should produce the same headline values:

| Entry Point | Purpose | Expected Text |
|---|---|---|
| `run_battery_rc_model` | Plotting script for visual inspection of current, SOC, and terminal voltage. | `Final SOC: 0.767` and `Voltage range: 3.425 V to 3.877 V` |
| `check_battery_rc_model` | No-plot script for quick validation and future automation. | `Battery RC check passed. Final SOC: 0.767` and `Voltage range: 3.425 V to 3.877 V` |

Small differences may appear if model parameters, sample data, or MATLAB interpolation behavior are changed. Update this note whenever the starter assumptions change intentionally.

## Validation Notes

- State units for every parameter.
- Compare simulated terminal voltage with a known pulse response.
- Report assumptions around temperature and SOC range.
- Treat the included OCV-SOC relation as a placeholder until replaced with measured or datasheet-derived values.
