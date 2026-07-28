function result = simulate_bess_unified_control(scenario, parameters)
%SIMULATE_BESS_UNIFIED_CONTROL Run one deterministic closed-loop scenario.

if nargin < 2
    parameters = bess_unified_control_parameters();
end
exampleDirectory = fileparts(mfilename('fullpath'));
sourceDirectory = fullfile(exampleDirectory, 'src');
originalPath = path;
pathCleanup = onCleanup(@() path(originalPath));
addpath(exampleDirectory, sourceDirectory);

inputVector = bess_scenario_input_vector(scenario, 1);
plantState = bess_initialize_plant_state(inputVector, parameters);
measurement = bess_measure_plant(plantState);
controllerState = bess_initialize_controller_state(inputVector, measurement);

result = bess_initialize_result(scenario);
sampleCount = numel(scenario.time_s);

for sampleIndex = 1:sampleCount
    inputVector = bess_scenario_input_vector(scenario, sampleIndex);
    [command, controllerState] = bess_controller_step( ...
        inputVector, measurement, controllerState, parameters);
    plantState = bess_plant_step( ...
        inputVector, command, plantState, parameters);
    measurement = bess_measure_plant(plantState);

    result.p_pu(sampleIndex) = measurement.p_pu;
    result.q_pu(sampleIndex) = measurement.q_pu;
    result.voltage_pu(sampleIndex) = measurement.voltage_pu;
    result.frequency_Hz(sampleIndex) = measurement.frequency_Hz;
    result.phase_rad(sampleIndex) = measurement.phase_rad;
    result.current_pu(sampleIndex) = measurement.current_pu;
    result.breaker_closed(sampleIndex) = measurement.breaker_closed;
    result.state_code(sampleIndex) = command.state_code;
    result.controller_ready(sampleIndex) = command.controller_ready;
    result.sync_ready(sampleIndex) = command.sync_ready;
    result.saturated(sampleIndex) = command.saturated;
    result.faulted(sampleIndex) = command.faulted;
    result.measurement_valid(sampleIndex) = command.measurement_valid;
    result.p_command_pu(sampleIndex) = command.p_command_pu;
    result.q_command_pu(sampleIndex) = command.q_command_pu;
    result.voltage_command_pu(sampleIndex) = ...
        command.voltage_command_pu;
    result.frequency_command_Hz(sampleIndex) = ...
        command.frequency_command_Hz;
    result.phase_error_rad(sampleIndex) = command.phase_error_rad;
    result.voltage_mismatch_pu(sampleIndex) = ...
        command.voltage_mismatch_pu;
    result.frequency_mismatch_Hz(sampleIndex) = ...
        command.frequency_mismatch_Hz;
end
clear pathCleanup;
end
