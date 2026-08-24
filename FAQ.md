<!-- markdownlint-disable MD013 -->

# MATLAB Simulink Energy Lab: Technical FAQ

This FAQ gives concise answers and routes each topic to its authoritative
source. MATLAB Simulink Energy Lab contains transparent reduced-order teaching
and research references; it is not a physical-cell, hardware, protection,
certification, or grid-code qualification package.

## What is MATLAB Simulink Energy Lab?

It is an open collection of runnable MATLAB and Simulink reference models for
lithium-ion battery equivalent circuits, state-of-charge (SOC) estimation,
battery thermal management, buck converters, and battery energy storage system
(BESS) control. Use the [model-selection guide](docs/model-selection-guide.md)
to choose the smallest model for a specific engineering question.

## Which model should I open first?

Start with the [first-order battery RC model](examples/battery-rc-model/README.md)
for battery voltage and SOC, the
[averaged converter](examples/converter-average-model/README.md) for first-pass
buck-converter calculations, or the
[model-selection guide](docs/model-selection-guide.md) for electrical,
thermal, estimation, converter, and BESS routes.

## Can I run the repository with MATLAB only?

Yes. The toolbox-free Base MATLAB profile runs 20 deterministic script checks:

```matlab
addpath('examples')
run_base_matlab_checks
```

See [Requirements](README.md#requirements) for the exact verified environments
and the distinction between MATLAB-only and Simulink examples.

## Which examples require Simulink?

The generated first-order RC, two-RC, electro-thermal, averaged-buck,
switching closed-loop buck, and unified-BESS block-diagram examples require
Simulink. Their MATLAB source or reference implementation remains inspectable;
the [examples index](examples/README.md) lists each dependency and command.

## Which MATLAB versions have been verified?

MATLAB R2026a with Simulink is the maintained CI baseline. A bounded one-time
record also exists for MATLAB R2025b Update 6 on an exact commit and hosted
run. These records do not promise compatibility with untested releases or
operating systems; see the [compatibility evidence](README.md#requirements).

## Does the repository include lithium-ion battery equivalent-circuit models?

Yes. It includes first-order RC and second-order two-RC equivalent-circuit
models (ECMs), nonlinear open-circuit-voltage versus SOC lookup, exact RC-state
propagation, and generated Simulink companions. Start with the
[battery electrical-model routes](docs/model-selection-guide.md#i-need-a-battery-electrical-model).

## Is battery parameter identification included?

Yes. The toolbox-free two-RC workflow estimates positive ECM parameters on a
calibration record and evaluates them on an independent held-out pulse profile.
Both records are synthetic, so the result demonstrates reproducible fitting
and held-out evaluation rather than physical-cell validation. See the
[parameter-identification tutorial](docs/two-rc-battery-parameter-identification.md).

## Is SOC estimation with an extended Kalman filter included?

Yes. The repository includes a transparent Joseph-form extended Kalman filter
(EKF), prescribed current-sensor-bias sensitivity, and a hysteresis-aware EKF
comparison. The benchmarks are synthetic and do not establish BMS safety,
sensor-bias rejection, or performance on a physical cell. See the
[SOC-estimation routes](docs/model-selection-guide.md#i-need-soc-estimation).

## Which battery thermal-management models are included?

The thermal examples cover a lumped electro-thermal cell, a six-cell serial
liquid-cooling network, a one-dimensional pouch-cell finite-volume temperature
gradient, and a generated Simulink electro-thermal companion. They are reduced
order and do not replace CFD, pack-level safety analysis, or measured thermal
validation. See the
[thermal-model routes](docs/model-selection-guide.md#i-need-a-battery-thermal-model).

## Does the repository model battery liquid cooling?

Yes. The
[module cooling network](examples/battery-module-cooling-network/README.md)
resolves six lumped cell temperatures, serial coolant warming, nearest-neighbor
cell conduction, and energy-balance diagnostics. It does not resolve detailed
channel geometry or computational fluid dynamics.

## Is there a pouch-cell finite-volume thermal model?

Yes. The
[pouch-cell thermal-gradient example](examples/pouch-cell-thermal-gradient/README.md)
uses conservative one-dimensional finite volumes, asymmetric face cooling,
analytic steady-state comparison, and grid-convergence checks. It does not
model in-plane gradients or three-dimensional geometry.

## Which power-electronics examples are included?

The repository includes averaged and explicitly switched buck converters,
bounded closed-loop control, open-loop/PI/filtered-PID comparison, generated
Simulink companions, and fixed-junction-temperature semiconductor-loss
sensitivity. See the
[buck-converter routes](docs/model-selection-guide.md#i-need-a-buck-converter-model)
and each example's limitations before interpreting loss results.

## Does it contain grid-forming and grid-following BESS control?

Yes. The
[unified BESS control example](examples/bess-unified-control/README.md) exercises
grid-following, grid-forming, islanding, synchronization, limits, faults, and
recovery in MATLAB and Simulink. It is an averaged educational controller, not
a certified controller or evidence of grid-code compliance. The
[executable walkthrough](docs/grid-forming-bess-control.md) explains the scope.

## Does it model BESS SOC reserve and DC-link constraints?

Yes. The
[BESS DC-reserve example](examples/bess-dc-reserve-model/README.md) exposes how
illustrative SOC reserve, battery-current capability, and finite DC-link energy
constrain requested DC-side power. It is deliberately separate from the AC
unified-control example and does not validate closed-loop battery-to-grid
integration.

## How is the repository validated?

`run_all_checks` invokes 26 check entry points: 25 general checks plus one
focused unified-BESS entry point that produces 31 MATLAB/Simulink test results.
The repository also validates its machine-readable manifest contract. Exact
expected outputs, source commit, CI run, environment, and claim boundaries are
listed in [validation results](docs/validation-results.md) and the
[validation manifest](docs/validation-manifest.md).

## Is the data measured or synthetic?

The bundled battery identification, SOC-estimation, sensitivity, and control
benchmarks use transparent synthetic or prescribed inputs. Illustrative model
parameters do not represent a named physical cell, pack, converter, or grid
installation unless the nearest example explicitly states and sources that
provenance.

## Can these models qualify a production system?

No. The checks establish deterministic behavior of reduced-order examples.
They do not establish physical-cell accuracy, hardware validation, protection
coordination, functional safety, certification, production readiness, or
grid-code compliance. Read [Scope and Limitations](README.md#scope-and-limitations)
and the selected example README before reuse.

## How do I reproduce all checks?

From the repository root, run:

```matlab
addpath('examples')
run_all_checks
```

This complete run requires Simulink. MATLAB-only users should run
`run_base_matlab_checks`. See [validation results](docs/validation-results.md)
for expected terminal output and evidence provenance.

## How do I cite the project?

Use GitHub's **Cite this repository** control or the tracked
[`CITATION.cff`](CITATION.cff). The machine-readable
[`codemeta.json`](codemeta.json) describes the same v0.10.0 software release;
do not infer a DOI or journal publication because none is declared.

## What license applies?

The source and documentation are distributed under the
[MIT License](LICENSE). External datasets, publications, datasheets, and tools
linked from the documentation retain their own terms.

## What is the canonical project URL?

The canonical source repository is
<https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab>. The linked
[project page](https://rezwankhan.tech/models/matlab-simulink-energy-lab/)
provides a public overview; repository source, checks, CI evidence, releases,
and tracked metadata remain authoritative when descriptions conflict.
