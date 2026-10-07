# Companion source and execution map

[Book contents](README.md) · [Notation](notation.md)

## Revision boundary

This first manuscript uses model source
[`f0f4a93587665a9ad36a75c95bd99ed965df7676`](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab/tree/f0f4a93587665a9ad36a75c95bd99ed965df7676).
No model implementation is changed by the manuscript. Relative links below
make navigation convenient in the manuscript checkout; the immutable link
identifies the model revision used for the initial teaching material.

The repository contained 69 Markdown files and 40,932 whitespace-delimited
tokens at that snapshot. This inventory includes headings, tables, commands and
repeated maintenance material; it is not a count of finished book prose. The
chapters reorganize the technical content into a teaching sequence rather than
claiming the old documentation was already a textbook.

## Chapter-to-code map

Commands are run from the repository root in a fresh MATLAB session. The check
column names an existing entry point, not a new exercise test introduced by this
book. “Base” refers to the primary workflow, not every optional companion.

| Chapter | Primary source | Plot/workflow entry point | Existing check | Products |
| --- | --- | --- | --- | --- |
| 1 | [One-RC](../examples/battery-rc-model/README.md) | `run_battery_rc_model.m` | `check_battery_rc_model.m` | Base MATLAB |
| 2 | [Two-RC](../examples/battery-2rc-model/README.md) | `run_battery_2rc_model.m` | `check_battery_2rc_model.m` | Base MATLAB |
| 3 | [Two-RC fit](../docs/two-rc-battery-parameter-identification.md) | `run_battery_2rc_fit.m` | `check_battery_2rc_fit.m` | Base MATLAB |
| 4 | [SOC EKF](../examples/battery-soc-ekf/README.md) | `run_battery_soc_ekf.m` | `check_battery_soc_ekf.m` | Base MATLAB |
| 5 | [Hysteresis-aware EKF](../examples/battery-soc-hysteresis-ekf/README.md) | `run_battery_soc_hysteresis_ekf.m` | `check_battery_soc_hysteresis_ekf.m` | Base MATLAB |
| 6 | [Lumped thermal](../examples/battery-thermal-model/README.md) | `run_battery_thermal_model.m` | `check_battery_thermal_model.m` | Base MATLAB |
| 7 | [Pouch gradient](../examples/pouch-cell-thermal-gradient/README.md) | `run_pouch_cell_thermal_model.m` | `check_pouch_cell_thermal_model.m` | Base MATLAB |
| 8 | [Module cooling](../examples/battery-module-cooling-network/README.md) | `run_battery_module_cooling_network.m` | `check_battery_module_cooling_network.m` | Base MATLAB |
| 9 | [Averaged feedback](../examples/converter-closed-loop-model/README.md) | `run_converter_controller_comparison.m` | `check_converter_controller_comparison.m` | Base MATLAB |
| 10 | [Switching feedback](../examples/converter-switching-closed-loop-model/README.md) | `run_switching_closed_loop_buck.m` | `check_switching_closed_loop_buck.m` | Base MATLAB |
| 11 | [DC reserve](../examples/bess-dc-reserve-model/README.md) | `run_bess_dc_reserve.m` | `check_bess_dc_reserve.m` | Base MATLAB |
| 12 | [Unified BESS](../examples/bess-unified-control/README.md) | `run_bess_unified_control('C')` | `check_bess_unified_control.m` | MATLAB; full focused check and generated diagram require Simulink |

For a script, use its full relative path, for example:

```matlab
run('examples/battery-2rc-model/check_battery_2rc_fit.m')
```

For Chapter 12's function entry point, first add its directory:

```matlab
addpath('examples/bess-unified-control');
result = run_bess_unified_control('C');
```

The one-RC simulator is reused by the two-RC and SOC examples. The hysteresis
estimator also reuses the hysteresis plant and two-state estimator. Keep the
repository directory structure intact; copying one runner without its siblings
is not the supported reproduction route.

## Prior runtime evidence, not a new manuscript test

The exact model-source commit above completed
[MATLAB validation run 34511290849](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab/actions/runs/34511290849)
successfully on September 10, 2026. Its BESS artifact reports MATLAB R2026a
Update 5, 77 focused tests, eight scenarios, and zero analyzer messages across
34 files. The general job reports 25 general check entry points. The separate
Base MATLAB profile contains 20 checks. These are different counts; they are
not added together as a single number of independent experiments.

That run tested the model source, not this later manuscript or new exercise
text. The targeted manuscript checks below are separate from that historical
full run. A passed baseline does not automatically
validate a new parameter experiment, a new explanation, or a translated claim.

Earlier source records reporting 31, 48 or 73 focused BESS results remain
historical. Their source revisions must not be relabelled as the current book
snapshot. The [validation manifest guide](../docs/validation-manifest.md)
explains the repository's commit-bound artifacts.

## Targeted manuscript verification — September 12, 2026

The authoring pass used MATLAB R2026a Update 5
(`26.1.0.3346908`) against the unchanged model source above. Its final
direct-API pass executed **18 MATLAB code blocks** copied from the chapters
and solutions, each in a separate function workspace with path and working
directory restored. All 18 completed without errors. Eleven blocks invoking
existing plotting or check runners were excluded from that final pass; they
were not silently counted as passed. Front-matter installation/full-suite
commands were inspected, not included in the 18-block total.

A separate selected-value pass checked **37 numerical expectations**, covering
hand calculations, the source SOC/current boundary, the switching-buck summary,
the BESS limiter, and the existing numerical gates for independently initialized
reference scenarios C and E. All 37 comparisons passed their stated tolerances.
The observed state sequences were:

| Scenario | State codes | Transition timestamps (s) |
| --- | --- | --- |
| C: grid loss | `1 → 2 → 3 → 4` | `0, 2, 2.02, 2.07` |
| E: grid return | `3 → 4 → 5 → 6 → 1` | `0, 0.05, 3, 3.455, 3.475` |

State names are given in [Chapter 12](chapters/12-bess-supervisor.md). These
results do not imply that C and E form one continuous experiment or that every
supervisor state must appear in each run. They also do not constitute a fresh
full Simulink validation, 48 automated exercise tests, or measured hardware
evidence. Conceptual answers and derivations still require technical review.

Static manuscript checks verify the twelve chapter/solution pairs, four
exercises and four solution sections in each pair, local file/heading links,
balanced code/math delimiters, and absence of private workspace links. All
extracted book equations also parse with KaTeX 0.16.22. Equation parsing is a
syntax check, not a proof of the mathematics or a guarantee of identical
layout in every Markdown viewer. The chapter/solution text was reviewed
against its linked source; the Chinese README is an onboarding translation,
not a full translated edition or independent professional translation review.

## Figure provenance and reuse

Battery, estimator, thermal, switching and DC-reserve figures linked from the
chapters are existing repository assets. They illustrate the companion
workflows; this manuscript does not claim to have newly measured their data or
regenerated every stored PNG. Chapter 2's discussion must distinguish the
identification figure from a pure dynamics demonstration if it refers to that
asset. Chapter 9's runner produces the relevant controller-comparison plot;
an unrelated stored switching plot is not substituted for it.

The BESS architecture and supervisor diagrams describe structure. Stored BESS
scenario plots and `validation/results.json` have their own embedded source
history and may predate the sample-timing correction. Do not use them to infer
current timing or current test counts. For current-source reproduction, use the
code snapshot and exact run above, plus
[sample-timing.md](../examples/bess-unified-control/docs/sample-timing.md).

## Derivation and literature boundaries

The book derives the equations implemented in this repository. Elementary
circuit, charge and energy balances are developed in the chapters; no external
textbook passages are reproduced. Source-specific implementation choices are
linked to the actual files, not presented as universal physical laws.

The unified controller has an explicit
[source ledger](../examples/bess-unified-control/requirements/source-ledger.csv)
and [limitations](../examples/bess-unified-control/docs/limitations.md). It is a
project translation of a subset of published control concepts with additional
project assumptions, not an exact reproduction of the publication. In
particular, this book does not introduce a virtual synchronous generator,
hardware protection validation, or a coupled DC-battery/AC-grid plant that the
code does not implement. Consult the ledger before citing a publication as
evidence for a particular behavior.

The switching example's fixed-temperature sensitivity uses its documented
datasheet anchors. Those anchors do not justify extrapolation outside the
stated range or a solved junction-temperature trajectory. Preserve the
original source notices and the repository's [license](../LICENSE) when reusing
figures or code.

## Reading and reporting this draft

There are twelve chapters and forty-eight exercises. Solutions are part of the
same manuscript revision as the questions. Numerical values may be rounded for
teaching; a tolerance must still be appropriate to the units and the comparison.
Report the equation, source revision and actual inputs for a discrepancy. Until
a chapter has independent classroom feedback, do not describe it as
classroom-tested. Until a translated passage has been reviewed, do not infer
independent translation review from the existence of a Chinese README.
