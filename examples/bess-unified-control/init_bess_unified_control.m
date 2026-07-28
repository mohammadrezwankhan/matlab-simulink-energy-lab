function parameters = init_bess_unified_control(overrides)
%INIT_BESS_UNIFIED_CONTROL Return validated starter parameters.

if nargin < 1
    overrides = struct();
end
parameters = bess_unified_control_parameters(overrides);
end
