# MATLAB Examples Index

This index lists the starter MATLAB examples, their purpose, key files, and run commands.

| Example | Purpose | Key Files | Run Commands |
|---|---|---|---|
| [Battery RC model](battery-rc-model/README.md) | Demonstrates a small first-order battery equivalent-circuit model with current, SOC, and terminal-voltage outputs. | `battery-rc-model/run_battery_rc_model.m`, `battery-rc-model/check_battery_rc_model.m`, `battery-rc-model/data/pulse_current_profile.csv` | `run_battery_rc_model`, `check_battery_rc_model` |
| [Converter average model](converter-average-model/README.md) | Provides a no-plot averaged converter scaffold for assumptions, signal naming, and first-pass estimates. | `converter-average-model/run_converter_average_model.m`, `converter-average-model/check_converter_average_model.m` | `run_converter_average_model`, `check_converter_average_model` |

## Example Guides

- [Example troubleshooting notes](guides/example-troubleshooting-notes.md)

- [Parameter Review Guide](guides/parameter-review-guide.md)

- [Expected Output Change Log](guides/expected-output-change-log.md)

- [Sample Data Quality Checklist](guides/sample-data-quality-checklist.md)

- [Automation Readiness Guide](guides/automation-readiness-guide.md)

- [Script Structure Review](guides/script-structure-review.md)

- [Plotting Script Review](guides/plotting-script-review.md)

- [Unit Consistency Checklist](guides/unit-consistency-checklist.md)

- [Validation Error Triage](guides/validation-error-triage.md)

- [Small Model Extension Plan](guides/small-model-extension-plan.md)

- [Result Interpretation Notes](guides/result-interpretation-notes.md)

- [Reproducibility Checklist](guides/reproducibility-checklist.md)

## Output Inventory

| Script | Expected Output |
|---|---|
| `battery-rc-model/check_battery_rc_model.m` | Prints `Battery RC check passed. Final SOC: 0.767` and voltage range `3.425 V to 3.877 V`. |
| `battery-rc-model/run_battery_rc_model.m` | Prints final SOC and voltage range, and opens current, SOC, and terminal-voltage plots. |
| `converter-average-model/check_converter_average_model.m` | Prints `Converter parameter check passed.`, output voltage `360.0 V`, and load current `18.0 A`. |
| `converter-average-model/run_converter_average_model.m` | Prints converter scaffold assumptions and first-pass output, current ripple, and voltage ripple estimates. |

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

## Maintenance Checklist

| Check | Why It Matters |
|---|---|
| Assumptions are listed before results | Reviewers should see placeholder values before trusting outputs. |
| Units are stated for parameters and outputs | MATLAB examples are easier to inspect when units are explicit. |
| Expected output is documented | Small examples should make intentional output changes obvious. |
| No-plot check exists | Future automation needs a fast validation command. |
| Plotting script remains inspectable | Visual scripts should explain behavior without hiding logic in large helpers. |
| Sample data is small and local | Examples should run without private files or external downloads. |
| Validation note is updated after model changes | Documentation should change when assumptions or outputs change. |

## Assumptions Checklist

| Check | Prompt |
|---|---|
| Parameter units | Are all parameters labeled with units in the README or script comments? |
| Placeholder values | Are educational placeholder values clearly separated from sourced project values? |
| Sample data | Is sample input data small, local, and safe to run in automation? |
| Solver or time step | Does the example explain the chosen time step or simplified solver assumption? |
| Expected output | Does the documented output match the current no-plot check? |
| Validation command | Can a reviewer run one short command to confirm the example still works? |
