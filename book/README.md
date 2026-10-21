# Battery Modeling and BESS Control in MATLAB

## An executable course from a current pulse to a grid-connected controller

**Mohammad Rezwan Khan · First manuscript draft · September 2026**

[Companion repository](../README.md) · [简体中文项目说明](../README.zh-CN.md) ·
[Notation](notation.md) · [Source and execution map](source-map.md)

A battery is not a voltage source with a percentage label. Its terminal voltage
depends on current, stored charge, polarization, temperature and history. A
converter does not make an arbitrary power request feasible merely because its
controller has an integral term. A battery energy storage system (BESS) must also
respect energy availability, current limits and the sequence in which it changes
operating modes. These observations connect the twelve chapters of this book.

The book begins with a question that fits on a laboratory bench: what should a
voltage trace do when a current pulse begins and ends? It ends with a question
that fits a control-room diagram: what should a storage controller do when the
grid disappears and later returns? Between those questions we develop the
models needed to reason about state estimation, heat flow, switching and reserve.

The companion code already implements the examples. The purpose of the book is
to explain *why* each state and equation is there, how the equation becomes the
actual update in the program, and what conclusions its output can support. You
will change small, explicit assumptions before you are asked to design a larger
system. You will also encounter cases where the right answer is to use a
different model, obtain better data, or decline to make a claim.

This is a teaching manuscript, not a hardware design manual, an accredited
course, or a promise of physical-cell accuracy. Most inputs and parameters are
synthetic or illustrative. Nothing here authorizes battery charging, converter
operation, grid connection or protection settings on physical equipment.

## Contents

| Chapter | Engineering question | Companion workflow | Worked answers |
| --- | --- | --- | --- |
| [1. From Current Pulses to Terminal Voltage](chapters/01-one-rc.md) | Which part of a voltage change is immediate, and which part remembers the past? | One-RC battery | [Solutions 1](solutions/01-one-rc.md) |
| [2. Fast and Slow Polarization](chapters/02-two-rc.md) | When does a second relaxation time add useful explanatory power? | Two-RC battery | [Solutions 2](solutions/02-two-rc.md) |
| [3. Identifying Battery Parameters](chapters/03-identification.md) | How can a fit be tested on a record it has not seen? | Two-RC identification | [Solutions 3](solutions/03-identification.md) |
| [4. Estimating State of Charge](chapters/04-soc-ekf.md) | How can noisy voltage correct an accumulated charge estimate? | SOC EKF | [Solutions 4](solutions/04-soc-ekf.md) |
| [5. Remembering Charge History](chapters/05-hysteresis.md) | Why can the same SOC have different voltage histories? | Hysteresis-aware EKF | [Solutions 5](solutions/05-hysteresis.md) |
| [6. Coupling Electrical and Thermal Behavior](chapters/06-electrothermal.md) | How do electrical losses, reversible heat and cooling change cell temperature? | Lumped electrothermal cell | [Solutions 6](solutions/06-electrothermal.md) |
| [7. Resolving Temperature Gradients](chapters/07-pouch-gradients.md) | When is one cell temperature no longer enough? | Pouch-cell finite volumes | [Solutions 7](solutions/07-pouch-gradients.md) |
| [8. Cooling a Battery Module](chapters/08-module-cooling.md) | How does an upstream cell affect the cooling of a downstream cell? | Serial liquid-cooling network | [Solutions 8](solutions/08-module-cooling.md) |
| [9. Regulating Converter Voltage](chapters/09-averaged-control.md) | What changes when a controller, rather than a fixed duty, supplies a load? | Averaged buck comparison | [Solutions 9](solutions/09-averaged-control.md) |
| [10. From Averaging to Switching](chapters/10-switching-control.md) | What survives, and what changes, when PWM is made explicit? | Sampled switching buck | [Solutions 10](solutions/10-switching-control.md) |
| [11. Managing Stored Energy](chapters/11-dc-reserve.md) | How much requested power is actually available? | DC-link and SOC reserve | [Solutions 11](solutions/11-dc-reserve.md) |
| [12. Following and Forming the Grid](chapters/12-bess-supervisor.md) | How should control modes and reconnection be sequenced? | Unified BESS supervisor | [Solutions 12](solutions/12-bess-supervisor.md) |

Each chapter has four exercises and a separate solution file. Try the exercises
before opening the answers. A worked solution is a reasoning example, not a
substitute for recording the output from your own environment.

## Who this book is for

The intended reader knows introductory circuit analysis, derivatives and
integrals, matrices, and basic MATLAB operations. Familiarity with first-order
differential equations is helpful; the first chapters derive the updates rather
than assuming a control-theory course. Chapter 4 introduces covariance and
linearization, Chapter 7 introduces finite-volume balances, and Chapter 12
introduces per-unit quantities and reference frames where they are used.

Battery/BMS students can work through Chapters 1–8, then use Chapter 11 to
connect SOC and reserve assumptions to power availability. Chapter 11 is a
separate DC-side model; no estimator-to-reserve interface is implemented.
Power-electronics students can
read Chapters 1–2 for battery conventions and then Chapters 9–12. Instructors
can pair a chapter with its existing no-plot check and select an exercise without
requiring a new software framework. These are suggested routes, not measured
completion times or claims of classroom use.

The book does not derive electrochemical transport, semiconductor physics,
protection coordination or grid-code compliance. Its state variables are chosen
to answer smaller questions. A reduced-order model can be useful precisely
because its assumptions are visible; it becomes misleading when those
assumptions are forgotten.

## Get the companion code

The manuscript's initial model-source snapshot is
`f0f4a93587665a9ad36a75c95bd99ed965df7676`. It is recorded separately from the
manuscript revision in the [source map](source-map.md). The snapshot is not a new
release tag. Use the revision supplied with the book when comparing its
expectations, and record a different revision if you deliberately use newer code.

For a fresh, separate clone:

```bash
git clone https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab.git
cd matlab-simulink-energy-lab
git switch --detach f0f4a93587665a9ad36a75c95bd99ed965df7676
```

The pinned code revision predates these manuscript files. Read the book in the
manuscript branch or browser, and use the separate pinned clone for calculations.
Do not switch a working repository containing unsaved changes just to reproduce
an example. When the manuscript is merged, its source map will still explain
which code snapshot the numerical expectations refer to.

MATLAB R2026a is the primary execution baseline. Chapters 1–11 use Base MATLAB
workflows. Chapter 12's direct reference simulation is MATLAB code; its complete
focused validation and generated block-diagram route also require Simulink.
Optional native Simulink companions elsewhere likewise require Simulink.
Neither the presence of an online badge nor a successful run in one environment
guarantees that a reader has the necessary product entitlement.

Set MATLAB's current folder to the repository root. Start with:

```matlab
run('examples/battery-rc-model/check_battery_rc_model.m')
run('examples/battery-rc-model/run_battery_rc_model.m')
```

**Use a fresh MATLAB session and save work first.** Several existing check and
plotting scripts clear variables, and plotting scripts may close figures. Native
builders reject loaded-name collisions but can replace generated files in their
chosen output directory. This book does not change those interfaces. Use a
separate scratch directory for generated files and do not run a builder over a
model you want to preserve.

The first check prints a final SOC of `0.767` and a voltage range of approximately
`3.425 V to 3.877 V` for its canonical profile. These are rounded deterministic
reference values, not specifications for a physical cell. The second command
provides the current, SOC and voltage traces discussed in Chapter 1. If a result
differs, retain the error or output and compare revision, inputs and environment
before changing a tolerance.

## A repeated learning pattern

Start by predicting a direction, not a precise graph. If resistance is doubled,
which voltage component should change immediately? If the coolant warms along
a channel, which cell receives the warmest inlet? If reserve is raised, which
part of a requested discharge profile becomes unavailable? Write that prediction
before running the code.

Next, derive a balance. Charge, energy and current balance expose units and sign
errors that a visually attractive plot can hide. Then discretize that balance
using the method the implementation actually uses. Some examples have exact
zero-order-held updates; others use explicit Euler and enforce a step-size
bound. An exact update for one subsystem is not a license to call the entire
simulation exact.

Run the smallest relevant check, inspect the output, and make one controlled
change in a scratch script. Preserve the repository's canonical parameter
files. State both the requested input and any input actually applied after a
limit. Finally, explain the observation in terms of the equation. “The test
passed” is an execution result; it is not an explanation of the phenomenon.

For every computational exercise, keep a compact notebook entry:

1. Model revision and MATLAB release.
2. Exact command and changed parameters, with units.
3. Prediction before execution.
4. Actual output or a labelled plot.
5. Explanation and at least one alternative interpretation ruled out.
6. A limitation that still matters after the result is obtained.

Do not edit expected answers to force agreement. The [reproduction-report
form](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab/issues/new?template=reproduction_report.yml)
provides a place for a commit-bound discrepancy, including a successful result
on another environment. Posting a report is optional; the notebook entry alone
is enough for the exercise.

## What counts as evidence?

A hand solution checks the reasoning under stated assumptions. A regression
check establishes that particular code satisfies a particular assertion for
particular inputs. A separate implementation can check translation consistency.
A held-out record can test prediction away from a calibration record. A
measured-cell experiment can test a physical claim, but only if its data,
conditions and comparison are suitable. These are different kinds of evidence;
none should be silently substituted for another.

For example, the synthetic identification exercise separates calibration and
held-out profiles, but both remain synthetic. The Simulink switching companion
reproduces the reference algorithm, so matching its output supports
implementation parity, not independent device accuracy. The BESS supervisor
checks sampled readiness at interval boundaries; it does not prove that an
unobserved continuous-time signal stayed within a threshold between samples.

The figures are existing companion assets or plots produced by the documented
runner. A stored figure is not automatically regenerated whenever the code
changes. Captions and the source map distinguish illustrative stored figures
from current execution receipts. There are no claimed classroom outcomes,
adoption rates or hardware qualifications attached to this manuscript.

## A deliberately unfinished system boundary

The DC-reserve model in Chapter 11 and the AC-side supervisor in Chapter 12
are separate examples. They are not already connected in a battery-to-grid
closed loop. Their separation is useful for teaching: it forces us to name the
interface, units, update rate, limits and energy accounting that an integration
would require. The final exercise asks you to design that contract, not to
pretend that a coupled simulation exists.

Likewise, a thermal plot does not make a battery model a thermal-runaway model,
and a switching-loss estimate does not create a junction-temperature state.
Understanding an omitted state is part of understanding the implemented model.

## Use, attribution and corrections

The manuscript is original teaching material built around this repository's
existing examples and retains its [MIT license](../LICENSE). Preserve the
license notice when redistributing material. Cite the software using
[CITATION.cff](../CITATION.cff) and include the actual code and manuscript
revisions. That file describes the software; it is not a fabricated book ISBN,
publisher record or peer-review claim.

Corrections should identify a chapter, equation or exercise and give a concrete
reason or reproducible counterexample. A change to a model deserves its own
focused review; a new edition of the book should not quietly redefine an old
execution receipt. Simplified Chinese onboarding is available in the project
README; the twelve-chapter manuscript and worked solutions are currently in
English.
