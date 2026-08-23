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
marked `worktree`; CI accepts only its exact 40-character `GITHUB_SHA`.

## Evidence split

The manifest covers the 22 entry points in `run_all_checks(false)`, matching
the general CI job. The
unified BESS job remains separate because it regenerates a focused eight-scenario
model package and 31-result suite. The tracked
[`results.json`](../examples/bess-unified-control/validation/results.json) is a
schema and historical evidence example; exact-commit metrics are regenerated
and uploaded by the separate BESS CI job.

This split prevents a general-suite artifact from claiming that two independent
jobs were one atomic execution. Neither artifact is hardware, safety, physical
cell, or grid-code qualification evidence.
