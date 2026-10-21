function report = run_all_checks(varargin)
%RUN_ALL_CHECKS Run all available no-plot checks from the repository root.
% With no arguments, Simulink is capability-detected. The returned profile,
% complete_suite flag and excluded_checks list distinguish a subset from a
% complete run. Pass (true, true, true) to require the full suite explicitly.
originalPath = path;
cleanup = onCleanup(@() path(originalPath));
addpath(fullfile(fileparts(mfilename('fullpath')), 'examples'));
report = run_catalog_checks(varargin{:});
clear cleanup;
end
