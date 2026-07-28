function scenarios = bess_validation_scenarios(parameters)
%BESS_VALIDATION_SCENARIOS Return deterministic mandatory scenarios A-H.

if nargin < 1
    parameters = bess_unified_control_parameters();
end
scenarios = repmat(base_scenario(parameters, 'A', '', 8), 1, 8);

scenarios(1) = base_scenario(parameters, 'A', ...
    'Grid-following active and reactive power steps', 8);
scenarios(1).inputs.p_ref_pu(scenarios(1).time_s >= 1) = 0.8;
scenarios(1).inputs.q_ref_pu(scenarios(1).time_s >= 3) = 0.2;
scenarios(1).inputs.q_ref_pu(scenarios(1).time_s >= 5) = -0.4;

scenarios(2) = base_scenario(parameters, 'B', ...
    'Grid voltage dip and frequency disturbance', 8);
scenarios(2).inputs.p_ref_pu(:) = 0.5;
scenarios(2).inputs.grid_support_enable(:) = 1;
dip = scenarios(2).time_s >= 2 & scenarios(2).time_s < 2.10;
halfRecovery = scenarios(2).time_s >= 2.10 & ...
    scenarios(2).time_s < 2.15;
scenarios(2).inputs.grid_voltage_pu(dip) = 0;
scenarios(2).inputs.grid_voltage_pu(halfRecovery) = 0.5;
frequencyEvent = scenarios(2).time_s >= 4 & ...
    scenarios(2).time_s < 4.4;
scenarios(2).inputs.grid_frequency_Hz(frequencyEvent) = 49.5;

scenarios(3) = base_scenario(parameters, 'C', ...
    'Grid loss and transition to islanded support', 8);
scenarios(3).inputs.p_ref_pu(:) = 0.5;
scenarios(3).inputs.q_ref_pu(:) = 0.1;
scenarios(3).inputs.load_p_pu(:) = 0.5;
scenarios(3).inputs.load_q_pu(:) = 0.1;
gridLost = scenarios(3).time_s >= 2;
scenarios(3).inputs.grid_present(gridLost) = 0;

scenarios(4) = base_scenario(parameters, 'D', ...
    'Islanded load increase and decrease', 8);
scenarios(4).inputs.grid_present(:) = 0;
scenarios(4).inputs.request_grid_following(:) = 0;
scenarios(4).inputs.load_p_pu(:) = 0.3;
scenarios(4).inputs.p_ref_pu(:) = 0.3;
loadIncrease = scenarios(4).time_s >= 2;
scenarios(4).inputs.load_p_pu(loadIncrease) = 0.8;
scenarios(4).inputs.p_ref_pu(loadIncrease) = 0.8;
loadDecrease = scenarios(4).time_s >= 5;
scenarios(4).inputs.load_p_pu(loadDecrease) = 0.4;
scenarios(4).inputs.p_ref_pu(loadDecrease) = 0.4;

scenarios(5) = base_scenario(parameters, 'E', ...
    'Grid return, synchronization, and reconnection', 8);
scenarios(5).inputs.grid_present(:) = 0;
scenarios(5).inputs.p_ref_pu(:) = 0.5;
scenarios(5).inputs.q_ref_pu(:) = 0.1;
scenarios(5).inputs.load_p_pu(:) = 0.5;
scenarios(5).inputs.load_q_pu(:) = 0.1;
scenarios(5).grid_phase_offset_rad = deg2rad(25);
gridReturned = scenarios(5).time_s >= 3;
scenarios(5).inputs.grid_present(gridReturned) = 1;
scenarios(5).inputs.grid_frequency_Hz(gridReturned) = 50.05;

scenarios(6) = base_scenario(parameters, 'F', ...
    'Infeasible P-Q command saturation and recovery', 7);
highCommand = scenarios(6).time_s >= 1 & ...
    scenarios(6).time_s < 4;
scenarios(6).inputs.p_ref_pu(highCommand) = 1.30;
scenarios(6).inputs.q_ref_pu(highCommand) = 0.80;
recoveredCommand = scenarios(6).time_s >= 4;
scenarios(6).inputs.p_ref_pu(recoveredCommand) = 0.40;
scenarios(6).inputs.q_ref_pu(recoveredCommand) = 0;

scenarios(7) = base_scenario(parameters, 'G', ...
    'Invalid measurement, fault-safe state, and recovery', 8);
scenarios(7).inputs.p_ref_pu(:) = 0.5;
invalidMeasurement = scenarios(7).time_s >= 2 & ...
    scenarios(7).time_s < 2.30;
scenarios(7).inputs.fault_code(invalidMeasurement) = 1;

scenarios(8) = base_scenario(parameters, 'H', ...
    'Valid operating boundaries and DC availability', 7);
scenarios(8).inputs.available_power_pu(:) = 0.20;
scenarios(8).inputs.dc_voltage_pu(:) = ...
    parameters.minimum_dc_voltage_pu;
scenarios(8).grid_phase_offset_rad = deg2rad(5);
scenarios(8).inputs.p_ref_pu(:) = 0.20;
scenarios(8).inputs.p_ref_pu(scenarios(8).time_s >= 1 & ...
    scenarios(8).time_s < 2) = 0;
scenarios(8).inputs.p_ref_pu(scenarios(8).time_s >= 2) = 1.0;
scenarios(8).inputs.q_ref_pu(scenarios(8).time_s >= 3) = 0.8;
biasInterval = scenarios(8).time_s >= 4 & ...
    scenarios(8).time_s < 4.5;
scenarios(8).inputs.fault_code(biasInterval) = 3;

for scenarioIndex = 1:numel(scenarios)
    scenarios(scenarioIndex) = finalize_grid_phase( ...
        scenarios(scenarioIndex), parameters);
end
end

function scenario = base_scenario(parameters, identifier, description, ...
        endTime_s)
time_s = (0:parameters.sample_time_s:endTime_s)';
sampleCount = numel(time_s);
scenario.id = identifier;
scenario.name = ['Scenario ', identifier];
scenario.description = description;
scenario.time_s = time_s;
scenario.grid_phase_offset_rad = 0;
scenario.inputs.p_ref_pu = 0.2 * ones(sampleCount, 1);
scenario.inputs.q_ref_pu = zeros(sampleCount, 1);
scenario.inputs.voltage_ref_pu = ones(sampleCount, 1);
scenario.inputs.frequency_ref_Hz = ...
    parameters.nominal_frequency_Hz * ones(sampleCount, 1);
scenario.inputs.load_p_pu = 0.2 * ones(sampleCount, 1);
scenario.inputs.load_q_pu = zeros(sampleCount, 1);
scenario.inputs.grid_present = ones(sampleCount, 1);
scenario.inputs.grid_voltage_pu = ones(sampleCount, 1);
scenario.inputs.grid_frequency_Hz = ...
    parameters.nominal_frequency_Hz * ones(sampleCount, 1);
scenario.inputs.grid_phase_rad = zeros(sampleCount, 1);
scenario.inputs.request_grid_following = ones(sampleCount, 1);
scenario.inputs.grid_support_enable = zeros(sampleCount, 1);
scenario.inputs.fault_code = zeros(sampleCount, 1);
scenario.inputs.available_power_pu = ones(sampleCount, 1);
scenario.inputs.dc_voltage_pu = ones(sampleCount, 1);
end

function scenario = finalize_grid_phase(scenario, parameters)
time_s = scenario.time_s;
frequency_Hz = scenario.inputs.grid_frequency_Hz;
phase_rad = zeros(size(time_s));
phase_rad(1) = scenario.grid_phase_offset_rad;
for sampleIndex = 2:numel(time_s)
    phase_rad(sampleIndex) = phase_rad(sampleIndex - 1) + ...
        2 * pi * frequency_Hz(sampleIndex - 1) * ...
        parameters.sample_time_s;
end
scenario.inputs.grid_phase_rad = phase_rad;
end
