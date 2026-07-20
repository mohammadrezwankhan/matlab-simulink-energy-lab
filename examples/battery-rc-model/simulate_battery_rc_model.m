function result = simulate_battery_rc_model(profile, parameters, dt_s)
%SIMULATE_BATTERY_RC_MODEL Run a validated first-order battery RC model.

requiredVariables = {'time_s', 'current_A'};
if ~istable(profile) || ...
        ~all(ismember(requiredVariables, profile.Properties.VariableNames))
    error('BatteryRC:ProfileColumns', ...
        'Profile must be a table containing time_s and current_A.');
end

profileTime_s = profile.time_s(:);
profileCurrent_A = profile.current_A(:);
if ~isnumeric(profileTime_s) || ~isnumeric(profileCurrent_A) || ...
        numel(profileTime_s) ~= numel(profileCurrent_A) || ...
        numel(profileTime_s) < 2
    error('BatteryRC:ProfileShape', ...
        'Profile columns must be numeric vectors with at least two rows.');
end
if any(~isfinite(profileTime_s)) || any(~isfinite(profileCurrent_A))
    error('BatteryRC:ProfileFinite', ...
        'Profile timestamps and currents must be finite.');
end
if abs(profileTime_s(1)) > 1e-12
    error('BatteryRC:ProfileStart', 'Profile time_s must start at zero.');
end
if any(diff(profileTime_s) <= 0)
    error('BatteryRC:TimeOrder', ...
        'Profile timestamps must be strictly increasing.');
end

if ~isnumeric(dt_s) || ~isscalar(dt_s) || ~isfinite(dt_s) || dt_s <= 0
    error('BatteryRC:TimeStep', 'dt_s must be a finite positive scalar.');
end
intervalCount = round(profileTime_s(end) / dt_s);
if intervalCount < 1 || abs(intervalCount * dt_s - profileTime_s(end)) > 1e-9
    error('BatteryRC:TimeGrid', ...
        'Profile end time must be an integer multiple of dt_s.');
end

requiredParameters = {
    'capacity_Ah';
    'initial_soc';
    'ocv_nominal_V';
    'r0_Ohm';
    'r1_Ohm';
    'c1_F'
};
if ~isstruct(parameters) || ...
        ~all(isfield(parameters, requiredParameters))
    error('BatteryRC:Parameters', ...
        'Parameter structure is missing one or more required fields.');
end
for parameterIndex = 1:numel(requiredParameters)
    parameterValue = parameters.(requiredParameters{parameterIndex});
    if ~isnumeric(parameterValue) || ~isscalar(parameterValue) || ...
            ~isfinite(parameterValue)
        error('BatteryRC:Parameters', ...
            'Every battery RC parameter must be a finite numeric scalar.');
    end
end
if parameters.capacity_Ah <= 0 || parameters.r0_Ohm < 0 || ...
        parameters.r1_Ohm <= 0 || parameters.c1_F <= 0
    error('BatteryRC:Parameters', ...
        'Capacity, R1, and C1 must be positive; R0 must be nonnegative.');
end
if parameters.initial_soc < 0 || parameters.initial_soc > 1
    error('BatteryRC:Parameters', 'initial_soc must be within [0, 1].');
end
if dt_s >= 2 * parameters.r1_Ohm * parameters.c1_F
    error('BatteryRC:NumericalStability', ...
        'dt_s must be less than twice the R1-C1 time constant.');
end

time_s = (0:dt_s:profileTime_s(end))';
current_A = interp1(profileTime_s, profileCurrent_A, time_s, ...
    'previous', 'extrap');
soc = zeros(size(time_s));
v_rc_V = zeros(size(time_s));
terminal_voltage_V = zeros(size(time_s));

soc(1) = parameters.initial_soc;
terminal_voltage_V(1) = parameters.ocv_nominal_V;

for sample = 2:numel(time_s)
    soc(sample) = soc(sample - 1) - ...
        (current_A(sample - 1) * dt_s) / ...
        (parameters.capacity_Ah * 3600);
    soc(sample) = min(max(soc(sample), 0), 1);

    voltageDerivative_V_per_s = ...
        -(v_rc_V(sample - 1) / ...
        (parameters.r1_Ohm * parameters.c1_F)) + ...
        current_A(sample - 1) / parameters.c1_F;
    v_rc_V(sample) = v_rc_V(sample - 1) + ...
        voltageDerivative_V_per_s * dt_s;

    ocv_V = parameters.ocv_nominal_V + 0.1 * (soc(sample) - 0.5);
    terminal_voltage_V(sample) = ocv_V - ...
        current_A(sample) * parameters.r0_Ohm - v_rc_V(sample);
end

result.time_s = time_s;
result.current_A = current_A;
result.soc = soc;
result.v_rc_V = v_rc_V;
result.terminal_voltage_V = terminal_voltage_V;
result.parameters = parameters;
result.dt_s = dt_s;
end
