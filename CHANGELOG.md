# Changelog

Notable changes to MATLAB Simulink Energy Lab are recorded here. The project
uses semantic versioning while its public model and validation interfaces are
still evolving.

## Unreleased

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
