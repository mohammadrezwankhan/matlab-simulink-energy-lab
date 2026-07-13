# ⚡ MATLAB Simulink Energy Lab

[![Markdown maintenance](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab/actions/workflows/markdown-maintenance.yml/badge.svg)](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab/actions/workflows/markdown-maintenance.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-2f6f5e.svg)](LICENSE)
[![MATLAB R2026a](https://img.shields.io/badge/MATLAB-R2026a-e16737.svg)](#requirements)
[![GitHub stars](https://img.shields.io/github/stars/mohammadrezwankhan/matlab-simulink-energy-lab?style=social)](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab/stargazers)

**Energy models should reveal the physics—not hide it.**

MATLAB Simulink Energy Lab is a growing collection of small, runnable, and highly inspectable energy-system examples. Start with a battery RC model or an averaged converter calculation, trace every assumption, run the checks, and then extend the foundation for your own study.

> ⭐ **Found this useful? Please [star the repository](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab) to support the project.** It helps other students and engineers discover the models—and tells me which open examples are worth building next.

![First-order battery RC model response showing discharge and charge current pulses, state-of-charge change, and terminal-voltage transients](assets/battery-rc-response.png)

## Why This Lab Exists

Foundational engineering models are often either too abbreviated to trust or too elaborate to learn from. This repository takes a middle path:

- **Inspectable:** equations, parameters, units, and assumptions stay visible.
- **Runnable:** every example has a script and a lightweight, no-plot check.
- **Engineering-led:** outputs answer a stated physical question rather than merely producing a figure.
- **Extension-friendly:** simple baselines make it easier to add controls, higher-order dynamics, measured data, or Simulink implementations.

The current release uses base-MATLAB reference implementations. They are transparent numerical foundations for future Simulink models—not calibrated production models or closed digital twins.

## Quick Start

Clone the repository and run the verified battery check:

```bash
git clone https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab.git
cd matlab-simulink-energy-lab
matlab -batch "run('examples/battery-rc-model/check_battery_rc_model.m')"
```

Expected output:

```text
Battery RC check passed. Final SOC: 0.767
Voltage range: 3.425 V to 3.877 V
```

To reproduce the current, state-of-charge, and terminal-voltage figure shown above, run:

```matlab
run('examples/battery-rc-model/run_battery_rc_model.m')
```

## Included Models

| Example | Question It Explores | Validation | Requirements |
|---|---|---|---|
| [Battery RC model](examples/battery-rc-model/README.md) | How do charge and discharge pulses affect SOC and terminal voltage in a first-order equivalent circuit? | `check_battery_rc_model.m` | Base MATLAB |
| [Converter average model](examples/converter-average-model/README.md) | What do duty cycle and component values imply for average voltage, load current, and first-pass ripple? | `check_converter_average_model.m` | Base MATLAB |

Run both lightweight checks from the repository root:

```bash
matlab -batch "run('examples/battery-rc-model/check_battery_rc_model.m'); run('examples/converter-average-model/check_converter_average_model.m')"
```

The [examples index](examples/README.md) connects each model to reproducibility, unit-consistency, validation, and review guidance. Shared conventions live in the [modeling standards](notes/modeling-standards.md).

## Who It Is For

- **Students** learning how electrical assumptions become executable models.
- **Instructors** looking for compact examples that can be discussed and modified in class.
- **Researchers** who need a transparent baseline before introducing higher-fidelity behavior.
- **Hobbyists and engineers** exploring battery and converter fundamentals without a large framework.

## Requirements

- MATLAB R2026a is the verified release.
- The current examples use base MATLAB functionality only.
- No additional toolbox is required for the included validation checks.

If you run the examples on another MATLAB release, please share the result in an issue so the compatibility record can grow.

## Scope And Limitations

- The examples are educational engineering references, not calibrated design models.
- The battery model uses a deliberately simple placeholder OCV-SOC relationship.
- Temperature, ageing, hysteresis, and cell-to-cell variation are not yet modeled.
- The converter example is an averaged calculation scaffold, not a detailed switching implementation.
- Parameters and expected outputs must be revalidated before use with real hardware or control designs.

## What Should Come Next?

The most useful next additions are likely to be:

- a temperature-aware or higher-order battery model;
- closed-loop control around the averaged converter;
- an averaged-versus-switched converter comparison;
- measured-data parameter identification and validation; or
- native Simulink implementations of the reference models.

[Request an example](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab/issues/new?template=example-request.md), open a focused issue, or propose an implementation through a pull request.

## Contributing

Contributions are welcome—especially measured-data validation, sourced parameter sets, additional equivalent-circuit variants, converter topologies, automated checks, and clearer teaching notes. Read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.

If the lab saves you time or helps you understand a model, **please leave a ⭐**. It is the simplest way to support continued open engineering work.

## License

Released under the [MIT License](LICENSE).
