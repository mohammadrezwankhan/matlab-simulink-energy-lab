function plan = buildfile
%BUILDFILE Define Base MATLAB checks and exact-commit release evidence.
% BUILDTool BASE remains the minimal-installation CI gate. CHECK TEST work
% with available capabilities; ARCHIVE requires every full-release phase.

plan = buildplan(localfunctions);
plan.DefaultTasks = ["check", "test"];
plan("archive").Dependencies = ["check", "test", "demos", "simulink"];
for name = ["base", "check", "test", "demos", "simulink", "archive"]
    plan(name).DisableIncremental = true;
end
end

function checkTask(~)
% Analyze every tracked MATLAB source and enforce product boundaries.
report = invoke_audit("check");
assert(report.passed, 'ReleaseBuild:Code', ...
    'Code Analyzer or dependency checks failed; inspect audit-check.json.');
end

function testTask(~)
% Run the original catalog, manifest contract, and release regression tests.
report = invoke_audit("test");
assert(report.passed, 'ReleaseBuild:Tests', ...
    'A regression failed; inspect audit-test.json and telemetry.');
end

function demosTask(~)
% Smoke-test all run_ entry points with scoped state in this headless process.
report = invoke_audit("demos");
assert(report.passed, 'ReleaseBuild:Demos', ...
    'A demonstration failed; inspect audit-demos.json.');
end

function simulinkTask(~)
% Compile all generated diagrams and inspect model diagnostics.
report = invoke_audit("simulink");
assert(report.passed, 'ReleaseBuild:Simulink', ...
    'Full model diagnostics require MATLAB + Simulink and passing models.');
end

function archiveTask(~)
% Package only fully verified committed source; do not tag or publish.
originalPath = path;
cleanup = onCleanup(@() path(originalPath));
addpath(fullfile(fileparts(mfilename('fullpath')), 'tools'));
archive_release;
clear cleanup;
end

function report = invoke_audit(phase)
originalPath = path;
cleanup = onCleanup(@() path(originalPath));
addpath(fullfile(fileparts(mfilename('fullpath')), 'tools'));
report = audit_repository(phase);
clear cleanup;
end

function baseTask(~)
% Verify that the advertised toolbox-free profile runs without Simulink.
assert(isempty(ver('Simulink')), ...
    'BaseMatlabCI:UnexpectedSimulink', ...
    'This job must run without Simulink installed.');
originalPath = path;
pathCleanup = onCleanup(@() path(originalPath));
addpath(fullfile(fileparts(mfilename('fullpath')), 'examples'));
run_base_matlab_checks;
clear pathCleanup;
end
