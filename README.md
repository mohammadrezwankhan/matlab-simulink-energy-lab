# MATLAB Simulink Energy Lab

[![Markdown maintenance](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab/actions/workflows/markdown-maintenance.yml/badge.svg)](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab/actions/workflows/markdown-maintenance.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-2f6f5e.svg)](LICENSE)

Small, inspectable MATLAB examples for battery and power-electronics modeling. Each example states its assumptions, includes a no-plot validation check, and connects the simulation output to an engineering question.

![First-order battery RC model response showing discharge and charge current pulses, state-of-charge change, and terminal-voltage transients](assets/battery-rc-response.png)

## Run A Verified Example

The battery example uses only base MATLAB functionality. It was verified with MATLAB R2026a.

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

Run `examples/battery-rc-model/run_battery_rc_model.m` in MATLAB to reproduce the plotted current, SOC, and terminal-voltage response above.

## Included Examples

| Example | Engineering Focus | Runnable Files |
|---|---|---|
| [Battery RC model](examples/battery-rc-model/README.md) | First-order equivalent-circuit response to charge and discharge pulses | `run_battery_rc_model.m`, `check_battery_rc_model.m` |
| [Converter average model](examples/converter-average-model/README.md) | Inspectable converter behavior and topology assumptions | `run_converter_average_model.m`, `check_converter_average_model.m` |

The [examples index](examples/README.md) links the executable models to validation, reproducibility, unit-consistency, and review guidance. Repository-wide conventions are documented in [modeling standards](notes/modeling-standards.md).

## Scope And Limitations

- The examples are educational engineering references, not calibrated design models.
- The battery example uses a deliberately simple placeholder OCV-SOC relationship.
- Temperature dependence, ageing, hysteresis, and cell-to-cell variation are outside its present scope.
- Parameters and expected outputs must be revalidated before extending an example to a real cell, converter, or control design.

## Contributing

Useful contributions include measured-data validation, additional equivalent-circuit variants, converter topologies, automated checks, and clearly sourced parameter sets. See [CONTRIBUTING.md](CONTRIBUTING.md) before opening an issue or pull request.

## License

Released under the [MIT License](LICENSE).
