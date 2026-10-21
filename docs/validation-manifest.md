# Machine-Readable Validation Manifest

The [general MATLAB validation job](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab/actions/workflows/matlab-validation.yml)
emits `validation-summary.json` as a GitHub Actions artifact named
`validation-summary-<commit>`. The JSON records the
exact commit, MATLAB environment, ordered check paths, pass/fail status, error
details for failed checks, related evidence, and the boundaries on what the
checks establish. The artifact upload runs even after a check failure so the
machine-readable failure evidence remains available while the job stays red.

The file is generated in CI instead of being committed. A committed file that
contains its own commit SHA would necessarily become stale when that file is
added. Per-run generation keeps the provenance exact.

## Generate locally

From the repository root, run:

```matlab
addpath('examples')
generate_validation_manifest("WORKTREE")
```

The output is `validation-artifacts/validation-summary.json`. Local output is
marked `worktree`; a commit-bound run accepts only the exact 40-character SHA
of this repository's clean checkout, independently of the caller's current
directory. A different commit or uncommitted source must not claim exact-commit
provenance.

The manifest records the selected `profile`, `required_products`,
`complete_suite`, and `excluded_checks` from the runner. A MATLAB-only result
must declare MATLAB alone and an incomplete suite. `status="passed"` means
that its selected checks passed; always inspect `complete_suite` and the
profile before treating the evidence as repository-wide.

Users without Simulink can run `run_base_matlab_checks` for the deterministic
20-check toolbox-free subset. The catalog contract verifies that this profile
preserves general-suite order while excluding all five native Simulink checks
and the focused unified-BESS entry point. It is not the commit-bound general CI
manifest and must not be presented as complete repository validation.

## Evidence split

The workflow also defines a separate **Validate Base MATLAB without Simulink**
job. It installs MATLAB R2026a without requesting Simulink, asserts that
Simulink is absent, and runs the 20-check Base profile. A green result for that
job supports the toolbox-free execution path for its checked commit; it does
not replace the two MATLAB/Simulink jobs or establish physical validation.
Check the job status before claiming that the profile passed in CI.
The task is defined in `buildfile.m` and invoked as `buildtool base`; it
deliberately fails if Simulink is installed. For an ordinary local run on an
installation that includes Simulink, use `run_base_matlab_checks` instead.

With Simulink available, the general manifest covers the 25 entry points in
`run_all_checks(false)`, matching the general CI job. The unified BESS job
remains separate because it regenerates a focused eight-scenario model
package and its current focused tests. Inherited run 39592416496 reports 92
focused results for `125b0a818c3c42292cfebc7c5dcb6b50689a70eb`; use the actual
candidate output for later test counts and status. The tracked
[`results.json`](../examples/bess-unified-control/validation/results.json) is a
schema and historical evidence example; exact-commit metrics are regenerated
and uploaded by the separate BESS CI job.

This split prevents a general-suite artifact from claiming that two independent
jobs were one atomic execution. Neither artifact is hardware, safety, physical
cell, or grid-code qualification evidence.

## Full release audit

The 1.12.0 release adds the root command
`matlab -batch "buildtool check test archive"`. Its archive task also runs
`demos` and `simulink` and requires all four reports to be complete and passed
for the exact current clean commit. This is a stricter gate than a passing
general manifest or a passing Base subset.

Deterministic `validation-artifacts/audit-<phase>.json` and Markdown reports
are separate from `audit-<phase>-telemetry.json`, which contains volatile
execution timing and console output. Release assets contain the actual
commit-bound reports; rerun the gate to verify a different revision. See
[release readiness](release-readiness.md) for the evidence states, migration,
metadata dates, and local tag checklist.
