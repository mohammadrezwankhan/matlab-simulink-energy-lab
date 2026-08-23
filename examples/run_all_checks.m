function report = run_all_checks(includeBess)
%RUN_ALL_CHECKS Execute every no-plot example check in isolation.
% Each check is a script that clears its local variables. A dedicated local
% function isolates that cleanup from this loop. The returned report is the
% single source for the machine-readable validation manifest.

if nargin < 1
    includeBess = true;
end
validateattributes(includeBess, {'logical', 'numeric'}, ...
    {'scalar', 'real', 'finite'});
examplesDirectory = fileparts(mfilename('fullpath'));
checks = validation_check_catalog(logical(includeBess));
checkResults = repmat(struct('path', "", 'status', ""), ...
    numel(checks), 1);

for checkIndex = 1:numel(checks)
    checkPath = fullfile(examplesDirectory, checks(checkIndex));
    fprintf('\n[%d/%d] Running %s\n', ...
        checkIndex, numel(checks), checks(checkIndex));
    run_check_script(checkPath);
    checkResults(checkIndex).path = checks(checkIndex);
    checkResults(checkIndex).status = "passed";
end

fprintf('\nAll %d MATLAB and Simulink checks passed.\n', numel(checks));
report.schema_version = "1.0.0";
if logical(includeBess)
    report.suite = "run_all_checks(true)";
else
    report.suite = "run_all_checks(false)";
end
report.check_count = numel(checks);
report.all_checks_passed = true;
report.checks = checkResults;
end

function run_check_script(checkPath)
run(checkPath);
end
