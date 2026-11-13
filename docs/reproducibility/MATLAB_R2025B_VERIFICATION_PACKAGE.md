# MATLAB R2025b Headless Reproducibility Package

Pinned Candidate Commit: `ef53d735076cf4756c6db394144e59c2c03c5d67` (latest `main`)  
Prior Baseline Commits: `e1aa015b67e3727c9ec91373511ebf6762334810`, `90c83f3654ee6648b31cc3cb9553670455e74c01` (R2025b Update 7 proof)  
Target Issue: [Issue #130: Compatibility check: run the headless suite on MATLAB R2025b](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab/issues/130)  
Repository: `mohammadrezwankhan/matlab-simulink-energy-lab`  
Date: 2026-11-12

---

## 1. Scope & Objective

This reproducibility package provides an authoritative, self-contained guide for independently executing the full headless validation suite of `matlab-simulink-energy-lab` on **MATLAB R2025b** with **Simulink**.

The objective is to establish an **independently executed, community-tested compatibility record** on an external environment without weakening or altering the repository's primary automated MATLAB R2026a baseline.

> [!IMPORTANT]
> Acceptance requires a clean execution log from an independent machine, capturing exact operating system, MATLAB and Simulink versions, and full pass/fail output for all 25 general checks and 31 focused unified-BESS scenario checks.

---

## 2. Environment & Prerequisites

### Required Software
- **MATLAB**: Release R2025b (`25.2.x`) or compatible release.
- **Simulink**: Release 25.2.
- **Operating System**: Linux (GLNXA64, Ubuntu/Debian/RHEL/Arch), Windows (win64, Windows 10/11 / Server), or macOS (maca64 / maci64, Apple Silicon / Intel).

### Dependencies & Toolboxes
- Standalone MATLAB: Runs the 20 Base MATLAB checks.
- Simulink: Required for the 5 native block-diagram checks and the unified BESS controller suite (31 scenarios).
- No third-party or paid proprietary add-ons required. All physical constants, parameters, and lookup tables are self-contained in the repository.

---

## 3. Checkout & Setup Instructions

Clone the repository and check out the exact candidate commit:

```bash
git clone https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab.git
cd matlab-simulink-energy-lab
git checkout ef53d735076cf4756c6db394144e59c2c03c5d67
```

Verify that the working tree is clean and pinned:
```bash
git rev-parse HEAD
# Output must match: ef53d735076cf4756c6db394144e59c2c03c5d67
```

---

## 4. Execution Commands

### A. Full Headless Suite (MATLAB + Simulink)
Execute the catalog checks in batch mode with all scenarios enabled:

```bash
matlab -batch "addpath('examples'); report = run_all_checks(true, true, true); assert(report.all_checks_passed && report.complete_suite)"
```

Or from within an interactive or headless MATLAB session:
```matlab
addpath('examples');
report = run_all_checks(true, true, true);
assert(report.all_checks_passed, 'Some validation checks failed.');
assert(report.complete_suite, 'Validation suite was incomplete.');
```

### B. Base MATLAB Only (Toolbox-Free / No Simulink)
If testing an environment without Simulink:
```bash
matlab -batch "addpath('examples'); run_base_matlab_checks"
```

---

## 5. Test Suite Structure & Expected Results

The test suite executes 26 check files in total isolation:

1. `battery-rc-model/check_battery_rc_model.m` (Base)
2. `battery-simulink-model/check_battery_rc_simulink_model.m` (Simulink)
3. `battery-2rc-model/check_battery_2rc_model.m` (Base)
4. `battery-2rc-model/check_battery_2rc_fit.m` (Base)
5. `battery-2rc-simulink-model/check_battery_2rc_simulink_model.m` (Simulink)
6. `battery-soc-ekf/check_battery_soc_ekf.m` (Base)
7. `battery-soc-ekf/check_battery_soc_ekf_current_bias.m` (Base)
8. `battery-ocv-hysteresis/check_battery_ocv_hysteresis.m` (Base)
9. `battery-soc-hysteresis-ekf/check_battery_soc_hysteresis_ekf.m` (Base)
10. `battery-thermal-model/check_battery_thermal_model.m` (Base)
11. `battery-thermal-model/check_battery_cooling_sensitivity.m` (Base)
12. `battery-module-cooling-network/check_battery_module_cooling_network.m` (Base)
13. `pouch-cell-thermal-gradient/check_pouch_cell_thermal_model.m` (Base)
14. `battery-thermal-simulink-model/check_battery_thermal_simulink_model.m` (Simulink)
15. `converter-average-model/check_converter_average_model.m` (Base)
16. `converter-closed-loop-model/check_closed_loop_converter.m` (Base)
17. `converter-closed-loop-model/check_converter_controller_comparison.m` (Base)
18. `converter-switching-model/check_switching_buck_converter.m` (Base)
19. `converter-switching-closed-loop-model/check_switching_closed_loop_buck.m` (Base)
20. `converter-switching-closed-loop-model/check_switching_closed_loop_buck_temperature_sensitivity.m` (Base)
21. `converter-switching-closed-loop-simulink-model/check_switching_closed_loop_buck_simulink_model.m` (Simulink)
22. `converter-simulink-model/check_average_buck_simulink_model.m` (Simulink)
23. `bess-dc-reserve-model/check_bess_dc_reserve.m` (Base)
24. `bess-dc-reserve-model/check_bess_dc_reserve_envelope.m` (Base)
25. `bess-dc-reserve-model/check_bess_dc_reserve_profile_sensitivity.m` (Base)
26. `bess-unified-control/check_bess_unified_control.m` (Simulink - 31 focused scenario checks)

### Expected Terminal Summary:
```text
All 26 MATLAB and Simulink checks passed.
```
Or for Base MATLAB:
```text
All 20 Base MATLAB checks passed.
```

---

## 6. Community Submission & Evidence Template

To submit an independent run report to [Issue #130](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab/issues/130), copy and populate the template below:

```markdown
### Independent MATLAB R2025b Compatibility Report

- **Reviewer / Submitter**: <Name or GitHub Account>
- **Date**: <YYYY-MM-DD>
- **Tested Commit SHA**: `ef53d735076cf4756c6db394144e59c2c03c5d67`
- **Operating System**: <e.g. Windows 11 Enterprise 24H2 / Ubuntu 24.04 LTS / macOS Sequoia 15.1>
- **Architecture**: <e.g. x86_64 / arm64 / win64 / GLNXA64 / MACA64>
- **MATLAB Version**: `<MATLAB version string from version()>`
- **Simulink Version**: `<Simulink version string from ver('Simulink')>`
- **Command Executed**: `matlab -batch "addpath('examples'); report = run_all_checks(true, true, true); assert(report.all_checks_passed && report.complete_suite)"`

#### Test Outcomes
- **General Checks**: <25/25 passed / X failed>
- **Focused Unified-BESS Checks**: <31/31 passed / X failed>
- **Figure Count**: 0 (Clean headless execution)

#### Execution Log Tail / Summary
```text
<Paste first 20 lines and final 30 lines of execution output>
```

#### Defect / Anomaly Report (if any)
<If any check failed, document the first reproducible failure with exact error identifier and stack trace>
```

---

## 7. Status & Tracking
- **Workstream Status**: `AWAITING INDEPENDENT MATLAB RUN`
- **Maintainer Automation**: Verified on commit `c0a5a2c` (Ubuntu 24 GLNXA64, MATLAB R2025b Update 6, 25 general + 31 BESS passed).
- **Candidate Pinned Baseline**: Commit `ef53d735076cf4756c6db394144e59c2c03c5d67`.
