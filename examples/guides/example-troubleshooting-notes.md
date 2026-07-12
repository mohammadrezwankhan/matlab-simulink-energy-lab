# Example Troubleshooting Notes

Use these notes to triage common run, path, data, and expected-output problems in the MATLAB examples.

| Symptom | Likely Cause | First Check | Recovery Action |
|---|---|---|---|
| Script cannot find a data file | MATLAB is running from the wrong folder | Confirm the current folder is the example directory | Change into the example folder or use the documented run command |
| Expected output changed | Parameter, sample data, or calculation logic changed | Run the matching no-plot check | Update the README only after confirming the change is intentional |
| Plot opens but values look unrealistic | Units or placeholder parameters were edited | Compare parameter units against the example README | Restore the starter value or document the new source |
| Check script fails after a documentation edit | Expected output text no longer matches behavior | Run the example manually and inspect printed values | Update the check and output inventory together |
| Example works locally but not in automation | Hidden dependency, path assumption, or external file was introduced | Review required files and products | Keep sample data local and document required MATLAB products |

## Review Prompts

- Can a reviewer reproduce the problem from a fresh clone?
- Does the failure point to data, assumptions, path setup, or expected output?
- Is the troubleshooting note short enough to help without hiding the actual model logic?
