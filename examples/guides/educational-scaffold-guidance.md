# Educational Scaffold Guidance

Use this guide for separating teaching simplifications from project-ready engineering assumptions. It is written for small MATLAB and Simulink examples that should remain easy to run, inspect, and validate.

| Review Area | Prompt | Expected Record |
|---|---|---|
| Purpose | What engineering question does the example answer? | One short purpose statement in the README. |
| Inputs | Which parameters, sample data, or assumptions drive the result? | Source, units, and placeholder status. |
| Execution | What command should a reviewer run first? | A short no-plot command when possible. |
| Output | What text, value, or plot should change if the example changes? | Expected output note or check result. |
| Maintenance | What documentation must be updated with the code? | README, validation command, and assumptions note. |

## Review Prompts

- Can the example run from a fresh clone without private files?
- Are teaching simplifications clearly separated from project-ready assumptions?
- Would a failed check point to the likely cause quickly?
- Does the guide keep the example small enough for review?
