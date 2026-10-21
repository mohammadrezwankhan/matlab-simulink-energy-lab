classdef bess_parameter_propagationTest < matlab.unittest.TestCase
    %BESS_PARAMETER_PROPAGATIONTEST Public builder/wrapper parameter contract.

    properties (TestParameter)
        Overrides = struct( ...
            'powerLimit', struct('active_power_limit_pu', 0.2), ...
            'plantDynamics', struct('filter_current_time_constant_s', 0.15), ...
            'samplePeriod', struct('sample_time_s', 0.01))
    end

    methods (TestMethodSetup)
        function configurePaths(testCase)
            exampleDirectory = fileparts(fileparts(mfilename('fullpath')));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                {exampleDirectory, fullfile(exampleDirectory, 'src')}));
            testCase.assertFalse(bdIsLoaded('bess_unified_control'), ...
                'Close the caller model before running these isolated tests.');
            testCase.addTeardown(@clear_runtime);
        end
    end

    methods (Test)
        function reusedModelHonorsParameters(testCase, Overrides)
            defaults = bess_unified_control_parameters();
            parameters = bess_unified_control_parameters(Overrides);
            modelPath = build_fixture(testCase, defaults);
            scenario = constant_scenario(parameters);

            expected = simulate_bess_unified_control(scenario, parameters);
            actual = simulate_bess_unified_control_model( ...
                scenario, parameters, modelPath);

            verify_result(testCase, actual, expected);
        end

        function generatedModelStoresParametersWithoutWrapper(testCase)
            parameters = bess_unified_control_parameters( ...
                struct('active_power_limit_pu', 0.2));
            modelPath = build_fixture(testCase, parameters);
            load_system(modelPath);
            clear_runtime();
            in = Simulink.SimulationInput('bess_unified_control');

            out = sim(in);
            data = squeeze(out.bess_output_vector.Data(:, 1, :)).';

            testCase.verifyEqual(max(data(:, 14)), 0.2, 'AbsTol', 1e-12);
        end

        function repeatedRunsDoNotLeakParameters(testCase)
            defaults = bess_unified_control_parameters();
            limited = bess_unified_control_parameters( ...
                struct('active_power_limit_pu', 0.2));
            modelPath = build_fixture(testCase, defaults);
            scenario = constant_scenario(defaults);

            first = simulate_bess_unified_control_model( ...
                scenario, defaults, modelPath);
            middle = simulate_bess_unified_control_model( ...
                scenario, limited, modelPath);
            last = simulate_bess_unified_control_model( ...
                scenario, defaults, modelPath);

            testCase.verifyEqual(max(first.p_command_pu), 0.8, 'AbsTol', 1e-12);
            testCase.verifyEqual(max(middle.p_command_pu), 0.2, 'AbsTol', 1e-12);
            verify_result(testCase, last, first);
        end

        function timeZeroAcceptsNewParametersBeforeCachedOutput(testCase)
            defaults = bess_unified_control_parameters();
            changed = bess_unified_control_parameters( ...
                struct('minimum_dc_voltage_pu', 1.1));
            scenario = constant_scenario(defaults);
            input = bess_scenario_input_vector(scenario, 1);
            clear_runtime();

            initial = bess_simulink_runtime(input, defaults);
            actual = bess_simulink_runtime(input, changed);
            clear_runtime();
            expected = bess_simulink_runtime(input, changed);

            testCase.verifyEqual(actual, expected, 'AbsTol', 1e-12);
            testCase.verifyNotEqual(actual, initial);
        end

        function oldModelWithoutParameterContractIsRejected(testCase)
            parameters = bess_unified_control_parameters();
            modelPath = build_fixture(testCase, parameters);
            load_system(modelPath);
            workspace = get_param('bess_unified_control', 'ModelWorkspace');
            evalin(workspace, 'clear bess_parameters');

            testCase.verifyError(@() simulate_bess_unified_control_model( ...
                constant_scenario(parameters), parameters, modelPath), ...
                'BessUnifiedControl:ModelParameterContract');

            testCase.verifyTrue(bdIsLoaded('bess_unified_control'));
            testCase.verifyFalse(hasVariable(workspace, 'bess_parameters'));
        end

        function midRunParameterChangeIsRejected(testCase)
            defaults = bess_unified_control_parameters();
            changed = bess_unified_control_parameters( ...
                struct('active_power_limit_pu', 0.2));
            scenario = constant_scenario(defaults);
            clear_runtime();
            bess_simulink_runtime(bess_scenario_input_vector(scenario, 1), defaults);

            testCase.verifyError(@() bess_simulink_runtime( ...
                bess_scenario_input_vector(scenario, 2), changed), ...
                'BessUnifiedControl:RuntimeParametersChanged');
        end
    end
end

function modelPath = build_fixture(testCase, parameters)
fixture = testCase.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture);
testCase.addTeardown(@close_fixture);
modelPath = build_bess_unified_control_model( ...
    fixture.Folder, constant_scenario(parameters), parameters);
end

function scenario = constant_scenario(parameters)
scenarios = bess_validation_scenarios(parameters);
scenario = scenarios(1);
count = round(0.5 / parameters.sample_time_s) + 1;
scenario.time_s = scenario.time_s(1:count);
names = fieldnames(scenario.inputs);
for index = 1:numel(names)
    scenario.inputs.(names{index}) = scenario.inputs.(names{index})(1:count);
end
scenario.inputs.p_ref_pu(:) = 0.8;
end

function verify_result(testCase, actual, expected)
names = fieldnames(expected);
for index = 1:numel(names)
    name = names{index};
    if isnumeric(expected.(name))
        testCase.verifyEqual(actual.(name), expected.(name), ...
            'AbsTol', 1e-10, sprintf('Mismatch in %s', name));
    else
        testCase.verifyEqual(actual.(name), expected.(name));
    end
end
end

function clear_runtime()
clear bess_simulink_runtime;
end

function close_fixture()
if bdIsLoaded('bess_unified_control')
    close_system('bess_unified_control', 0);
end
end
