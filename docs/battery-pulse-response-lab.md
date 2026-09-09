# Battery pulse-response lab in Base MATLAB

Use a first-order equivalent-circuit model to explain how current pulses change
state of charge (SOC) and terminal voltage. This is a suggested 60-minute lab
for students with basic MATLAB and introductory circuit knowledge, not a
measured classroom completion time. Simulink is not required.

The inputs and parameters are prescribed educational examples. Passing the
checks does not establish physical-cell accuracy, hardware validation, battery
safety, production BMS performance, or classroom adoption.

## Before you start

Download or clone the repository and set MATLAB's current folder to its root.
Use a fresh MATLAB session: the existing check clears workspace variables, and
the plotting demo clears variables and closes open figures. Save work and
figures before running either script. Neither entry point needs a Simulink
model to be opened or rebuilt.

The two entry points below were run on MATLAB R2026a Update 4 for the
[source-bound receipt](#reproduction-receipt). This is not a claim of testing
every MATLAB release or every installation without Simulink.

## What you will learn

1. Separate open-circuit voltage (OCV), ohmic drop, and RC polarization.
2. Reproduce a deterministic check and inspect the corresponding plot.
3. Distinguish requested current from SOC-feasible applied current.
4. Explain charge throughput in Ah and terminal-energy throughput in Wh.
5. State what a regression check cannot establish about a physical battery.

## 1. Reproduce the baseline — minutes 0–12

From the repository root, run:

```matlab
run('examples/battery-rc-model/check_battery_rc_model.m')
```

Expected output, rounded as printed by the script:

```text
Battery RC check passed. Final SOC: 0.767
Voltage range: 3.425 V to 3.877 V
Charge throughput: 3.312 Ah (0.03312 equivalent full cycles)
Terminal energy throughput: 11.730 Wh
```

Record the source commit, MATLAB version, command, and actual output. If a
check fails, preserve the error and investigate; do not change the expected
values just to obtain a pass.

## 2. Explain the traces — minutes 12–25

In the same fresh session, run the existing plotting entry point:

```matlab
run('examples/battery-rc-model/run_battery_rc_model.m')
```

It produces current, SOC, and terminal-voltage plots and the same baseline
totals. Positive current means discharge; negative current means charge.
Annotate one pulse onset and one relaxation interval. Which change is
immediate, which evolves over time, and which reflects accumulated charge?

Inspect `requested_current_A`, `current_A`, and `current_limited` in `result`.
For this canonical profile, the demo reports zero SOC-limited current samples.
That does not validate a cell's current rating: these limits only prevent
interval charge from driving SOC outside its allowed range.

## 3. Read the assumptions — minutes 25–40

Open [the parameter function](../examples/battery-rc-model/battery_rc_default_parameters.m)
and [the model explanation](../examples/battery-rc-model/README.md#model-scope).
Write down the units and roles of `r0_Ohm`, `r1_Ohm`, `c1_F`, `capacity_Ah`,
`initial_soc`, and the OCV–SOC lookup vectors.

Use the [duty-cycle accounting explanation](../examples/battery-rc-model/README.md#duty-cycle-accounting)
to answer two questions:

- Why is total charge throughput different from net discharged charge?
- Why does the final timestamp not contribute another energy interval?

Equivalent full cycles here normalize absolute Ah throughput by twice the
nominal capacity. They are not a battery-aging prediction or a rainflow count.

## 4. Make one controlled change — minutes 40–52

Keep the committed baseline files unchanged. In a separate scratch script,
call the existing parameter function and simulator using the same pulse
profile. Change one parameter, such as `r0_Ohm`, in the returned parameter
structure. Predict the effect before running the changed case.

Use the [public simulator interface](../examples/battery-rc-model/README.md#how-to-run)
and keep both baseline and changed results. Compare one trace and explain the
observation using the model's assumptions. A student-selected change is a new
experiment; the baseline receipt below does not validate its result.

## 5. Submit a reviewable result — minutes 52–60

Submit the source commit and MATLAB version, baseline command output, one
annotated plot, the exact changed parameter and units, your prediction and
observation, and two limitations. Keep prescribed-input evidence separate
from any later measured-cell comparison.

For further study, use the [model-selection guide](model-selection-guide.md)
to choose two-RC dynamics or SOC estimation. Do not treat a more detailed model
as automatically more accurate for a different engineering question.

## Reproduction receipt

On 2026-09-09, the exact check and plotting entry points above completed
successfully from source commit
[`6ab87e515abe4cbf6dcbb8644ee4aaae2a4a0ddb`](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab/commit/6ab87e515abe4cbf6dcbb8644ee4aaae2a4a0ddb).
The run used an isolated MATLAB batch process, version
`26.1.0.3312084 (R2026a) Update 4`, on `PCWIN64`, with figures hidden.
Both entry points produced the baseline values shown above; the plotted
entry point also reported zero SOC-limited samples. MATLAB exited with code 0.

This receipt covers those two existing entry points, not a new execution of
the whole repository, classroom timing, a student extension, or a visual
review of the hidden figure. It remains bound to the stated source even when
the repository advances. Use [CITATION.cff](../CITATION.cff) with the actual
source commit when citing your run; retain the [MIT license](../LICENSE) when
redistributing source.
