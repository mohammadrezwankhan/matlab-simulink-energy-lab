classdef TestSimulinkRunnerCleanup < matlab.unittest.TestCase
    % Errors after loading a demo model must release only owned resources.
    properties (TestParameter)
        FailureStage = {'beforeHandleCapture', 'afterHandleCapture'}
        Runner = {
            'converter-simulink-model/run_average_buck_simulink_model.m', ...
            'battery-simulink-model/run_battery_rc_simulink_model.m', ...
            'battery-2rc-simulink-model/run_battery_2rc_simulink_model.m', ...
            'battery-thermal-simulink-model/run_battery_thermal_simulink_model.m', ...
            ['converter-switching-closed-loop-simulink-model/', ...
                'run_switching_closed_loop_buck_simulink_model.m']
        }
    end

    methods (Test)
        function failedDemoReleasesItsModelAndFigure(testCase, Runner, FailureStage)
            testCase.assumeTrue(~isempty(ver('simulink')) && ...
                license('test', 'Simulink'), 'Requires MATLAB and Simulink.');
            examplesDirectory = fileparts(fileparts(fileparts(mfilename('fullpath'))));
            sourcePath = fullfile(examplesDirectory, Runner);
            [~, runnerName] = fileparts(sourcePath);
            modelName = extractAfter(runnerName, 'run_');
            testCase.assumeFalse(bdIsLoaded(modelName));
            folder = testCase.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture);
            outputDirectory = fullfile(folder.Folder, 'output');
            mkdir(outputDirectory);
            callerFigure = figure('Visible', 'off');
            originalFigures = findall(groot, 'Type', 'figure');
            originalPath = path;
            testCase.addTeardown(@() restore_fixture(modelName, originalFigures, callerFigure));
            source = fileread(sourcePath);
            source = strrep(source, 'mfilename(''fullpath'')', quote_text(sourcePath));
            builderName = strrep(runnerName, 'run_', 'build_');
            source = strrep(source, [builderName, '()'], ...
                [builderName, '(', quote_text(outputDirectory), ')']);
            source = strrep(source, [builderName, '([], parameters)'], ...
                [builderName, '(', quote_text(outputDirectory), ', parameters)']);
            injection = ['figure(''Visible'', ''off'');', newline, ...
                'error(''AuditRunner:InjectedFailure'', ''Injected demo failure.'');'];
            marker = 'simulationOutput = sim(modelName);';
            if strcmp(FailureStage, 'beforeHandleCapture')
                marker = 'load_system(modelPath);';
                injection = [marker, newline, injection];
            end
            testCase.assertEqual(numel(strfind(source, marker)), 1);
            source = strrep(source, marker, injection);
            fixturePath = fullfile(folder.Folder, 'audit_injected_runner.m');
            identifier = fopen(fixturePath, 'w');
            testCase.assertGreaterThanOrEqual(identifier, 0);
            fwrite(identifier, source, 'char');
            fclose(identifier);

            testCase.verifyError(@() run_fixture(fixturePath), 'AuditRunner:InjectedFailure');

            testCase.verifyFalse(bdIsLoaded(modelName));
            testCase.verifyTrue(isgraphics(callerFigure));
            testCase.verifyEqual(findall(groot, 'Type', 'figure'), originalFigures);
            testCase.verifyEqual(path, originalPath);
        end
    end
end

function text = quote_text(value)
text = ['''', strrep(value, '''', ''''''), ''''];
end

function run_fixture(fixturePath)
run(fixturePath);
end

function restore_fixture(modelName, originalFigures, callerFigure)
if bdIsLoaded(modelName)
    close_system(modelName, 0);
end
figures = findall(groot, 'Type', 'figure');
delete(figures(~ismember(figures, originalFigures)));
if isgraphics(callerFigure)
    delete(callerFigure);
end
end
