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

The pull request workflow runs the relevant repository checks again. Include
the exact local command and a short result summary in the pull request.

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
