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
- Explore how irreversible electrical losses and cooling change a lumped cell
  temperature and temperature-dependent resistance.
- Validate model behavior from the command line without opening plots.
- Estimate output voltage, load current, and ripple for an averaged converter.
- Inspect bounded closed-loop voltage tracking for an averaged buck converter.
- Trace every parameter, unit, sign convention, and limitation before extending
  a model.

## Start in 60 Seconds

The included checks use base MATLAB functionality and were verified with MATLAB
R2026a. The MATLAB validation workflow runs the same checks whenever executable
model code changes.

```bash
git clone https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab.git
cd matlab-simulink-energy-lab
matlab -batch "run('examples/battery-rc-model/check_battery_rc_model.m'); run('examples/battery-thermal-model/check_battery_thermal_model.m'); run('examples/converter-average-model/check_converter_average_model.m'); run('examples/converter-closed-loop-model/check_closed_loop_converter.m')"
```

Expected output:

```text
Battery RC check passed. Final SOC: 0.767
Voltage range: 3.425 V to 3.877 V
Battery thermal check passed.
Peak cell temperature: 37.32 degC
Final cell temperature: 28.95 degC
Peak irreversible heat: 33.32 W
Final SOC: 0.608
Converter parameter check passed.
Output voltage: 360.0 V
Load current: 18.0 A
Closed-loop converter check passed.
Final average voltage: 399.49 V
Peak voltage after step: 421.90 V
Two-percent settling time: 38.6 ms
```

To reproduce the plotted battery response above, run:

```matlab
run('examples/battery-rc-model/run_battery_rc_model.m')
```

## Models at a Glance

| Example | Question It Explores | Validation | Requirements |
| --- | --- | --- | --- |
| [Battery RC model](examples/battery-rc-model/README.md) | How do charge and discharge pulses affect SOC and terminal voltage in a first-order equivalent circuit? | `check_battery_rc_model.m` | Base MATLAB |
| [Temperature-aware battery model](examples/battery-thermal-model/README.md) | How do equivalent-circuit losses, ambient cooling, and resistance feedback affect lumped cell temperature? | `check_battery_thermal_model.m` | Base MATLAB |
| [Converter average model](examples/converter-average-model/README.md) | What do duty cycle and component values imply for average voltage, load current, and first-pass ripple? | `check_converter_average_model.m` | Base MATLAB |
| [Closed-loop converter](examples/converter-closed-loop-model/README.md) | How does bounded cascaded control track an averaged buck-converter voltage reference? | `check_closed_loop_converter.m` | Base MATLAB |

Current release status: the executable examples are MATLAB scripts. The
converter references include an algebraic estimate and a dynamic closed-loop
average model, but not a switching simulation. Native Simulink implementations
are planned as the lab grows.

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
|   |-- battery-thermal-model/      # Coupled electrical-thermal cell model
|   |-- converter-average-model/    # Average-model scaffold and check
|   |-- converter-closed-loop-model/ # Dynamic plant, controller, and check
|   `-- guides/                     # Reproducibility and review notes
|-- notes/                          # Repository-wide modeling standards
|-- CONTRIBUTING.md
`-- LICENSE
```

## Requirements

- MATLAB R2026a is the verified release.
- The current examples and validation checks use base MATLAB only.
- No additional toolbox is required for the included checks.

If you run the examples on another MATLAB release, please share the result in
an issue so the compatibility record can grow.

## Scope and Limitations

- These examples are educational engineering references, not calibrated design
  models.
- The battery model uses a deliberately simple, replaceable OCV-SOC lookup
  table that must be calibrated before cell-specific use.
- Battery current is zero-order held between supplied timestamps; the RC branch
  is propagated exactly over each interval, and applied current is limited to
  the interval charge available before SOC reaches zero or one.
- Temperature, ageing, hysteresis, and cell-to-cell variation are not yet
  modeled.
- The converter scaffold does not model switching devices, losses, control-loop
  dynamics, or non-ideal components.
- Parameters and expected outputs must be revalidated before use with real
  cells, converters, or control designs.

## What Should Come Next?

The most useful next additions are likely to be:

- a higher-order battery model with hysteresis or additional RC branches;
- an averaged-versus-switched converter comparison;
- measured-data parameter identification and validation; or
- native Simulink implementations of the reference models.

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
