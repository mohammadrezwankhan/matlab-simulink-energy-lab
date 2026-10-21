<!-- markdownlint-disable MD024 -->

# Changelog

Notable changes to MATLAB Simulink Energy Lab are recorded here. The project
uses semantic versioning while its public model and validation interfaces are
still evolving.

## Unreleased

### Fixed

- Reject nonfinite or nonnumeric second inputs in the standalone BESS Clarke
  and Park transforms, matching the validation applied to their other inputs.

## 1.12.0 — Proposed, unreleased

The metadata in this candidate targets 1.12.0. No publication date or release
tag is asserted. The candidate requires the exact-commit native verification
described in [release readiness](docs/release-readiness.md) before publication.
Historical results below remain bound to their recorded versions and commits.

### Added

- A root MATLAB Build Tool pipeline with `check`, `test`, `demos`, `simulink`,
  and `archive` tasks. `matlab -batch "buildtool check test archive"` collects
  all required phases before it can archive a clean, verified commit.
- Per-file Code Analyzer diagnostics, complexity output, dependency-product
  records, execution telemetry, and generated-model solver/block diagnostics.
  Deterministic JSON/Markdown result reports are separate from elapsed time
  and console telemetry.
- Release regression coverage for runner dispatch, capability boundaries,
  provenance, workspace preservation, and failure cleanup, plus targeted
  numerical and BESS limit/lifecycle cases. These additions require native
  MATLAB execution; static review does not establish their pass status.
- Explicit binary attributes for MATLAB/Simulink artifacts and exclusions
  for generated caches, code-generation outputs, and native build products.

### Changed

- **Script workspace behavior change:** documented `run('.../run_*.m')` and
  `run('.../check_*.m')` script entry points execute in local workspaces.
  They preserve caller variables, MATLAB path, current folder, RNG state,
  and existing figures. Plotting demos still create their own result figures.
  Code that relied on residual script variables must call the public
  simulator/estimator function and capture its returned result explicitly.
- Root and legacy `run_all_checks` entry points delegate to one catalog
  implementation. A MATLAB-only default run selects the 20-check Base profile
  and explicitly reports an incomplete full suite; `run_all_checks(true, true,
  true)` requires Simulink and the complete catalog.
- Prescribed thermal current profiles that would leave the feasible SOC
  interval now raise `BatteryThermal:SOCProfile` before integration. This
  hardens the documented clipping limitation; feasible default trajectories
  and the existing electrical/thermal equations remain unchanged.
- Publication metadata is staged consistently at 1.12.0 in `CITATION.cff`,
  `codemeta.json`, and `project-metadata.yml`; publication dates remain absent
  until an actual release. No existing numerical snapshot is relabeled as
  candidate evidence.

### Fixed

- Project tolerated covariance roundoff to a valid symmetric positive-
  semidefinite input in both SOC EKFs and reject invalid innovation variance.
- Reject complex or incorrectly shaped physical inputs, retain accepted
  uniform-grid endpoints, and normalize accepted OCV/entropic-table endpoints.
- Align DC-reserve events to accepted decimal breakpoints and use a stable
  current root; reject response-summary windows without the required samples.
- Project the final BESS active command into a contracting availability bound
  after normal slew limiting; recovery continues from the projected command.
  Existing default numerical benchmarks remain pinned.
- Preserve pre-existing generated-model files through failed rebuilds and
  close only owned models; preserve the caller figure in the BESS plotting
  runner and bind BESS evidence provenance to the source repository.
- Replaced stale active-suite counts and destructive-workspace instructions
  in current guides; historical 31-result BESS evidence is retained as history.
- Corrected metadata-validation and CI coverage gaps for release inputs.
- Capture cleanup state safely in native demo and audit callbacks, retain
  fallback guards through restoration, and test failures before and after
  model-handle capture without disturbing caller-owned figures.
- Include every discovered check in the catalog contract and exercise source
  archival in release CI. Static dependency reports retain uncertain product
  matches separately from confirmed undeclared requirements.

### Release gates still required

- Execute every required phase on MATLAB R2026a with Simulink; inspect actual
  Code Analyzer, dependency, numerical, lifecycle, solver and model results.
- Regenerate commit-bound manifests and selected result images from the
  verified source. `assets/social-preview.png` has been regenerated and reviewed
  with MATLAB R2026a for the 1.12.0 candidate and 26-check catalog.
- Commit any final metadata date change, rerun the release gate on that exact
  clean commit, create and check the archive/checksum, then create a local tag.
  Publication remains a separate maintainer action.

## 0.11.0 - 2026-09-22

### Fixed

- Propagate supplied BESS parameters into the generated Simulink runtime,
  including temporary solver-step overrides. Older generated models without
  the parameter contract require regeneration.
- Preserve caller-owned loaded models, workspace data, dirty state, MATLAB
  path, and file-generation settings during BESS simulation and failures.
- Align BESS outputs with causal sample boundaries and reject invalid logged
  time grids rather than silently mislabel results.

### Added

- A two-command first battery result with expected output and workspace-safety
  guidance, plus an independent Base MATLAB CI job that requires Simulink to
  be absent before running the 20-check profile.
- A nine-case prescribed BESS DC-reserve dynamic-profile sensitivity spanning
  three fixed requests and three reserve floors, with within-profile ordering,
  charge/discharge partitions, exact zero identity, independent state-energy
  closure, doubled-grid convergence, and explicit non-envelope boundaries.
- A one-command 20-check Base MATLAB validation profile with dependency-aware
  catalog filtering, deterministic order, machine-readable report metadata,
  invalid-flag rejection, and an explicit incomplete-suite boundary.
- A five-case prescribed current-sensor-bias sensitivity for the battery SOC
  EKF, with fixed-truth isolation, exact zero-bias parity, SOC/voltage/
  innovation metrics, covariance checks, irregular timestamps, and explicit
  non-rejection boundaries.
- A source-backed fixed-junction-temperature sensitivity for the switched
  closed-loop buck, interpolating published 25-to-175 degC ON-resistance and
  switching-energy anchors with exact baseline parity, energy, convergence,
  determinism, and range checks while explicitly deferring invented thermal
  dynamics.
- A deterministic machine-readable validation manifest generated by CI for
  the exact commit under test, with ordered check status, environment,
  related evidence, and explicit qualification boundaries.
- An illustrative BESS DC-reserve constant-request sensitivity map spanning
  three reserve floors and six requested-power levels, with actual curtailment
  time, saturation evidence, full-case energy checks, and doubled-grid tests.
- A generated fixed-step native Simulink companion for the switching
  closed-loop buck, with transparent sampled control, anti-windup, integer PWM,
  exact affine plant branches, topology checks, and exact MATLAB parity.
- A question-led model selection guide spanning battery electrical, SOC
  estimation, thermal, converter, and BESS workflows, with focused MATLAB
  Online launch links for six Base MATLAB examples.
- A hysteresis-aware three-state battery SOC EKF benchmark that compares
  against a two-state no-hysteresis baseline on a deterministic reversal-rich
  profile, with covariance, reduction, irregular-time, and malformed-input
  checks.
- A switched closed-loop buck-converter benchmark with exact event-aligned
  affine propagation, a bounded period-sampled voltage/current controller,
  freewheel-diode loss, reference/load steps, energy accounting, fixed-duty
  parity, and doubled-grid convergence checks. Its loss evidence now includes
  nominal SiC MOSFET ON resistance and datasheet-reference turn-on/off energy,
  with zero-loss parity, frequency sensitivity, and explicit non-hardware
  validation boundaries.
- A DC-side BESS reserve benchmark with affine OCV-SOC battery energy,
  charge/discharge current limits, SOC-dependent availability, finite DC-link
  buffering, requested-versus-delivered power, curtailment, exact energy
  accounting, and doubled-grid convergence checks.

### Changed

- Labeled older hosted validation results as historical reference evidence,
  completed the 26-entry validation command block, and expanded Markdown
  maintenance to all tracked Markdown files and relevant main-branch pushes.
- Updated the repository validation index and expected output for 26 MATLAB and
  Simulink check entry points.
- Aligned reference and load events by integer grid index in the switched
  closed-loop buck, eliminating floating-point ambiguity at exact step times.

## 0.10.0 - 2026-08-19

### Added

- A source-linked two-RC battery parameter-identification tutorial that
  distinguishes calibration from independent held-out pulse validation and
  documents the synthetic benchmark boundary.
- A grid-forming BESS control walkthrough covering grid-following operation,
  grid loss, islanded support, synchronization, reconnection, limits, fault
  behavior, and recovery, with direct links to executable evidence.

### Changed

- Refined repository discovery metadata and the README documentation map so
  MATLAB/Simulink users can reach the validated battery and BESS workflows
  from the project landing page.

## 0.9.0 - 2026-07-28

### Added

- A reproducibly generated unified grid-tied/grid-forming BESS control
  reference with an explicit eight-state supervisor, averaged three-phase
  plant, P/Q and V/f control, synchronization interlocks, current/DC limits,
  measurement-fault recovery, and scenarios A-H.
- A 31-result focused MATLAB/Simulink suite covering analytic transforms and
  power, dq/filter dynamics, voltage-support sign, forming anti-windup,
  limits, model regeneration, deterministic scenario metrics, Simulink
  wrapper parity, and requirement traceability.
- Source ledger, stable requirements, machine-readable traceability, project
  assumptions, architecture/equation/tuning/reproduction/limitation guides,
  JSON evidence, and original validation diagrams and plots.

## 0.8.0 - 2026-07-25

### Added

- A toolbox-free one-state battery OCV hysteresis model with exact
  throughput-domain propagation, zero-current memory, a reversal minor-loop
  benchmark, same-SOC voltage-gap validation, and explicit limiting cases.

## 0.7.0 - 2026-07-24

### Added

- A reusable controller-comparison metrics table with deterministic row order,
  explicit units, export-ready columns, and no-plot regression coverage.
- A toolbox-free two-RC parameter-identification workflow with positive
  resistance constraints, ordered time constants, deterministic grid
  refinement, and an independent held-out pulse-profile benchmark.

## 0.6.0 - 2026-07-23

### Added

- A toolbox-free one-dimensional pouch-cell finite-volume model with
  asymmetric face cooling, resolved through-thickness temperature, hot-spot
  tracking, node and whole-cell energy balances, a continuous steady-state
  reference, and spatial grid-convergence validation.

## 0.5.0 - 2026-07-23

### Added

- A toolbox-free six-cell battery module thermal network with serial coolant
  warming, nearest-neighbor conduction, nonuniform heat generation, flow-rate
  sensitivity, and local, cell, and module energy-balance checks.

## 0.4.0 - 2026-07-23

### Added

- A toolbox-free two-state extended Kalman filter that estimates battery SOC
  and first-order polarization from measured current and terminal voltage.
- A deterministic one-hour benchmark with nonlinear OCV lookup, noisy voltage,
  Joseph-form covariance validation, irregular timestamps, and explicit
  convergence metrics.

## 0.3.0 - 2026-07-23

### Added

- Exact first- and second-order battery equivalent-circuit simulators with a
  configurable OCV-SOC table, irregular time intervals, SOC-boundary current
  limiting, and duty-cycle accounting.
- Native Simulink references for the first-order, second-order, and coupled
  electro-thermal battery models, each checked against its MATLAB reference.
- Reversible entropic heat, temperature-dependent resistance, continuous
  thermal-limit exposure metrics, and a cooling-conductance sensitivity study.
- Ideal switching, closed-loop averaged, controller-comparison, and native
  Simulink buck-converter references.
- MATLAB R2026a validation in GitHub Actions and a single `run_all_checks`
  entry point for all twelve no-plot checks.
- Machine-readable software citation metadata in `CITATION.cff`.

### Changed

- Consolidated plotting and validation scripts around reusable simulators and
  documented engineering assumptions, units, limitations, and expected output.
- Expanded contributor guidance with scoped acceptance criteria and an explicit
  genuine-attribution policy.

### Fixed

- Isolated check-script variable cleanup so the complete validation suite runs
  instead of terminating after its first script.

## 0.2.0 - 2026-07-19

- Added the first temperature-aware battery model with irreversible electrical
  heat, lumped cooling, temperature-dependent resistance, and energy-balance
  validation.

## 0.1.0 - 2026-07-13

- Published the first validated battery RC and averaged-converter examples,
  engineering review guidance, and no-plot checks.
