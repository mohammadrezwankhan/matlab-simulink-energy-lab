function state = bess_initialize_controller_state(inputVector, measurement)
%BESS_INITIALIZE_CONTROLLER_STATE Create deterministic supervisor state.

input = bess_unpack_input(inputVector);
states = bess_state_codes();
if input.grid_present && input.request_grid_following
    state.mode = states.GRID_FOLLOWING;
else
    state.mode = states.GRID_FORMING;
end
state.state_timer_s = 0;
state.sync_timer_s = 0;
state.frequency_restoration_Hz = 0;
state.voltage_restoration_pu = 0;
state.previous_p_command_pu = measurement.p_pu;
state.previous_q_command_pu = measurement.q_pu;
state.previous_voltage_command_pu = max(measurement.voltage_pu, 0.9);
state.previous_frequency_command_Hz = measurement.frequency_Hz;
end
