# Unified BESS Control Requirements

## Status and scope

This example is a transparent engineering translation of the unified BESS
controller framework described by Khan et al. It is not a numerically exact
paper reproduction. The publication supplies operating concepts, controller
families, and qualitative case results, but it does not publish every equation,
gain, plant parameter, transition rule, or numerical acceptance threshold
needed for a reproducible executable model.

Source-backed behavior is separated from `PROJECT_ASSUMPTION` extensions in
the source ledger and traceability matrix. In particular, the publication
identifies planned and unplanned islanding and main-grid reconnection as future
work. Those transitions, their breaker interlocks, and their recovery behavior
are project-defined extensions.

## Stable requirements

### Operating modes

- `BESS-MODE-001`: When a valid grid is connected, the controller shall operate
  as a grid-following current-source equivalent and track active- and
  reactive-power references.
- `BESS-MODE-002`: When operating without a grid reference, the controller
  shall establish voltage and frequency as a grid-forming source.
- `BESS-MODE-003`: Following detected grid loss, the supervisor shall open the
  breaker and transition from grid-following to grid-forming operation through
  explicit preparation states.
- `BESS-MODE-004`: In islanded support, the controller shall supply a local
  three-phase load within configured current, power, voltage, frequency, and
  DC-side limits.
- `BESS-MODE-005`: When the grid returns, the controller shall synchronize the
  islanded PCC voltage, frequency, and phase before permitting reconnection.
- `BESS-MODE-006`: Following a valid synchronization hold, the controller shall
  close the breaker and transfer to grid-following operation without violating
  the configured transition envelope.
- `BESS-MODE-007`: Invalid measurements, impossible commands, or unavailable
  DC power shall lead to deterministic fault-safe or recovery behavior.

### Interfaces

- `BESS-IF-001`: Voltage reference and measurement interfaces shall declare
  units, nominal value, valid range, and sign convention.
- `BESS-IF-002`: Frequency reference and measurement interfaces shall declare
  units, nominal value, valid range, and sign convention.
- `BESS-IF-003`: Active- and reactive-power references and measurements shall
  declare units, bases, valid ranges, and the positive-injection convention.
- `BESS-IF-004`: Current, apparent-power, active-power, reactive-power,
  voltage, frequency, and DC-availability limits shall be explicit.
- `BESS-IF-005`: Grid-breaker and operating-mode requests shall be explicit
  inputs or outputs of the supervisory interface.
- `BESS-IF-006`: Grid-present, synchronization-ready, controller-ready,
  saturation, measurement-valid, and fault status shall be observable.
- `BESS-IF-007`: Reference frames, per-unit bases, sample times, solver,
  initial conditions, and valid ranges shall be documented and executable.

### Plant and measurements

- `BESS-PLANT-001`: The validation plant shall be a parameterized,
  deterministic, averaged three-phase converter reference with explicit
  reduced-order dynamics.
- `BESS-PLANT-002`: The model shall include a replaceable DC availability
  representation and shall enforce available active power.
- `BESS-PLANT-003`: The model shall expose a PCC, grid equivalent, controllable
  breaker, and local active/reactive load.
- `BESS-PLANT-004`: The model shall produce voltage, current, active power,
  reactive power, frequency, phase, breaker, and limit measurements.

### Unified controller

- `BESS-CTRL-001`: Common measurement conditioning shall include finite/stale
  checks and executable Clarke and Park transformations.
- `BESS-CTRL-002`: Grid-following operation shall include grid synchronization
  and active/reactive power regulation.
- `BESS-CTRL-003`: Grid-forming operation shall include source-backed
  real-power/frequency and reactive-power/voltage relationships, with
  project-defined restoration dynamics where the source is silent.
- `BESS-CTRL-004`: The averaged converter dynamics shall expose bounded inner
  regulation or an explicitly documented reduced-order equivalent.
- `BESS-CTRL-005`: Current/power limiting, command slew limiting, and
  anti-windup behavior shall prevent unbounded controller state.
- `BESS-CTRL-006`: The supervisor shall expose the states
  `GRID_FOLLOWING`, `PREPARE_ISLAND`, `GRID_FORMING`,
  `ISLANDED_SUPPORT`, `SYNCHRONIZING`, `PREPARE_RECONNECT`, `RECOVERY`,
  and `FAULT_SAFE`.
- `BESS-CTRL-007`: Breaker closure shall be impossible unless voltage mismatch
  is at most 5%, frequency mismatch is at most 0.1 Hz, phase mismatch is at
  most 5 degrees, and all validity and readiness flags are true.
- `BESS-CTRL-008`: Invalid or nonfinite input shall not propagate nonfinite
  plant outputs or cause unintended breaker closure.

### Mandatory scenarios

- `BESS-SCEN-001`: Grid-following baseline with separate active- and
  reactive-power reference steps.
- `BESS-SCEN-002`: Grid-voltage and grid-frequency disturbances with bounded
  response and recovery.
- `BESS-SCEN-003`: Grid loss and ordered transition to grid-forming islanded
  support.
- `BESS-SCEN-004`: Islanded load increase and decrease with bounded
  voltage/frequency response and recovery.
- `BESS-SCEN-005`: Grid return with initial voltage, frequency, or phase
  mismatch; interlocked synchronization and reconnection.
- `BESS-SCEN-006`: Infeasible active/reactive commands; current/power
  saturation, anti-windup, finite response, and recovery.
- `BESS-SCEN-007`: Invalid or stale measurement; deterministic safe state,
  status reporting, and recovery after the fault clears.
- `BESS-SCEN-008`: Zero and maximum references, initial phase offset, DC
  availability boundary, and invalid parameter rejection.

### Evidence and reproducibility

- `BESS-PROV-001`: Every material equation, parameter, scenario, and
  acceptance criterion shall be traceable as `DIRECT_SOURCE`, `DERIVED`, or
  `PROJECT_ASSUMPTION`; unresolved paper inconsistencies shall remain visible.
- `BESS-EVID-001`: A clean checkout shall regenerate the `.slx` model from
  readable MATLAB source without a manual GUI step.
- `BESS-EVID-002`: The generated model shall compile and simulate
  non-interactively with MATLAB R2026a and Simulink.
- `BESS-EVID-003`: Every mandatory scenario shall have executable numeric
  assertions; plots alone are not acceptance evidence.
- `BESS-EVID-004`: Important transforms, power equations, droop relationships,
  limiters, synchronization metrics, and steady-state balances shall have
  independent analytic checks.
- `BESS-EVID-005`: Every mandatory requirement shall map to implementation and
  at least one automated test in `traceability.csv`.
- `BESS-EVID-006`: Validation evidence shall record commands, release,
  dependencies, warnings, scenario metrics, and the validated commit SHA.
- `BESS-EVID-007`: Repeated clean runs shall produce equivalent pass/fail
  results and metrics within documented numerical tolerance.

## Project acceptance gates

The paper's reported qualitative pass results and 150 ms voltage-recovery
statement are retained as source facts. The following gates are
`PROJECT_ASSUMPTION` criteria used to make the executable translation
reviewable:

- no simulation error, unresolved model reference, `NaN`, `Inf`, or unintended
  complex result;
- steady grid-following P and Q error no greater than 2% of rated value;
- steady grid-forming voltage error no greater than 2% of nominal;
- steady grid-forming frequency error no greater than 0.1% of nominal;
- normal transition voltage within 0.85 to 1.15 p.u.;
- normal transition frequency within 98% to 102% of nominal;
- current no greater than 101% of the configured hard current limit;
- breaker synchronization thresholds stated in `BESS-CTRL-007`;
- documented settling within each scenario's simulation window; and
- deterministic rerun equivalence within the recorded metric tolerances.

These gates are project acceptance criteria, not claims about IEEE paper
performance.

## Publication discrepancies retained

The authorized paper contains conflicts that this example does not silently
resolve:

- Figures 3 to 5 show 8 MW and 2 Mvar cases, whereas Tables I and II print
  8 MW with positive or negative 4 MVar cases.
- The charge and discharge rows both print `P_ref = 10` and do not define the
  sign convention; Table II also repeats the word "Charging".
- Some table headers say `Var` while the narrative and figures use Mvar.
- Tables III and IV contain apparent unit/scale typos such as `8e6 MVar` and
  `8e6 MW`, plus 8 MW versus 10 MW mixed-load narrative differences.

The executable model uses the documented positive-injection convention and
normalized scenarios. It preserves the reported variants in the source ledger
and never claims those starter signs or values were uniquely determined by the
paper.
