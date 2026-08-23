function report = run_base_matlab_checks(continueOnFailure)
%RUN_BASE_MATLAB_CHECKS Run the toolbox-free validation subset.
% This profile excludes native Simulink diagrams and the focused unified-BESS
% suite. It is useful adoption evidence, not complete repository validation.

if nargin < 1
    continueOnFailure = false;
end
report = run_all_checks(false, continueOnFailure, false);
report.suite = "run_base_matlab_checks";
report.claim_boundary = ...
    "Base MATLAB subset; excludes native diagrams and focused BESS control.";
end
