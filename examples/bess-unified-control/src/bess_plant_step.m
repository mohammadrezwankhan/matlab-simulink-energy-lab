function state = bess_plant_step(inputVector, command, state, parameters)
%BESS_PLANT_STEP Advance the reduced-order averaged three-phase plant.

input = bess_unpack_input(inputVector);
states = bess_state_codes();
canClose = command.breaker_command && input.grid_present && ...
    command.controller_ready && command.measurement_valid;
state.breaker_closed = logical(canClose);

if state.breaker_closed
    targetP_pu = command.p_command_pu;
    targetQ_pu = command.q_command_pu;
    targetVoltage_pu = max(0, input.grid_voltage_pu + ...
        parameters.grid_voltage_sensitivity_pu_per_pu * state.q_pu);
    targetFrequency_Hz = input.grid_frequency_Hz;
else
    targetP_pu = command.p_command_pu;
    targetQ_pu = command.q_command_pu;
    targetVoltage_pu = command.voltage_command_pu;
    targetFrequency_Hz = command.frequency_command_Hz;
end
if command.state_code == states.FAULT_SAFE
    targetP_pu = 0;
    targetQ_pu = 0;
end

currentAlpha = 1 - exp(-parameters.sample_time_s / ...
    parameters.filter_current_time_constant_s);
voltageAlpha = 1 - exp(-parameters.sample_time_s / ...
    parameters.plant_voltage_time_constant_s);
frequencyAlpha = 1 - exp(-parameters.sample_time_s / ...
    parameters.plant_frequency_time_constant_s);
state.voltage_pu = state.voltage_pu + voltageAlpha * ...
    (targetVoltage_pu - state.voltage_pu);
state.frequency_Hz = state.frequency_Hz + frequencyAlpha * ...
    (targetFrequency_Hz - state.frequency_Hz);

voltageForCurrent_pu = max(state.voltage_pu, 0.05);
targetCurrentD_pu = targetP_pu / voltageForCurrent_pu;
targetCurrentQ_pu = -targetQ_pu / voltageForCurrent_pu;
state.current_d_pu = state.current_d_pu + currentAlpha * ...
    (targetCurrentD_pu - state.current_d_pu);
state.current_q_pu = state.current_q_pu + currentAlpha * ...
    (targetCurrentQ_pu - state.current_q_pu);
currentMagnitude_pu = hypot( ...
    state.current_d_pu, state.current_q_pu);
if currentMagnitude_pu > parameters.current_limit_pu
    scale = parameters.current_limit_pu / currentMagnitude_pu;
    state.current_d_pu = state.current_d_pu * scale;
    state.current_q_pu = state.current_q_pu * scale;
end
state.p_pu = state.voltage_pu * state.current_d_pu;
state.q_pu = -state.voltage_pu * state.current_q_pu;
if state.breaker_closed
    state.phase_rad = input.grid_phase_rad;
else
    state.phase_rad = state.phase_rad + 2 * pi * ...
        state.frequency_Hz * parameters.sample_time_s;
end
end
