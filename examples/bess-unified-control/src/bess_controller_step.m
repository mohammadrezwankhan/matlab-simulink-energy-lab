function [command, state] = bess_controller_step(inputVector, ...
        measurement, state, parameters)
%BESS_CONTROLLER_STEP Execute conditioning, supervisor, control, and limits.

input = bess_unpack_input(inputVector);
states = bess_state_codes();
[conditioned, measurementValid] = bess_condition_measurement( ...
    measurement, input, parameters);
if measurementValid
    gridPhaseForSync_rad = input.grid_phase_rad;
    if measurement.breaker_closed && input.time_s > 0
        gridPhaseForSync_rad = input.grid_phase_rad - 2 * pi * ...
            input.grid_frequency_Hz * parameters.sample_time_s;
    end
    sync = bess_sync_metrics(conditioned.voltage_pu, ...
        conditioned.frequency_Hz, conditioned.phase_rad, ...
        input.grid_voltage_pu, input.grid_frequency_Hz, ...
        gridPhaseForSync_rad, parameters);
else
    sync.voltage_mismatch_pu = ...
        parameters.maximum_valid_voltage_pu + 1;
    sync.frequency_mismatch_Hz = ...
        parameters.maximum_valid_frequency_Hz;
    sync.phase_error_rad = pi;
    sync.phase_mismatch_deg = 180;
    sync.within_limits = false;
end
syncReady = sync.within_limits && measurementValid && ...
    input.grid_present && input.request_grid_following;

previousMode = state.mode;
state.state_timer_s = state.state_timer_s + parameters.sample_time_s;
faultRequested = ~measurementValid;
if faultRequested && state.mode ~= states.FAULT_SAFE
    state.mode = states.FAULT_SAFE;
    state.state_timer_s = 0;
    state.sync_timer_s = 0;
elseif state.mode == states.FAULT_SAFE
    if ~faultRequested
        state.mode = states.RECOVERY;
        state.state_timer_s = 0;
    end
elseif state.mode == states.RECOVERY
    if state.state_timer_s >= parameters.recovery_hold_time_s
        if input.grid_present && input.request_grid_following
            state.mode = states.SYNCHRONIZING;
        else
            state.mode = states.GRID_FORMING;
        end
        state.state_timer_s = 0;
    end
elseif state.mode == states.GRID_FOLLOWING
    if ~input.grid_present || ~input.request_grid_following
        state.mode = states.PREPARE_ISLAND;
        state.state_timer_s = 0;
    end
elseif state.mode == states.PREPARE_ISLAND
    if state.state_timer_s >= parameters.prepare_island_time_s
        state.mode = states.GRID_FORMING;
        state.state_timer_s = 0;
    end
elseif state.mode == states.GRID_FORMING
    if state.state_timer_s >= parameters.forming_prepare_time_s
        state.mode = states.ISLANDED_SUPPORT;
        state.state_timer_s = 0;
    end
elseif state.mode == states.ISLANDED_SUPPORT
    if input.grid_present && input.request_grid_following
        state.mode = states.SYNCHRONIZING;
        state.state_timer_s = 0;
        state.sync_timer_s = 0;
    end
elseif state.mode == states.SYNCHRONIZING
    if ~input.grid_present || ~input.request_grid_following
        state.mode = states.ISLANDED_SUPPORT;
        state.state_timer_s = 0;
        state.sync_timer_s = 0;
    elseif syncReady
        state.sync_timer_s = state.sync_timer_s + ...
            parameters.sample_time_s;
        if state.sync_timer_s >= parameters.sync_hold_time_s
            state.mode = states.PREPARE_RECONNECT;
            state.state_timer_s = 0;
        end
    else
        state.sync_timer_s = 0;
    end
elseif state.mode == states.PREPARE_RECONNECT
    if ~syncReady
        state.mode = states.SYNCHRONIZING;
        state.state_timer_s = 0;
        state.sync_timer_s = 0;
    elseif state.state_timer_s >= parameters.prepare_reconnect_time_s
        state.mode = states.GRID_FOLLOWING;
        state.state_timer_s = 0;
    end
else
    state.mode = states.FAULT_SAFE;
    state.state_timer_s = 0;
end

if state.mode ~= previousMode && ...
        state.mode ~= states.SYNCHRONIZING
    state.sync_timer_s = 0;
end

if measurementValid
    measuredP_pu = conditioned.p_from_abc_pu;
    measuredQ_pu = conditioned.q_from_abc_pu;
    measuredVoltage_pu = conditioned.voltage_pu;
    measuredFrequency_Hz = conditioned.frequency_Hz;
else
    measuredP_pu = 0;
    measuredQ_pu = 0;
    measuredVoltage_pu = input.voltage_ref_pu;
    measuredFrequency_Hz = input.frequency_ref_Hz;
end

formingState = any(state.mode == [
    states.PREPARE_ISLAND, states.GRID_FORMING, ...
    states.ISLANDED_SUPPORT, states.SYNCHRONIZING, ...
    states.PREPARE_RECONNECT, states.RECOVERY]);
if state.mode == states.GRID_FOLLOWING
    supportFrequency = input.grid_support_enable * ...
        parameters.grid_support_frequency_gain_pu_per_Hz * ...
        (input.frequency_ref_Hz - measuredFrequency_Hz);
    supportVoltage = input.grid_support_enable * ...
        parameters.grid_support_voltage_gain_pu_per_pu * ...
        (input.voltage_ref_pu - measuredVoltage_pu);
    requestedP_pu = input.p_ref_pu + supportFrequency;
    requestedQ_pu = input.q_ref_pu + supportVoltage;
    rawVoltageCommand_pu = input.grid_voltage_pu;
    rawFrequencyCommand_Hz = input.grid_frequency_Hz;
elseif formingState
    requestedP_pu = input.load_p_pu;
    requestedQ_pu = input.load_q_pu;
    if state.mode == states.SYNCHRONIZING || ...
            state.mode == states.PREPARE_RECONNECT
        rawFrequencyCommand_Hz = input.grid_frequency_Hz + ...
            parameters.sync_phase_gain_Hz_per_rad * ...
            sync.phase_error_rad;
        rawVoltageCommand_pu = input.grid_voltage_pu + ...
            parameters.sync_voltage_gain * ...
            (input.grid_voltage_pu - measuredVoltage_pu);
    else
        frequencyError_Hz = input.frequency_ref_Hz - ...
            measuredFrequency_Hz;
        voltageError_pu = input.voltage_ref_pu - ...
            measuredVoltage_pu;
        state.frequency_restoration_Hz = clamp( ...
            state.frequency_restoration_Hz + ...
            parameters.frequency_restoration_gain_per_s * ...
            frequencyError_Hz * parameters.sample_time_s, -1, 1);
        state.voltage_restoration_pu = clamp( ...
            state.voltage_restoration_pu + ...
            parameters.voltage_restoration_gain_per_s * ...
            voltageError_pu * parameters.sample_time_s, -0.2, 0.2);
        rawFrequencyCommand_Hz = input.frequency_ref_Hz - ...
            parameters.grid_frequency_droop_Hz_per_pu * ...
            (measuredP_pu - input.p_ref_pu) + ...
            state.frequency_restoration_Hz;
        rawVoltageCommand_pu = input.voltage_ref_pu - ...
            parameters.grid_voltage_droop_pu_per_pu * ...
            (measuredQ_pu - input.q_ref_pu) + ...
            state.voltage_restoration_pu;
    end
else
    requestedP_pu = 0;
    requestedQ_pu = 0;
    rawVoltageCommand_pu = input.voltage_ref_pu;
    rawFrequencyCommand_Hz = input.frequency_ref_Hz;
end

if state.mode == states.FAULT_SAFE
    requestedP_pu = 0;
    requestedQ_pu = 0;
end
[limitedP_pu, limitedQ_pu, ~, saturated] = bess_limit_pq( ...
    requestedP_pu, requestedQ_pu, max(measuredVoltage_pu, 0.05), ...
    input.available_power_pu, parameters);

command.p_command_pu = slew( ...
    state.previous_p_command_pu, limitedP_pu, ...
    parameters.power_command_slew_pu_per_s * parameters.sample_time_s);
command.q_command_pu = slew( ...
    state.previous_q_command_pu, limitedQ_pu, ...
    parameters.power_command_slew_pu_per_s * parameters.sample_time_s);
rawVoltageCommand_pu = clamp(rawVoltageCommand_pu, 0, 1.2);
rawFrequencyCommand_Hz = clamp(rawFrequencyCommand_Hz, ...
    0.98 * parameters.nominal_frequency_Hz, ...
    1.02 * parameters.nominal_frequency_Hz);
command.voltage_command_pu = slew( ...
    state.previous_voltage_command_pu, rawVoltageCommand_pu, ...
    parameters.voltage_command_slew_pu_per_s * ...
    parameters.sample_time_s);
command.frequency_command_Hz = slew( ...
    state.previous_frequency_command_Hz, rawFrequencyCommand_Hz, ...
    parameters.frequency_command_slew_Hz_per_s * ...
    parameters.sample_time_s);

command.breaker_command = state.mode == states.GRID_FOLLOWING && ...
    input.grid_present && measurementValid && ...
    (measurement.breaker_closed || syncReady);
command.state_code = state.mode;
command.controller_ready = measurementValid && ...
    state.mode ~= states.FAULT_SAFE;
command.sync_ready = syncReady;
command.saturated = saturated;
command.faulted = state.mode == states.FAULT_SAFE;
command.measurement_valid = measurementValid;
command.phase_error_rad = sync.phase_error_rad;
command.voltage_mismatch_pu = sync.voltage_mismatch_pu;
command.frequency_mismatch_Hz = sync.frequency_mismatch_Hz;

state.previous_p_command_pu = command.p_command_pu;
state.previous_q_command_pu = command.q_command_pu;
state.previous_voltage_command_pu = command.voltage_command_pu;
state.previous_frequency_command_Hz = command.frequency_command_Hz;
end

function value = clamp(value, lowerBound, upperBound)
value = min(max(value, lowerBound), upperBound);
end

function value = slew(previousValue, targetValue, maximumStep)
value = previousValue + min(max(targetValue - previousValue, ...
    -maximumStep), maximumStep);
end
