function envelope = evaluate_bess_dc_reserve_envelope( ...
    parameters, reserveLevels, requestedDischargePower_W)
%EVALUATE_BESS_DC_RESERVE_ENVELOPE Sweep reserve and constant DC requests.

if nargin < 1 || isempty(parameters)
    parameters = bess_dc_reserve_default_parameters();
end
if nargin < 2
    reserveLevels = [0.10, 0.15, 0.20];
end
if nargin < 3
    requestedDischargePower_W = [0, 100e3, 200e3, 250e3, 300e3, 325e3];
end
reserveLevels = validate_reserves(reserveLevels, parameters.initial_soc);
requestedDischargePower_W = validate_requests(requestedDischargePower_W);

caseCount = numel(reserveLevels)*numel(requestedDischargePower_W);
minimumReserveSoc = zeros(caseCount, 1);
requestedDischargePower_kW = zeros(caseCount, 1);
requestedDischargeEnergy_kWh = zeros(caseCount, 1);
deliveredDischargeEnergy_kWh = zeros(caseCount, 1);
averageDeliveredPower_kW = zeros(caseCount, 1);
curtailedDischargeEnergy_kWh = zeros(caseCount, 1);
minimumSoc = zeros(caseCount, 1);
finalSoc = zeros(caseCount, 1);
socTaperActiveTime_s = zeros(caseCount, 1);
curtailmentTime_s = zeros(caseCount, 1);
peakDischargeCurrent_A = zeros(caseCount, 1);
minimumDcVoltage_V = zeros(caseCount, 1);
maximumDcVoltage_V = zeros(caseCount, 1);
ohmicLossEnergy_kWh = zeros(caseCount, 1);
batteryEnergyResidual_J = zeros(caseCount, 1);
dcLinkEnergyResidual_J = zeros(caseCount, 1);

caseIndex = 0;
for reserveIndex = 1:numel(reserveLevels)
    for requestIndex = 1:numel(requestedDischargePower_W)
        caseIndex = caseIndex + 1;
        caseParameters = parameters;
        caseParameters.minimum_reserve_soc = reserveLevels(reserveIndex);
        caseParameters.request_breakpoints_s = 0;
        caseParameters.requested_converter_power_W = ...
            requestedDischargePower_W(requestIndex);
        result = simulate_bess_dc_reserve(caseParameters);
        metrics = summarize_bess_dc_reserve(result);

        minimumReserveSoc(caseIndex) = reserveLevels(reserveIndex);
        requestedDischargePower_kW(caseIndex) = ...
            requestedDischargePower_W(requestIndex)/1000;
        requestedDischargeEnergy_kWh(caseIndex) = ...
            metrics.requested_discharge_energy_kWh;
        deliveredDischargeEnergy_kWh(caseIndex) = ...
            metrics.delivered_discharge_energy_kWh;
        averageDeliveredPower_kW(caseIndex) = ...
            metrics.delivered_discharge_energy_kWh*3600/parameters.end_time_s;
        curtailedDischargeEnergy_kWh(caseIndex) = ...
            metrics.curtailed_discharge_energy_kWh;
        minimumSoc(caseIndex) = metrics.minimum_soc;
        finalSoc(caseIndex) = metrics.final_soc;
        socTaperActiveTime_s(caseIndex) = ...
            metrics.soc_taper_active_time_s;
        curtailmentTime_s(caseIndex) = metrics.curtailment_time_s;
        peakDischargeCurrent_A(caseIndex) = ...
            metrics.peak_discharge_current_A;
        minimumDcVoltage_V(caseIndex) = metrics.minimum_dc_voltage_V;
        maximumDcVoltage_V(caseIndex) = metrics.maximum_dc_voltage_V;
        ohmicLossEnergy_kWh(caseIndex) = metrics.ohmic_loss_energy_kWh;
        batteryEnergyResidual_J(caseIndex) = ...
            metrics.battery_energy_residual_J;
        dcLinkEnergyResidual_J(caseIndex) = ...
            metrics.dc_link_energy_residual_J;
    end
end

envelope = table(minimumReserveSoc, requestedDischargePower_kW, ...
    requestedDischargeEnergy_kWh, deliveredDischargeEnergy_kWh, ...
    averageDeliveredPower_kW, curtailedDischargeEnergy_kWh, minimumSoc, ...
    finalSoc, socTaperActiveTime_s, curtailmentTime_s, ...
    peakDischargeCurrent_A, ...
    minimumDcVoltage_V, maximumDcVoltage_V, ohmicLossEnergy_kWh, ...
    batteryEnergyResidual_J, dcLinkEnergyResidual_J);
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

function values = validate_requests(values)
if ~isnumeric(values) || ~isvector(values) || isempty(values) || ...
        ~isreal(values) || any(~isfinite(values))
    error('BessDcEnvelope:RequestedPower', ...
        'Requested powers must be a finite real vector.');
end
values = values(:)';
if any(values < 0) || any(diff(values) <= 0)
    error('BessDcEnvelope:RequestedPower', ...
        'Requested powers must be nonnegative and strictly increasing.');
end
end
