# Engineering evidence and readiness ledger

> Scope: reduced-order educational and research examples only. CI results apply
> to the exact checked-out commit, installed toolchain, and reported profile.
> Structural checks, scenario tests, physical validation, and certification
> are different forms of evidence. Never reuse a historical PASS as a new run.

## Native execution receipts (immutable historical records)

| UTC date | Executed source SHA | Toolchain and profile | Observed result | Evidence |
| --- | --- | --- | --- | --- |
| 2026-11-09 | `ef53d73b066bf1913e2bb7080f9c86ff52ea22ed` | R2026a Update 5; Base MATLAB | 22/22 Base catalog checks passed | [GitHub job 129186511716](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab/actions/runs/42625040387/job/129186511716) |
| 2026-11-09 | `ef53d73b066bf1913e2bb7080f9c86ff52ea22ed` | R2026a Update 5 + Simulink; general catalog | 27/27 passed; `complete_suite=false` because the focused BESS entry was run separately | [GitHub job 129186511566](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab/actions/runs/42625040387/job/129186511566) |
| 2026-11-09 | `ef53d73b066bf1913e2bb7080f9c86ff52ea22ed` | R2026a Update 5 + Simulink; focused BESS | 123 focused tests and eight scenarios passed | [GitHub job 129186511254](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab/actions/runs/42625040387/job/129186511254) |
| 2026-11-14 | `c26f3d9d446a46a3f8831ee24f7d25deb5de7be5` | R2026a + Simulink; complete release build | 28/28 catalog entries; 123 focused BESS tests; 31 demo entry points with cleanup; six generated model audits; `check`, `test`, `demos`, `simulink` all reported `passed=true`, `complete=true` and clean source | [Release-readiness run 43611300621](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab/actions/runs/43611300621) |

The last row records the tested pull-request merge-checkout SHA printed in the
job log, not the pull-request head SHA. The CI artifact is named for that same
checkout. No entry in this table certifies a subsequent commit.

## Current-source verification procedure

1. Open the [GitHub Actions runs](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab/actions) for the intended commit. Locate `Release readiness` and `MATLAB validation` for that exact SHA (on PRs, also record the tested synthetic merge SHA).
2. Inspect the native logs, not only the check badge. Require `buildtool -continueOnFailure check test archive` to complete successfully. For release readiness, inspect all four `audit-<phase>.json` reports and their telemetry in the `release-audit-<sha>` artifact.
3. Require each native phase to have `passed=true`, `complete=true`, `source_state=clean`, and `source_commit` equal to the actual checked-out commit. Missing or mismatched reports block release.
4. Independently inspect focused BESS scenarios and test counts, source/requirement provenance and generated model compilation; do not substitute the separate 27-check profile for the 28-entry complete suite.
5. In `Release readiness`, require the `Engineering integrity` step and the native MATLAB steps to succeed.
6. Obtain independent technical review for physics and solver claims before expanding intended use or claiming a completed external audit.

To reproduce the native release gate on a licensed R2026a + Simulink host:

```bash
matlab -batch "buildtool -continueOnFailure check test archive"
```

To reproduce the read-only structural gate without MATLAB:

```bash
python3 tools/check_repository_integrity.py
python3 -m unittest discover -s tests -p 'test_repository_integrity.py' -v
```

## Independent and physical-evidence blockers

- **R2025b cross-release independence:** [External reproducibility package](reproducibility/MATLAB_R2025B_VERIFICATION_PACKAGE.md) records a pending independent machine run. Maintainer CI, even when successful on R2025b, is not independent signoff.
- **BESS physical scope:** The [project assumptions](../examples/bess-unified-control/requirements/assumptions.md) explicitly exclude PWM, semiconductor loss, protection coordination, transformer saturation, DC/DC detail, and cell electrochemistry. Do not claim protection, power-quality, safety or grid-code qualification.
- **Measured-cell scope:** The [LFP](../examples/battery-2rc-model/data/a123-lfp/README.md) and [NASA RW3](../examples/battery-2rc-model/data/nasa-rw3/README.md) held-outs exercise specific records and quasi-OCV proxies. They do not establish transfer to other temperatures, ages, cells or hardware.
- **Independent audit:** Technical peer signoff must identify reviewer, scope, source SHA and reproduced evidence; do not report an automated self-check as an independent expert review.

**Release gate:** Native CI, structural integrity and provenance must all pass on
the candidate. All required independent/physical evidence must also be available
before broader deployment or certification claims. A website deployment is not
an engineering release or certification.
