function plan = buildfile
%BUILDFILE Define the independent Base MATLAB CI validation task.
% Run BUILDTOOL BASE in a MATLAB-only installation. The complete repository
% suite still uses the separate MATLAB/Simulink workflow jobs.

plan = buildplan(localfunctions);
plan.DefaultTasks = "base";
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
