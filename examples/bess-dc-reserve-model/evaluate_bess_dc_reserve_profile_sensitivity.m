function sensitivity = evaluate_bess_dc_reserve_profile_sensitivity( ...
    parameters, profiles, reserveLevels)
%EVALUATE_BESS_DC_RESERVE_PROFILE_SENSITIVITY Sweep fixed dynamic requests.
% The profiles are prescribed cases, not normalized evidence of a general
% profile-shape law or an operating envelope.

if nargin < 1 || isempty(parameters)
    parameters = bess_dc_reserve_default_parameters();
end
if nargin < 2 || isempty(profiles)
    profiles = bess_dc_reserve_dynamic_profiles();
end
if nargin < 3
    reserveLevels = [0.10, 0.15, 0.20];
end
reserveLevels = validate_reserves(reserveLevels, parameters.initial_soc);
profiles = validate_profiles(profiles, parameters);

caseCount = numel(profiles)*numel(reserveLevels);
profileId = strings(caseCount, 1);
minimumReserveSoc = zeros(caseCount, 1);
requestedDischargeEnergy_kWh = zeros(caseCount, 1);
deliveredDischargeEnergy_kWh = zeros(caseCount, 1);
curtailedDischargeEnergy_kWh = zeros(caseCount, 1);
requestedChargeEnergy_kWh = zeros(caseCount, 1);
acceptedChargeEnergy_kWh = zeros(caseCount, 1);
curtailedChargeEnergy_kWh = zeros(caseCount, 1);
horizonAverageDeliveredDischargePower_kW = zeros(caseCount, 1);
activeWindowAverageDeliveredDischargePower_kW = zeros(caseCount, 1);
minimumSoc = zeros(caseCount, 1);
finalSoc = zeros(caseCount, 1);
socTaperActiveTime_s = zeros(caseCount, 1);
curtailmentTime_s = zeros(caseCount, 1);
peakDischargeCurrent_A = zeros(caseCount, 1);
peakChargeCurrent_A = zeros(caseCount, 1);
minimumDcVoltage_V = zeros(caseCount, 1);
maximumDcVoltage_V = zeros(caseCount, 1);
ohmicLossEnergy_kWh = zeros(caseCount, 1);
batteryEnergyResidual_J = zeros(caseCount, 1);
dcLinkEnergyResidual_J = zeros(caseCount, 1);
stateBatteryEnergyResidual_J = zeros(caseCount, 1);
stateDcLinkEnergyResidual_J = zeros(caseCount, 1);

caseIndex = 0;
for profileIndex = 1:numel(profiles)
    for reserveIndex = 1:numel(reserveLevels)
        caseIndex = caseIndex + 1;
        caseParameters = parameters;
        caseParameters.minimum_reserve_soc = reserveLevels(reserveIndex);
        caseParameters.request_breakpoints_s = ...
            profiles(profileIndex).request_breakpoints_s;
        caseParameters.requested_converter_power_W = ...
            profiles(profileIndex).requested_converter_power_W;
        result = simulate_bess_dc_reserve(caseParameters);
        metrics = summarize_bess_dc_reserve(result);
        timeStep_s = caseParameters.sample_time_s;
        activeDischargeTime_s = sum( ...
            result.requested_converter_power_W > 0)*timeStep_s;

        profileId(caseIndex) = profiles(profileIndex).id;
        minimumReserveSoc(caseIndex) = reserveLevels(reserveIndex);
        requestedDischargeEnergy_kWh(caseIndex) = ...
            metrics.requested_discharge_energy_kWh;
        deliveredDischargeEnergy_kWh(caseIndex) = ...
            metrics.delivered_discharge_energy_kWh;
        curtailedDischargeEnergy_kWh(caseIndex) = ...
            metrics.curtailed_discharge_energy_kWh;
        requestedChargeEnergy_kWh(caseIndex) = ...
            metrics.requested_charge_energy_kWh;
        acceptedChargeEnergy_kWh(caseIndex) = ...
            metrics.accepted_charge_energy_kWh;
        curtailedChargeEnergy_kWh(caseIndex) = ...
            metrics.requested_charge_energy_kWh - ...
            metrics.accepted_charge_energy_kWh;
        horizonAverageDeliveredDischargePower_kW(caseIndex) = ...
            metrics.delivered_discharge_energy_kWh*3600/parameters.end_time_s;
        if activeDischargeTime_s == 0
            activeWindowAverageDeliveredDischargePower_kW(caseIndex) = 0;
        else
            activeWindowAverageDeliveredDischargePower_kW(caseIndex) = ...
                metrics.delivered_discharge_energy_kWh*3600/activeDischargeTime_s;
        end
        minimumSoc(caseIndex) = metrics.minimum_soc;
        finalSoc(caseIndex) = metrics.final_soc;
        socTaperActiveTime_s(caseIndex) = metrics.soc_taper_active_time_s;
        curtailmentTime_s(caseIndex) = metrics.curtailment_time_s;
        peakDischargeCurrent_A(caseIndex) = metrics.peak_discharge_current_A;
        peakChargeCurrent_A(caseIndex) = metrics.peak_charge_current_A;
        minimumDcVoltage_V(caseIndex) = metrics.minimum_dc_voltage_V;
        maximumDcVoltage_V(caseIndex) = metrics.maximum_dc_voltage_V;
        ohmicLossEnergy_kWh(caseIndex) = metrics.ohmic_loss_energy_kWh;
        batteryEnergyResidual_J(caseIndex) = metrics.battery_energy_residual_J;
        dcLinkEnergyResidual_J(caseIndex) = metrics.dc_link_energy_residual_J;
        [stateBatteryEnergyResidual_J(caseIndex), ...
            stateDcLinkEnergyResidual_J(caseIndex)] = ...
            state_energy_residuals(result);
    end
end

sensitivity = table(profileId, minimumReserveSoc, ...
    requestedDischargeEnergy_kWh, deliveredDischargeEnergy_kWh, ...
    curtailedDischargeEnergy_kWh, requestedChargeEnergy_kWh, ...
    acceptedChargeEnergy_kWh, curtailedChargeEnergy_kWh, ...
    horizonAverageDeliveredDischargePower_kW, ...
    activeWindowAverageDeliveredDischargePower_kW, minimumSoc, finalSoc, ...
    socTaperActiveTime_s, curtailmentTime_s, peakDischargeCurrent_A, ...
    peakChargeCurrent_A, minimumDcVoltage_V, maximumDcVoltage_V, ...
    ohmicLossEnergy_kWh, batteryEnergyResidual_J, dcLinkEnergyResidual_J, ...
    stateBatteryEnergyResidual_J, stateDcLinkEnergyResidual_J);
end

function profiles = validate_profiles(profiles, parameters)
requiredFields = {'id', 'request_breakpoints_s', ...
    'requested_converter_power_W', 'description'};
if ~isstruct(profiles) || isempty(profiles) || ...
        ~all(isfield(profiles, requiredFields))
    error('BessDcProfileSensitivity:Profiles', ...
        'Profiles must be a nonempty structure with all required fields.');
end
ids = strings(numel(profiles), 1);
for profileIndex = 1:numel(profiles)
    id = string(profiles(profileIndex).id);
    description = string(profiles(profileIndex).description);
    if ~isscalar(id) || ismissing(id) || strlength(id) == 0 || ...
            ~isscalar(description) || ismissing(description) || ...
            strlength(description) == 0
        error('BessDcProfileSensitivity:Profiles', ...
            'Every profile needs a nonempty scalar ID and description.');
    end
    breakpoints = profiles(profileIndex).request_breakpoints_s;
    powers = profiles(profileIndex).requested_converter_power_W;
    if ~isnumeric(breakpoints) || ~isvector(breakpoints) || ...
            isempty(breakpoints) || ~isreal(breakpoints) || ...
            any(~isfinite(breakpoints)) || ~isnumeric(powers) || ...
            ~isvector(powers) || isempty(powers) || ~isreal(powers) || ...
            any(~isfinite(powers)) || numel(breakpoints) ~= numel(powers)
        error('BessDcProfileSensitivity:Profiles', ...
            'Profile breakpoints and powers must be equal finite real vectors.');
    end
    profiles(profileIndex).id = id;
    profiles(profileIndex).description = description;
    profiles(profileIndex).request_breakpoints_s = breakpoints(:);
    profiles(profileIndex).requested_converter_power_W = powers(:);
    testParameters = parameters;
    testParameters.request_breakpoints_s = breakpoints(:);
    testParameters.requested_converter_power_W = powers(:);
    simulate_bess_dc_reserve(testParameters);
    ids(profileIndex) = id;
end
if numel(unique(ids)) ~= numel(ids)
    error('BessDcProfileSensitivity:Profiles', ...
        'Profile IDs must be unique.');
end
end

function values = validate_reserves(values, initialSoc)
if ~isnumeric(values) || ~isvector(values) || isempty(values) || ...
        ~isreal(values) || any(~isfinite(values))
    error('BessDcEnvelope:ReserveLevels', ...
        'Reserve levels must be a finite real vector.');
end
values = values(:)';
if any(values < 0) || any(values >= initialSoc) || ...
        any(diff(values) <= 0)
    error('BessDcEnvelope:ReserveLevels', ...
        'Reserve levels must increase and remain below initial SOC.');
end
end

function [batteryResidual_J, dcResidual_J] = state_energy_residuals(result)
parameters = result.parameters;
capacityAs = parameters.capacity_Ah*3600;
socStart = result.soc(1);
socEnd = result.soc(end);
chemicalEnergyFromState_J = capacityAs*( ...
    parameters.ocv_intercept_V*(socStart - socEnd) + ...
    0.5*parameters.ocv_slope_V_per_soc*(socStart^2 - socEnd^2));
timeStep_s = parameters.sample_time_s;
terminalEnergy_J = sum(result.battery_power_W)*timeStep_s;
lossEnergy_J = sum(result.ohmic_loss_power_W)*timeStep_s;
batteryResidual_J = chemicalEnergyFromState_J - ...
    terminalEnergy_J - lossEnergy_J;
dcResidual_J = result.dc_energy_J(end) - result.dc_energy_J(1) - ...
    sum(result.battery_power_W - result.converter_power_W)*timeStep_s;
end
