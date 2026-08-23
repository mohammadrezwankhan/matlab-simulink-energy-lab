<!-- markdownlint-disable MD013 -->

# Which MATLAB Battery, Converter, or BESS Model Should I Use?

Use this guide to choose the smallest model that answers your engineering
question. Every route below links to an executable example, its assumptions,
and a no-plot regression check.

These are transparent reduced-order teaching and research references. They are
not cell-test, hardware, protection, certification, or grid-code models.

## Choose by question

### I need a battery electrical model

| Your question | Start here | Why | Do not use it for |
| --- | --- | --- | --- |
| How do current pulses change SOC and terminal voltage? | [First-order RC](../examples/battery-rc-model/README.md) | Smallest electrical baseline; nonlinear OCV and one polarization state. | Separating fast and slow relaxation. |
| Do I need two polarization time scales? | [Two-RC model](../examples/battery-2rc-model/README.md) | Exact fast/slow RC propagation and transparent pulse data. | Claiming parameters generalize without a held-out profile. |
| Can positive two-RC parameters fit one record and predict another? | [Two-RC identification tutorial](two-rc-battery-parameter-identification.md) | Separates calibration from deterministic held-out validation. | Physical-cell validation; the bundled records are synthetic. |
| Does charge/discharge history change OCV at the same SOC? | [OCV hysteresis](../examples/battery-ocv-hysteresis/README.md) | Adds one exact bounded memory state and a reversal minor loop. | Rate-dependent electrochemistry or ageing. |

### I need SOC estimation

| Your question | Start here | Why | Do not use it for |
| --- | --- | --- | --- |
| Can voltage measurements correct a biased SOC estimate? | [Battery SOC EKF](../examples/battery-soc-ekf/README.md) | Transparent two-state Joseph-form EKF with uncertainty and irregular-time checks. | Hysteretic voltage behavior. |
| How sensitive is that EKF to a constant current-sensor offset? | [SOC EKF current-bias sensitivity](../examples/battery-soc-ekf/README.md#prescribed-current-bias-sensitivity) | Holds truth and voltage fixed while sweeping five prescribed estimator-input biases. | Bias detection, estimation, rejection, or BMS safety claims. |
| What error appears when an estimator omits known hysteresis? | [Hysteresis-aware SOC EKF](../examples/battery-soc-hysteresis-ekf/README.md) | Compares three-state and two-state estimators on the same reversal-rich synthetic case. | Broad robustness or physical-cell claims. |

### I need a battery thermal model

| Your question | Start here | Why | Do not use it for |
| --- | --- | --- | --- |
| How do loss, entropic heat, and cooling affect one cell temperature? | [Lumped electro-thermal cell](../examples/battery-thermal-model/README.md) | Couples RC electrical behavior, resistance feedback, and one thermal state. | Internal spatial gradients. |
| How does serial coolant warming affect a module? | [Module liquid-cooling network](../examples/battery-module-cooling-network/README.md) | Resolves six cell temperatures, coolant segments, and cell-to-cell conduction. | Detailed channel CFD. |
| Where is the through-thickness hot spot in a pouch cell? | [Pouch-cell thermal gradient](../examples/pouch-cell-thermal-gradient/README.md) | Conservative one-dimensional finite volumes with grid convergence. | In-plane gradients or three-dimensional geometry. |

### I need a buck-converter model

| Your question | Start here | Why | Do not use it for |
| --- | --- | --- | --- |
| What are the first-pass voltage, current, and ripple estimates? | [Averaged scaffold](../examples/converter-average-model/README.md) | Fastest algebraic starting point. | Startup or control transients. |
| How does explicit ideal PWM compare with averaged estimates? | [Switching buck](../examples/converter-switching-model/README.md) | Event-aligned ON/OFF propagation and ripple checks. | Semiconductor loss prediction. |
| How do open-loop, PI, and filtered PID compare on one averaged plant? | [Closed-loop averaged converter](../examples/converter-closed-loop-model/README.md) | Bounded cascaded control and comparable load-step metrics. | Switch-level ripple. |
| Can a period-sampled controller regulate an explicitly switched plant? | [Switching closed-loop buck](../examples/converter-switching-closed-loop-model/README.md) | Couples bounded control to lossy event-aligned PWM and separates nominal datasheet-reference switch losses. | Hardware or device-loss qualification. |
| How do published junction-temperature anchors change the same switch-loss estimate? | [Switch fixed-temperature sensitivity](../examples/converter-switching-closed-loop-model/README.md#fixed-junction-temperature-sensitivity) | Prescribes 25-to-175 degC junction temperature and reruns the closed-loop benchmark with source-traceable interpolation. | Predicting junction temperature, cooling, SOA, or lifetime. |
| Can I inspect the same sampled controller and switched plant as native blocks? | [Native Simulink switching closed-loop buck](../examples/converter-switching-closed-loop-simulink-model/README.md) | Generates a fixed-step diagram and checks exact PWM, controller, and state parity. | Independent physical validation or new device physics. |

### I need a BESS control model

| Your question | Start here | Why | Do not use it for |
| --- | --- | --- | --- |
| How do SOC reserve, current limits, and finite DC-link energy constrain requested power? | [BESS DC reserve](../examples/bess-dc-reserve-model/README.md) | Exposes requested, delivered, curtailed, and battery power with energy balances. | AC-grid dynamics or a switching converter. |
| How does one controller transition between grid-following and grid-forming modes? | [Unified BESS control](../examples/bess-unified-control/README.md) | Eight scenarios cover islanding, synchronization, limits, faults, and recovery. | Closed-loop battery-to-AC integration or grid-code qualification. |

The DC reserve and unified AC-control examples are deliberately separate. Do
not combine their results as if a closed-loop battery-to-grid integration had
been validated.

## Choose MATLAB or Simulink

- Choose a **Base MATLAB** example when you want the governing equations in a
  compact script, fast parameter studies, or a browser-runnable starting point.
- Choose a **generated Simulink companion** when you need an inspectable block
  diagram. The RC, two-RC, electro-thermal, averaged-buck, switched-buck, and unified-BESS
  examples have Simulink routes; see the [examples index](../examples/README.md).
- Start with the MATLAB reference when both exist. The generated Simulink
  checks compare their logged outputs against that reference.

## Six browser-runnable starting points

These links target Base MATLAB scripts and open the repository in MATLAB
Online. Run the opened script after the repository finishes loading.

- [Open the hysteresis-aware SOC EKF](https://matlab.mathworks.com/open/github/v1?repo=mohammadrezwankhan/matlab-simulink-energy-lab&file=examples/battery-soc-hysteresis-ekf/run_battery_soc_hysteresis_ekf.m)
- [Open the SOC EKF current-bias sensitivity](https://matlab.mathworks.com/open/github/v1?repo=mohammadrezwankhan/matlab-simulink-energy-lab&file=examples/battery-soc-ekf/run_battery_soc_ekf_current_bias.m)
- [Open the switching closed-loop buck](https://matlab.mathworks.com/open/github/v1?repo=mohammadrezwankhan/matlab-simulink-energy-lab&file=examples/converter-switching-closed-loop-model/run_switching_closed_loop_buck.m)
- [Open the switch fixed-junction-temperature sensitivity](https://matlab.mathworks.com/open/github/v1?repo=mohammadrezwankhan/matlab-simulink-energy-lab&file=examples/converter-switching-closed-loop-model/run_switching_closed_loop_buck_temperature_sensitivity.m)
- [Open the BESS DC reserve model](https://matlab.mathworks.com/open/github/v1?repo=mohammadrezwankhan/matlab-simulink-energy-lab&file=examples/bess-dc-reserve-model/run_bess_dc_reserve.m)
- [Open the BESS prescribed dynamic-profile sensitivity](https://matlab.mathworks.com/open/github/v1?repo=mohammadrezwankhan/matlab-simulink-energy-lab&file=examples/bess-dc-reserve-model/run_bess_dc_reserve_profile_sensitivity.m)

## Focused Simulink first runs

Run either command from the repository root. Both checks require Simulink but
no battery, power-electronics, control, or testing toolbox. Each command builds
a temporary `.slx` model, inspects and simulates it, compares its outputs with
the corresponding MATLAB reference, and removes the generated files.

| Engineering question | Command | Expected terminal result |
| --- | --- | --- |
| Can a native battery RC block diagram reproduce the MATLAB model? | `run('examples/battery-simulink-model/check_battery_rc_simulink_model.m')` | `Native Simulink battery RC check passed.` |
| Can a native switching closed-loop buck reproduce the controller, PWM sequence, and plant states? | `run('examples/converter-switching-closed-loop-simulink-model/check_switching_closed_loop_buck_simulink_model.m')` | `Native Simulink switching closed-loop buck check passed.` |

For a no-plot confidence check, run the example's `check_*.m` entry point. To
validate the whole repository from its root folder, run:

```matlab
addpath('examples')
run_all_checks
```

See [validation results](validation-results.md) for expected outputs and
provenance, then read the selected example's limitations before adapting it.
