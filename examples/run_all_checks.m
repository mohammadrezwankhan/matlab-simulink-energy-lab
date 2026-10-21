function report = run_all_checks(varargin)
%RUN_ALL_CHECKS Backward-compatible entry point for the check catalog.
% The implementation has a distinct name so the root entry point cannot recurse.
report = run_catalog_checks(varargin{:});
end
