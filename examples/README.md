<!-- markdownlint-disable MD013 MD060 -->

# MATLAB Examples Index

This index lists the starter MATLAB examples, their purpose, key files, and run commands.

Run every no-plot check from the repository root with:

```matlab
addpath('examples')
run_all_checks
```

The runner invokes each script in an isolated function workspace because the
checks intentionally clear their own variables.

| Example | Purpose | Key Files | Run Commands |
|---|---|---|---|
| [Battery RC model](battery-rc-model/README.md) | Demonstrates a shared first-order battery equivalent-circuit simulator with current, SOC, terminal-voltage, and duty-cycle accounting outputs. | `battery-rc-model/simulate_battery_rc_model.m`, `battery-rc-model/summarize_battery_duty_cycle.m`, `battery-rc-model/check_battery_rc_model.m` | `run_battery_rc_model`, `check_battery_rc_model` |
| [Native Simulink battery RC](battery-simulink-model/README.md) | Generates and validates an inspectable battery RC block diagram against the exact MATLAB reference. | `battery-simulink-model/build_battery_rc_simulink_model.m`, `battery-simulink-model/check_battery_rc_simulink_model.m` | `run_battery_rc_simulink_model`, `check_battery_rc_simulink_model` |
| [Battery 2RC model](battery-2rc-model/README.md) | Adds exact fast and slow polarization branches while reusing validated current, SOC, and OCV states. | `battery-2rc-model/simulate_battery_2rc_model.m`, `battery-2rc-model/check_battery_2rc_model.m` | `run_battery_2rc_model`, `check_battery_2rc_model` |
| [Native Simulink battery 2RC](battery-2rc-simulink-model/README.md) | Generates separate fast and slow RC state paths and validates seven logged outputs against the exact two-RC solver. | `battery-2rc-simulink-model/build_battery_2rc_simulink_model.m`, `battery-2rc-simulink-model/check_battery_2rc_simulink_model.m` | `run_battery_2rc_simulink_model`, `check_battery_2rc_simulink_model` |
| [Battery SOC EKF](battery-soc-ekf/README.md) | Estimates SOC and first-order polarization from noisy current and voltage measurements with a transparent Joseph-form EKF. | `battery-soc-ekf/estimate_battery_soc_ekf.m`, `battery-soc-ekf/simulate_battery_soc_ekf_example.m`, `battery-soc-ekf/check_battery_soc_ekf.m` | `run_battery_soc_ekf`, `check_battery_soc_ekf` |
| [Temperature-aware battery model](battery-thermal-model/README.md) | Couples an RC equivalent circuit to a lumped heat balance with SOC-dependent reversible heat, resistance feedback, duration/degree-hour temperature-limit exposure, and cooling-conductance sensitivity. | `battery-thermal-model/simulate_battery_thermal_model.m`, `battery-thermal-model/summarize_battery_temperature_limits.m`, `battery-thermal-model/compare_battery_cooling_sensitivity.m` | `run_battery_thermal_model`, `run_battery_cooling_sensitivity`, `check_battery_thermal_model`, `check_battery_cooling_sensitivity` |
| [Battery module liquid-cooling network](battery-module-cooling-network/README.md) | Resolves six lumped cell temperatures along a serial coolant channel with nonuniform heat, coolant warming, nearest-neighbor conduction, and energy-balance diagnostics. | `battery-module-cooling-network/simulate_battery_module_cooling_network.m`, `battery-module-cooling-network/check_battery_module_cooling_network.m` | `run_battery_module_cooling_network`, `check_battery_module_cooling_network` |
| [Pouch-cell thermal gradient](pouch-cell-thermal-gradient/README.md) | Resolves through-thickness temperature with conservative finite volumes, asymmetric face cooling, analytic steady-state comparison, and grid-convergence checks. | `pouch-cell-thermal-gradient/simulate_pouch_cell_thermal_model.m`, `pouch-cell-thermal-gradient/check_pouch_cell_thermal_model.m` | `run_pouch_cell_thermal_model`, `check_pouch_cell_thermal_model` |
| [Native Simulink battery thermal](battery-thermal-simulink-model/README.md) | Generates explicit electrical, entropic, and thermal paths and validates thirteen logged outputs against the shared discrete solver. | `battery-thermal-simulink-model/build_battery_thermal_simulink_model.m`, `battery-thermal-simulink-model/check_battery_thermal_simulink_model.m` | `run_battery_thermal_simulink_model`, `check_battery_thermal_simulink_model` |
| [Converter average model](converter-average-model/README.md) | Provides a no-plot averaged converter scaffold for assumptions, signal naming, and first-pass estimates. | `converter-average-model/run_converter_average_model.m`, `converter-average-model/check_converter_average_model.m` | `run_converter_average_model`, `check_converter_average_model` |
| [Switching buck converter](converter-switching-model/README.md) | Resolves ideal event-aligned PWM with exact ON/OFF state propagation and averaged/ripple comparisons. | `converter-switching-model/simulate_switching_buck_converter.m`, `converter-switching-model/check_switching_buck_converter.m` | `run_switching_buck_converter`, `check_switching_buck_converter` |
| [Closed-loop converter](converter-closed-loop-model/README.md) | Simulates bounded cascaded control and compares open-loop, PI, and filtered-PID regulation under a common load step. | `converter-closed-loop-model/simulate_closed_loop_converter.m`, `converter-closed-loop-model/simulate_converter_controller_comparison.m` | `run_closed_loop_converter`, `check_closed_loop_converter`, `run_converter_controller_comparison`, `check_converter_controller_comparison` |
| [Native Simulink averaged buck](converter-simulink-model/README.md) | Generates, compiles, and validates an inspectable block diagram against the exact averaged state solution. | `converter-simulink-model/build_average_buck_simulink_model.m`, `converter-simulink-model/check_average_buck_simulink_model.m` | `run_average_buck_simulink_model`, `check_average_buck_simulink_model` |

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
| `battery-rc-model/check_battery_rc_model.m` | Prints validation, SOC/voltage, `3.312 Ah` charge throughput, `0.03312` equivalent full cycles, and `11.730 Wh` energy throughput. |
| `battery-rc-model/run_battery_rc_model.m` | Prints the same duty summary and opens current, SOC, and terminal-voltage plots. |
| `battery-simulink-model/check_battery_rc_simulink_model.m` | Generates and compiles an SLX model, verifies topology, and compares five outputs with exact MATLAB cases. |
| `battery-simulink-model/run_battery_rc_simulink_model.m` | Generates and opens the battery diagram, simulates the canonical pulse, and plots current, SOC, and voltage. |
| `battery-2rc-model/check_battery_2rc_model.m` | Prints final SOC, terminal-voltage range, and fast/slow peak polarization. |
| `battery-2rc-model/run_battery_2rc_model.m` | Prints the same summary and plots current, SOC, terminal voltage, and both polarization states. |
| `battery-2rc-simulink-model/check_battery_2rc_simulink_model.m` | Generates and compiles an SLX model, verifies both RC state paths, and compares seven outputs with exact MATLAB cases. |
| `battery-2rc-simulink-model/run_battery_2rc_simulink_model.m` | Generates and opens the two-RC diagram, simulates the canonical pulse, and plots both polarization states. |
| `battery-soc-ekf/check_battery_soc_ekf.m` | Verifies deterministic convergence from a 20-point SOC bias, Joseph covariance structure, irregular timestamps, and malformed-input rejection. |
| `battery-soc-ekf/run_battery_soc_ekf.m` | Plots SOC and uncertainty, voltage correction, estimation error, and current for the one-hour benchmark. |
| `battery-thermal-model/check_battery_thermal_model.m` | Validates temperature, heat, energy balance, and multi-limit duration/degree-hour exposure with analytic, irregular-time, and CSV checks. |
| `battery-thermal-model/run_battery_thermal_model.m` | Prints the thermal and limit summaries and plots separated irreversible, reversible, and total heat. |
| `battery-thermal-model/check_battery_cooling_sensitivity.m` | Verifies cooling-case ordering, monotonic canonical temperature/exposure trends, net cooling energy, retained results, and malformed-input rejection. |
| `battery-thermal-model/run_battery_cooling_sensitivity.m` | Prints cooling-sensitivity metrics and plots temperature traces plus degree-hours above the selected limit. |
| `battery-module-cooling-network/check_battery_module_cooling_network.m` | Verifies coolant-segment, cell, and module energy balances; temperature nonuniformity; flow sensitivity; irregular timestamps; and malformed-input rejection. |
| `battery-module-cooling-network/run_battery_module_cooling_network.m` | Prints hottest-cell, temperature-spread, coolant-outlet, and energy-balance metrics and plots the six-cell thermal response. |
| `pouch-cell-thermal-gradient/check_pouch_cell_thermal_model.m` | Verifies finite-volume conservation, boundary convection, symmetry, analytic steady state, grid convergence, irregular timestamps, and malformed-input rejection. |
| `pouch-cell-thermal-gradient/run_pouch_cell_thermal_model.m` | Prints hot-spot, gradient, and energy-balance metrics and plots transient and spatial temperatures plus boundary heat removal. |
| `battery-thermal-simulink-model/check_battery_thermal_simulink_model.m` | Generates and compiles an SLX model, verifies the lookup and feedback topology, and compares thirteen outputs with shared MATLAB cases. |
| `battery-thermal-simulink-model/run_battery_thermal_simulink_model.m` | Generates and opens the thermal diagram and plots current, voltage, temperature, and heat generation. |
| `converter-average-model/check_converter_average_model.m` | Prints `Converter parameter check passed.`, output voltage `360.0 V`, and load current `18.0 A`. |
| `converter-average-model/run_converter_average_model.m` | Prints converter scaffold assumptions and first-pass output, current ripple, and voltage ripple estimates. |
| `converter-switching-model/check_switching_buck_converter.m` | Verifies exact PWM state propagation, settled averages and ripple, whole-period balance, and grid convergence. |
| `converter-switching-model/run_switching_buck_converter.m` | Plots startup plus settled switch-node, inductor-current, and output-voltage waveforms. |
| `converter-closed-loop-model/check_closed_loop_converter.m` | Verifies finite states, duty limits, final tracking error, overshoot, and two-percent settling time. |
| `converter-closed-loop-model/run_closed_loop_converter.m` | Plots the voltage reference and response, current loop, and bounded duty command. |
| `converter-closed-loop-model/check_converter_controller_comparison.m` | Reports and verifies open-loop, PI, and filtered-PID steady error, overshoot, settling, and saturation compliance under one load step. |
| `converter-closed-loop-model/run_converter_controller_comparison.m` | Plots comparable output-voltage, inductor-current, and duty-cycle traces for all three control strategies. |
| `converter-simulink-model/check_average_buck_simulink_model.m` | Generates and compiles an SLX model, verifies topology, and compares both states with the exact matrix-exponential solution. |
| `converter-simulink-model/run_average_buck_simulink_model.m` | Generates and opens the Simulink diagram, simulates startup, and plots output voltage and inductor current. |

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
cd examples/battery-simulink-model
check_battery_rc_simulink_model
```

```matlab
cd examples/battery-2rc-model
check_battery_2rc_model
```

```matlab
cd examples/battery-2rc-simulink-model
check_battery_2rc_simulink_model
```

```matlab
cd examples/battery-soc-ekf
check_battery_soc_ekf
```

```matlab
cd examples/battery-thermal-model
check_battery_thermal_model
```

```matlab
cd examples/battery-thermal-model
check_battery_cooling_sensitivity
```

```matlab
cd examples/battery-module-cooling-network
check_battery_module_cooling_network
```

```matlab
cd examples/pouch-cell-thermal-gradient
check_pouch_cell_thermal_model
```

```matlab
cd examples/battery-thermal-simulink-model
check_battery_thermal_simulink_model
```

```matlab
cd examples/converter-average-model
check_converter_average_model
```

```matlab
cd examples/converter-switching-model
check_switching_buck_converter
```

```matlab
cd examples/converter-closed-loop-model
check_closed_loop_converter
```

```matlab
cd examples/converter-closed-loop-model
check_converter_controller_comparison
```

```matlab
cd examples/converter-simulink-model
check_average_buck_simulink_model
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
