classdef TestBessPowerAvailability < matlab.unittest.TestCase
    %TESTBESSPOWERAVAILABILITY Hard availability bounds during limit changes.

    properties (TestParameter)
        PowerSign = {-1, 1}
        DropLimit = {0, 0.2}
    end

    methods (TestMethodSetup)
        function configurePaths(testCase)
            exampleDirectory = fileparts(fileparts(mfilename('fullpath')));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                {exampleDirectory, fullfile(exampleDirectory, 'src')}));
        end
    end

    methods (Test)
        function availabilityDropOverridesSlew(testCase, PowerSign, DropLimit)
            [inputVector, measurement, state, parameters] = ...
                operating_point(PowerSign);
            inputVector(15) = DropLimit;

            [command, nextState] = bess_controller_step( ...
                inputVector, measurement, state, parameters, ...
                parameters.sample_time_s);

            testCase.verifyEqual(command.p_command_pu, ...
                PowerSign * DropLimit, 'AbsTol', 1e-12);
            testCase.verifyTrue(command.saturated);
            testCase.verifyEqual(nextState.previous_p_command_pu, ...
                command.p_command_pu, 'AbsTol', 1e-12);
        end

        function priorCommandIsLimitedWithFeasibleReference(testCase, PowerSign)
            [inputVector, measurement, state, parameters] = ...
                operating_point(PowerSign);
            inputVector(2) = PowerSign * 0.1;
            inputVector(15) = 0.2;

            command = bess_controller_step(inputVector, measurement, ...
                state, parameters, parameters.sample_time_s);

            testCase.verifyEqual(command.p_command_pu, ...
                PowerSign * 0.2, 'AbsTol', 1e-12);
            testCase.verifyTrue(command.saturated);
        end

        function restoredAvailabilityResumesSlew(testCase, PowerSign)
            [inputVector, measurement, state, parameters] = ...
                operating_point(PowerSign);
            inputVector(15) = 0.2;
            [~, state] = bess_controller_step(inputVector, measurement, ...
                state, parameters, parameters.sample_time_s);
            inputVector(15) = 1;

            command = bess_controller_step(inputVector, measurement, ...
                state, parameters, parameters.sample_time_s);

            maximumStep = parameters.power_command_slew_pu_per_s * ...
                parameters.sample_time_s;
            testCase.verifyEqual(command.p_command_pu, ...
                PowerSign * (0.2 + maximumStep), 'AbsTol', 1e-12);
        end
    end
end

function [inputVector, measurement, state, parameters] = operating_point(signP)
parameters = bess_unified_control_parameters();
scenarios = bess_validation_scenarios(parameters);
inputVector = bess_scenario_input_vector(scenarios(1), 1);
inputVector(2) = signP * 0.8;
inputVector(3) = 0;
plantState = bess_initialize_plant_state(inputVector, parameters);
measurement = bess_measure_plant(plantState);
state = bess_initialize_controller_state(inputVector, measurement);
state.previous_p_command_pu = signP * 0.8;
end
