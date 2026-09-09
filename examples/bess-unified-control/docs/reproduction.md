# Reproduction

## Environment

Verified with MATLAB R2026a and Simulink. No additional toolbox is required.
Use a clean clone to reproduce the published result:

```bash
git clone https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab.git
cd matlab-simulink-energy-lab
matlab -batch "addpath('examples/bess-unified-control'); run('examples/bess-unified-control/check_bess_unified_control.m')"
matlab -batch "addpath('examples'); run_all_checks"
```

## Rebuild the Simulink model

```matlab
addpath('examples/bess-unified-control')
parameters = bess_unified_control_parameters();
scenarios = bess_validation_scenarios(parameters);
modelPath = build_bess_unified_control_model([], scenarios(1), parameters)
```

The returned `.slx` is generated beneath the operating-system temporary
directory unless an output directory is supplied. It is disposable and may be
deleted and regenerated.

## Run one scenario

For an interactive plot:

```matlab
addpath('examples/bess-unified-control')
result = run_bess_unified_control('E');
```

For no-plot numeric scoring:

```matlab
parameters = bess_unified_control_parameters();
scenarios = bess_validation_scenarios(parameters);
result = simulate_bess_unified_control(scenarios(5), parameters);
score = bess_score_scenario(result, parameters);
assert(score.passed)
```

## Regenerate evidence

```matlab
addpath('examples/bess-unified-control')
[gitStatus, sourceCommit] = system('git rev-parse HEAD');
assert(gitStatus == 0)
generate_bess_validation_evidence(strtrim(sourceCommit))
```

This compiles one generated model, runs scenarios A–H through Simulink,
applies numeric gates, writes `validation/results.json`, and exports three
original PNG plots. A full SHA must match a clean checkout before any
commit-bound evidence is written. Passing `"WORKTREE"` instead creates
explicitly unbound local output. The GitHub Actions validation run and release
evidence asset provide authoritative commit-bound provenance for the public
release.

## Determinism

Scenario profiles are fixed arrays with explicit time, solver, sample time,
initial conditions, and fault definitions. The bounded “noise” fault is a
deterministic analytic perturbation, not an unseeded random process. Tests run
every scenario twice, compare the generated Simulink shell with its shared
reviewed MATLAB kernels, rebuild the model in two clean directories, and
compare structural signatures. Separate analytic tests provide independent
equation, sign, limit, synchronization, and anti-windup evidence; wrapper
parity is not presented as an independent controller implementation.
