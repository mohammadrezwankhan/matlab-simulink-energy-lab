<!-- markdownlint-disable MD013 MD060 -->

# MATLAB Examples Index

This index lists the starter MATLAB examples, their purpose, key files, and run commands.

| Example | Purpose | Key Files | Run Commands |
|---|---|---|---|
| [Battery RC model](battery-rc-model/README.md) | Demonstrates a shared first-order battery equivalent-circuit simulator with current, SOC, and terminal-voltage outputs. | `battery-rc-model/simulate_battery_rc_model.m`, `battery-rc-model/check_battery_rc_model.m`, `battery-rc-model/data/pulse_current_profile.csv` | `run_battery_rc_model`, `check_battery_rc_model` |
| [Temperature-aware battery model](battery-thermal-model/README.md) | Couples an RC equivalent circuit to a lumped heat balance with temperature-dependent ohmic resistance. | `battery-thermal-model/run_battery_thermal_model.m`, `battery-thermal-model/check_battery_thermal_model.m` | `run_battery_thermal_model`, `check_battery_thermal_model` |
| [Converter average model](converter-average-model/README.md) | Provides a no-plot averaged converter scaffold for assumptions, signal naming, and first-pass estimates. | `converter-average-model/run_converter_average_model.m`, `converter-average-model/check_converter_average_model.m` | `run_converter_average_model`, `check_converter_average_model` |
| [Closed-loop converter](converter-closed-loop-model/README.md) | Simulates bounded cascaded voltage and current control around an averaged buck-converter plant. | `converter-closed-loop-model/simulate_closed_loop_converter.m`, `converter-closed-loop-model/check_closed_loop_converter.m` | `run_closed_loop_converter`, `check_closed_loop_converter` |

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

- [Example Release Checklist](guides/example-release-checklist.md)

- [Input Profile Review Guide](guides/input-profile-review-guide.md)

- [Assumptions To Tests Map](guides/assumptions-to-tests-map.md)

- [Dependency Inventory Guide](guides/dependency-inventory-guide.md)

- [Reviewer Runbook](guides/reviewer-runbook.md)

- [Educational Scaffold Guidance](guides/educational-scaffold-guidance.md)

- [Documentation Update Playbook](guides/documentation-update-playbook.md)

- [Example Quality Scorecard](guides/example-quality-scorecard.md)

- [Future Example Idea Bank](guides/future-example-idea-bank.md)

## Output Inventory

| Script | Expected Output |
|---|---|
| `battery-rc-model/check_battery_rc_model.m` | Prints `Battery RC check passed. Final SOC: 0.767` and voltage range `3.425 V to 3.877 V`. |
| `battery-rc-model/run_battery_rc_model.m` | Prints final SOC and voltage range, and opens current, SOC, and terminal-voltage plots. |
| `battery-thermal-model/check_battery_thermal_model.m` | Prints validation status, peak and final cell temperature, peak irreversible heat, and final SOC. |
| `battery-thermal-model/run_battery_thermal_model.m` | Prints the same thermal summary and opens current, voltage, temperature, and heat-generation plots. |
| `converter-average-model/check_converter_average_model.m` | Prints `Converter parameter check passed.`, output voltage `360.0 V`, and load current `18.0 A`. |
| `converter-average-model/run_converter_average_model.m` | Prints converter scaffold assumptions and first-pass output, current ripple, and voltage ripple estimates. |
| `converter-closed-loop-model/check_closed_loop_converter.m` | Verifies finite states, duty limits, final tracking error, overshoot, and two-percent settling time. |
| `converter-closed-loop-model/run_closed_loop_converter.m` | Plots the voltage reference and response, current loop, and bounded duty command. |

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
cd examples/battery-thermal-model
check_battery_thermal_model
```

```matlab
cd examples/converter-average-model
check_converter_average_model
```

```matlab
cd examples/converter-closed-loop-model
check_closed_loop_converter
```

The plotting scripts are intended for visual inspection and explanation. Use
the no-plot checks for quick validation before future automation.

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
