function maps = switching_closed_loop_buck_interval_maps( ...
    parameters, timeStep_s)
%SWITCHING_CLOSED_LOOP_BUCK_INTERVAL_MAPS Return exact affine plant maps.

if nargin < 2 || ~isnumeric(timeStep_s) || ~isscalar(timeStep_s) || ...
        ~isreal(timeStep_s) || ~isfinite(timeStep_s) || timeStep_s <= 0
    error('SwitchingClosedLoopBuck:TimeStep', ...
        'The interval time step must be a positive finite real scalar.');
end

loadValues = [parameters.initial_load_resistance_Ohm, ...
    parameters.final_load_resistance_Ohm];
maps = repmat(struct('transition', zeros(2), ...
    'increment', zeros(2, 1), 'system_matrix', zeros(2)), 2, 2);
for loadIndex = 1:2
    for switchIndex = 1:2
        isOn = switchIndex == 2;
        systemMatrix = [
            -(parameters.inductor_resistance_Ohm + ...
            double(isOn)*parameters.switch_on_resistance_Ohm)/ ...
            parameters.inductance_H, -1/parameters.inductance_H; ...
            1/parameters.capacitance_F, ...
            -1/(loadValues(loadIndex)*parameters.capacitance_F)
        ];
        if isOn
            inputVector = [parameters.input_voltage_V/ ...
                parameters.inductance_H; 0];
        else
            inputVector = [-parameters.diode_forward_voltage_V/ ...
                parameters.inductance_H; 0];
        end
        transition = expm(systemMatrix*timeStep_s);
        increment = systemMatrix\((transition - eye(2))*inputVector);
        maps(loadIndex, switchIndex).transition = transition;
        maps(loadIndex, switchIndex).increment = increment;
        maps(loadIndex, switchIndex).system_matrix = systemMatrix;
    end
end
end
