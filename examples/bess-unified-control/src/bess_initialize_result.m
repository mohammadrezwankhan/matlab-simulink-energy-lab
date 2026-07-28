function result = bess_initialize_result(scenario)
%BESS_INITIALIZE_RESULT Allocate the documented scenario result interface.

sampleCount = numel(scenario.time_s);
result.scenario_id = scenario.id;
result.scenario_name = scenario.name;
result.description = scenario.description;
result.time_s = scenario.time_s;
result.p_ref_pu = scenario.inputs.p_ref_pu;
result.q_ref_pu = scenario.inputs.q_ref_pu;
result.load_p_pu = scenario.inputs.load_p_pu;
result.load_q_pu = scenario.inputs.load_q_pu;
result.grid_present = scenario.inputs.grid_present;
result.grid_voltage_pu = scenario.inputs.grid_voltage_pu;
result.grid_frequency_Hz = scenario.inputs.grid_frequency_Hz;
result.p_pu = zeros(sampleCount, 1);
result.q_pu = zeros(sampleCount, 1);
result.voltage_pu = zeros(sampleCount, 1);
result.frequency_Hz = zeros(sampleCount, 1);
result.phase_rad = zeros(sampleCount, 1);
result.current_pu = zeros(sampleCount, 1);
result.breaker_closed = false(sampleCount, 1);
result.state_code = zeros(sampleCount, 1);
result.controller_ready = false(sampleCount, 1);
result.sync_ready = false(sampleCount, 1);
result.saturated = false(sampleCount, 1);
result.faulted = false(sampleCount, 1);
result.measurement_valid = false(sampleCount, 1);
result.p_command_pu = zeros(sampleCount, 1);
result.q_command_pu = zeros(sampleCount, 1);
result.voltage_command_pu = zeros(sampleCount, 1);
result.frequency_command_Hz = zeros(sampleCount, 1);
result.phase_error_rad = zeros(sampleCount, 1);
result.voltage_mismatch_pu = zeros(sampleCount, 1);
result.frequency_mismatch_Hz = zeros(sampleCount, 1);
end
