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
  data/
    pulse_current_profile.csv
  results/
    terminal_voltage_plot.png
```

## Validation Notes

- State units for every parameter.
- Compare simulated terminal voltage with a known pulse response.
- Report assumptions around temperature and SOC range.
