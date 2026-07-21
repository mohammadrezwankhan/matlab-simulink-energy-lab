<!-- markdownlint-disable MD013 -->

# ⚡ MATLAB Simulink Energy Lab

[![Markdown maintenance](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab/actions/workflows/markdown-maintenance.yml/badge.svg)](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab/actions/workflows/markdown-maintenance.yml)
[![MATLAB validation](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab/actions/workflows/matlab-validation.yml/badge.svg)](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab/actions/workflows/matlab-validation.yml)
![MATLAB R2026a](https://img.shields.io/badge/verified-MATLAB%20R2026a-e86e25.svg)
[![License: MIT](https://img.shields.io/badge/license-MIT-2f6f5e.svg)](LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/mohammadrezwankhan/matlab-simulink-energy-lab?style=social)](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab)

> **See the equations become waveforms—and inspect every assumption in between.**

MATLAB Simulink Energy Lab is a growing collection of small, runnable, and
highly inspectable energy-system examples for students, researchers, and
hobbyists. Start with a battery RC model or an averaged converter calculation,
trace every parameter, run the checks, and extend the foundation for your own
study.

> [!TIP]
> **If a model helps you learn or saves you setup time, [star this repository](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab).**
> Your star helps more energy-engineering learners discover the lab and shows
> which open examples are worth expanding next.

![First-order battery RC model response showing discharge and charge current pulses, state-of-charge change, and terminal-voltage transients](assets/battery-rc-response.png)

## What You Can Explore

- Simulate the terminal-voltage and state-of-charge response of a first-order
  battery RC model on uniform or native irregular time grids.
- Separate fast and slow battery polarization with an exact two-RC model.
- Generate and validate a native Simulink two-RC battery block diagram.
- Explore how irreversible electrical losses, reversible entropic heat, and
  cooling change a lumped cell temperature and temperature-dependent resistance.
- Generate and validate a native Simulink electro-thermal feedback diagram.
- Generate and validate a native Simulink battery RC block diagram.
- Validate model behavior from the command line without opening plots.
- Estimate output voltage, load current, and ripple for an averaged converter.
- Inspect bounded closed-loop voltage tracking for an averaged buck converter.
- Generate and validate a native Simulink averaged buck-converter diagram.
- Trace every parameter, unit, sign convention, and limitation before extending
  a model.

## Start in 60 Seconds

The six script-based checks use base MATLAB functionality. The four native
block-diagram checks additionally require Simulink. All ten were configured for
MATLAB R2026a, and the MATLAB validation workflow runs them whenever executable
model code changes.

```bash
git clone https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab.git
cd matlab-simulink-energy-lab
matlab -batch "run('examples/battery-rc-model/check_battery_rc_model.m'); run('examples/battery-simulink-model/check_battery_rc_simulink_model.m'); run('examples/battery-2rc-model/check_battery_2rc_model.m'); run('examples/battery-2rc-simulink-model/check_battery_2rc_simulink_model.m'); run('examples/battery-thermal-model/check_battery_thermal_model.m'); run('examples/battery-thermal-simulink-model/check_battery_thermal_simulink_model.m'); run('examples/converter-average-model/check_converter_average_model.m'); run('examples/converter-closed-loop-model/check_closed_loop_converter.m'); run('examples/converter-switching-model/check_switching_buck_converter.m'); run('examples/converter-simulink-model/check_average_buck_simulink_model.m')"
```

Expected output:

```text
Battery RC check passed. Final SOC: 0.767
Voltage range: 3.425 V to 3.877 V
Native Simulink battery RC check passed.
Final SOC: 0.767
Voltage range: 3.425 V to 3.877 V
Battery 2RC check passed. Final SOC: 0.767
Voltage range: 3.325 V to 3.925 V
Peak polarization: fast 0.075 V, slow 0.125 V
Native Simulink battery 2RC check passed.
Final SOC: 0.767
Voltage range: 3.325 V to 3.925 V
Battery thermal check passed.
Peak cell temperature: 36.92 degC
Final cell temperature: 28.96 degC
Peak irreversible heat: 33.31 W
Reversible heat range: -2.31 W to 1.12 W
Peak total heat: 34.29 W
Final SOC: 0.608
Native Simulink battery thermal check passed.
Peak cell temperature: 36.92 degC
Final cell temperature: 28.96 degC
Reversible heat range: -2.31 W to 1.12 W
Converter parameter check passed.
Output voltage: 360.0 V
Load current: 18.0 A
Closed-loop converter check passed.
Final average voltage: 399.49 V
Peak voltage after step: 421.90 V
Two-percent settling time: 38.6 ms
Switching buck converter check passed.
Average output voltage: 358.209 V
Average inductor current: 17.910 A
Current ripple: 9.901 A peak-to-peak
Voltage ripple: 0.124 V peak-to-peak
Measured duty cycle: 0.450
Native Simulink averaged buck check passed.
Final output voltage: 358.209 V
Final inductor current: 17.910 A
```

To reproduce the plotted battery response above, run:

```matlab
run('examples/battery-rc-model/run_battery_rc_model.m')
```

## Models at a Glance

| Example | Question It Explores | Validation | Requirements |
| --- | --- | --- | --- |
| [Battery RC model](examples/battery-rc-model/README.md) | How do charge and discharge pulses affect SOC, terminal voltage, charge throughput, and delivered energy? | `check_battery_rc_model.m` | Base MATLAB |
| [Native Simulink battery RC](examples/battery-simulink-model/README.md) | Can a generated diagram reproduce the exact first-order battery pulse response and nonlinear OCV lookup? | `check_battery_rc_simulink_model.m` | MATLAB and Simulink |
| [Battery 2RC model](examples/battery-2rc-model/README.md) | How do fast and slow polarization branches shape pulse response and voltage recovery? | `check_battery_2rc_model.m` | Base MATLAB |
| [Native Simulink battery 2RC](examples/battery-2rc-simulink-model/README.md) | Can a generated diagram reproduce both exact battery polarization time scales? | `check_battery_2rc_simulink_model.m` | MATLAB and Simulink |
| [Temperature-aware battery model](examples/battery-thermal-model/README.md) | How do irreversible loss, reversible entropic heat, ambient cooling, and resistance feedback affect lumped cell temperature? | `check_battery_thermal_model.m` | Base MATLAB |
| [Native Simulink battery thermal](examples/battery-thermal-simulink-model/README.md) | Can a generated discrete diagram reproduce coupled electrical, entropic, and thermal feedback sample by sample? | `check_battery_thermal_simulink_model.m` | MATLAB and Simulink |
| [Converter average model](examples/converter-average-model/README.md) | What do duty cycle and component values imply for average voltage, load current, and first-pass ripple? | `check_converter_average_model.m` | Base MATLAB |
| [Switching buck converter](examples/converter-switching-model/README.md) | How do ideal PWM switching waveforms compare with averaged voltage, current, and ripple estimates? | `check_switching_buck_converter.m` | Base MATLAB |
| [Closed-loop converter](examples/converter-closed-loop-model/README.md) | How does bounded cascaded control track an averaged buck-converter voltage reference? | `check_closed_loop_converter.m` | Base MATLAB |
| [Native Simulink averaged buck](examples/converter-simulink-model/README.md) | Can a generated block diagram reproduce the exact transient and lossy steady state of the averaged equations? | `check_average_buck_simulink_model.m` | MATLAB and Simulink |

Current release status: the battery examples and three converter references run
as MATLAB scripts. Native battery RC, battery 2RC, battery thermal, and averaged
buck references additionally generate, compile, and simulate Simulink diagrams.

## Why This Lab Is Inspectable

Foundational engineering models are often either too abbreviated to trust or
too elaborate to learn from. This repository takes a middle path:

- **Small models:** the governing logic fits in a short script.
- **Visible assumptions:** parameters, units, and sign conventions live beside
  the equations.
- **Repeatable checks:** no-plot scripts assert basic physical and numerical
  behavior.
- **Engineering context:** every example begins with a question and ends with
  limitations and next steps.
- **Extension-friendly:** simple baselines make it easier to add controls,
  higher-order dynamics, measured data, or Simulink implementations.

The [examples index](examples/README.md) connects each model to reproducibility,
unit consistency, validation, and review guidance. Shared conventions live in
the [modeling standards](notes/modeling-standards.md).

## Who It Is For

- **Students** learning how electrical assumptions become executable models.
- **Instructors** looking for compact examples that can be discussed and
  modified in class.
- **Researchers** who need a transparent baseline before introducing
  higher-fidelity behavior.
- **Hobbyists and engineers** exploring battery and converter fundamentals
  without a large framework.

## Project Structure

```text
matlab-simulink-energy-lab/
|-- assets/                         # Result images used in the documentation
|-- examples/
|   |-- battery-rc-model/           # RC simulation, pulse data, and check
|   |-- battery-simulink-model/     # Generated native battery RC diagram
|   |-- battery-2rc-model/          # Fast/slow polarization model and check
|   |-- battery-2rc-simulink-model/ # Generated native two-RC diagram
|   |-- battery-thermal-model/      # Coupled electrical-thermal cell model
|   |-- battery-thermal-simulink-model/ # Generated thermal feedback diagram
|   |-- converter-average-model/    # Average-model scaffold and check
|   |-- converter-switching-model/  # Ideal PWM switching model and check
|   |-- converter-closed-loop-model/ # Dynamic plant, controller, and check
|   |-- converter-simulink-model/   # Generated native Simulink model and check
|   `-- guides/                     # Reproducibility and review notes
|-- notes/                          # Repository-wide modeling standards
|-- CONTRIBUTING.md
`-- LICENSE
```

## Requirements

- MATLAB R2026a is the verified release.
- The script-based examples and their validation checks use base MATLAB only.
- Simulink is required only for the four native block-diagram examples.
- No power-electronics, control, or testing toolbox is required.

If you run the examples on another MATLAB release, please share the result in
an issue so the compatibility record can grow.

## Scope and Limitations

- These examples are educational engineering references, not calibrated design
  models.
- The battery model uses a deliberately simple, replaceable OCV-SOC lookup
  table that must be calibrated before cell-specific use.
- The native battery RC diagram receives the reference model's prevalidated,
  SOC-feasible current trace rather than duplicating its boundary limiter.
- The native battery 2RC diagram uses that same prevalidated current policy and
  independently integrates both polarization branches.
- The native thermal diagram reproduces a checked discrete educational model;
  it is not a spatial, safety, or thermal-runaway simulation.
- Its SOC-indexed entropic-coefficient table is illustrative, varies neither
  with temperature nor ageing, and must be replaced with measured cell data.
- Battery current is zero-order held between supplied timestamps; RC
  polarization states are propagated exactly over each interval, and applied
  current is limited to the interval charge available before SOC reaches zero
  or one.
- Ageing, OCV hysteresis, and cell-to-cell variation are not yet modeled.
- The switching converter resolves ideal PWM and inductor copper loss but omits
  semiconductor loss, dead time, parasitics, EMI, protection, and switched
  closed-loop control.
- The native Simulink converter is an averaged open-loop model and therefore
  omits PWM ripple and switching events.
- Parameters and expected outputs must be revalidated before use with real
  cells, converters, or control designs.

## What Should Come Next?

The most useful next additions are likely to be:

- measured-data identification and cross-validation for the two-RC model;
- switched closed-loop control or a source-backed semiconductor loss model;
- OCV hysteresis with charge/discharge minor-loop validation; or
- measured thermal-parameter identification and held-out drive-cycle validation.

[Request an example](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab/issues/new?template=example-request.md),
open a focused issue, or propose an implementation through a pull request.

## Contributing

Contributions are welcome—especially measured-data validation, sourced
parameter sets, equivalent-circuit variants, converter topologies, automated
checks, and clearer teaching notes. Read [CONTRIBUTING.md](CONTRIBUTING.md)
before opening a pull request.

If the lab saves you time or helps you understand a model, **please leave a ⭐**.
It is the simplest way to support continued open engineering work.

## License

Released under the [MIT License](LICENSE).

## Collaboration note

Co-authored documentation pass clarifying validation expectations for battery RC and converter average-model examples.
