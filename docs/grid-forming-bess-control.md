<!-- markdownlint-disable MD013 -->

# Grid-Forming BESS Control in MATLAB and Simulink: An Executable Walkthrough

Grid-forming control is easiest to learn when operating modes, transition
guards, signal limits, and validation scenarios are visible together. This
tutorial uses the repository's unified BESS reference to move from
grid-following P/Q control through islanding and back to a guarded grid
reconnection.

> This is an educational reduced-order reference. It is not a qualified plant
> controller, protection system, grid-code certification model, or substitute
> for converter, battery, network, hardware-in-the-loop, or site validation.

## What the runnable model covers

The reference uses a 10 MVA, 690 V line-line, 50 Hz per-unit starter base and
a fixed 5 ms discrete solver. It combines a balanced dq-current/filter-
equivalent plant with a supervisory state machine. The eight explicit states
make the intended operating sequence inspectable:

```text
GRID_FOLLOWING
  -> PREPARE_ISLAND
  -> GRID_FORMING
  -> ISLANDED_SUPPORT
  -> SYNCHRONIZING
  -> PREPARE_RECONNECT
  -> GRID_FOLLOWING

FAULT_SAFE -> RECOVERY -> SYNCHRONIZING
```

The model enforces active and reactive power, available power, DC-voltage,
current, slew, and breaker limits. It rebuilds its disposable Simulink model
from MATLAB source, so the generated `.slx` is never the only source of truth.

## Run one scenario

From the repository root, build the model and run Scenario C, the grid-loss
case:

```matlab
addpath('examples/bess-unified-control')
parameters = init_bess_unified_control();
modelPath = build_bess_unified_control();
result = run_bess_unified_control('C');
```

Scenario C checks the ordered islanding sequence and breaker opening. Explore
the other scenarios after that:

| Scenario | Engineering question |
| --- | --- |
| A | Can connected P and Q references track within their configured gates? |
| B | Does the reference recover from a voltage dip and frequency event? |
| C | Does grid loss produce an ordered islanding transition? |
| D | Can islanded support regulate voltage/frequency across load changes? |
| E | Does the reconnection interlock block unsafe phase/frequency mismatch? |
| F | How does the controller respond to an infeasible P/Q request? |
| G | Does invalid measurement handling reach a safe state and recover? |
| H | Do DC availability and bounded bias gates limit operation as intended? |

Run every scenario without plots with:

```matlab
run('examples/bess-unified-control/check_bess_unified_control.m')
```

The focused check runs the scenarios in both MATLAB and Simulink. The complete
repository runner remains available through `addpath('examples'); run_all_checks`.

## Understand the reconnection guard

The transition supervisor treats breaker closure as an explicit decision, not
a consequence of a mode request. Before reconnection, the model requires valid
measurements and controller readiness, then holds voltage, frequency, and
phase mismatch inside configured bounds. Its starter thresholds are:

| Guard | Configured bound |
| --- | ---: |
| Voltage mismatch | 0.05 p.u. |
| Frequency mismatch | 0.10 Hz |
| Phase mismatch | 5 degrees |

These values are project gates for the educational model, not universal grid
requirements. They belong in a project-specific protection and interconnection
review before any practical use.

## What is source-backed and what is assumed

The example is a transparent engineering translation of the controller
framework discussed in Khan et al.,
[*Design of a Unified Controller Framework for Grid-tied and Grid-forming
Battery Energy Storage System*](https://doi.org/10.1109/IECON49645.2022.9968382).
The repository deliberately distinguishes source-backed concepts from values
that the publication does not provide completely enough to reproduce:

- Grid-following P/Q operation, synchronization context, and grid-forming
  P-frequency/Q-voltage behavior are source-backed concepts.
- The reduced-order plant, gains, timers, interlocks, fault recovery, initial
  conditions, sample time, and normalized acceptance gates are documented
  project assumptions or derived starter values.
- The reference does not claim to reproduce a VSG swing equation, inertia,
  AVR, governor, or a qualified field controller.

This distinction is the key to using the model responsibly: change an
assumption openly, then update the associated check and its evidence.

## Inspect the evidence

- [Unified BESS example README](../examples/bess-unified-control/README.md)
  lists signals, limits, scenarios, requirements, and scope.
- [Validation report](../examples/bess-unified-control/validation/validation-report.md)
  records the accepted scenario evidence.
- [Architecture and equations](../examples/bess-unified-control/docs/architecture.md)
  and [reference frames](../examples/bess-unified-control/docs/equations.md)
  expose the model structure.
- [Assumptions ledger](../examples/bess-unified-control/requirements/assumptions.md)
  records why each replaceable starter value exists.

If this walkthrough helps you evaluate or teach BESS control transitions, star
the [repository](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab)
to help other MATLAB and Simulink learners find it.
