function metrics = summarize_bess_dc_reserve(result)
%SUMMARIZE_BESS_DC_RESERVE Return deterministic reserve and energy metrics.

parameters = result.parameters;
timeStep_s = parameters.sample_time_s;
requestedDischarge_W = max(result.requested_converter_power_W, 0);
deliveredDischarge_W = max(result.converter_power_W, 0);
requestedCharge_W = max(-result.requested_converter_power_W, 0);
acceptedCharge_W = max(-result.converter_power_W, 0);

metrics.minimum_soc = min(result.soc);
metrics.final_soc = result.soc(end);
metrics.minimum_dc_voltage_V = min(result.dc_voltage_V);
metrics.maximum_dc_voltage_V = max(result.dc_voltage_V);
metrics.peak_discharge_current_A = max(result.battery_current_A);
metrics.peak_charge_current_A = max(-result.battery_current_A);
metrics.requested_discharge_energy_kWh = ...
    sum(requestedDischarge_W)*timeStep_s/3.6e6;
metrics.delivered_discharge_energy_kWh = ...
    sum(deliveredDischarge_W)*timeStep_s/3.6e6;
metrics.curtailed_discharge_energy_kWh = sum(max( ...
    requestedDischarge_W - deliveredDischarge_W, 0))*timeStep_s/3.6e6;
metrics.requested_charge_energy_kWh = ...
    sum(requestedCharge_W)*timeStep_s/3.6e6;
metrics.accepted_charge_energy_kWh = ...
    sum(acceptedCharge_W)*timeStep_s/3.6e6;
metrics.reserve_limited_time_s = sum( ...
    result.requested_converter_power_W > 0 & ...
    result.discharge_availability < 1 - 1e-12)*timeStep_s;
metrics.ohmic_loss_energy_kWh = ...
    sum(result.ohmic_loss_power_W)*timeStep_s/3.6e6;
chemicalEnergy_J = sum(result.chemical_power_W)*timeStep_s;
terminalEnergy_J = sum(result.battery_power_W)*timeStep_s;
ohmicLossEnergy_J = sum(result.ohmic_loss_power_W)*timeStep_s;
metrics.battery_energy_residual_J = chemicalEnergy_J - ...
    terminalEnergy_J - ohmicLossEnergy_J;
metrics.dc_link_energy_residual_J = result.dc_energy_J(1) + ...
    sum(result.battery_power_W - result.converter_power_W)*timeStep_s - ...
    result.dc_energy_J(end);
end
