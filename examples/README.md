# MATLAB Examples Index

This index lists the starter MATLAB examples, their purpose, key files, and run commands.

| Example | Purpose | Key Files | Run Commands |
|---|---|---|---|
| [Battery RC model](battery-rc-model/README.md) | Demonstrates a small first-order battery equivalent-circuit model with current, SOC, and terminal-voltage outputs. | `battery-rc-model/run_battery_rc_model.m`, `battery-rc-model/check_battery_rc_model.m`, `battery-rc-model/data/pulse_current_profile.csv` | `run_battery_rc_model`, `check_battery_rc_model` |
| [Converter average model](converter-average-model/README.md) | Provides a no-plot averaged converter scaffold for assumptions, signal naming, and first-pass estimates. | `converter-average-model/run_converter_average_model.m`, `converter-average-model/check_converter_average_model.m` | `run_converter_average_model`, `check_converter_average_model` |

## Review Use

- Start with the example README before running a script.
- Run no-plot checks when validating assumptions or preparing automation.
- Treat placeholder values as educational scaffolds until replaced with project, datasheet, or measured parameters.
- Keep expected output notes updated whenever model assumptions change.

## Validation Commands

Run these no-plot checks from MATLAB when validating the current starter examples:

```matlab
cd examples/battery-rc-model
check_battery_rc_model
```

```matlab
cd examples/converter-average-model
check_converter_average_model
```

The plotting scripts, `run_battery_rc_model` and `run_converter_average_model`, are intended for visual inspection and explanation. Use the no-plot checks for quick validation before future automation.
