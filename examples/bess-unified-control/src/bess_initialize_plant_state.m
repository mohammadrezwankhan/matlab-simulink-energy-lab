function state = bess_initialize_plant_state(inputVector, parameters)
%BESS_INITIALIZE_PLANT_STATE Create deterministic plant initial conditions.

input = bess_unpack_input(inputVector);
state.p_pu = 0;
state.q_pu = 0;
state.current_d_pu = 0;
state.current_q_pu = 0;
state.voltage_pu = input.voltage_ref_pu;
state.frequency_Hz = input.frequency_ref_Hz;
if input.grid_present
    state.phase_rad = input.grid_phase_rad;
    state.breaker_closed = true;
else
    state.phase_rad = 0;
    state.breaker_closed = false;
end
state = enforce_state_limits(state, parameters);
end

function state = enforce_state_limits(state, parameters)
state.voltage_pu = min(max(state.voltage_pu, 0), ...
    parameters.maximum_valid_voltage_pu);
state.frequency_Hz = min(max(state.frequency_Hz, ...
    parameters.minimum_valid_frequency_Hz), ...
    parameters.maximum_valid_frequency_Hz);
end
