classdef TestGeneratedModelDestinations < matlab.unittest.TestCase
    %TESTGENERATEDMODELDESTINATIONS Rebuild failure preserves saved model bytes.
    % The failure fixture copies a builder into a temporary directory and
    % injects a throwing InitFcn immediately before its existing update call.
    % The repository source, equations, and model topology are not modified.

    properties (TestParameter)
        Builder = {
            'converter-simulink-model/build_average_buck_simulink_model.m', ...
            'battery-simulink-model/build_battery_rc_simulink_model.m', ...
            'battery-2rc-simulink-model/build_battery_2rc_simulink_model.m', ...
            'battery-thermal-simulink-model/build_battery_thermal_simulink_model.m', ...
            ['converter-switching-closed-loop-simulink-model/', ...
                'build_switching_closed_loop_buck_simulink_model.m'], ...
            'bess-unified-control/build_bess_unified_control_model.m'
        }
    end

    properties (Access = private)
        ExamplesDirectory
        TemporaryDirectory
    end

    methods (TestMethodSetup)
        function configureFixture(testCase)
            testCase.assumeTrue(~isempty(ver('simulink')) && ...
                license('test', 'Simulink'), 'Requires MATLAB and Simulink.');
            testCase.ExamplesDirectory = fileparts(fileparts( ...
                fileparts(mfilename('fullpath'))));
            folderFixture = testCase.applyFixture( ...
                matlab.unittest.fixtures.TemporaryFolderFixture);
            testCase.TemporaryDirectory = folderFixture.Folder;
            directoryNames = {'converter-simulink-model', ...
                'battery-simulink-model', 'battery-2rc-simulink-model', ...
                'battery-thermal-simulink-model', 'battery-rc-model', ...
                'battery-2rc-model', 'battery-thermal-model', ...
                'converter-switching-closed-loop-model', ...
                'converter-switching-closed-loop-simulink-model', ...
                'bess-unified-control', fullfile('bess-unified-control', 'src')};
            directories = cellfun(@(name) fullfile( ...
                testCase.ExamplesDirectory, name), directoryNames, ...
                'UniformOutput', false);
            directories{end + 1} = testCase.TemporaryDirectory;
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(directories));
            clear_injected_builder();
            testCase.addTeardown(@clear_injected_builder);
        end
    end

    methods (Test)
        function failedUpdatePreservesExistingDestination(testCase, Builder)
            [builderName, modelName, outputDirectory] = ...
                prepare_builder(testCase, Builder);
            destination = fullfile(outputDirectory, [modelName, '.slx']);
            originalBytes = uint8([0, 255, 17, 42, 83, 76, 88, 13, 10]);
            write_bytes(destination, originalBytes);

            verify_injected_failure(testCase, outputDirectory);

            testCase.verifyEqual(read_bytes(destination), originalBytes);
            testCase.verifyFalse(bdIsLoaded(modelName));
            verify_forced_rollback_order(testCase, outputDirectory, modelName);
            testCase.verifyEqual(read_bytes(destination), originalBytes);
            testCase.verifyFalse(bdIsLoaded(modelName));
            % The uninstrumented builder still replaces the file successfully.
            rebuiltPath = feval(builderName, outputDirectory);
            testCase.verifyEqual(rebuiltPath, destination);
            testCase.verifyFalse(bdIsLoaded(modelName));
            testCase.verifyNotEqual(read_bytes(destination), originalBytes);
            load_system(rebuiltPath);
            set_param(modelName, 'SimulationCommand', 'update');
            close_system(modelName, 0);
        end

        function failedUpdateLeavesNoPartialDestination(testCase, Builder)
            [~, modelName, outputDirectory] = prepare_builder(testCase, Builder);
            destination = fullfile(outputDirectory, [modelName, '.slx']);

            verify_injected_failure(testCase, outputDirectory);

            testCase.verifyFalse(isfile(destination));
            testCase.verifyFalse(bdIsLoaded(modelName));
            verify_forced_rollback_order(testCase, outputDirectory, modelName);
            testCase.verifyFalse(isfile(destination));
            testCase.verifyFalse(bdIsLoaded(modelName));
        end
    end

    methods (Access = private)
        function [builderName, modelName, outputDirectory] = ...
                prepare_builder(testCase, relativePath)
            sourcePath = fullfile(testCase.ExamplesDirectory, relativePath);
            [~, builderName] = fileparts(sourcePath);
            modelName = extractAfter(builderName, 'build_');
            if strcmp(builderName, 'build_bess_unified_control_model')
                modelName = 'bess_unified_control';
            end
            modelName = char(modelName);
            testCase.assumeFalse(bdIsLoaded(modelName), ...
                'A caller-owned model must not be replaced by this fixture.');
            outputDirectory = fullfile(testCase.TemporaryDirectory, 'output');
            mkdir(outputDirectory);
            testCase.addTeardown(@() close_fixture_model(modelName));

            source = fileread(sourcePath);
            source = strrep(source, builderName, 'audit_injected_builder');
            source = strrep(source, 'mfilename(''fullpath'')', ...
                ['''', strrep(sourcePath, '''', ''''''), '''']);
            update = 'set_param(modelName, ''SimulationCommand'', ''update'');';
            testCase.assertEqual(numel(strfind(source, update)), 1, ...
                'Failure injection must target exactly the existing update.');
            callback = ['error(''AuditBuilder:InjectedUpdateFailure'', ', ...
                '''AUDIT_INJECTED_UPDATE_FAILURE'');'];
            injection = ['set_param(modelName, ''InitFcn'', ''', ...
                strrep(callback, '''', ''''''), ''');', newline];
            source = strrep(source, update, [injection, update]);
            injectedPath = fullfile(testCase.TemporaryDirectory, ...
                'audit_injected_builder.m');
            write_bytes(injectedPath, unicode2native(source, 'UTF-8'));
        end
    end
end

function verify_forced_rollback_order(testCase, outputDirectory, modelName)
fixtureDirectory = fileparts(outputDirectory);
injectedPath = fullfile(fixtureDirectory, 'audit_injected_builder.m');
destination = fullfile(outputDirectory, [modelName, '.slx']);
observationPath = fullfile(fixtureDirectory, 'close-order.csv');
source = fileread(injectedPath);
update = 'set_param(modelName, ''SimulationCommand'', ''update'');';
% Record the destination's presence while the model is still closing.
callback = ['writematrix(isfile(''', strrep(destination, '''', ''''''), ...
    '''), ''', strrep(observationPath, '''', ''''''), ''');'];
forcedRollback = [ ...
    'set_param(modelName, ''CloseFcn'', ''', ...
    strrep(callback, '''', ''''''), ''');', newline, ...
    'clear destinationCleanup;', newline, ...
    'assert(~bdIsLoaded(modelName), ''AuditBuilder:RollbackOrder'', ', ...
    '''Rollback must close the generated model before returning.'');', newline, ...
    'error(''AuditBuilder:InjectedUpdateFailure'', ', ...
    '''AUDIT_INJECTED_UPDATE_FAILURE'');'];
testCase.assertEqual(numel(strfind(source, update)), 1);
source = strrep(source, update, forcedRollback);
clear_injected_builder();
write_bytes(injectedPath, unicode2native(source, 'UTF-8'));

verify_injected_failure(testCase, outputDirectory);

testCase.assertTrue(isfile(observationPath));
testCase.verifyEqual(readmatrix(observationPath), 0, ...
    'Rollback must close the generated model before restoring saved bytes.');
end

function verify_injected_failure(testCase, outputDirectory)
observedInjection = false;
try
    audit_injected_builder(outputDirectory);
catch exception
    observedInjection = contains(getReport(exception, 'extended', ...
        'hyperlinks', 'off'), 'AUDIT_INJECTED_UPDATE_FAILURE');
end
testCase.assertTrue(observedInjection, ...
    'The build must reach and fail at the injected update callback.');
end

function close_fixture_model(modelName)
if bdIsLoaded(modelName)
    close_system(modelName, 0);
end
end

function clear_injected_builder()
clear audit_injected_builder;
end

function write_bytes(filePath, bytes)
[fileId, message] = fopen(filePath, 'w');
assert(fileId >= 0, 'Cannot write fixture: %s', message);
cleanup = onCleanup(@() fclose(fileId));
fwrite(fileId, bytes, 'uint8');
end

function bytes = read_bytes(filePath)
[fileId, message] = fopen(filePath, 'r');
assert(fileId >= 0, 'Cannot read fixture: %s', message);
cleanup = onCleanup(@() fclose(fileId));
bytes = fread(fileId, '*uint8')';
end
