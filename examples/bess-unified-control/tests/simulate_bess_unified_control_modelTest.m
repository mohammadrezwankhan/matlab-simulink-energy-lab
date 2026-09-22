classdef simulate_bess_unified_control_modelTest < matlab.unittest.TestCase
    %SIMULATE_BESS_UNIFIED_CONTROL_MODELTEST Caller-state safety checks.

    properties
        ExampleDirectory
        Parameters
        Scenario
    end

    methods (TestMethodSetup)
        function configurePaths(testCase)
            testCase.ExampleDirectory = fileparts(fileparts( ...
                mfilename('fullpath')));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                {testCase.ExampleDirectory, ...
                fullfile(testCase.ExampleDirectory, 'src')}));
            testCase.Parameters = bess_unified_control_parameters();
            scenarios = bess_validation_scenarios(testCase.Parameters);
            testCase.Scenario = short_scenario(scenarios(1), 4);
        end
    end

    methods (Test)
        function cleanPreloadedModelStateIsPreserved(testCase)
            verify_preloaded_model_state(testCase, false);
        end

        function dirtyPreloadedModelStateIsPreserved(testCase)
            verify_preloaded_model_state(testCase, true);
        end

        function differentLoadedModelIsRejectedBeforeMutation(testCase)
            [requestedPath, requestedDirectory] = ...
                build_test_model(testCase);
            [collisionPath, collisionDirectory] = ...
                build_test_model(testCase);
            [~, modelName] = fileparts(requestedPath);
            load_system(collisionPath);
            modelHandle = get_param(modelName, 'Handle');
            testCase.addTeardown(@() cleanup_test_model( ...
                modelName, collisionPath, collisionDirectory));
            testCase.addTeardown(@() remove_test_directory( ...
                requestedDirectory));

            modelWorkspace = get_param(modelName, 'ModelWorkspace');
            assignin(modelWorkspace, 'callerSentinel', [17, 29]);
            set_param(modelName, 'Description', ...
                'Unsaved caller-owned collision model');
            expectedDirty = get_param(modelName, 'Dirty');
            expectedDescription = get_param(modelName, 'Description');
            expectedWorkspaceVariables = ...
                sort(evalin(modelWorkspace, 'who'));
            expectedSentinel = evalin(modelWorkspace, 'callerSentinel');
            expectedStopTime = get_param(modelName, 'StopTime');
            expectedInitFcn = get_param(modelName, 'InitFcn');
            expectedFileGenerationConfig = ...
                Simulink.fileGenControl('getConfig');
            expectedPath = path;
            requestedBytes = read_binary_file(requestedPath);
            collisionBytes = read_binary_file(collisionPath);

            testCase.verifyError(@() simulate_bess_unified_control_model( ...
                testCase.Scenario, testCase.Parameters, requestedPath), ...
                'BessUnifiedControl:ModelPathCollision');

            testCase.verifyTrue(bdIsLoaded(modelName));
            testCase.verifyEqual(get_param(modelName, 'Handle'), ...
                modelHandle);
            testCase.verifyEqual(get_param(modelName, 'FileName'), ...
                collisionPath);
            testCase.verifyEqual(get_param(modelName, 'Dirty'), ...
                expectedDirty);
            testCase.verifyEqual(get_param(modelName, 'Description'), ...
                expectedDescription);
            testCase.verifyEqual(get_param(modelName, 'InitFcn'), ...
                expectedInitFcn);
            testCase.verifyEqual(get_param(modelName, 'StopTime'), ...
                expectedStopTime);
            testCase.verifyEqual(sort(evalin(modelWorkspace, 'who')), ...
                expectedWorkspaceVariables);
            testCase.verifyEqual(evalin(modelWorkspace, ...
                'callerSentinel'), expectedSentinel);
            testCase.verifyEqual(read_binary_file(requestedPath), ...
                requestedBytes);
            testCase.verifyEqual(read_binary_file(collisionPath), ...
                collisionBytes);
            testCase.verifyTrue(strcmp(path, expectedPath), ...
                'MATLAB path changed after wrapper execution.');
            testCase.verifyEqual( ...
                Simulink.fileGenControl('getConfig'), ...
                expectedFileGenerationConfig);
        end

        function preloadedStateIsPreservedWhenSimulationFails(testCase)
            [modelPath, modelDirectory] = build_test_model(testCase);
            [~, modelName] = fileparts(modelPath);
            load_system(modelPath);
            modelWorkspace = get_param(modelName, 'ModelWorkspace');
            assignin(modelWorkspace, 'callerSentinel', [31, 47]);
            save_system(modelName);
            set_param(modelName, 'Description', ...
                'Unsaved caller-owned failure fixture');
            set_forced_simulation_failure(modelName);
            testCase.addTeardown(@() cleanup_test_model( ...
                modelName, modelPath, modelDirectory));
            expectedState = capture_caller_state( ...
                modelName, modelPath, modelDirectory);

            scenario = short_scenario(testCase.Scenario, 3);
            scenario.inputs.p_ref_pu(:) = 0.4;
            failure = capture_wrapper_failure( ...
                scenario, testCase.Parameters, modelPath);
            testCase.verifyFalse(isempty(failure));
            testCase.verifyTrue(exception_has_identifier(failure, ...
                'BessUnifiedControlModelWrapper:ForcedSimulationFailure'));

            verify_caller_state(testCase, expectedState);
        end

        function wrapperClosesModelItLoaded(testCase)
            [modelPath, modelDirectory] = build_test_model(testCase);
            [~, modelName] = fileparts(modelPath);
            testCase.addTeardown(@() cleanup_test_model( ...
                modelName, modelPath, modelDirectory));
            testCase.assertFalse(bdIsLoaded(modelName));
            expectedPath = path;
            expectedFileGenerationConfig = ...
                Simulink.fileGenControl('getConfig');
            expectedFileBytes = read_binary_file(modelPath);

            scenario = short_scenario(testCase.Scenario, 3);
            result = simulate_bess_unified_control_model( ...
                scenario, testCase.Parameters, modelPath);

            testCase.verifyEqual(numel(result.time_s), ...
                numel(scenario.time_s));
            testCase.verifyFalse(bdIsLoaded(modelName));
            testCase.verifyTrue(strcmp(path, expectedPath), ...
                'MATLAB path changed after wrapper execution.');
            testCase.verifyEqual( ...
                Simulink.fileGenControl('getConfig'), ...
                expectedFileGenerationConfig);
            testCase.verifyEqual(read_binary_file(modelPath), ...
                expectedFileBytes);
        end

        function wrapperClosesModelItLoadedWhenSimulationFails(testCase)
            [modelPath, modelDirectory] = build_test_model(testCase);
            [~, modelName] = fileparts(modelPath);
            load_system(modelPath);
            set_forced_simulation_failure(modelName);
            save_system(modelName);
            close_system(modelName, 0);
            testCase.addTeardown(@() cleanup_test_model( ...
                modelName, modelPath, modelDirectory));
            testCase.assertFalse(bdIsLoaded(modelName));
            expectedPath = path;
            expectedFileGenerationConfig = ...
                Simulink.fileGenControl('getConfig');
            expectedFileBytes = read_binary_file(modelPath);

            failure = capture_wrapper_failure( ...
                testCase.Scenario, testCase.Parameters, modelPath);
            testCase.verifyFalse(isempty(failure));
            testCase.verifyTrue(exception_has_identifier(failure, ...
                'BessUnifiedControlModelWrapper:ForcedSimulationFailure'));

            testCase.verifyFalse(bdIsLoaded(modelName));
            testCase.verifyTrue(strcmp(path, expectedPath), ...
                'MATLAB path changed after wrapper execution.');
            testCase.verifyEqual( ...
                Simulink.fileGenControl('getConfig'), ...
                expectedFileGenerationConfig);
            testCase.verifyEqual(read_binary_file(modelPath), ...
                expectedFileBytes);
        end
    end
end

function verify_preloaded_model_state(testCase, makeDirty)
[modelPath, modelDirectory] = build_test_model(testCase);
[~, modelName] = fileparts(modelPath);
load_system(modelPath);
modelWorkspace = get_param(modelName, 'ModelWorkspace');
assignin(modelWorkspace, 'callerSentinel', [7, 13]);
save_system(modelName);
if makeDirty
    set_param(modelName, 'Description', ...
        'Unsaved caller-owned model description');
end
testCase.addTeardown(@() cleanup_test_model( ...
    modelName, modelPath, modelDirectory));
expectedState = capture_caller_state(modelName, modelPath, modelDirectory);

scenario = short_scenario(testCase.Scenario, 3);
scenario.inputs.p_ref_pu(:) = 0.4;
result = simulate_bess_unified_control_model( ...
    scenario, testCase.Parameters, modelPath);

testCase.verifyEqual(numel(result.time_s), numel(scenario.time_s));
verify_caller_state(testCase, expectedState);
end

function state = capture_caller_state(modelName, modelPath, modelDirectory)
modelWorkspace = get_param(modelName, 'ModelWorkspace');
profile = evalin(modelWorkspace, 'bess_profile');
state.modelName = modelName;
state.modelPath = modelPath;
state.modelDirectory = modelDirectory;
state.modelHandle = get_param(modelName, 'Handle');
state.dirty = get_param(modelName, 'Dirty');
state.description = get_param(modelName, 'Description');
state.initFcn = get_param(modelName, 'InitFcn');
state.stopTime = get_param(modelName, 'StopTime');
state.workspaceVariables = sort(evalin(modelWorkspace, 'who'));
state.sentinel = evalin(modelWorkspace, 'callerSentinel');
state.profileData = profile.Data;
state.profileTime = profile.Time;
state.fileBytes = read_binary_file(modelPath);
state.path = path;
state.fileGenerationConfig = Simulink.fileGenControl('getConfig');
end

function verify_caller_state(testCase, state)
modelName = state.modelName;
modelWorkspace = get_param(modelName, 'ModelWorkspace');
profile = evalin(modelWorkspace, 'bess_profile');
testCase.verifyTrue(bdIsLoaded(modelName));
testCase.verifyEqual(get_param(modelName, 'Handle'), state.modelHandle);
testCase.verifyEqual(get_param(modelName, 'FileName'), state.modelPath);
testCase.verifyEqual(get_param(modelName, 'Dirty'), state.dirty);
testCase.verifyEqual(get_param(modelName, 'Description'), ...
    state.description);
testCase.verifyEqual(get_param(modelName, 'InitFcn'), state.initFcn);
testCase.verifyEqual(get_param(modelName, 'StopTime'), state.stopTime);
testCase.verifyEqual(sort(evalin(modelWorkspace, 'who')), ...
    state.workspaceVariables);
testCase.verifyEqual(evalin(modelWorkspace, 'callerSentinel'), ...
    state.sentinel);
testCase.verifyEqual(profile.Data, state.profileData);
testCase.verifyEqual(profile.Time, state.profileTime);
testCase.verifyEqual(read_binary_file(state.modelPath), state.fileBytes);
testCase.verifyTrue(strcmp(path, state.path), ...
    sprintf('Added: %s; removed: %s', ...
    strjoin(setdiff(strsplit(path, pathsep), strsplit(state.path, pathsep)), ', '), ...
    strjoin(setdiff(strsplit(state.path, pathsep), strsplit(path, pathsep)), ', ')));
testCase.verifyEqual(Simulink.fileGenControl('getConfig'), ...
    state.fileGenerationConfig);
end

function [modelPath, modelDirectory] = build_test_model(testCase)
modelDirectory = tempname;
modelPath = build_bess_unified_control_model( ...
    modelDirectory, testCase.Scenario, testCase.Parameters);
[~, modelName] = fileparts(modelPath);
testCase.addTeardown(@() cleanup_test_model( ...
    modelName, modelPath, modelDirectory));
end

function scenario = short_scenario(sourceScenario, sampleCount)
scenario = sourceScenario;
scenario.time_s = sourceScenario.time_s(1:sampleCount);
inputNames = fieldnames(sourceScenario.inputs);
for inputIndex = 1:numel(inputNames)
    inputName = inputNames{inputIndex};
    inputValues = sourceScenario.inputs.(inputName);
    scenario.inputs.(inputName) = inputValues(1:sampleCount);
end
end

function set_forced_simulation_failure(modelName)
set_param(modelName, 'InitFcn', ...
    ['error(''BessUnifiedControlModelWrapper:ForcedSimulationFailure'', ', ...
    '''Deliberate test simulation failure.'')']);
end

function failure = capture_wrapper_failure(scenario, parameters, modelPath)
try
    simulate_bess_unified_control_model(scenario, parameters, modelPath);
    failure = [];
catch caught
    failure = caught;
end
end

function containsIdentifier = exception_has_identifier(exception, identifier)
containsIdentifier = strcmp(exception.identifier, identifier);
causes = exception.cause;
for causeIndex = 1:numel(causes)
    containsIdentifier = containsIdentifier || ...
        exception_has_identifier(causes{causeIndex}, identifier);
end
end

function cleanup_test_model(modelName, modelPath, modelDirectory)
if bdIsLoaded(modelName) && model_matches_path(modelName, modelPath)
    close_system(modelName, 0);
end
remove_test_directory(modelDirectory);
end

function matches = model_matches_path(modelName, modelPath)
loadedPath = get_param(modelName, 'FileName');
if isempty(loadedPath)
    matches = false;
    return;
end
if ~isfile(loadedPath) || ~isfile(modelPath)
    matches = false;
    return;
end
loadedPermissions = filePermissions(loadedPath);
requestedPermissions = filePermissions(modelPath);
if ispc
    matches = strcmpi(loadedPermissions.AbsolutePath, ...
        requestedPermissions.AbsolutePath);
else
    matches = strcmp(loadedPermissions.AbsolutePath, ...
        requestedPermissions.AbsolutePath);
end
end

function remove_test_directory(directory)
if isfolder(directory)
    rmdir(directory, 's');
end
end

function bytes = read_binary_file(filePath)
fileIdentifier = fopen(filePath, 'rb');
assert(fileIdentifier > 0, 'Could not read model file.');
fileCleanup = onCleanup(@() fclose(fileIdentifier));
bytes = fread(fileIdentifier, inf, '*uint8');
end
