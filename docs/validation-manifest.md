# Machine-Readable Validation Manifest

The [general MATLAB validation job](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab/actions/workflows/matlab-validation.yml)
emits `validation-summary.json` as a GitHub Actions artifact named
`validation-summary-<commit>`. The JSON records the
exact commit, MATLAB environment, ordered check paths, pass status, related
evidence, and the boundaries on what the checks establish.

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
marked `worktree`; CI accepts only its exact 40-character `GITHUB_SHA`.

## Evidence split

The manifest covers `run_all_checks(false)`, matching the general CI job. The
unified BESS job remains separate because it regenerates a focused eight-scenario
model package and 31-result suite. The tracked
[`results.json`](../examples/bess-unified-control/validation/results.json) is a
schema and historical evidence example; exact-commit metrics are regenerated
and uploaded by the separate BESS CI job.

This split prevents a general-suite artifact from claiming that two independent
jobs were one atomic execution. Neither artifact is hardware, safety, physical
cell, or grid-code qualification evidence.
