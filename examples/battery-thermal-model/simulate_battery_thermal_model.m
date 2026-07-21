function result = simulate_battery_thermal_model(profile, parameters, dt_s)
%SIMULATE_BATTERY_THERMAL_MODEL Run the discrete electro-thermal model.
% Omit dt_s to preserve native profile timestamps.

if nargin < 3
    dt_s = [];
end

[profileTime_s, profileCurrent_A] = validate_profile(profile);
validate_parameters(parameters);
if ~isempty(dt_s)
    validate_time_step(dt_s, profileTime_s(end));
    time_s = (0:dt_s:profileTime_s(end))';
    current_A = interp1(profileTime_s, profileCurrent_A, time_s, ...
        'previous', 'extrap');
else
    time_s = profileTime_s;
    current_A = profileCurrent_A;
end

interval_s = diff(time_s);
thermalCapacity_J_per_K = ...
    parameters.cell_mass_kg * parameters.specific_heat_J_per_kgK;
validate_explicit_euler_stability(...
    interval_s, parameters, thermalCapacity_J_per_K);

soc = zeros(size(time_s));
v_rc_V = zeros(size(time_s));
ocv_V = zeros(size(time_s));
terminal_voltage_V = zeros(size(time_s));
cell_temp_C = zeros(size(time_s));
r0_Ohm = zeros(size(time_s));
heat_generation_W = zeros(size(time_s));
entropic_coefficient_V_per_K = zeros(size(time_s));
reversible_heat_W = zeros(size(time_s));
total_heat_generation_W = zeros(size(time_s));
cooling_power_W = zeros(size(time_s));
net_heat_W = zeros(size(time_s));

soc(1) = parameters.initial_soc;
cell_temp_C(1) = parameters.initial_cell_temp_C;
r0_Ohm(1) = temperature_dependent_resistance(...
    cell_temp_C(1), parameters);

for intervalIndex = 1:numel(interval_s)
    [ocv_V(intervalIndex), terminal_voltage_V(intervalIndex), ...
        heat_generation_W(intervalIndex), ...
        entropic_coefficient_V_per_K(intervalIndex), ...
        reversible_heat_W(intervalIndex), ...
        total_heat_generation_W(intervalIndex), ...
        cooling_power_W(intervalIndex)] = calculate_outputs(...
            soc(intervalIndex), v_rc_V(intervalIndex), ...
            cell_temp_C(intervalIndex), r0_Ohm(intervalIndex), ...
            current_A(intervalIndex), parameters);
    net_heat_W(intervalIndex) = ...
        total_heat_generation_W(intervalIndex) - ...
        cooling_power_W(intervalIndex);

    intervalDuration_s = interval_s(intervalIndex);
    soc(intervalIndex + 1) = soc(intervalIndex) - ...
        current_A(intervalIndex) * intervalDuration_s / ...
        (parameters.capacity_Ah * 3600);
    soc(intervalIndex + 1) = min(max(soc(intervalIndex + 1), 0), 1);

    polarizationRate_V_per_s = ...
        current_A(intervalIndex) / parameters.c1_F - ...
        v_rc_V(intervalIndex) / ...
        (parameters.r1_Ohm * parameters.c1_F);
    v_rc_V(intervalIndex + 1) = v_rc_V(intervalIndex) + ...
        polarizationRate_V_per_s * intervalDuration_s;

    cell_temp_C(intervalIndex + 1) = cell_temp_C(intervalIndex) + ...
        net_heat_W(intervalIndex) * intervalDuration_s / ...
        thermalCapacity_J_per_K;
    r0_Ohm(intervalIndex + 1) = temperature_dependent_resistance(...
        cell_temp_C(intervalIndex + 1), parameters);
end

[ocv_V(end), terminal_voltage_V(end), heat_generation_W(end), ...
    entropic_coefficient_V_per_K(end), reversible_heat_W(end), ...
    total_heat_generation_W(end), cooling_power_W(end)] = ...
    calculate_outputs(...
        soc(end), v_rc_V(end), cell_temp_C(end), r0_Ohm(end), ...
        current_A(end), parameters);
net_heat_W(end) = total_heat_generation_W(end) - cooling_power_W(end);

allSignals = [soc, v_rc_V, ocv_V, terminal_voltage_V, cell_temp_C, ...
    r0_Ohm, heat_generation_W, entropic_coefficient_V_per_K, ...
    reversible_heat_W, total_heat_generation_W, cooling_power_W, ...
    net_heat_W];
if any(~isfinite(allSignals), 'all')
    error('BatteryThermal:Numerics', ...
        'Thermal model states and outputs must remain finite.');
end

thermalEnergyChange_J = thermalCapacity_J_per_K * ...
    (cell_temp_C(end) - cell_temp_C(1));
integratedNetHeat_J = sum(net_heat_W(1:end-1) .* interval_s);

result.time_s = time_s;
result.current_A = current_A;
result.soc = soc;
result.v_rc_V = v_rc_V;
result.ocv_V = ocv_V;
result.terminal_voltage_V = terminal_voltage_V;
result.cell_temp_C = cell_temp_C;
result.r0_Ohm = r0_Ohm;
result.heat_generation_W = heat_generation_W;
result.entropic_coefficient_V_per_K = entropic_coefficient_V_per_K;
result.reversible_heat_W = reversible_heat_W;
result.total_heat_generation_W = total_heat_generation_W;
result.cooling_power_W = cooling_power_W;
result.net_heat_W = net_heat_W;
result.interval_s = interval_s;
result.thermal_capacity_J_per_K = thermalCapacity_J_per_K;
result.thermal_energy_change_J = thermalEnergyChange_J;
result.integrated_net_heat_J = integratedNetHeat_J;
result.energy_balance_error_J = ...
    thermalEnergyChange_J - integratedNetHeat_J;
result.parameters = parameters;

uniformTolerance_s = 1e-12 * max(1, max(abs(interval_s)));
if max(abs(interval_s - interval_s(1))) <= uniformTolerance_s
    result.dt_s = interval_s(1);
else
    result.dt_s = [];
end
end

function [profileTime_s, profileCurrent_A] = validate_profile(profile)
requiredVariables = {'time_s', 'current_A'};
if ~istable(profile) || ...
        ~all(ismember(requiredVariables, profile.Properties.VariableNames))
    error('BatteryThermal:ProfileColumns', ...
        'Profile must be a table containing time_s and current_A.');
end
profileTime_s = profile.time_s(:);
profileCurrent_A = profile.current_A(:);
if ~isnumeric(profileTime_s) || ~isnumeric(profileCurrent_A) || ...
        ~isreal(profileTime_s) || ~isreal(profileCurrent_A) || ...
        numel(profileTime_s) ~= numel(profileCurrent_A) || ...
        numel(profileTime_s) < 2
    error('BatteryThermal:ProfileShape', ...
        'Profile columns must be numeric vectors with at least two rows.');
end
if any(~isfinite(profileTime_s)) || any(~isfinite(profileCurrent_A))
    error('BatteryThermal:ProfileFinite', ...
        'Profile timestamps and currents must be finite.');
end
if abs(profileTime_s(1)) > 1e-12
    error('BatteryThermal:ProfileStart', ...
        'Profile time_s must start at zero.');
end
if any(diff(profileTime_s) <= 0)
    error('BatteryThermal:TimeOrder', ...
        'Profile timestamps must be strictly increasing.');
end
end

function validate_time_step(dt_s, profileEndTime_s)
if ~isnumeric(dt_s) || ~isscalar(dt_s) || ~isfinite(dt_s) || dt_s <= 0
    error('BatteryThermal:TimeStep', ...
        'dt_s must be empty or a finite positive scalar.');
end
intervalCount = round(profileEndTime_s / dt_s);
if intervalCount < 1 || ...
        abs(intervalCount * dt_s - profileEndTime_s) > 1e-9
    error('BatteryThermal:TimeGrid', ...
        'Profile end time must be an integer multiple of dt_s.');
end
end

function validate_parameters(parameters)
requiredScalarParameters = {
    'capacity_Ah';
    'initial_soc';
    'ocv_nominal_V';
    'ocv_soc_slope_V';
    'r0_reference_Ohm';
    'r1_Ohm';
    'c1_F';
    'resistance_temp_coefficient_per_C';
    'reference_temp_C';
    'ambient_temp_C';
    'initial_cell_temp_C';
    'cell_mass_kg';
    'specific_heat_J_per_kgK';
    'heat_transfer_W_per_K'
};
requiredLookupParameters = {
    'entropic_soc_breakpoints';
    'entropic_coefficient_V_per_K'
};
requiredParameters = [requiredScalarParameters; requiredLookupParameters];
if ~isstruct(parameters) || ~all(isfield(parameters, requiredParameters))
    error('BatteryThermal:Parameters', ...
        'Parameter structure is missing one or more required fields.');
end
for parameterIndex = 1:numel(requiredScalarParameters)
    parameterValue = parameters.(requiredScalarParameters{parameterIndex});
    if ~isnumeric(parameterValue) || ~isscalar(parameterValue) || ...
            ~isreal(parameterValue) || ~isfinite(parameterValue)
        error('BatteryThermal:Parameters', ...
            'Every thermal model parameter must be a finite real scalar.');
    end
end
if parameters.capacity_Ah <= 0 || parameters.r0_reference_Ohm <= 0 || ...
        parameters.r1_Ohm <= 0 || parameters.c1_F <= 0 || ...
        parameters.cell_mass_kg <= 0 || ...
        parameters.specific_heat_J_per_kgK <= 0
    error('BatteryThermal:Parameters', ...
        'Capacity, resistances, capacitance, mass, and heat capacity must be positive.');
end
if parameters.initial_soc < 0 || parameters.initial_soc > 1 || ...
        parameters.ocv_nominal_V <= 0 || ...
        parameters.resistance_temp_coefficient_per_C < 0 || ...
        parameters.heat_transfer_W_per_K < 0
    error('BatteryThermal:Parameters', ...
        'SOC and nonnegative thermal parameter bounds are invalid.');
end
temperatureParameters_C = [parameters.reference_temp_C, ...
    parameters.ambient_temp_C, parameters.initial_cell_temp_C];
if any(temperatureParameters_C <= -273.15)
    error('BatteryThermal:Parameters', ...
        'Configured temperatures must remain above absolute zero.');
end

breakpoints = parameters.entropic_soc_breakpoints;
coefficients = parameters.entropic_coefficient_V_per_K;
if ~isnumeric(breakpoints) || ~isvector(breakpoints) || ...
        ~isreal(breakpoints) || any(~isfinite(breakpoints)) || ...
        ~isnumeric(coefficients) || ~isvector(coefficients) || ...
        ~isreal(coefficients) || any(~isfinite(coefficients)) || ...
        numel(breakpoints) ~= numel(coefficients) || numel(breakpoints) < 2
    error('BatteryThermal:EntropicTable', ...
        'Entropic lookup vectors must be finite, real, equal-length vectors.');
end
if abs(breakpoints(1)) > 1e-12 || abs(breakpoints(end) - 1) > 1e-12 || ...
        any(diff(breakpoints) <= 0)
    error('BatteryThermal:EntropicTable', ...
        'Entropic SOC breakpoints must increase strictly from zero to one.');
end
end

function validate_explicit_euler_stability(...
        interval_s, parameters, thermalCapacity_J_per_K)
electricalLimit_s = 2 * parameters.r1_Ohm * parameters.c1_F;
if any(interval_s >= electricalLimit_s)
    error('BatteryThermal:TimeStepStability', ...
        'Every interval must be shorter than twice the RC time constant.');
end
if parameters.heat_transfer_W_per_K > 0
    thermalLimit_s = 2 * thermalCapacity_J_per_K / ...
        parameters.heat_transfer_W_per_K;
    if any(interval_s >= thermalLimit_s)
        error('BatteryThermal:TimeStepStability', ...
            'Every interval must satisfy the explicit thermal stability limit.');
    end
end
end

function resistance_Ohm = temperature_dependent_resistance(...
        cellTemp_C, parameters)
resistance_Ohm = parameters.r0_reference_Ohm * exp(...
    parameters.resistance_temp_coefficient_per_C * ...
    (parameters.reference_temp_C - cellTemp_C));
end

function [ocv_V, terminalVoltage_V, irreversibleHeat_W, ...
        entropicCoefficient_V_per_K, reversibleHeat_W, ...
        totalHeatGeneration_W, coolingPower_W] = ...
        calculate_outputs(soc, vRc_V, cellTemp_C, resistance_Ohm, ...
            current_A, parameters)
ocv_V = parameters.ocv_nominal_V + ...
    parameters.ocv_soc_slope_V * (soc - 0.5);
ohmicDrop_V = current_A * resistance_Ohm;
terminalVoltage_V = ocv_V - ohmicDrop_V - vRc_V;
irreversibleHeat_W = current_A * (ohmicDrop_V + vRc_V);
absoluteTemperature_K = cellTemp_C + 273.15;
if absoluteTemperature_K <= 0
    error('BatteryThermal:AbsoluteTemperature', ...
        'Simulated cell temperature must remain above absolute zero.');
end
entropicCoefficient_V_per_K = interp1(...
    parameters.entropic_soc_breakpoints, ...
    parameters.entropic_coefficient_V_per_K, soc, 'linear');
reversibleHeat_W = -current_A * absoluteTemperature_K * ...
    entropicCoefficient_V_per_K;
totalHeatGeneration_W = irreversibleHeat_W + reversibleHeat_W;
coolingPower_W = parameters.heat_transfer_W_per_K * ...
    (cellTemp_C - parameters.ambient_temp_C);
end
