classdef TestBessSampleTiming < matlab.unittest.TestCase
    %TESTBESSSAMPLETIMING Independent causal sample-time checks.

    properties (TestParameter)
        SampleCount = {1, 2, 11}
        FaultCode = {1, 2}
    end

    methods (TestMethodSetup)
        function configurePaths(testCase)
            exampleDirectory = fileparts(fileparts(mfilename('fullpath')));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                {exampleDirectory, fullfile(exampleDirectory, 'src')}));
            clear_runtime();
            testCase.addTeardown(@clear_runtime);
        end
    end

    methods (Test)
        function initialSamplePreservesPlantState(testCase)
            parameters = bess_unified_control_parameters();
            scenario = short_scenario(parameters, 1, 1);

            result = simulate_bess_unified_control(scenario, parameters);

            testCase.verifyEqual(result.time_s, 0, 'AbsTol', 1e-12);
            testCase.verifyEqual(result.p_pu, 0, 'AbsTol', 1e-12);
            testCase.verifyEqual(result.q_pu, 0, 'AbsTol', 1e-12);
            testCase.verifyEqual(result.current_pu, 0, 'AbsTol', 1e-12);
            testCase.verifyEqual(result.phase_rad, 0, 'AbsTol', 1e-12);
            testCase.verifyEqual(result.voltage_pu, 1, 'AbsTol', 1e-12);
            testCase.verifyEqual(result.frequency_Hz, 50, 'AbsTol', 1e-12);
            testCase.verifyEqual(result.p_command_pu, 0, 'AbsTol', 1e-12);
        end

        function islandPhaseMatchesElapsedDuration(testCase, SampleCount)
            parameters = bess_unified_control_parameters();
            scenario = short_scenario(parameters, 4, SampleCount);
            scenario.inputs.p_ref_pu(:) = 0;
            scenario.inputs.q_ref_pu(:) = 0;
            scenario.inputs.load_p_pu(:) = 0;
            scenario.inputs.load_q_pu(:) = 0;

            result = simulate_bess_unified_control(scenario, parameters);

            testCase.verifyEqual(result.phase_rad, ...
                2 * pi * 50 * scenario.time_s, 'AbsTol', 1e-10);
            testCase.verifyEqual(result.p_pu, ...
                zeros(SampleCount, 1), 'AbsTol', 1e-12);
        end

        function inputStepCannotAdvancePlantAtSameTimestamp(testCase)
            parameters = bess_unified_control_parameters();
            scenario = short_scenario(parameters, 1, 5);
            scenario.inputs.p_ref_pu(:) = [0; 0; 0.8; 0.8; 0.8];

            result = simulate_bess_unified_control(scenario, parameters);

            testCase.verifyEqual(result.p_pu(1:3), zeros(3, 1), ...
                'AbsTol', 1e-12);
            testCase.verifyGreaterThan(result.p_pu(4), 0);
        end

        function gridLossOpensBreakerAtBoundary(testCase)
            parameters = bess_unified_control_parameters();
            scenario = short_scenario(parameters, 1, 5);
            scenario.inputs.grid_present(:) = [1; 1; 0; 0; 0];

            result = simulate_bess_unified_control(scenario, parameters);

            testCase.verifyEqual(result.breaker_closed, ...
                logical([1; 1; 0; 0; 0]));
            testCase.verifyEqual(result.phase_rad(1:3), ...
                scenario.inputs.grid_phase_rad(1:3), 'AbsTol', 1e-12);
        end

        function connectedPhaseUsesCurrentBoundary(testCase)
            parameters = bess_unified_control_parameters();
            scenario = short_scenario(parameters, 1, 5);
            scenario.inputs.grid_frequency_Hz(:) = [50; 50; 49.5; 49.5; 49.5];
            scenario.inputs.grid_phase_rad = [0; cumsum( ...
                2 * pi * scenario.inputs.grid_frequency_Hz(1:end-1) * ...
                parameters.sample_time_s)];

            result = simulate_bess_unified_control(scenario, parameters);

            testCase.verifyTrue(all(result.breaker_closed));
            testCase.verifyEqual(result.phase_rad, ...
                scenario.inputs.grid_phase_rad, 'AbsTol', 1e-12);
            testCase.verifyEqual(result.phase_error_rad, zeros(5, 1), ...
                'AbsTol', 1e-12);
        end

        function formingTimerGetsNoInitialTimeCredit(testCase)
            parameters = bess_unified_control_parameters();
            scenario = short_scenario(parameters, 4, 12);
            states = bess_state_codes();

            result = simulate_bess_unified_control(scenario, parameters);

            testCase.verifyEqual(result.state_code(1:10), ...
                repmat(states.GRID_FORMING, 10, 1));
            testCase.verifyEqual(result.state_code(11:12), ...
                repmat(states.ISLANDED_SUPPORT, 2, 1));
        end

        function commandSlewUsesOnlyElapsedTime(testCase)
            parameters = bess_unified_control_parameters();
            scenario = short_scenario(parameters, 1, 11);
            scenario.inputs.p_ref_pu(:) = 0.8;

            result = simulate_bess_unified_control(scenario, parameters);

            testCase.verifyLessThanOrEqual(abs(result.p_command_pu), ...
                parameters.power_command_slew_pu_per_s * ...
                scenario.time_s + 1e-12);
            testCase.verifyGreaterThan(result.p_command_pu(end), 0);
        end

        function measurementFaultOpensAtBoundary(testCase, FaultCode)
            parameters = bess_unified_control_parameters();
            scenario = short_scenario(parameters, 1, 5);
            scenario.inputs.fault_code(:) = [0; 0; FaultCode; FaultCode; FaultCode];

            result = simulate_bess_unified_control(scenario, parameters);

            testCase.verifyEqual(result.breaker_closed, ...
                logical([1; 1; 0; 0; 0]));
            testCase.verifyEqual(result.faulted, ...
                logical([0; 0; 1; 1; 1]));
        end

        function repeatedRuntimeTimestampDoesNotAdvance(testCase)
            parameters = bess_unified_control_parameters();
            scenario = short_scenario(parameters, 4, 3);
            firstInput = bess_scenario_input_vector(scenario, 1);
            nextInput = bess_scenario_input_vector(scenario, 2);

            bess_simulink_runtime(firstInput);
            firstOutput = bess_simulink_runtime(nextInput);
            repeatedOutput = bess_simulink_runtime(nextInput);

            testCase.verifyEqual(repeatedOutput, firstOutput, 'AbsTol', 1e-12);
        end

        function newlyValidSyncGetsNoRetroactiveCredit(testCase)
            parameters = bess_unified_control_parameters();
            scenario = short_scenario(parameters, 1, 3);
            inputVector = bess_scenario_input_vector(scenario, 1);
            plantState = bess_initialize_plant_state(inputVector, parameters);
            plantState.phase_rad = pi;
            plantState.breaker_closed = false;
            measurement = bess_measure_plant(plantState);
            state = bess_initialize_controller_state(inputVector, measurement);
            states = bess_state_codes();
            state.mode = states.SYNCHRONIZING;

            [~, state] = bess_controller_step( ...
                inputVector, measurement, state, parameters, 0);
            inputVector(1) = parameters.sample_time_s;
            inputVector(11) = pi;
            [command, firstValidState] = bess_controller_step( ...
                inputVector, measurement, state, parameters, ...
                parameters.sample_time_s);
            inputVector(1) = 2 * parameters.sample_time_s;
            [~, nextState] = bess_controller_step( ...
                inputVector, measurement, firstValidState, parameters, ...
                parameters.sample_time_s);

            testCase.verifyTrue(command.sync_ready);
            testCase.verifyEqual(firstValidState.sync_timer_s, 0, ...
                'AbsTol', 1e-12);
            testCase.verifyEqual(nextState.sync_timer_s, ...
                parameters.sample_time_s, 'AbsTol', 1e-12);
        end

        function irregularReferenceGridIsRejected(testCase)
            parameters = bess_unified_control_parameters();
            scenario = short_scenario(parameters, 1, 3);
            scenario.time_s(2) = 0.5 * parameters.sample_time_s;

            testCase.verifyError(@() simulate_bess_unified_control( ...
                scenario, parameters), 'BessUnifiedControl:TimeGrid');
        end

        function skippedRuntimeSampleIsRejected(testCase)
            parameters = bess_unified_control_parameters();
            scenario = short_scenario(parameters, 1, 3);
            bess_simulink_runtime(bess_scenario_input_vector(scenario, 1));
            skippedInput = bess_scenario_input_vector(scenario, 3);

            testCase.verifyError(@() bess_simulink_runtime(skippedInput), ...
                'BessUnifiedControl:TimeGrid');
        end

        function clockRoundoffDoesNotChangeIntegration(testCase)
            parameters = bess_unified_control_parameters();
            scenario = short_scenario(parameters, 4, 2);
            firstInput = bess_scenario_input_vector(scenario, 1);
            nextInput = bess_scenario_input_vector(scenario, 2);
            nextInput(1) = nextInput(1) + eps(nextInput(1));
            reference = simulate_bess_unified_control(scenario, parameters);

            bess_simulink_runtime(firstInput);
            output = bess_simulink_runtime(nextInput);

            testCase.verifyEqual(output(5), reference.phase_rad(2), ...
                'AbsTol', 1e-14);
        end
    end
end

function scenario = short_scenario(parameters, scenarioIndex, sampleCount)
scenarios = bess_validation_scenarios(parameters);
scenario = scenarios(scenarioIndex);
scenario.time_s = scenario.time_s(1:sampleCount);
inputNames = fieldnames(scenario.inputs);
for fieldIndex = 1:numel(inputNames)
    fieldName = inputNames{fieldIndex};
    scenario.inputs.(fieldName) = scenario.inputs.(fieldName)(1:sampleCount);
end
end

function clear_runtime()
clear bess_simulink_runtime;
end
