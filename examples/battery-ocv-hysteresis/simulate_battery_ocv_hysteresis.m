function result = simulate_battery_ocv_hysteresis(profile, parameters, dt_s)
%SIMULATE_BATTERY_OCV_HYSTERESIS Simulate a one-state hysteresis ECM.
% Omit dt_s to preserve native profile timestamps. Positive current
% discharges the cell. The normalized hysteresis state approaches -1 during
% discharge and +1 during charge as fractional charge throughput accrues.

if nargin < 3
    dt_s = [];
end

requiredVariables = {'time_s', 'current_A'};
if ~istable(profile) || ...
        ~all(ismember(requiredVariables, profile.Properties.VariableNames))
    error('BatteryHysteresis:ProfileColumns', ...
        'Profile must be a table containing time_s and current_A.');
end

profileTime_s = profile.time_s(:);
profileCurrent_A = profile.current_A(:);
if ~isnumeric(profileTime_s) || ~isnumeric(profileCurrent_A) || ...
        numel(profileTime_s) ~= numel(profileCurrent_A) || ...
        numel(profileTime_s) < 2
    error('BatteryHysteresis:ProfileShape', ...
        'Profile columns must be numeric vectors with at least two rows.');
end
if any(~isfinite(profileTime_s)) || any(~isfinite(profileCurrent_A))
    error('BatteryHysteresis:ProfileFinite', ...
        'Profile timestamps and currents must be finite.');
end
if abs(profileTime_s(1)) > 1e-12
    error('BatteryHysteresis:ProfileStart', ...
        'Profile time_s must start at zero.');
end
if any(diff(profileTime_s) <= 0)
    error('BatteryHysteresis:TimeOrder', ...
        'Profile timestamps must be strictly increasing.');
end

if ~isempty(dt_s)
    if ~isnumeric(dt_s) || ~isscalar(dt_s) || ~isfinite(dt_s) || dt_s <= 0
        error('BatteryHysteresis:TimeStep', ...
            'dt_s must be empty or a finite positive scalar.');
    end
    intervalCount = round(profileTime_s(end) / dt_s);
    if intervalCount < 1 || ...
            abs(intervalCount*dt_s - profileTime_s(end)) > 1e-9
        error('BatteryHysteresis:TimeGrid', ...
            'Profile end time must be an integer multiple of dt_s.');
    end
end

requiredScalarParameters = {
    'capacity_Ah';
    'initial_soc';
    'r0_Ohm';
    'r1_Ohm';
    'c1_F';
    'hysteresis_max_V';
    'hysteresis_rate_per_fractional_throughput';
    'initial_hysteresis_state'
};
requiredParameters = [requiredScalarParameters; {
    'ocv_soc_breakpoints';
    'ocv_lookup_V'
}];
if ~isstruct(parameters) || ~all(isfield(parameters, requiredParameters))
    error('BatteryHysteresis:Parameters', ...
        'Parameter structure is missing one or more required fields.');
end
for parameterIndex = 1:numel(requiredScalarParameters)
    parameterValue = parameters.(requiredScalarParameters{parameterIndex});
    if ~isnumeric(parameterValue) || ~isscalar(parameterValue) || ...
            ~isreal(parameterValue) || ~isfinite(parameterValue)
        error('BatteryHysteresis:Parameters', ...
            'Every scalar parameter must be finite, real, and numeric.');
    end
end
if parameters.capacity_Ah <= 0 || parameters.r0_Ohm < 0 || ...
        parameters.r1_Ohm <= 0 || parameters.c1_F <= 0 || ...
        parameters.hysteresis_max_V < 0 || ...
        parameters.hysteresis_rate_per_fractional_throughput < 0
    error('BatteryHysteresis:Parameters', ...
        ['Capacity, R1, and C1 must be positive; R0 and hysteresis ', ...
        'parameters must be nonnegative.']);
end
if parameters.initial_soc < 0 || parameters.initial_soc > 1
    error('BatteryHysteresis:Parameters', ...
        'initial_soc must be within [0, 1].');
end
if abs(parameters.initial_hysteresis_state) > 1
    error('BatteryHysteresis:Parameters', ...
        'initial_hysteresis_state must be within [-1, 1].');
end

ocvSocBreakpoints = parameters.ocv_soc_breakpoints(:);
ocvLookup_V = parameters.ocv_lookup_V(:);
if ~isnumeric(parameters.ocv_soc_breakpoints) || ...
        ~isvector(parameters.ocv_soc_breakpoints) || ...
        ~isreal(parameters.ocv_soc_breakpoints) || ...
        ~isnumeric(parameters.ocv_lookup_V) || ...
        ~isvector(parameters.ocv_lookup_V) || ...
        ~isreal(parameters.ocv_lookup_V) || ...
        numel(ocvSocBreakpoints) < 2 || ...
        numel(ocvSocBreakpoints) ~= numel(ocvLookup_V) || ...
        any(~isfinite(ocvSocBreakpoints)) || any(~isfinite(ocvLookup_V))
    error('BatteryHysteresis:OCVCurve', ...
        'OCV lookup fields must be equal-length finite numeric vectors.');
end
if abs(ocvSocBreakpoints(1)) > 1e-12 || ...
        abs(ocvSocBreakpoints(end) - 1) > 1e-12 || ...
        any(diff(ocvSocBreakpoints) <= 0)
    error('BatteryHysteresis:OCVCurve', ...
        'OCV SOC breakpoints must increase strictly from zero to one.');
end
if any(ocvLookup_V <= 0) || any(diff(ocvLookup_V) < 0)
    error('BatteryHysteresis:OCVCurve', ...
        'OCV values must be positive and nondecreasing with SOC.');
end

if isempty(dt_s)
    time_s = profileTime_s;
    requestedCurrent_A = profileCurrent_A;
else
    time_s = (0:dt_s:profileTime_s(end))';
    requestedCurrent_A = interp1(profileTime_s, profileCurrent_A, time_s, ...
        'previous', 'extrap');
end

interval_s = diff(time_s);
sampleCount = numel(time_s);
soc = zeros(sampleCount, 1);
v_rc_V = zeros(sampleCount, 1);
hysteresis_state = zeros(sampleCount, 1);
ocv_mean_V = zeros(sampleCount, 1);
hysteresis_voltage_V = zeros(sampleCount, 1);
equilibrium_voltage_V = zeros(sampleCount, 1);
terminal_voltage_V = zeros(sampleCount, 1);
current_A = requestedCurrent_A;
current_limited = false(sampleCount, 1);
interval_net_discharge_Ah = zeros(sampleCount - 1, 1);
interval_fractional_throughput = zeros(sampleCount - 1, 1);
cumulative_net_discharge_Ah = zeros(sampleCount, 1);
cumulative_fractional_throughput = zeros(sampleCount, 1);
soc_charge_balance_error = zeros(sampleCount, 1);

soc(1) = parameters.initial_soc;
hysteresis_state(1) = parameters.initial_hysteresis_state;
ocv_mean_V(1) = interp1(ocvSocBreakpoints, ocvLookup_V, soc(1), 'linear');
hysteresis_voltage_V(1) = ...
    parameters.hysteresis_max_V*hysteresis_state(1);
equilibrium_voltage_V(1) = ocv_mean_V(1) + hysteresis_voltage_V(1);

for intervalIndex = 1:numel(interval_s)
    intervalDuration_s = interval_s(intervalIndex);
    maximumDischargeCurrent_A = ...
        soc(intervalIndex)*parameters.capacity_Ah*3600/intervalDuration_s;
    minimumChargeCurrent_A = ...
        -(1 - soc(intervalIndex))*parameters.capacity_Ah*3600/ ...
        intervalDuration_s;
    current_A(intervalIndex) = min(max(...
        requestedCurrent_A(intervalIndex), minimumChargeCurrent_A), ...
        maximumDischargeCurrent_A);
    current_limited(intervalIndex) = ...
        current_A(intervalIndex) ~= requestedCurrent_A(intervalIndex);
    terminal_voltage_V(intervalIndex) = ...
        equilibrium_voltage_V(intervalIndex) - ...
        current_A(intervalIndex)*parameters.r0_Ohm - v_rc_V(intervalIndex);

    interval_net_discharge_Ah(intervalIndex) = ...
        current_A(intervalIndex)*intervalDuration_s/3600;
    interval_fractional_throughput(intervalIndex) = ...
        abs(interval_net_discharge_Ah(intervalIndex))/parameters.capacity_Ah;
    cumulative_net_discharge_Ah(intervalIndex + 1) = ...
        cumulative_net_discharge_Ah(intervalIndex) + ...
        interval_net_discharge_Ah(intervalIndex);
    cumulative_fractional_throughput(intervalIndex + 1) = ...
        cumulative_fractional_throughput(intervalIndex) + ...
        interval_fractional_throughput(intervalIndex);
    soc(intervalIndex + 1) = soc(intervalIndex) - ...
        interval_net_discharge_Ah(intervalIndex)/parameters.capacity_Ah;
    soc(intervalIndex + 1) = min(max(soc(intervalIndex + 1), 0), 1);
    expectedSoc = parameters.initial_soc - ...
        cumulative_net_discharge_Ah(intervalIndex + 1)/ ...
        parameters.capacity_Ah;
    soc_charge_balance_error(intervalIndex + 1) = ...
        soc(intervalIndex + 1) - expectedSoc;

    rcDecayFactor = exp(-intervalDuration_s/ ...
        (parameters.r1_Ohm*parameters.c1_F));
    v_rc_V(intervalIndex + 1) = ...
        rcDecayFactor*v_rc_V(intervalIndex) + ...
        parameters.r1_Ohm*(1 - rcDecayFactor)*current_A(intervalIndex);

    if current_A(intervalIndex) == 0 || ...
            parameters.hysteresis_rate_per_fractional_throughput == 0
        hysteresis_state(intervalIndex + 1) = ...
            hysteresis_state(intervalIndex);
    else
        hysteresisTarget = -sign(current_A(intervalIndex));
        hysteresisDecayFactor = exp(...
            -parameters.hysteresis_rate_per_fractional_throughput* ...
            interval_fractional_throughput(intervalIndex));
        hysteresis_state(intervalIndex + 1) = hysteresisTarget + ...
            (hysteresis_state(intervalIndex) - hysteresisTarget)* ...
            hysteresisDecayFactor;
        hysteresis_state(intervalIndex + 1) = min(max(...
            hysteresis_state(intervalIndex + 1), -1), 1);
    end

    ocv_mean_V(intervalIndex + 1) = interp1(...
        ocvSocBreakpoints, ocvLookup_V, soc(intervalIndex + 1), 'linear');
    hysteresis_voltage_V(intervalIndex + 1) = ...
        parameters.hysteresis_max_V*hysteresis_state(intervalIndex + 1);
    equilibrium_voltage_V(intervalIndex + 1) = ...
        ocv_mean_V(intervalIndex + 1) + ...
        hysteresis_voltage_V(intervalIndex + 1);
end

if (soc(end) <= 1e-12 && requestedCurrent_A(end) > 0) || ...
        (soc(end) >= 1 - 1e-12 && requestedCurrent_A(end) < 0)
    current_A(end) = 0;
    current_limited(end) = true;
end
terminal_voltage_V(end) = equilibrium_voltage_V(end) - ...
    current_A(end)*parameters.r0_Ohm - v_rc_V(end);

result.time_s = time_s;
result.requested_current_A = requestedCurrent_A;
result.current_A = current_A;
result.current_limited = current_limited;
result.soc = soc;
result.v_rc_V = v_rc_V;
result.hysteresis_state = hysteresis_state;
result.ocv_mean_V = ocv_mean_V;
result.hysteresis_voltage_V = hysteresis_voltage_V;
result.equilibrium_voltage_V = equilibrium_voltage_V;
result.terminal_voltage_V = terminal_voltage_V;
result.interval_s = interval_s;
result.interval_net_discharge_Ah = interval_net_discharge_Ah;
result.interval_fractional_throughput = interval_fractional_throughput;
result.cumulative_net_discharge_Ah = cumulative_net_discharge_Ah;
result.cumulative_fractional_throughput = ...
    cumulative_fractional_throughput;
result.soc_charge_balance_error = soc_charge_balance_error;
result.parameters = parameters;

uniformTolerance_s = 1e-12*max(1, max(abs(interval_s)));
if max(abs(interval_s - interval_s(1))) <= uniformTolerance_s
    result.dt_s = interval_s(1);
else
    result.dt_s = [];
end
end
