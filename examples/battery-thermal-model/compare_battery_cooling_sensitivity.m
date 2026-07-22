function comparison = compare_battery_cooling_sensitivity(...
    profile, baseParameters, heatTransferValues_W_per_K, ...
    limitTemperature_C, dt_s)
%COMPARE_BATTERY_COOLING_SENSITIVITY Sweep lumped cooling conductance.
% Returns one validated thermal result per cooling case and a compact table
% of temperature, limit-exposure, heat-removal, and final-SOC metrics.

if nargin < 5
    dt_s = [];
end

heatTransferValues_W_per_K = validate_heat_transfer_values(...
    heatTransferValues_W_per_K);
validate_limit_temperature(limitTemperature_C);

caseCount = numel(heatTransferValues_W_per_K);
results = cell(caseCount, 1);
peakTemperature_C = zeros(caseCount, 1);
finalTemperature_C = zeros(caseCount, 1);
peakTemperatureRise_C = zeros(caseCount, 1);
timeAboveLimit_s = zeros(caseCount, 1);
degreeHoursAboveLimit_C_h = zeros(caseCount, 1);
exposureFraction = zeros(caseCount, 1);
marginToLimit_C = zeros(caseCount, 1);
netCoolingEnergy_Wh = zeros(caseCount, 1);
finalSoc = zeros(caseCount, 1);

for caseIndex = 1:caseCount
    caseParameters = baseParameters;
    caseParameters.heat_transfer_W_per_K = ...
        heatTransferValues_W_per_K(caseIndex);
    result = simulate_battery_thermal_model(...
        profile, caseParameters, dt_s);
    limitSummary = summarize_battery_temperature_limits(...
        result, limitTemperature_C);

    results{caseIndex} = result;
    peakTemperature_C(caseIndex) = max(result.cell_temp_C);
    finalTemperature_C(caseIndex) = result.cell_temp_C(end);
    peakTemperatureRise_C(caseIndex) = ...
        peakTemperature_C(caseIndex) - caseParameters.ambient_temp_C;
    timeAboveLimit_s(caseIndex) = limitSummary.time_above_limit_s;
    degreeHoursAboveLimit_C_h(caseIndex) = ...
        limitSummary.degree_hours_above_limit_C_h;
    exposureFraction(caseIndex) = limitSummary.exposure_fraction;
    marginToLimit_C(caseIndex) = limitSummary.margin_to_limit_C;
    netCoolingEnergy_Wh(caseIndex) = sum(...
        result.cooling_power_W(1:end-1) .* result.interval_s) / 3600;
    finalSoc(caseIndex) = result.soc(end);
end

comparison.summary = table(...
    heatTransferValues_W_per_K, peakTemperature_C, finalTemperature_C, ...
    peakTemperatureRise_C, timeAboveLimit_s, ...
    degreeHoursAboveLimit_C_h, exposureFraction, marginToLimit_C, ...
    netCoolingEnergy_Wh, finalSoc, ...
    'VariableNames', {
        'heat_transfer_W_per_K';
        'peak_temperature_C';
        'final_temperature_C';
        'peak_temperature_rise_C';
        'time_above_limit_s';
        'degree_hours_above_limit_C_h';
        'exposure_fraction';
        'margin_to_limit_C';
        'net_cooling_energy_Wh';
        'final_soc'
    });
comparison.results = results;
comparison.limit_temperature_C = limitTemperature_C;
comparison.base_parameters = baseParameters;
comparison.dt_s = dt_s;
end

function values = validate_heat_transfer_values(values)
if ~isnumeric(values) || ~isvector(values) || isempty(values) || ...
        ~isreal(values) || any(~isfinite(values)) || any(values < 0)
    error('BatteryCoolingStudy:HeatTransferValues', ...
        ['Heat-transfer values must be a nonempty finite real vector ' ...
        'containing no negative values.']);
end
values = values(:);
if numel(unique(values)) ~= numel(values)
    error('BatteryCoolingStudy:HeatTransferValues', ...
        'Heat-transfer values must be unique.');
end
end

function validate_limit_temperature(limitTemperature_C)
if ~isnumeric(limitTemperature_C) || ~isscalar(limitTemperature_C) || ...
        ~isreal(limitTemperature_C) || ~isfinite(limitTemperature_C) || ...
        limitTemperature_C <= -273.15
    error('BatteryCoolingStudy:LimitTemperature', ...
        'The comparison limit must be a finite scalar above absolute zero.');
end
end
