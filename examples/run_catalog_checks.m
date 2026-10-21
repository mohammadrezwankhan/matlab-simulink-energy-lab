function report = run_catalog_checks( ...
    includeBess, continueOnFailure, includeSimulink)
%RUN_CATALOG_CHECKS Execute every no-plot example check in isolation.
% A dedicated local function protects the runner's state, including when a
% check fails. The returned report is the
% single source for the machine-readable validation manifest.

if nargin < 1
    includeBess = true;
end
if nargin < 2
    continueOnFailure = false;
end
if nargin < 3
    includeSimulink = ~isempty(ver('Simulink')) && ...
        license('test', 'Simulink');
end
validateattributes(includeBess, {'logical', 'numeric'}, ...
    {'scalar', 'real', 'finite'});
validateattributes(continueOnFailure, {'logical', 'numeric'}, ...
    {'scalar', 'real', 'finite'});
validateattributes(includeSimulink, {'logical', 'numeric'}, ...
    {'scalar', 'real', 'finite'});
if ~ismember(includeBess, [0, 1])
    error('ValidationChecks:IncludeBess', ...
        'includeBess must be logical true or false.');
end
if ~ismember(continueOnFailure, [0, 1])
    error('ValidationChecks:ContinueOnFailure', ...
        'continueOnFailure must be logical true or false.');
end
if ~ismember(includeSimulink, [0, 1])
    error('ValidationChecks:IncludeSimulink', ...
        'includeSimulink must be logical true or false.');
end
examplesDirectory = fileparts(mfilename('fullpath'));
checks = validation_check_catalog( ...
    logical(includeBess), logical(includeSimulink));
checkResults = repmat(struct( ...
    'path', "", ...
    'status', "", ...
    'error_identifier', "", ...
    'error_message', ""), numel(checks), 1);

telemetry = repmat(struct('path', "", 'elapsed_seconds', NaN, ...
    'stdout', "", 'new_figure_count', 0, ...
    'caller_figures_preserved', true), numel(checks), 1);

for checkIndex = 1:numel(checks)
    checkPath = fullfile(examplesDirectory, checks(checkIndex));
    fprintf('\n[%d/%d] Running %s\n', ...
        checkIndex, numel(checks), checks(checkIndex));
    checkResults(checkIndex).path = checks(checkIndex);
    [telemetry(checkIndex), checkError] = ...
        run_check_isolated(checkPath, checks(checkIndex));
    if isempty(checkError)
        checkResults(checkIndex).status = "passed";
    else
        checkResults(checkIndex).status = "failed";
        checkResults(checkIndex).error_identifier = ...
            string(checkError.identifier);
        checkResults(checkIndex).error_message = string(checkError.message);
        if ~logical(continueOnFailure)
            rethrow(checkError);
        end
    end
end

allChecksPassed = all(string({checkResults.status}) == "passed");
if logical(includeSimulink)
    suiteLabel = 'MATLAB and Simulink';
else
    suiteLabel = 'Base MATLAB';
end
if allChecksPassed
    fprintf('\nAll %d %s checks passed.\n', numel(checks), suiteLabel);
else
    fprintf('\n%d of %d %s checks passed.\n', ...
        nnz(string({checkResults.status}) == "passed"), ...
        numel(checks), suiteLabel);
end
report.schema_version = "1.0.0";
if ~logical(includeSimulink)
    report.suite = "run_all_checks(includeSimulink=false)";
    report.profile = "base_matlab";
    report.required_products = "MATLAB";
elseif logical(includeBess)
    report.suite = "run_all_checks(true)";
    report.profile = "complete";
    report.required_products = ["MATLAB", "Simulink"];
else
    report.suite = "run_all_checks(false)";
    report.profile = "general";
    report.required_products = ["MATLAB", "Simulink"];
end
report.check_count = numel(checks);
report.all_checks_passed = allChecksPassed;
report.checks = checkResults;
report.complete_suite = logical(includeBess) && logical(includeSimulink);
allRequested = validation_check_catalog(true, true);
report.excluded_checks = allRequested(~ismember(allRequested, checks));
% Timings and console output are deliberately excluded from stable manifests.
report.telemetry = telemetry;
end

function [telemetry, checkError] = run_check_isolated(checkPath, relativePath)
originalPath = path;
originalFolder = pwd;
originalRng = rng;
originalFigures = findall(groot, 'Type', 'figure');
cleanup = onCleanup(@() restore_environment(originalPath, originalFolder, ...
    originalRng, originalFigures));
started = tic;
executeCheck = @() run_check_script(checkPath); %#ok<NASGU> Used by the constant evalc expression below.
[stdout, checkError] = evalc('executeCheck()');
currentFigures = findall(groot, 'Type', 'figure');
newFigures = currentFigures(~ismember(currentFigures, originalFigures));
telemetry = struct('path', relativePath, 'elapsed_seconds', toc(started), ...
    'stdout', string(stdout), 'new_figure_count', numel(newFigures), ...
    'caller_figures_preserved', all(isgraphics(originalFigures)));
if ~telemetry.caller_figures_preserved && isempty(checkError)
    checkError = MException('ValidationChecks:CallerFigure', ...
        'A check closed a caller-owned figure.');
end
fprintf('%s', stdout);
clear cleanup;
end

function checkError = run_check_script(checkPath)
checkError = [];
try
    run_in_child_workspace(checkPath);
catch caughtError
    checkError = caughtError;
end
end

function run_in_child_workspace(checkPath)
run(checkPath);
end

function restore_environment(originalPath, originalFolder, originalRng, figures)
currentFigures = findall(groot, 'Type', 'figure');
newFigures = currentFigures(~ismember(currentFigures, figures));
if ~isempty(newFigures)
    delete(newFigures);
end
rng(originalRng);
cd(originalFolder);
path(originalPath);
end
