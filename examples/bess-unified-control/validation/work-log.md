# Unified BESS Control Work Log

## 2026-07-28 — reconnaissance and rollback checkpoint

- Model repository:
  `https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab`
- Isolated worktree: feature worktree created from `origin/main` (local
  machine path intentionally omitted).
- Feature branch: `codex/feat/unified-bess-control`
- Rollback checkpoint and initial HEAD:
  `b639d7cb673b1c44c87d1bec5b027c71ee74279d` (`v0.8.0`)
- Existing unrelated checkout left unchanged on
  `codex/add-simulink-readme-preview`.
- GitHub authentication succeeded for `mohammadrezwankhan`; repository
  permissions include admin and push.
- MATLAB:
  `26.1.0.3312084 (R2026a) Update 4`
- Simulink license probe: `license('test', 'Simulink') == 1`
- Baseline command:

  ```powershell
  matlab -batch "addpath('examples'); run_all_checks"
  ```

- Baseline result: all 17 MATLAB and Simulink checks passed; process exit 0.
- Website rollback checkpoint:
  `5b0b85a5daf9f890e5c64d6b3e6267883f8c956b`
- Website baseline result: Scholar parser, IndexNow, static validation, source
  link integrity, link-validator tests, Pages build, deploy-artifact
  validation, and deploy link integrity all passed; process exit 0.
- Public coordination issue:
  `https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab/issues/114`

## Tooling disposition

The first baseline attempt through the MATLAB desktop bridge failed before a
test result with:

```text
failed to send request: Post "https://localhost:31516/messageservice/json/secure":
read tcp 127.0.0.1:23240->127.0.0.1:31516: wsarecv:
An existing connection was forcibly closed by the remote host.
```

The required non-interactive `matlab -batch` path was then used successfully.
This bridge failure is not recorded as a model failure.

The optional Simulink agent-library prerequisite files were absent:

- `.satk/reuse-libraries.json`
- `.satk/block-policy.json`
- `.satk/library-kg/index.md`

The referenced `library.LibraryConfig.save` API was also unavailable in the
installed MATLAB path. No `.satk` file was fabricated. The implementation
therefore follows the repository's existing, user-required idempotent MATLAB
builder convention using `new_system`, `add_block`, `add_line`, `set_param`,
and `save_system`.

## Source-review boundary

The publisher DOI, the CC BY 4.0 Zenodo author deposit, the public BESS
specification page, the public research summary, and repository standards were
reviewed. No paywall was bypassed and no paper figure will be copied.

The publication explicitly states:

- grid-following uses PLL/current regulation and follows P/Q references;
- grid-forming uses voltage-source behavior with P-frequency and Q-voltage
  relationships;
- the reported cases cover no-load, active, reactive, and combined loads;
- the BESS plant is an ideal power source and omits converter-grid dynamics;
  and
- planned/unplanned islanding and main-grid reconnection are future work.

Accordingly, the executable plant and transition/fault supervisor are labeled
project assumptions and extensions.

## Implementation and verification checkpoint

- Requirements and source ledger: complete; stable IDs and source/assumption
  classifications recorded.
- MATLAB reference kernels: complete; deterministic controller, plant,
  transforms, limiter, synchronization, scenarios, and scorer implemented.
- Programmatic Simulink builder: complete; generated model compiles and runs.
- Automated scenario verification: 31 focused test results pass after model
  regeneration, determinism, analytic, traceability, and A-H parity checks.
- Validation artifacts: generated JSON and three original PNG plots; final
  commit-bound evidence will be regenerated for the public release.
- Publication and deployment: pending GitHub CI/release, then website update.

## Failure and repair record

- No implementation acceptance threshold has been changed.
- The first generated model used an Interpreted MATLAB Function library path
  removed from R2026a. The builder was repaired to discover and use the
  supported MATLAB Function block.
- The first scenario profile omitted its explicit time field from the signal
  payload. It was repaired to pass the full 16-field profile in a timeseries.
- Zero-order-held profile lookup selected a prior unwrapped phase sample at a
  few floating-point boundaries. Enabling interpolation produced phase parity
  within 7e-13 without changing acceptance gates.
- Visual review of Scenario E exposed a one-sample timestamp mismatch in the
  connected-state phase-error observable. The grid phase is now aligned to the
  closed-breaker measurement timestamp, and the scenario scorer asserts that
  connected V/f/phase mismatch observables remain inside all sync thresholds.
- Initial unit-test calls used incorrect utility signatures; the tests were
  corrected to the documented three-phase and four-output interfaces.
- Independent review blocked release on nonfinite fault observables, the
  reactive-support plant sign, scalar P/Q plant states, incomplete parameter
  validation, untested forming anti-windup, VSG/source-case overclaims, and
  worktree evidence marked complete. The repair replaces fault `Inf` values
  with finite invalid sentinels, corrects the Q-voltage sign, introduces
  dynamic d/q current/filter-equivalent states, validates all feedback/gate
  signs, adds support and anti-windup tests, narrows VSG/source-case claims, and
  leaves commit-bound evidence pending until publication.
