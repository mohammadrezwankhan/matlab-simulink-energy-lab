<!-- markdownlint-disable MD013 -->

# Contributing

Thank you for helping make the energy-system examples clearer, more
reproducible, and easier to validate. Contributions can be code,
documentation, measured-data references, test cases, or careful engineering
review.

## Before You Start

1. Check the [open issues](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab/issues)
   for an existing task or open a focused issue before starting a larger
   change.
2. Comment on the issue with the part you want to tackle and any assumptions
   you expect to introduce. This prevents duplicated work and gives the
   maintainer a chance to clarify the validation target.
3. Keep one pull request focused on one engineering question. Small, complete
   changes are easier to reproduce and review than unrelated bundles.

Issue comments are also the preferred place to coordinate genuine pair work.
For example, one contributor can propose a table schema while another checks
units, tolerances, or documentation against the implementation.

## Good Contributions

- Add a small, inspectable model with a stated engineering question.
- Add a no-plot validation check or strengthen an existing assertion.
- Improve setup instructions, expected outputs, or troubleshooting guidance.
- Document assumptions, units, sign conventions, and model limitations.
- Add a source-backed parameter set or a measured-data validation path that
  can be redistributed with the repository.
- Submit a commit-bound reproduction report from a clean checkout, including
  the exact command, MATLAB release, operating system, and observed result.
- Review an open implementation for numerical, physical, or teaching clarity.

## Development Setup

Fork or clone the repository, create a branch, and run the check nearest to the
area you plan to change. Script-based examples use base MATLAB; the generated
block-diagram examples also require Simulink.

```bash
git clone https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab.git
cd matlab-simulink-energy-lab
git switch -c contributor/short-task-name
```

Run an individual check while iterating:

```bash
matlab -batch "run('examples/battery-rc-model/check_battery_rc_model.m')"
```

For converter-controller changes, run both checks:

```bash
matlab -batch "run('examples/converter-closed-loop-model/check_closed_loop_converter.m'); run('examples/converter-closed-loop-model/check_converter_controller_comparison.m')"
```

For repository-wide diagnostics and available-capability checks, run:

```bash
matlab -batch "buildtool check test"
```

For release verification, commit the reviewed candidate and run
`matlab -batch "buildtool check test archive"` on MATLAB R2026a with Simulink.
Archival requires the `check`, `test`, `demos`, and `simulink` reports to pass
and be complete for that exact clean commit. A passing MATLAB-only subset
does not satisfy the full release gate. See [release readiness](docs/release-readiness.md).

The pull request workflow runs the relevant repository checks again. Include
the exact local command, source commit, capability profile, and observed result
in the pull request. Do not report Code Analyzer or Simulink checks as passed
when they have not executed.

## Modeling and Validation Standard

Every executable example should make the following items inspectable:

| Area | Expected evidence |
| --- | --- |
| Purpose | One engineering question and a bounded scope |
| Inputs | Parameters, units, valid ranges, and source or rationale |
| Equations | Sign conventions and simplifying assumptions |
| Output | Deterministic expected values or physically justified bounds |
| Validation | A no-plot check that fails clearly when behavior regresses |
| Limitations | What the model must not be used to claim |
| Dependencies | Required MATLAB release and products |

Keep scripts compatible with `run('path/to/script.m')` while running their
work in a local function. Preserve the caller's path, current folder, RNG and
existing figures. Return reusable data through simulator/estimator functions;
do not rely on script variables escaping into the caller. The current synthetic
perturbations are deterministic signals and need no RNG seeding. If future
code samples randomness, scope and restore the original RNG state.

Do not commit generated `.slx` files when the checked builder script is the
source of truth. Do not add proprietary data, confidential material, or files
whose redistribution rights are unclear.

## Pull Request Workflow

1. Link the coordinating issue with `Closes #<number>` when the change fully
   resolves it.
2. Explain the engineering value and any changed assumptions.
3. List the commands you ran and the observed result.
4. Update the nearest README when users need a new command, parameter, output,
   or limitation.
5. Respond to review comments with follow-up commits so the technical history
   remains visible until the pull request is ready to merge.

## Collaboration and Attribution

Use a `Co-authored-by:` trailer only when each named person materially
contributed to the code, analysis, validation, or documentation in that commit
and agreed to the attribution. Use the email address that contributor confirms
is associated with their GitHub account; a GitHub-provided `noreply` address is
appropriate when they prefer not to expose a personal email.

Do not add people, bots, alternate identities, or unrelated accounts as
co-authors merely to influence profile statistics. Tool-assisted work remains
the responsibility of the human contributor who reviews and submits it.

## Pull Request Checklist

- [ ] The example or documentation purpose is clear.
- [ ] Assumptions, units, and limitations are stated.
- [ ] Required MATLAB/Simulink products are listed.
- [ ] Results are reproducible from the documented commands.
- [ ] New behavior has a deterministic check or a justified test update.
- [ ] Documentation and expected outputs reflect the implementation.
- [ ] Every named co-author materially contributed and approved attribution.

## Release Metadata Checklist

Complete this checklist for every versioned release. The repository metadata
validator checks tracked files; GitHub settings and external surfaces still
require authenticated review.

- [ ] Keep `project-metadata.yml`, `CITATION.cff`, and `codemeta.json` at the
      same candidate version. Before publication, keep both `date-released`
      and `datePublished` absent and label the changelog unreleased. Add the
      same actual publication date to both only when finalizing the release;
      commit the change and repeat exact-commit verification before tagging.
- [ ] Confirm the GitHub About description matches the description recorded in
      `project-metadata.yml` and uses the core terminology exactly.
- [ ] Review all 20 GitHub topics for accuracy; change a topic only with
      discovery evidence and record the change in the release notes.
- [ ] Confirm GitHub remains the source of record for code, releases, citation
      metadata, and validation evidence.
- [ ] Confirm the public project overview remains the search landing page and
      links back to the source-of-record repository.
- [ ] Review the 2:1 social preview (1280×640 recommended by GitHub) against the current
      model-family scope and upload it in the GitHub repository settings.
      The README currently uses `assets/social-preview-v3.jpg`, with generation
      and export notes in `assets/social-preview-v3.md`. The previous v2 image
      is retained for history. The older
      `assets/social-preview.png` was regenerated and visually reviewed with
      MATLAB R2026a for the 1.12.0 release and 26-check catalog. Its generator
      reads current version/catalog metadata. Regenerate and review it after
      those inputs change; repository settings are managed separately.
- [ ] Confirm `git status --short` is empty before generating commit-bound
      validation evidence or release assets.
- [ ] Run `.github/scripts/validate-project-metadata.sh`, Markdown links, CFF
      validation, and all executable checks required by the changed paths.
- [ ] Verify the release tag, downloadable assets, checksums, hosted validation
      run, and citation control after publication.
