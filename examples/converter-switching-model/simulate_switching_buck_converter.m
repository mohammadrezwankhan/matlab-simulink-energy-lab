function result = simulate_switching_buck_converter(parameters)
%SIMULATE_SWITCHING_BUCK_CONVERTER Simulate an ideal switched synchronous buck.

if nargin < 1
    parameters = switching_buck_default_parameters();
end

requiredFields = {
    'input_voltage_V', ...
    'duty_cycle', ...
    'switching_frequency_Hz', ...
    'inductance_H', ...
    'inductor_resistance_Ohm', ...
    'capacitance_F', ...
    'load_resistance_Ohm', ...
    'end_time_s', ...
    'steps_per_switching_period', ...
    'initial_inductor_current_A', ...
    'initial_output_voltage_V'
};
if ~isstruct(parameters) || ~all(isfield(parameters, requiredFields))
    error('SwitchingBuck:Parameters', ...
        'Parameter structure is missing one or more required fields.');
end
for fieldIndex = 1:numel(requiredFields)
    fieldName = requiredFields{fieldIndex};
    value = parameters.(fieldName);
    if ~isnumeric(value) || ~isscalar(value) || ~isreal(value) || ...
            ~isfinite(value)
        error('SwitchingBuck:Parameters', ...
            'Every parameter must be a finite numeric scalar.');
    end
end

positiveFields = {
    'input_voltage_V', ...
    'switching_frequency_Hz', ...
    'inductance_H', ...
    'capacitance_F', ...
    'load_resistance_Ohm', ...
    'end_time_s'
};
for fieldIndex = 1:numel(positiveFields)
    if parameters.(positiveFields{fieldIndex}) <= 0
        error('SwitchingBuck:Parameters', ...
            'Voltage, frequency, L, C, load, and duration must be positive.');
    end
end
if parameters.inductor_resistance_Ohm < 0
    error('SwitchingBuck:Parameters', ...
        'Inductor resistance must be nonnegative.');
end
if parameters.duty_cycle <= 0 || parameters.duty_cycle >= 1
    error('SwitchingBuck:Parameters', ...
        'Duty cycle must be strictly between zero and one.');
end

stepsPerPeriod = parameters.steps_per_switching_period;
if stepsPerPeriod ~= round(stepsPerPeriod) || stepsPerPeriod < 20
    error('SwitchingBuck:TimeGrid', ...
        'Steps per switching period must be an integer of at least 20.');
end
onStepsPerPeriod = parameters.duty_cycle * stepsPerPeriod;
if abs(onStepsPerPeriod - round(onStepsPerPeriod)) > 1e-10
    error('SwitchingBuck:TimeGrid', ...
        'Duty cycle must align with an integer PWM step count.');
end
onStepsPerPeriod = round(onStepsPerPeriod);

periodCount = parameters.end_time_s * ...
    parameters.switching_frequency_Hz;
if abs(periodCount - round(periodCount)) > 1e-10
    error('SwitchingBuck:TimeGrid', ...
        'Simulation duration must contain a whole number of switching periods.');
end
periodCount = round(periodCount);

switchingPeriod_s = 1 / parameters.switching_frequency_Hz;
timeStep_s = switchingPeriod_s / stepsPerPeriod;
intervalCount = periodCount * stepsPerPeriod;
time_s = (0:intervalCount)' * timeStep_s;
intervalStartTime_s = time_s(1:end-1);
phaseStep = mod((0:(intervalCount - 1))', stepsPerPeriod);
switchState = phaseStep < onStepsPerPeriod;

systemMatrix = [
    -parameters.inductor_resistance_Ohm / parameters.inductance_H, ...
    -1 / parameters.inductance_H; ...
    1 / parameters.capacitance_F, ...
    -1 / (parameters.load_resistance_Ohm * parameters.capacitance_F)
];
inputVector = [
    parameters.input_voltage_V / parameters.inductance_H; ...
    0
];
stateTransition = expm(systemMatrix * timeStep_s);
onInputIncrement = systemMatrix \ ...
    ((stateTransition - eye(2)) * inputVector);

state = zeros(2, intervalCount + 1);
state(:, 1) = [
    parameters.initial_inductor_current_A; ...
    parameters.initial_output_voltage_V
];
for intervalIndex = 1:intervalCount
    state(:, intervalIndex + 1) = ...
        stateTransition * state(:, intervalIndex) + ...
        double(switchState(intervalIndex)) * onInputIncrement;
end

inductorCurrent_A = state(1, :)';
outputVoltage_V = state(2, :)';
loadCurrent_A = outputVoltage_V / parameters.load_resistance_Ohm;
capacitorCurrent_A = inductorCurrent_A - loadCurrent_A;
switchNodeVoltage_V = double(switchState) * parameters.input_voltage_V;
inductorVoltage_V = switchNodeVoltage_V - outputVoltage_V(1:end-1) - ...
    parameters.inductor_resistance_Ohm * inductorCurrent_A(1:end-1);

result.time_s = time_s;
result.interval_start_time_s = intervalStartTime_s;
result.switch_state = switchState;
result.switch_node_voltage_V = switchNodeVoltage_V;
result.inductor_current_A = inductorCurrent_A;
result.output_voltage_V = outputVoltage_V;
result.load_current_A = loadCurrent_A;
result.capacitor_current_A = capacitorCurrent_A;
result.inductor_voltage_V = inductorVoltage_V;
result.time_step_s = timeStep_s;
result.switching_period_s = switchingPeriod_s;
result.period_count = periodCount;
result.on_steps_per_period = onStepsPerPeriod;
result.state_transition = stateTransition;
result.on_input_increment = onInputIncrement;
result.parameters = parameters;
end
