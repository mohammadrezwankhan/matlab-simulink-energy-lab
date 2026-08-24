<!-- markdownlint-disable MD013 -->

# Unified Grid-Tied and Grid-Forming BESS Control

This example is a transparent, executable engineering translation of the
controller framework in Khan et al., “Design of a Unified Controller Framework
for Grid-tied and Grid-forming Battery Energy Storage System,”
[DOI 10.1109/IECON49645.2022.9968382](https://doi.org/10.1109/IECON49645.2022.9968382).
It is not a numerically exact reproduction: the paper does not publish all
controller equations, gains, plant parameters, solver settings, transition
rules, or initial conditions needed to recreate its results.

> [!CAUTION]
> This is an educational research reference. It is not a qualified plant
> controller, protection system, grid-code certification model, or substitute
> for converter, battery, network, hardware-in-the-loop, and site validation.

![Original unified BESS controller architecture](docs/architecture.svg)

## Engineering question

Can one deterministic reference exercise grid-following P/Q control,
grid-forming voltage/frequency control, grid loss, islanded load support,
synchronization, reconnection, saturation, measurement faults, and recovery
with every important behavior covered by executable assertions?

The answer for the documented reduced-order plant and starter parameters is
yes. The model:

- uses a 10 MVA, 690 V line-to-line, 50 Hz per-unit base;
- represents a balanced dq-current/filter-equivalent converter/PCC plant;
- executes at a fixed 5 ms sample time with a discrete solver;
- exposes eight explicit supervisor states;
- enforces P, Q, available-power, DC-voltage, current, slew, and breaker limits;
- regenerates its disposable `.slx` from MATLAB source; and
- checks scenarios A through H in both MATLAB and Simulink.

## Quick start

From the repository root:

```matlab
addpath('examples/bess-unified-control')
parameters = init_bess_unified_control();
scenarios = bess_validation_scenarios(parameters);
scenarioC = scenarios(strcmp({scenarios.id}, 'C'));
modelPath = build_bess_unified_control_model([], scenarioC, parameters);
result = run_bess_unified_control('C');
```

The builder creates the disposable native Simulink model configured for
Scenario C. The runner separately simulates and plots the reduced-order MATLAB
reference for that same scenario; the focused check below compares both paths.

Run the focused no-plot verification:

```matlab
addpath('examples/bess-unified-control')
run('examples/bess-unified-control/check_bess_unified_control.m')
```

Run every repository check:

```matlab
addpath('examples')
run_all_checks
```

Regenerate machine-readable evidence and original plots:

```matlab
addpath('examples/bess-unified-control')
generate_bess_validation_evidence("YOUR_COMMIT_SHA")
```

## Reproducible model construction

`build_bess_unified_control_model.m` is the source of truth. It creates a new
model with `new_system`, configures a fixed-step discrete solver, adds and
connects blocks with `add_block` and `add_line`, compiles the diagram, and saves
it with `save_system`. The generated `.slx` is intentionally not committed.

The model contains a scenario-profile source, an executable MATLAB Function
block, a 20-signal observable interface, named Outports, and a validation
logger. Control and plant behavior remain in reviewable MATLAB functions under
`src/`. A clean checkout can delete any generated model and rebuild it without
GUI placement or a base-workspace dependency.

## Modes and transition behavior

![Original eight-state supervisor diagram](docs/supervisor-states.svg)

| Code | State | Purpose |
| ---: | --- | --- |
| 1 | `GRID_FOLLOWING` | Connected P/Q regulation and optional grid support |
| 2 | `PREPARE_ISLAND` | Immediate breaker-open transfer preparation |
| 3 | `GRID_FORMING` | Initialize voltage/frequency-forming commands |
| 4 | `ISLANDED_SUPPORT` | Supply the local load with droop and restoration |
| 5 | `SYNCHRONIZING` | Reduce PCC/grid voltage, frequency, and phase mismatch |
| 6 | `PREPARE_RECONNECT` | Hold valid synchronization before closure |
| 7 | `RECOVERY` | Delay restart after a cleared measurement fault |
| 8 | `FAULT_SAFE` | Open breaker and drive P/Q commands safely toward zero |

The paper describes grid-following, grid-supporting, grid-forming, and VSG
concepts, but identifies islanding and main-grid reconnection as future work.
The eight-state transition supervisor is therefore a `PROJECT_ASSUMPTION`
extension. Breaker closure requires valid measurements and controller readiness
plus mismatch no greater than 0.05 p.u., 0.1 Hz, and 5 degrees for the configured
hold interval.

## Signal interface

All signals are real scalars sampled at 5 ms. Positive active power is BESS
discharge/injection into the PCC; charging is negative. Positive reactive power
uses the transform convention implemented in `bess_power_from_abc.m`.

| Signal | Unit/range | Direction | Meaning |
| --- | --- | --- | --- |
| `p_ref_pu`, `q_ref_pu` | p.u. | input | Grid-following power references |
| `voltage_ref_pu` | p.u., nominal 1 | input | Grid-forming voltage reference |
| `frequency_ref_Hz` | Hz, nominal 50 | input | Grid-forming frequency reference |
| `load_p_pu`, `load_q_pu` | p.u. | input | Local balanced load demand |
| `grid_present` | Boolean | input | Utility-grid availability |
| `grid_voltage_pu` | 0 to 1.3 valid | input | Grid-equivalent RMS voltage |
| `grid_frequency_Hz` | 45 to 55 valid | input | Grid frequency |
| `grid_phase_rad` | rad | input | Grid angle used by synchronization |
| `request_grid_following` | Boolean | input | Requested connected operating mode |
| `grid_support_enable` | Boolean | input | Frequency/voltage support enable |
| `fault_code` | 0 to 4 | input | Normal, invalid, stale, bias, or noise |
| `available_power_pu` | 0 to 1 | input | DC-side active-power availability |
| `dc_voltage_pu` | 0.75 to 1.2 valid | input | Simplified DC readiness |
| `p_pu`, `q_pu` | p.u. | output | PCC active/reactive power |
| `voltage_pu`, `frequency_Hz` | p.u., Hz | output | PCC voltage and frequency |
| `current_pu` | p.u. | output | Apparent RMS current magnitude |
| `breaker_closed` | Boolean | output | Physical breaker state |
| `state_code` | 1 to 8 | output | Supervisor state |
| status flags | Boolean | output | Ready, sync, saturation, fault, validity |
| mismatch signals | p.u., Hz, rad | output | Reconnection guard evidence |

The complete packed interface is defined by
`bess_scenario_input_vector.m` and the output list in
`build_bess_unified_control_model.m`.

## Parameters

All missing numerical source values are centralized `PROJECT_ASSUMPTION`
starter values in `bess_unified_control_parameters.m`.

| Parameter | Default | Unit | Classification |
| --- | ---: | --- | --- |
| Rated apparent power | 10 | MVA | Project assumption |
| Nominal line voltage | 690 | V RMS line-line | Project assumption |
| Nominal frequency | 50 | Hz | Source context/starter |
| Controller sample time | 0.005 | s | Project assumption |
| Current limit | 1.00 | p.u. | Project assumption |
| Active/reactive limits | 1.00 / 0.80 | p.u. | Project assumption |
| Minimum/maximum DC voltage | 0.75 / 1.20 | p.u. | Project assumption |
| Dq current/filter time constant | 0.040 | s | Project assumption |
| Voltage/frequency time constants | 0.050 / 0.050 | s | Project assumption |
| P-f / Q-V droop | 0.50 / 0.050 | Hz/p.u., p.u./p.u. | Derived starter |
| Sync thresholds | 0.05 / 0.10 / 5 | p.u., Hz, deg | Project gate |

See [tuning.md](docs/tuning.md) for every replaceable control setting and
[assumptions.md](requirements/assumptions.md) for its rationale.

## Mandatory validation scenarios

| ID | Scenario | Main executable evidence |
| --- | --- | --- |
| A | Separate grid-following P and Q steps | 2% tracking and current gates |
| B | 0% voltage dip/recovery and frequency event | bounded recovery and valid state |
| C | Grid loss | ordered islanding sequence and open breaker |
| D | Islanded load increase/decrease | load balance and V/f regulation |
| E | Grid return with phase/frequency mismatch | synchronization interlock and closure |
| F | Infeasible P/Q request | current saturation and controlled recovery |
| G | Invalid measurement | fault-safe, recovery, resynchronization |
| H | DC availability and bounded bias | available-power limiting and validity |

The focused `v0.9.0` publication metrics are preserved in
[validation-report.md](validation/validation-report.md); use the root
[validation results](../../docs/validation-results.md) for current release and
commit-specific CI provenance. The historical machine-readable metrics are in
[results.json](validation/results.json). Plots are supplementary evidence; the
acceptance decision comes from `bess_score_scenario.m` and the test suite.

## Source boundary

Directly source-backed concepts include grid-following P/Q operation,
PLL/synchronization context, grid-forming P-frequency and Q-voltage behavior,
and the publication's qualitative case set. The following are not published
fully enough for exact reproduction and are visibly classified as derived or
assumed:

- reduced-order averaged plant and starter ratings;
- complete controller gains and inner-loop equivalent;
- state-transition timers, breaker interlocks, and fault recovery;
- current/DC availability and slew implementations;
- initial conditions, sample time, and solver; and
- normalized numeric acceptance gates other than the retained paper FRT
  statement.

The executable subset implements grid-following, droop-enabled grid support,
and stiff grid-forming behavior. It does not implement the paper's separate
VSG variant: no swing equation, inertia, AVR, or governor is claimed. The
publication's conflicting numeric tables and figure cases are retained as
source evidence but are not presented as reproduced validation cases.

The paper also contains conflicting power values, signs, and units. Those
conflicts are retained in the [source ledger](requirements/source-ledger.csv)
instead of silently selecting a “paper parameter.”

## Requirements and engineering detail

- [Stable requirements](requirements/requirements.md)
- [Machine-readable traceability](requirements/traceability.csv)
- [Source ledger](requirements/source-ledger.csv)
- [Project assumptions](requirements/assumptions.md)
- [Architecture](docs/architecture.md)
- [Equations and reference frames](docs/equations.md)
- [Tuning](docs/tuning.md)
- [Reproduction](docs/reproduction.md)
- [Limitations and safety](docs/limitations.md)
- [Validation report](validation/validation-report.md)

## Requirements

- MATLAB R2026a
- Simulink

No Control System Toolbox, Simscape Electrical, Stateflow, or additional
testing toolbox is required. `matlab.unittest` is part of MATLAB.

## License and citation

Repository code and original diagrams are released under the repository's MIT
License. The publication remains under its own license; no paper figure is
redistributed. Cite the paper using its DOI and cite this repository using
`CITATION.cff`.
