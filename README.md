# ⚡ MATLAB Simulink Energy Lab

[![Markdown maintenance](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab/actions/workflows/markdown-maintenance.yml/badge.svg)](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab/actions/workflows/markdown-maintenance.yml)
![MATLAB R2026a](https://img.shields.io/badge/verified-MATLAB%20R2026a-e86e25.svg)
[![License: MIT](https://img.shields.io/badge/license-MIT-2f6f5e.svg)](LICENSE)

> **See the equations become waveforms.**

MATLAB Simulink Energy Lab is a collection of small, inspectable energy-system examples for students, researchers, and hobbyists. It turns battery and converter equations into runnable experiments, with assumptions you can trace and checks you can repeat.

> [!TIP]
> **If a model helps you learn or saves you setup time, [star this repository](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab).** Your star helps more energy-engineering learners discover the lab and shows which examples are worth expanding next.

![First-order battery RC model response showing discharge and charge current pulses, state-of-charge change, and terminal-voltage transients](assets/battery-rc-response.png)

## What you can explore

- Simulate the terminal-voltage and state-of-charge response of a first-order battery RC model.
- Validate model behavior from the command line without opening plots.
- Estimate output voltage, load current, and ripple for an averaged buck converter.
- Trace every parameter, unit, sign convention, and limitation before extending a model.

## Start in 60 seconds

The included checks use base MATLAB functionality and were verified with MATLAB R2026a.

```bash
git clone https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab.git
cd matlab-simulink-energy-lab
matlab -batch "run('examples/battery-rc-model/check_battery_rc_model.m'); run('examples/converter-average-model/check_converter_average_model.m')"
```

Expected output:

```text
Battery RC check passed. Final SOC: 0.767
Voltage range: 3.425 V to 3.877 V
Converter parameter check passed.
Output voltage: 360.0 V
Load current: 18.0 A
```

To reproduce the plotted response above, run `examples/battery-rc-model/run_battery_rc_model.m` in MATLAB.

## Models at a glance

| Example | What it demonstrates | Entry points |
|---|---|---|
| [Battery RC model](examples/battery-rc-model/README.md) | First-order equivalent-circuit response to charge and discharge pulses | `run_battery_rc_model.m`, `check_battery_rc_model.m` |
| [Converter average model](examples/converter-average-model/README.md) | First-pass buck-converter output and ripple estimates | `run_converter_average_model.m`, `check_converter_average_model.m` |

Current release status: the executable examples are MATLAB scripts. The converter example is an algebraic average-model scaffold, not a switching simulation. Simulink implementations are planned as the lab grows.

## Why this lab is inspectable

Each example is designed to be understood before it is extended:

- **Small models:** the governing logic fits in a short script.
- **Visible assumptions:** parameters, units, and sign conventions live beside the equations.
- **Repeatable checks:** no-plot scripts assert basic physical and numerical behavior.
- **Engineering context:** every example begins with a question and ends with limitations and next steps.

The [examples index](examples/README.md) connects the runnable models to validation, reproducibility, unit-consistency, and review guides. Repository-wide conventions are documented in the [modeling standards](notes/modeling-standards.md).

## Project structure

```text
matlab-simulink-energy-lab/
|-- assets/                         # Result images used in the documentation
|-- examples/
|   |-- battery-rc-model/           # RC simulation, pulse data, and validation check
|   |-- converter-average-model/    # Average-model scaffold and parameter check
|   `-- guides/                     # Reproducibility and model-review notes
|-- notes/                          # Repository-wide modeling standards
|-- CONTRIBUTING.md
`-- LICENSE
```

## Scope and limitations

- These examples are educational engineering references, not calibrated design models.
- The battery example uses a deliberately simple placeholder OCV-SOC relationship.
- Temperature dependence, ageing, hysteresis, and cell-to-cell variation are outside the present battery-model scope.
- The converter scaffold does not model switching devices, losses, control-loop dynamics, or non-ideal components.
- Parameters and expected outputs must be revalidated before use with real cells, converters, or control designs.

## Contributing

Contributions are welcome, especially measured-data validation, additional equivalent-circuit variants, converter topologies, Simulink implementations, automated checks, and clearly sourced parameter sets.

Read [CONTRIBUTING.md](CONTRIBUTING.md), then [open an issue](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab/issues) or submit a focused pull request. If you are new to the project, the issue templates include a guided first-task path.

## License

Released under the [MIT License](LICENSE).
