function result = simulate_battery_2rc_model(profile, parameters, dt_s)
%SIMULATE_BATTERY_2RC_MODEL Run a two-time-scale battery RC model.
% Omit dt_s to preserve native profile timestamps.

if nargin < 3
    dt_s = [];
end

requiredSecondBranchParameters = {'r2_Ohm', 'c2_F'};
if ~isstruct(parameters) || ...
        ~all(isfield(parameters, requiredSecondBranchParameters))
    error('Battery2RC:Parameters', ...
        'Parameter structure must contain r2_Ohm and c2_F.');
end
for parameterIndex = 1:numel(requiredSecondBranchParameters)
    parameterName = requiredSecondBranchParameters{parameterIndex};
    parameterValue = parameters.(parameterName);
    if ~isnumeric(parameterValue) || ~isscalar(parameterValue) || ...
            ~isfinite(parameterValue) || parameterValue <= 0
        error('Battery2RC:Parameters', ...
            'R2 and C2 must be finite positive numeric scalars.');
    end
end

modelDirectory = fileparts(mfilename('fullpath'));
baseModelDirectory = fullfile(fileparts(modelDirectory), 'battery-rc-model');
baseSimulator = fullfile(baseModelDirectory, 'simulate_battery_rc_model.m');
if ~isfile(baseSimulator)
    error('Battery2RC:Dependency', ...
        'The battery-rc-model simulator is required beside this example.');
end
originalPath = path;
pathCleanup = onCleanup(@() path(originalPath));
addpath(baseModelDirectory);

baseResult = simulate_battery_rc_model(profile, parameters, dt_s);
v_rc2_V = zeros(size(baseResult.time_s));
for intervalIndex = 1:numel(baseResult.interval_s)
    decayFactor = exp(-baseResult.interval_s(intervalIndex) / ...
        (parameters.r2_Ohm * parameters.c2_F));
    v_rc2_V(intervalIndex + 1) = ...
        decayFactor * v_rc2_V(intervalIndex) + ...
        parameters.r2_Ohm * (1 - decayFactor) * ...
        baseResult.current_A(intervalIndex);
end

result = rmfield(baseResult, 'v_rc_V');
result.v_rc1_V = baseResult.v_rc_V;
result.v_rc2_V = v_rc2_V;
result.v_polarization_V = result.v_rc1_V + result.v_rc2_V;
result.terminal_voltage_V = result.ocv_V - ...
    result.current_A * parameters.r0_Ohm - result.v_polarization_V;
result.parameters = parameters;
result.branch_time_constants_s = [
    parameters.r1_Ohm * parameters.c1_F, ...
    parameters.r2_Ohm * parameters.c2_F
];
end
