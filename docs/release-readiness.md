# 1.12.0 release readiness and migration

**Status: proposed and unreleased.** The tracked version metadata targets
1.12.0. MATLAB/Simulink verification is recorded per exact source commit in
`validation-artifacts/`. Publication dates and the release tag remain pending.
A source audit or patch package alone does not establish a release pass.

## Evidence states

| Source | Evidence | Permitted interpretation |
| --- | --- | --- |
| `125b0a818c3c42292cfebc7c5dcb6b50689a70eb` | [Hosted run 39592416496](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab/actions/runs/39592416496): 20 Base checks, 25 general checks and manifest contract, 92 focused BESS results | Observed native results for that source and environment |
| `a8ea7b9093b596bb169bb31841b77cb4fe88ccb9` | Audited baseline; only Markdown differs from the hosted run's source | Inherited code evidence, not a new native execution |
| 1.12.0 candidate | Exact-commit `audit-check`, `audit-test`, `audit-demos`, and `audit-simulink` reports from the release gate | Accept only reports with `passed=true`, `complete=true`, and `source_state="clean"` matching the source commit |
| Historical 31-result BESS JSON/report and older expected-output tables | Their original commits, environments, and dates | Preserve as historical records; never relabel as current execution |

The catalog has 20 Base MATLAB checks, five additional general Simulink
checks, and one focused BESS entry point. Focused tests expand within that
entry point; obtain their current count from actual test results. Entry-point
counts, focused-test counts, scenarios, and independent experiments are
different measures.

## Commands and capability boundaries

Run from the repository root on MATLAB R2026a:

```bash
matlab -batch "buildtool check test"
```

`check` records Code Analyzer diagnostics and complexity output for every
tracked MATLAB source, plus required-file/product evidence. `test` runs the
available catalog, manifest contract, and infrastructure regression tests.
On MATLAB-only installations, required Simulink work is explicitly unavailable
and the report is incomplete. A selected-profile pass is not a release pass.

For the strict complete catalog without packaging:

```matlab
report = run_all_checks(true, true, true);
assert(report.all_checks_passed && report.complete_suite)
```

The no-argument `run_all_checks` detects Simulink and returns the selected
`profile`, `complete_suite`, and `excluded_checks`. The existing
`run_base_matlab_checks` remains the explicit 20-check subset. `buildtool base`
is the CI proof that intentionally requires Simulink to be absent.

After committing all candidate source changes, run the full release gate:

```bash
matlab -batch "buildtool check test archive"
```

`archive` also depends on `demos` and `simulink`. The four required reports
(`check`, `test`, `demos`, `simulink`) must each have `passed=true`,
`complete=true`, the exact current `source_commit`, and `source_state="clean"`.
Missing Simulink, skipped required work, stale evidence, or a dirty checkout
blocks archival. The command creates a source ZIP locally; it does not create
a tag or publish a release.

Reports are written to `validation-artifacts/audit-<phase>.json` and Markdown.
Their `audit-<phase>-telemetry.json` companions contain volatile timing and
console data. Keep the deterministic decision evidence separate from telemetry
when comparing runs. Preserve both for review.

Native model diagnostics must establish the actual solver, fixed-step,
sample-time, algebraic-loop, lifecycle, and parity results. Optional Model
Advisor work is separate and may require Simulink Check; it is not an implicit
core dependency or an audit already performed.

## Script workspace migration

`run('.../run_*.m')` and `run('.../check_*.m')` entry points remain available.
Their implementation work now runs in local functions, preserving caller
variables, path, current folder, RNG, and existing figures. Demos may create
new figures. They do not leave local `result`, `parameters`, or intermediate
arrays in the base workspace.

Call a public simulator/estimator explicitly when numerical data are needed:

```matlab
originalPath = path;
pathGuard = onCleanup(@() path(originalPath));
addpath('examples/battery-rc-model')
profile = readtable('examples/battery-rc-model/data/pulse_current_profile.csv');
parameters = battery_rc_default_parameters();
result = simulate_battery_rc_model(profile, parameters, 1);
clear pathGuard
```

This changes the script interface for consumers that
depended on script workspace residue. Public function outputs are the supported
data interface. Existing synthetic perturbations are prescribed deterministic
signals; no random-number seeding is needed for those signals.

## Publication and citation gates

1. Apply and review all candidate patches, then run targeted checks. Resolve
   every native failure without changing pinned defaults merely to obtain a
   pass. Record a mathematical residual justification for any necessary
   numerical reference change.
2. Keep `CITATION.cff`, `codemeta.json`, and `project-metadata.yml` at the same
   version. For a candidate, omit both `date-released` and `datePublished`.
   Cite the actual commit used. The metadata does not establish a published
   1.12.0 release or a DOI.
3. Review CFF/CodeMeta and local/external documentation links. Regenerate
   commit-bound validation manifests and result images on native MATLAB.
   `assets/social-preview.png` was regenerated and reviewed with MATLAB R2026a
   for the 1.12.0 candidate and 26-check catalog. Repeat generation and review
   when the source inputs change. Preserve historical BESS evidence separately
   when producing current evidence.
4. When publication is ready, insert the same actual publication date in CFF
   and CodeMeta and finalize the changelog. Commit these source changes, then
   rerun `buildtool check test archive` on that exact clean commit. Check the
   source ZIP and independently record its SHA-256 checksum.
5. Only after those gates pass, record the verified full commit SHA and create
   an annotated local tag against that commit. The commands below are a
   maintainer checklist, not actions already performed:

```bash
git status --short
git rev-parse HEAD
git tag -a v1.12.0 VERIFIED_FULL_COMMIT_SHA -m "Release v1.12.0"
git show --no-patch v1.12.0
```

Replace `VERIFIED_FULL_COMMIT_SHA` with the exact clean commit that passed all
four phases. Do not move an existing tag. Remote publication, release-asset
upload, and repository-setting updates remain separate maintainer actions.
Confirm published tag, checksums, hosted evidence, and citation metadata after
publication before advertising 1.12.0 as released.

### Static dependency ambiguity

The native dependency report keeps the complete
[`requiredFilesAndProducts`](https://www.mathworks.com/help/matlab/ref/matlab.codetools.requiredfilesandproducts.html)
result, including its `Certain` flags. Confirmed undeclared products fail the
check. Possible undeclared products remain visible in
`possible_undeclared_products`: on a fully installed R2026a system,
`load_system`, `save_system`, and `close_system` also suggest overloaded methods
from HDL Verifier, Simulink Real-Time, and Stateflow. Those suggestions do not
establish runtime requirements. The independent MATLAB-only job and the
MATLAB-plus-Simulink release job remain required product-isolation evidence.
The audit does not interpret a clean static report as proof of a minimal runtime.

Cleanup callbacks capture their inputs and use
[`onCleanup.cancel`](https://www.mathworks.com/help/matlab/ref/oncleanup.cancel.html)
after success, which is available from R2025a. R2026a remains the maintained
verification target.
